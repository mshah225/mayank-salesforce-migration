@isTest
private class UserPresenceControllerTest {
    @isTest
    private static void testOOO() {
        String message = 'Out of Office';
        UserPresenceController uc = new UserPresenceController();
        uc.ooo = true;
        uc.oooMessage = message;
        uc.saveOOOM();

        User userRec = [SELECT Id, Out_Of_Office_Message__c FROM User WHERE Id = :UserInfo.getUserId()];
        System.assertEquals(false, String.isBlank(userRec.Out_Of_Office_Message__c));
        System.assertEquals(true, 'Out of Office'.equalsIgnoreCase(userRec.Out_Of_Office_Message__c));
    }
}
