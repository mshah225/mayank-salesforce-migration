/**
 * Various helper functions for interacting with user profiles.
 *
 * There are two primary utilities from this class
 * 1. The userHasProfile functions
 *    These helper functions return true or false to indicate if a user has a specific profile or not.
 * 2. getProfileId
 *    This function returns the Id for a specific profile name.
 *
 * Limitations:
 *  1. When querying a profile id by name, this tries using the Profile_Ids__c custom setting cache. If that fails then it
 *     uses 2 SOQL queries, ~200 SOQL records to query all profiles and build a cache from name -> id, and 1 queueable job
 *     (to add job to update the cache)
 *  2. When asking which profile as specific user has, this takes 1 SOQL query and 1 SOQL record PER user.
 *     The only exception is the current user, which we get from UserInfo and which doesn't cost a SOQL query.
 *  3. These functions do not Error Log on their own, you are expected to handle your own error logging
 *
 * Anti-Limitation:
 *  1. We don't use any DML in these functions, this means that these are all safe to call from @AuraEnabled(cacheable=true) functions
 *  2. We do caching wherever possible so calling the function with the same parameters should be governor-limit free
 *
 */
public without sharing class ProfileHelper {
    /**
     * Checks if the current user has a specific profile using profile name.
     *
     * @param profileName The name of the profile.
     * @return Boolean indicating if the current user has the profile.
     * @throws ProfileHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 1.
     */
    public static Boolean currentUserHasProfile(String profileName) {
        return userHasProfile(profileName, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific profile.
     *
     * @param profileName The name of the profile.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the profile.
     * @throws ProfileHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 1 and 2.
     */
    public static Boolean userHasProfile(String profileName, Id userId) {
        return userHasProfileId(getProfileId(profileName), userId);
    }

    /**
     * Checks if the current user has a specific profile ID.
     *
     * @param profileId The ID of the profile.
     * @return Boolean indicating if the current user has the profile ID.
     */
    public static Boolean currentUserHasProfileId(Id profileId) {
        return userHasProfileId(profileId, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific profile ID.
     *
     * @param profileId The ID of the profile.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the profile ID.
     * @throws ProfileHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 2.
     */
    public static Boolean userHasProfileId(Id profileId, Id userId) {
        if (String.isBlank(profileId) || String.isBlank(userId))
            return false;
        if (getUserProfileId(userId) == profileId)
            return true;
        return false;
    }

    /**
     * Checks if a profile name is valid.
     *
     * @param profileName The name of the profile.
     * @return Boolean indicating if the profile name is valid.
     */
    public static Boolean isValidProfileName(String profileName) {
        return (String.isNotBlank(profileName) && (getProfileId(profileName) != null));
    }

    /**
     * Get the id for a speicific profile name.
     * This first uses the Profile_Ids__c custom setting, which is a cache of profile name and ids.
     * If the record isn't in this cache, then we perform SOQL for all profile ids not in the
     * cache, and enqueue a ProfileHelperQueueable job to update the cache.
     *
     * @param profileName name of profile you want the id for
     * @return The ID of that profile, null if doesn't exist
     * @throws ProfileHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning If we are near the governor limits for queued jobs, we just don't enqueue the update job (and don't throw an error).
     * @warning See limitation 1.
     *
     * If record is in cache, then this is governor-limit-free but if the cache is out of date then this takes 1 SOQL query, ~200 SQOL records (usually less,
     * the upper limit is the number of profile in the org, but we only query those that aren't in the cache, so it usually is significantly less than 200),
     * and 1 queueable job (to setup cache update).
     */
    public static Id getProfileId(String profileName) {
        if (String.isBlank(profileName))
            return null;

        // first time calling - get from custom setting cache
        if (profileNameToId == null) {
            profileNameToId = new Map<String, Id>();
            for (Profile_Ids__c pi : Profile_Ids__c.getAll().values())
                profileNameToId.put(pi.Name__c, pi.Id__c);
        }

        // not in custom setting cache and we haven't SOQL-ed yet this transaction
        if (!profileNameToId.containsKey(profileName) && !hasQueriedProfileIds) {
            hasQueriedProfileIds = true;

            // At SOQL query limit - throw error rather than hit the limit (this way error logger can catches and report this)
            if (Limits.getQueries() >= Limits.getLimitQueries())
                throw new ProfileHelperSoqlGovernorLimitException(
                    'Already at SOQL query limit, cannot udpate cache to get profile id for profile ' + profileName
                );

            // At SOQL record limit - throw error rather than hit the limit (this way error logger can catches and report this)
            if (Limits.getQueryRows() >= Limits.getLimitQueryRows() - APPROX_NUMBER_OF_PROFILE)
                throw new ProfileHelperSoqlGovernorLimitException(
                    'Too close to SOQL row query limit, cannot udpate cache to get profile id for profile ' +
                    profileName
                );

            // not in cache - let's update the cache using SOQL
            for (Profile p : [
                SELECT Name, Id
                FROM Profile
                WHERE Name NOT IN :profileNameToId.keySet()
            ])
                profileNameToId.put(p.Name, p.Id);

            // After SOQL we now were able to find mapping - so let's queue a job to update the cache
            if (profileNameToId.containsKey(profileName)) {
                // Not yet at queuebale job limit, and there is enough SOQL queries to check for duplicate jobs
                if (
                    Limits.getQueueableJobs() < Limits.getLimitQueueableJobs() &&
                    Limits.getQueries() < Limits.getLimitQueries() &&
                    Limits.getQueryRows() < Limits.getLimitQueryRows()
                ) {
                    // We want to prevent duplicate jobs
                    // One option that would be better than what we have but don't work is using AsyncOptions().DuplicateSignature
                    //    Benefits: Basically designed for exactly this problem and no SOQL needed.
                    //    Problem: If we catch the DuplicateMessageException (which we want to do since we
                    //             just want to not queue it - not abort the whole transaction) then the
                    //             job is still queued and we need to find a way to dequeue it (we don't have
                    //             the jobId in this scenario and even if we DID, abortJob is a DML statement)
                    // So instead we need to SOQL query to check for duplicates before enqueuing the job.
                    List<AsyncApexJob> alreadyQueued = [
                        SELECT Id
                        FROM AsyncApexJob
                        WHERE
                            Status IN ('Queued', 'Preparing', 'Processing')
                            AND ApexClass.Name = 'ProfileHelperQueueable'
                        LIMIT 1
                    ];

                    // none already queued, queue the job
                    if (alreadyQueued.isEmpty())
                        System.enqueueJob(new ProfileHelperQueueable());
                } else {
                    // Fine if we can't, we don't need to throw an error since the job will almost certainly be queued by a different, less taxed, transaction
                }
            }
        }

        return profileNameToId.get(profileName);
    }
    private static Map<String, Id> profileNameToId = null;
    private static Boolean hasQueriedProfileIds = false;
    private static Integer APPROX_NUMBER_OF_PROFILE = 200; // hardcoded approx number of profiles in org to use for avoiding governor limit exceptions

    /**
     * Get the profile id for a user - this uses cahcing to minimize the number of SOQL
     * queries made, so if a user's profile changes during the transaction, it might be
     * inaccurate
     *
     * @param userId User we need profile id for
     * @return The profile id for that user
     * @throws ProfileHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 2.
     */
    private static Id getUserProfileId(Id userId) {
        if (userToProfileId == null) {
            userToProfileId = new Map<String, Id>();
        }
        if (!userToProfileId.containsKey(userId)) {
            if (userId == UserInfo.getUserId())
                userToProfileId.put(userId, UserInfo.getProfileId());
            else {
                // At SOQL query limit - throw error rather than hit the limit (this way error logger can catches and report this)
                if (Limits.getQueries() >= Limits.getLimitQueries())
                    throw new ProfileHelperSoqlGovernorLimitException(
                        'Already at SOQL query limit, cannot query profile for user ' + userId
                    );

                // At SOQL record limit - throw error rather than hit the limit (this way error logger can catches and report this)
                if (Limits.getQueryRows() >= Limits.getLimitQueryRows())
                    throw new ProfileHelperSoqlGovernorLimitException(
                        'Too close to SOQL row query limit, cannot query profile for user ' + userId
                    );

                userToProfileId.put(userId, [SELECT ProfileId FROM User WHERE Id = :userId].ProfileId);
            }
        }
        return userToProfileId.get(userId);
    }
    private static Map<String, Id> userToProfileId = null;

    public class ProfileHelperSoqlGovernorLimitException extends Exception {
    }
}
