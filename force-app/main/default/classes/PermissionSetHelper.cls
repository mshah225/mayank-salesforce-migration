/**
 * Various helper functions for checking for a user's permission sets
 *
 * The main utility from this class is:
 * 1. userHasPermissionSet
 *    These helper functions return true or false to indicate if a user has a specific permission set or not.
 *
 * Limitations:
 *  1. When asking which permissions set a specific user has, this takes 1 SOQL query per user, and tkaes as many
 *     query rows as the user has permission sets.
 *  2. These functions do not Error Log on their own, you are expected to handle your own error logging
 *
 * Anti-Limitation:
 *  1. We don't use any DML in these functions, this means that these are all safe to call from @AuraEnabled(cacheable=true) functions
 *  2. We do caching wherever possible so calling the function with the same parameters should be governor-limit free
 */
public without sharing class PermissionSetHelper {
    /**
     * Checks if the current user has a specific permission set.
     * @warning Uses caching, inaccurate if permission sets assignments change over the course of the transaction
     *
     * @param permissionSetName The name of the permission set.
     * @return Boolean indicating if the current user has the permission set.
     * @throws PermissionSetHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 1.
     */
    public static Boolean currentUserHasPermissionSet(String permissionSetName) {
        return userHasPermissionSet(permissionSetName, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific permission set.
     * @warning Uses caching, inaccurate if permission sets assignments change over the course of the transaction
     *
     * @param permissionSetName The name of the permission set.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the permission set.
     * @throws PermissionSetHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 1.
     */
    public static Boolean userHasPermissionSet(String permissionSetName, Id userId) {
        if (String.isBlank(permissionSetName) || String.isBlank(userId))
            return false;
        for (PermissionSetAssignment psa : getPermissionSetsForUser(userId))
            if (psa.PermissionSet.Name == permissionSetName)
                return true;
        return false;
    }

    /**
     * Checks if the current user has a specific permission set ID.
     * @warning Uses caching, inaccurate if permission sets assignments change over the course of the transaction
     *
     * @param permissionSetId The ID of the permission set.
     * @return Boolean indicating if the current user has the permission set ID.
     * @throws PermissionSetHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 1.
     */
    public static Boolean currentUserHasPermissionSetId(Id permissionSetId) {
        return userHasPermissionSetId(permissionSetId, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific permission set ID.
     * @warning Uses caching, inaccurate if permission sets assignments change over the course of the transaction
     *
     * @param permissionSetId The ID of the permission set.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the permission set ID.
     * @throws PermissionSetHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     * @warning See limitation 1.
     */
    public static Boolean userHasPermissionSetId(Id permissionSetId, Id userId) {
        if (String.isBlank(permissionSetId) || String.isBlank(userId))
            return false;
        for (PermissionSetAssignment psa : getPermissionSetsForUser(userId))
            if (psa.PermissionSetId == permissionSetId)
                return true;
        return false;
    }

    /**
     * Get a list of all permission sets a user has - this uses caching so minimize the number of SOQL
     * queries made, so it only populates this list once per user per transaction - if values are
     * expected to change during the transaction then this might not be accurate.
     * @param userId User we need the permission sets for
     * @return A list of permission set assignments for that user
     * @throws PermissionSetHelperSoqlGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls or SOQL rows)
     */
    public static List<PermissionSetAssignment> getPermissionSetsForUser(Id userId) {
        if (userIdToPermSets == null)
            userIdToPermSets = new Map<Id, List<PermissionSetAssignment>>();

        if (!userIdToPermSets.containsKey(userId)) {
            // At SOQL query limit - throw error rather than hit the limit (this way error logger can catches and report this)
            if (Limits.getQueries() >= Limits.getLimitQueries())
                throw new PermissionSetHelperSoqlGovernorLimitException(
                    'Already at SOQL query limit, cannot query permission sets for user ' + userId
                );

            // At SOQL record limit - throw error rather than hit the limit (this way error logger can catches and report this)
            if (Limits.getQueryRows() >= Limits.getLimitQueryRows() - APPROX_NUMBER_OF_PERM_SET_PER_USER)
                throw new PermissionSetHelperSoqlGovernorLimitException(
                    'Too close to SOQL row query limit, cannot query permission sets for user ' + userId
                );

            userIdToPermSets.put(
                userId,
                new List<PermissionSetAssignment>(
                    [
                        SELECT PermissionSetId, PermissionSet.Name
                        FROM PermissionSetAssignment
                        WHERE AssigneeId = :userId
                    ]
                )
            );
        }

        return userIdToPermSets.get(userId);
    }
    private static Map<Id, List<PermissionSetAssignment>> userIdToPermSets = null;
    private static Integer APPROX_NUMBER_OF_PERM_SET_PER_USER = 20; // hardcoded approx number of perm sets per user, used to predict and avoid governor limit exceptions

    public class PermissionSetHelperSoqlGovernorLimitException extends Exception {
    }
}
