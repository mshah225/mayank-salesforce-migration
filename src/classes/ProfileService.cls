public without sharing class ProfileService 
{
	/**
	* Returns a list of objects that the profile has access to
	* @param The id of the profile you'd like the list for
	* @return An ObjectPermissions list of objects
	*/
	public static List<ObjectPermissions> getAccessibleObjectsByProfile(Id profileId) 
	{
		List<ObjectPermissions> objectPerms = [SELECT ParentId, SObjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                               				   FROM ObjectPermissions 
                               				   WHERE ParentId 
                               				   IN (SELECT Id FROM PermissionSet 
                                   				   WHERE IsOwnedByProfile = true 
                                   				   AND PermissionSet.Profile.Id = :profileId)
                               				   ORDER BY SObjectType]; 
        objectPerms.sort();

        return objectPerms;
	}

	/**
	* Returns a list of all objects the the profile does NOT have access to
	* @param The id of the profile you'd like the list for
	* @return A string list of the objects the profile does NOT have access to
	*/
	public static List<String> getInaccessibleObjectsByProfile(Id profileId)
	{
		List<ObjectPermissions> objectHasAccess = new List<ObjectPermissions>();
        objectHasAccess = [SELECT ParentId, SObjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                     FROM ObjectPermissions 
                     WHERE ParentId 
                     IN (SELECT Id FROM PermissionSet 
                         WHERE IsOwnedByProfile = true 
                         AND PermissionSet.Profile.Id = :profileId)]; 
        
        Set<String> hasAccessSet = new Set<String>();
        for (ObjectPermissions op: objectHasAccess)
        {
            hasAccessSet.add(op.SObjectType);
        }

        Set<String> finalSet = new Set<String>();
        for (Schema.SObjectType typ: Schema.getGlobalDescribe().values()) 
        {
            String sobjName = String.valueOf(typ);
            if(!hasAccessSet.contains(sobjName))
            {
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
	* @return A FieldPermissions list of all the fields for the object that the profile has
	* access to
	*/
	public static List<FieldPermissions> getAccessibleObjectFieldsByProfile(Id profileId, String objectName)
	{
		List<FieldPermissions> fieldPerms = [SELECT ParentId, SObjectType, Field, PermissionsEdit, PermissionsRead
                      						 FROM FieldPermissions 
                      						 WHERE ParentId IN (SELECT Id FROM PermissionSet 
                                         						 WHERE IsOwnedByProfile = true 
                                         						 AND PermissionSet.Profile.Id = :profileId) 
                      						 AND SObjectType = :objectName
                      						 ORDER BY Field]; 
        return fieldPerms;
	}
}