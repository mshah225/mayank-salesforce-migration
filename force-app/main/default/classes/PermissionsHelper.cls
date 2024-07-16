/**
 * A helper class providing utility methods for working with profiles and permissions in Salesforce.
 */
public class PermissionsHelper {
    /**
     * Retrieves all profile IDs from the custom object and caches them.
     *
     * @return List of Profile_Ids__c objects.
     */
    public static List<Profile_Ids__c> profileIds {
        get {
            if (profileIds == null) {
                profileIds = Profile_Ids__c.getAll().values();
            }
            return profileIds;
        }
        set;
    }

    /**
     * Gets the profile ID by profile name.
     *
     * @param profileName The name of the profile.
     * @return The ID of the profile.
     */
    public static Id getProfileIdByName(String profileName) {
        for (Profile_Ids__c pi : profileIds) {
            if (pi.Name__c == profileName) {
                return pi.Id__c;
            }
        }
        if (rebuildProfileIdCache(profileName)) {
            return getProfileIdByName(profileName);
        } else {
            return null;
        }
    }

    /**
     * Rebuilds the profile ID cache.
     *
     * @param profileName The name of the profile to check existence.
     * @return Boolean indicating if the profile exists.
     */
    public static Boolean rebuildProfileIdCache(String profileName) {
        if (profileIds.size() > 0) {
            delete profileIds;
            profileIds = null;
        }
        Boolean exists = false;
        profileIds = new List<Profile_Ids__c>();

        for (Profile p : [SELECT Id, Name FROM Profile]) {
            if (p.Name == profileName) {
                exists = true;
            }

            Profile_Ids__c profileId = new Profile_Ids__c();
            profileId.Name = p.Id;
            profileId.Name__c = p.Name;
            profileId.Id__c = p.Id;

            profileIds.add(profileId);
        }

        if (profileIds.size() > 0) {
            insert profileIds;
        }
        return exists;
    }

    /**
     * Checks if the current user has a specific profile.
     *
     * @param profileName The name of the profile.
     * @return Boolean indicating if the current user has the profile.
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
     */
    public static Boolean userHasProfile(String profileName, Id userId) {
        return (profileName != null &&
            profileName != '' &&
            userId != null &&
            ([SELECT Profile.Name FROM User WHERE Id = :userId].Profile.Name == profileName))
            ? true
            : false;
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
     */
    public static Boolean userHasProfileId(Id profileId, Id userId) {
        return (profileId != null &&
            userId != null &&
            ([SELECT Profile.Id FROM User WHERE Id = :userId].Profile.Id == profileId))
            ? true
            : false;
    }

    /**
     * Checks if the current user has a specific permission set.
     *
     * @param permissionSetName The name of the permission set.
     * @return Boolean indicating if the current user has the permission set.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean currentUserHasPermissionSet(String permissionSetName) {
        return userHasPermissionSet(permissionSetName, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific permission set.
     *
     * @param permissionSetName The name of the permission set.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the permission set.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean userHasPermissionSet(String permissionSetName, Id userId) {
        return (permissionSetName != null &&
            permissionSetName != '' &&
            userId != null &&
            ([
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = :permissionSetName AND AssigneeId = :userId
                LIMIT 1
            ] == 1))
            ? true
            : false;
    }

    /**
     * Checks if the current user has a specific permission set ID.
     *
     * @param permissionSetId The ID of the permission set.
     * @return Boolean indicating if the current user has the permission set ID.
     */
    public static Boolean currentUserHasPermissionSetId(Id permissionSetId) {
        return userHasPermissionSetId(permissionSetId, UserInfo.getUserId());
    }

    /**
     * Checks if a user has a specific permission set ID.
     *
     * @param permissionSetId The ID of the permission set.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the permission set ID.
     */
    public static Boolean userHasPermissionSetId(Id permissionSetId, Id userId) {
        return (permissionSetId != null &&
            userId != null &&
            ([
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE PermissionSet.Id = :permissionSetId AND AssigneeId = :userId
                LIMIT 1
            ] == 1))
            ? true
            : false;
    }

    /**
     * Checks if a user has a specific custom permission.
     *
     * @param customPermissionName The name of the custom permission.
     * @param userId The ID of the user.
     * @return Boolean indicating if the user has the custom permission.
     */
    public static Boolean userHasCustomPermission(String customPermissionName, Id userId) {
        // Get the permission set IDs that include the custom permission
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

        // Check if the user has any of the permission sets that include the custom permission
        for (PermissionSetAssignment psa : [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId AND PermissionSetId IN :permissionSetIds
        ]) {
            return true;
        }

        // Return false if no matching permission set assignments are found
        return false;
    }

    /**
     * Checks if the current user has permissions to create cases.
     *
     * @return Boolean indicating if the current user has permissions to create cases.
     */
    public static Boolean currentUserHasCreateCasePermissions() {
        return Schema.sObjectType.Case.isCreateable();
    }
}