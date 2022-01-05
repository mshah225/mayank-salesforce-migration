@isTest
private class BomgarCreateCaseTriggerTest {
    @TestSetup
    private static void setup() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.user@test.example.com',
            EMPLID__c = '1231231231',
            ASURite_Id__c = 'testuser'
        );

        insert testContact;
    }

    @isTest
    private static void testCreateCase() {
        Contact con = [SELECT Id, EMPLID__c, ASURite_Id__c FROM Contact LIMIT 1];
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c(
            bomgar__ExternalKey__c = 'SFDC:{' +
                '"employeeNumber":"' +
                con.EMPLID__c +
                '", ' +
                '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
                '"asuriteId":"' +
                con.ASURite_Id__c +
                '", ' +
                '"externalKey":"Other"}',
            bomgar__BomgarSessionID__c = 'lsid',
            bomgar__EventType__c = 'support_conference_member_added',
            bomgar__ConferenceMemberType__c = 'representative',
            bomgar__UserID__c = '12345',
            bomgar__Username__c = 'joe12345'
        );

        Test.startTest();
        insert webEvent;
        Test.stopTest();

        List<Case> cases = [SELECT Id, ContactId FROM Case];

        System.assert(!cases.isEmpty(), 'Failed to create case');
        for (Case c : cases)
            System.assertEquals(con.Id, c.ContactId, 'Incorrect contact associated with case');
    }

    @isTest
    private static void padTests() {
        /**
         * We don't do anything on update,delete,undelete currently so this method
         * exists just to call those triggers and pad the code coverage.
         */
        Contact con = [SELECT Id, EMPLID__c, ASURite_Id__c FROM Contact LIMIT 1];
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c(
            bomgar__ExternalKey__c = 'SFDC:{' +
                '"employeeNumber":"' +
                con.EMPLID__c +
                '", ' +
                '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
                '"asuriteId":"' +
                con.ASURite_Id__c +
                '", ' +
                '"externalKey":"Other"}',
            bomgar__BomgarSessionID__c = 'lsid',
            bomgar__EventType__c = 'support_conference_member_added',
            bomgar__ConferenceMemberType__c = 'representative',
            bomgar__UserID__c = '12345',
            bomgar__Username__c = 'joe12345'
        );

        Test.startTest();
        insert webEvent;
        Test.stopTest();
        webEvent.bomgar__UserID__c = '23456';

        // Trigger all other functions for test coverage
        update webEvent;
        delete webEvent;
        undelete webEvent;
    }
}
