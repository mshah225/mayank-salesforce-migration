@isTest
private class ProfileAuditControllerTest {
    @isTest
    static void testHasAccessSearch() {
        Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        ProfileAuditController pac = new ProfileAuditController();
        pac.getProfileOptions();
        pac.getAccessOptions();
        pac.selectedProfileId = sysAdminProfile;
        pac.selectedAccess = 'Has Access';
        System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
        System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Access: ' + pac.selectedAccess);
        pac.profilePermissionSearch();
        System.assertNotEquals(null, pac.objectPerms);
        System.assertNotEquals(null, pac.selectedProfileName);
        List<String> tempList = new List<String>();
        tempList.addAll(pac.objectPerms.keySet());
        pac.selectedObject = tempList[0];
        pac.drillDownSearch();
        System.assertNotEquals(null, pac.fieldDrillList);
    }

    @isTest
    static void testFieldSearch() {
        Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        ProfileAuditController pac = new ProfileAuditController();
        pac.getProfileOptions();
        pac.getAccessOptions();
        pac.selectedProfileId = sysAdminProfile;
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

    @isTest
    static void testResetForm() {
        Id sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        ProfileAuditController pac = new ProfileAuditController();
        pac.getProfileOptions();
        pac.getAccessOptions();
        pac.selectedProfileId = sysAdminProfile;
        pac.selectedAccess = 'No Access';
        System.debug('!!!!!!!!!!!!!!!!!!!!!! Selected Profile: ' + pac.selectedProfileId);
        pac.profilePermissionSearch();
        pac.reStart();
        System.assertEquals(null, pac.objectPerms);
        System.assertEquals(null, pac.fieldPerms);
        System.assertEquals(null, pac.selectedAccess);
    }
}
