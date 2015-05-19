@isTest
private class Test_ProfileAuditController 
{
	@isTest static void testHasAccessSearch() 
	{
		ProfileAuditController pac = new ProfileAuditController();
		pac.getProfileOptions();
		pac.getAccessOptions();
		pac.selectedProfileId = pac.profileList[0].Id;
		pac.selectedAccess = 'Has Access';
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Access: ' + pac.selectedAccess);
		pac.profilePermissionSearch();
		System.assertNotEquals(null, pac.objectPerms);
		System.assertNotEquals(null, pac.selectedProfileName);
		pac.selectedObject = pac.objectPerms[0].SObjectType;
		pac.drillDownSearch();
		System.assertNotEquals(null, pac.fieldDrillList);
	}
	
	@isTest static void testFieldSearch() 
	{
		ProfileAuditController pac = new ProfileAuditController();
		pac.getProfileOptions();
		pac.getAccessOptions();
		pac.selectedProfileId = pac.profileList[0].Id;
		pac.selectedAccess = 'No Access';
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Access: ' + pac.selectedAccess);
		pac.profilePermissionSearch();
		System.assertNotEquals(null, pac.finalList);
		System.assertNotEquals(null, pac.selectedProfileName);
		pac.selectedObject = pac.finalList[0];
		pac.drillDownFieldSearch();
		System.assertNotEquals(null, pac.fieldPerms);
	}

	@isTest static void testResetForm() 
	{
		ProfileAuditController pac = new ProfileAuditController();
		pac.getProfileOptions();
		pac.getAccessOptions();
		pac.selectedProfileId = pac.profileList[0].Id;
		pac.selectedAccess = 'No Access';
		System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
		pac.profilePermissionSearch();
		pac.reStart();
		System.assertEquals(null, pac.objectPerms);
		System.assertEquals(null, pac.fieldPerms);
		System.assertEquals(null, pac.selectedAccess);
	}
}