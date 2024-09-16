/**
 * Various helper functions for checking for a user's custom permissions.
 *
 * The main utility from this class is:
 * 1. userHasCustomPermission
 *    These helper functions return true or false to indicate if a user has a custom permission or not.
 *
 * Limitations:
 *  1. When asking if a user has a custom permission, this takes one SOQL query to get all the permission sets that grant
 *     that custom perm, and then 1 additional query PER user to determine which permission sets they have (we then can
 *     compare the two lists).
 *  2. These functions do not Error Log on their own, you are expected to handle your own error logging
 *
 * Anti-Limitation:
 *  1. We don't use any DML in these functions, this means that these are all safe to call from @AuraEnabled(cacheable=true) functions
 *  2. We do caching wherever possible so calling the function with the same parameters should be governor-limit free
 */
public without sharing class CustomPermissionHelper {
    /**
     * Checks if the current user has a custom permission.
     *
     * @param customPermissionName The name of the custom permission.
     * @return Boolean indicating if the current user has the permission set ID.
     */
    public static Boolean currentUserHasCustomPermission(String customPermissionName) {
        return userHasCustomPermission(customPermissionName, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific custom permission.
     *
     * @param customPermissionName The name of the custom permission.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the custom permission.
     * @throws CustomPermissionHelperSoqGovernorLimitException If it needs to make a SOQL query but is already too close to the governor limits (SOQL calls)
     */
    public static Boolean userHasCustomPermission(String customPermissionName, Id userId) {
        if (userId == UserInfo.getUserId())
            return FeatureManagement.checkPermission(customPermissionName);

        // Get the permission set IDs that include the custom permission
        Set<Id> permissionSetIds = getPermSetIdsForCustomPerm(customPermissionName);
        List<PermissionSetAssignment> permSetsForUser;

        try {
            permSetsForUser = PermissionSetHelper.getPermissionSetsForUser(userId);
        } catch (PermissionSetHelper.PermissionSetHelperSoqlGovernorLimitException ex) {
            throw new CustomPermissionHelperSoqGovernorLimitException(ex.getMessage()); // convert exception type
        }

        // Check if the user has any of the permission sets that include the custom permission
        for (PermissionSetAssignment psa : permSetsForUser)
            if (permissionSetIds.contains(psa.PermissionSetId))
                return true;

        // Return false if no matching permission set assignments are found
        return false;
    }

    /**
     * Gets all permission sets that grant a specific custom permission - uses caching to only do one SOQL query per custom permission
     */
    private static Set<Id> getPermSetIdsForCustomPerm(String customPermissionName) {
        if (customPermToPermSetIdsMp == null)
            customPermToPermSetIdsMp = new Map<String, Set<Id>>();
        if (!customPermToPermSetIdsMp.containsKey(customPermissionName)) {
            // Safe to query?
            // At SOQL query limit - throw error rather than hit the limit (this way error logger can catch and report this)
            if (Limits.getQueries() > Limits.getLimitQueries() - 1)
                throw new CustomPermissionHelperSoqGovernorLimitException(
                    'Already at SOQL query limit, cannot query which permission sets grant access to custom permission ' +
                    customPermissionName
                );

            // At SOQL record limit - throw error rather than hit the limit (this way error logger can catches and report this)
            if (Limits.getQueryRows() > Limits.getLimitQueryRows() - APPROX_NUMBER_OF_PERM_SET_GRANTING_CUSTOM_PERM)
                throw new CustomPermissionHelperSoqGovernorLimitException(
                    'Too close to SOQL row query limit, cannot query which permission sets grant access to custom permission ' +
                    customPermissionName
                );

            // get all perm sets that include this custom permission
            Set<Id> permissionSetIds = new Set<Id>();
            for (SetupEntityAccess access : [
                SELECT ParentId
                FROM SetupEntityAccess
                WHERE
                    SetupEntityId IN (
                        SELECT Id
                        FROM CustomPermission
                        WHERE DeveloperName = :customPermissionName
                    )
            ]) {
                permissionSetIds.add(access.ParentId);
            }
            // add to cache
            customPermToPermSetIdsMp.put(customPermissionName, permissionSetIds);
        }
        return customPermToPermSetIdsMp.get(customPermissionName);
    }
    private static Map<String, Set<Id>> customPermToPermSetIdsMp;
    private static Integer APPROX_NUMBER_OF_PERM_SET_GRANTING_CUSTOM_PERM = 20; // hardcoded approx number of perm sets that grant a given custom permission, used to predict and avoid governor limit exceptions

    public class CustomPermissionHelperSoqGovernorLimitException extends Exception {
    }
}
