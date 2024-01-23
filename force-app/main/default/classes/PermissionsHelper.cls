public class PermissionsHelper {
    public static List<Profile_Ids__c> profileIds {
        get {
            if (profileIds == null) {
                profileIds = Profile_Ids__c.getAll().values();
            }

            return profileIds;
        }
        set;
    }

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

    public static Boolean currentUserHasProfile(String profileName) {
        return userHasProfile(profileName, UserInfo.getUserId());
    }

    public static Boolean userHasProfile(String profileName, Id userId) {
        return (profileName != null &&
            profileName != '' &&
            userId != null &&
            ([
                SELECT Profile.Name
                FROM User
                WHERE Id = :userId
            ]
            .Profile.Name == profileName))
            ? true
            : false;
    }

    public static Boolean currentUserHasProfileId(Id profileId) {
        return userHasProfileId(profileId, UserInfo.getUserId());
    }

    public static Boolean userHasProfileId(Id profileId, Id userId) {
        return (profileId != null &&
            userId != null &&
            ([
                SELECT Profile.Id
                FROM User
                WHERE Id = :userId
            ]
            .Profile.Id == profileId))
            ? true
            : false;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean currentUserHasPermissionSet(String permissionSetName) {
        return userHasPermissionSet(permissionSetName, UserInfo.getUserId());
    }

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

    public static Boolean currentUserHasPermissionSetId(Id permissionSetId) {
        return userHasPermissionSetId(permissionSetId, UserInfo.getUserId());
    }

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
}