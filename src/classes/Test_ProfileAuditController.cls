@isTest
private class Test_ProfileAuditController 
{
	@isTest static void testObjectSearch() 
	{
		ProfileAuditController pac = new ProfileAuditController();
		pac.getTypeOptions();
		pac.getProfileOptions();
		pac.selectedType = 'Object Permissions';
		pac.selectedProfileId = pac.profileList[0].Id;
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
		pac.profilePermissionSearch();
		System.assertNotEquals(null, pac.objectPerms);
		System.assertNotEquals(null, pac.selectedProfileName);
	}
	
	@isTest static void testFieldSearch() 
	{
		ProfileAuditController pac = new ProfileAuditController();
		pac.getTypeOptions();
		pac.getProfileOptions();
		pac.selectedType = 'Field Permissions';
		pac.selectedProfileId = pac.profileList[0].Id;
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
		pac.profilePermissionSearch();
		System.assertNotEquals(null, pac.fieldPerms);
		System.assertNotEquals(null, pac.selectedProfileName);
	}

	@isTest static void testResetForm() 
	{
		ProfileAuditController pac = new ProfileAuditController();
		pac.getTypeOptions();
		pac.getProfileOptions();
		pac.selectedType = 'Field Permissions';
		pac.selectedProfileId = pac.profileList[0].Id;
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
		pac.profilePermissionSearch();
		pac.resetForm();
		System.assertEquals(null, pac.objectPerms);
		System.assertEquals(null, pac.fieldPerms);
		System.assertEquals('--Select--', pac.selectedType);
	}
}