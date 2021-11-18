@isTest
public class ExternalObjectQueryServiceTest {
    /**
     * Test external data query helper
     */
    public static testMethod void testExternalObjectQueryService() {
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        // Begin
        Test.startTest();

        // Create contacts
        List<Contact> internalContacts = TestDataFactory.createContacts(5);
        insert internalContacts;

        // Test passthrough
        List<SObject> results = ExternalObjectQueryService.getRecords(internalContacts);
        System.assertEquals(5, results.size());

        // End
        Test.stopTest();
    }
}
