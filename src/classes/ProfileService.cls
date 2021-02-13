public without sharing class ProfileService {
    /**
     * Returns a list of objects that the profile has access to
     * @param The id of the profile you'd like the list for
     * @return A Map<String, List<String>> of the ObjectPermissions object the user HAS access to
     */
    public static Map<String, List<String>> getAccessibleObjectsByProfile(Id profileId) {
        List<ObjectPermissions> objectPerms = [
            SELECT
                ParentId,
                SObjectType,
                PermissionsCreate,
                PermissionsDelete,
                PermissionsEdit,
                PermissionsModifyAllRecords,
                PermissionsRead,
                PermissionsViewAllRecords
            FROM ObjectPermissions
            WHERE
                ParentId IN (
                    SELECT Id
                    FROM PermissionSet
                    WHERE IsOwnedByProfile = TRUE AND PermissionSet.Profile.Id = :profileId
                )
            ORDER BY SObjectType
        ];

        Map<String, List<String>> permMap = new Map<String, List<String>>();
        for (ObjectPermissions ob : objectPerms) {
            List<String> tempList = new List<String>();
            tempList.add(String.valueOf(ob.PermissionsCreate));
            tempList.add(String.valueOf(ob.PermissionsRead));
            tempList.add(String.valueOf(ob.PermissionsEdit));
            tempList.add(String.valueOf(ob.PermissionsDelete));
            tempList.add(String.valueOf(ob.PermissionsModifyAllRecords));
            tempList.add(String.valueOf(ob.PermissionsViewAllRecords));
            permMap.put(ob.SObjectType, tempList);
        }

        return permMap;
    }

    /**
     * Returns a list of all objects the the profile does NOT have access to
     * @param The id of the profile you'd like the list for
     * @return A string list of the objects the profile does NOT have access to
     */
    public static List<String> getInaccessibleObjectsByProfile(Id profileId) {
        List<ObjectPermissions> objectHasAccess = new List<ObjectPermissions>();
        objectHasAccess = [
            SELECT
                ParentId,
                SObjectType,
                PermissionsCreate,
                PermissionsDelete,
                PermissionsEdit,
                PermissionsModifyAllRecords,
                PermissionsRead,
                PermissionsViewAllRecords
            FROM ObjectPermissions
            WHERE
                ParentId IN (
                    SELECT Id
                    FROM PermissionSet
                    WHERE IsOwnedByProfile = TRUE AND PermissionSet.Profile.Id = :profileId
                )
        ];

        Set<String> hasAccessSet = new Set<String>();
        for (ObjectPermissions op : objectHasAccess) {
            hasAccessSet.add(op.SObjectType);
        }

        Set<String> finalSet = new Set<String>();
        for (Schema.SObjectType typ : Schema.getGlobalDescribe().values()) {
            String sobjName = String.valueOf(typ);
            if (!hasAccessSet.contains(sobjName)) {
                finalSet.add(sobjName);
            }
        }

        List<String> finalList = new List<String>();
        finalList.addAll(finalSet);
        finalList.sort();

        return finalList;
    }

    /**
     * Returns a list of fields that the profile has access to.
     * @param The id of the profile and the name of the object you want the accessible fields for
     * @return A Map<String, List<String>> of all the fields for the object that the profile has
     * access to
     */
    public static Map<String, List<String>> getAccessibleObjectFieldsByProfile(Id profileId, String objectName) {
        List<FieldPermissions> fieldPerms = [
            SELECT ParentId, SObjectType, Field, PermissionsEdit, PermissionsRead
            FROM FieldPermissions
            WHERE
                ParentId IN (
                    SELECT Id
                    FROM PermissionSet
                    WHERE IsOwnedByProfile = TRUE AND PermissionSet.Profile.Id = :profileId
                )
                AND SObjectType = :objectName
            ORDER BY Field
        ];

        Map<String, List<String>> fieldMap = new Map<String, List<String>>();
        for (FieldPermissions fp : fieldPerms) {
            List<String> tempList = new List<String>();
            tempList.add(String.valueOf(fp.PermissionsRead));
            tempList.add(String.valueOf(fp.PermissionsEdit));
            String tempString = String.valueOf(fp.Field);
            tempString = tempString.substring(tempString.indexOf('.') + 1);
            fieldMap.put(tempString, tempList);
        }

        return fieldMap;
    }
}
