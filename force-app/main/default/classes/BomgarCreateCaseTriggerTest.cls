@isTest
private class BomgarCreateCaseTriggerTest {
    @testSetup
    static void setUpTest() {
        Contact testContact = ContactService.createTestContact();
        testContact.EMPLID__c = '1231231231';
        testContact.ASURite_Id__c = 'testuser';

        insert testContact;
    }

    @isTest
    static void createCaseTriggerTest() {
        Test.startTest();

        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"1231231231", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
            '"asuriteId":"testuser", ' +
            '"externalKey":"Other"}';
        webEvent.bomgar__BomgarSessionID__c = 'lsid';
        webEvent.bomgar__EventType__c = 'support_conference_member_added';
        webEvent.bomgar__ConferenceMemberType__c = 'representative';
        webEvent.bomgar__UserID__c = '12345';
        webEvent.bomgar__Username__c = 'joe12345';

        insert webEvent;

        Test.stopTest();
    }
}
