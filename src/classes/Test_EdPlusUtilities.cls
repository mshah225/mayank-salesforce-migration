/*****************************************
 * File: Test_EdPlusUtilities
 * Author: Carl Hussey, ASU
 * Description: Unit Tests for EdPlusUtilities.cls
 ******************************************/
@isTest
public class Test_EdPlusUtilities {
    /**
     * Test track usage method
     */
    static testmethod void trackUsage() {
        Test.startTest();

        Id pId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        User rec = TestDataFactory.createUser('John', pId);
        insert rec;

        EdPlusUtilities.TrackUsage(rec.Id, 'Viewed Record', 'ABC123');
        List<EntCrossOrgUsageStats__c> totalRecords = [SELECT Id FROM EntCrossOrgUsageStats__c];

        system.assertEquals(1, totalRecords.size() );

        Test.stopTest();
    }

    /**
     * Test getting external ContactIds
     * based on CrossOrg API Service
     */
    static testmethod void testGetExternalContacts() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGen_CrossOrgShare() );
        HTTPRestService_CrossOrgShare crosswalkService = new HTTPRestService_CrossOrgShare();

        Contact c1 = TestDataFactory.createContact('ASU');
        c1.SSB_CRMSYSTEM_Contact_ID__c = '9C7E57CF-2DC7-4C89-B476-11166DED34D0';
        
        insert c1;

        Id testContact = [SELECT Id FROM Contact LIMIT 1].Id;

        Test.startTest();
        List<Id> actualResponse = new List<Id>();
        actualResponse = EdPlusUtilities.GetExternalContacts(testContact);
        Test.stopTest();

        System.assertEquals(testContact, actualResponse[0]);
    }
}
