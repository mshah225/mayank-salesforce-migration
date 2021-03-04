/*****************************************
 * File: EdPlusUtilitiesTest
 * Author: Carl Hussey, ASU
 * Description: Unit Tests for EdPlusUtilities.cls
 ******************************************/
@isTest
public class EdPlusUtilitiesTest {
    /**
     * Test track usage method
     */
    static testMethod void trackUsage() {
        Test.startTest();

        Id pId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        User rec = TestDataFactory.createUser('John', pId);
        insert rec;

        EdPlusUtilities.trackUsage(rec.Id, 'Viewed Record', 'ABC123');
        List<EntCrossOrgUsageStats__c> totalRecords = [SELECT Id FROM EntCrossOrgUsageStats__c];

        system.assertEquals(1, totalRecords.size());

        Test.stopTest();
    }

    /**
     * Test getting external ContactIds
     * based on CrossOrg API Service
     */
    static testMethod void testgetExternalContacts() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());
        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();

        Contact c1 = TestDataFactory.createContact('ASU');
        c1.SSB_CRMSYSTEM_Contact_ID__c = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';

        insert c1;

        Id testContact = [SELECT Id FROM Contact LIMIT 1].Id;

        Test.startTest();
        List<Id> actualResponse = new List<Id>();
        actualResponse = EdPlusUtilities.getExternalContacts(testContact);
        Test.stopTest();

        System.assertEquals(testContact, actualResponse[0]);
    }
}
