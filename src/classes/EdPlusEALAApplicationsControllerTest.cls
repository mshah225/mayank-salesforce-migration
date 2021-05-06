/*****************************************
 * File: EdPlusEALAApplicationsControllerTest 
 * Author: Carl Hussey, ASU
 * Description: Unit Tests for EdPlusEALAApplicationsControllerTest .cls
 ******************************************/
@isTest
public class EdPlusEALAApplicationsControllerTest  {
    /**
     * Extend our Query class to mock our external data
     */
    class Mock extends Query {
        final Map<SObjectType, List<SObject>> cache;
        public Mock() {
            cache = new Map<SObjectType, List<SObject>>();
        }
        public Mock setDataStore(List<SObject> records) {
            cache.put(records.getSObjectType(), records);

            return this;
        }
        protected override List<SObject> passthrough(List<SObject> records) {
            return cache.get(records.getSObjectType());
        }
    }

    /**
     * Setup the test for the main controller
     */
    public static testMethod void testController() {

        // Create mocked data
        createTestData();

        // Set HTTP mock for the controller we are testing
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        // Query the test contacts and get an ID
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c
            FROM Contact
            WHERE FirstName = 'Mister' AND LastName = '0'
            LIMIT 1
        ];
        Id testContactId = testContact.Id;

        // Set the necessary parameters on the page
        PageReference pg = Page.EdPlusEALAApplications;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', testContactId);

        // Instantiate the standard Contact controller so we can later instantiate our controller extension
        ApexPages.StandardController stdController = new ApexPages.StandardController(testContact);

        // Begin
        Test.startTest();

        // Instantiate the controller, which will get the Aggregated Task and Event Details
        EdPlusEALAApplicationsController controller = new EdPlusEALAApplicationsController(stdController);

        // There should be 5 records total
        System.assertEquals(5, controller.applications.size());

        // Confirm that we found values
        System.assertEquals('ELEA-0', controller.applications[0].Name__c);
        System.assertEquals(12.0, controller.applications[0].Number_of_Credits_Needed__c);

        // End
        Test.stopTest();
    }

    /**
     * Test ability to insert tracking record
     */
    public static testMethod void insertTracking() {

        // Create mocked data
        createTestData();

        // Set HTTP mock for the controller we are testing
        Test.setMock(HttpCalloutMock.class, new CrossOrgShareCalloutMock());

        // Query the test contacts and get an ID
        Contact testContact = [
            SELECT Id, SSB_CRMSYSTEM_Contact_ID__c
            FROM Contact
            WHERE FirstName = 'Mister' AND LastName = '0'
            LIMIT 1
        ];
        Id testContactId = testContact.Id;

        // Set the necessary parameters on the page
        PageReference pg = Page.EdPlusEALAApplications;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', testContactId);

        // Instantiate the standard Contact controller so we can later instantiate our controller extension
        ApexPages.StandardController stdController = new ApexPages.StandardController(testContact);

        // Begin
        Test.startTest();

        // Instantiate the controller, which will get the Aggregated Task and Event Details
        EdPlusEALAApplicationsController controller = new EdPlusEALAApplicationsController(stdController);

        controller.trackedAction = 'Viewed Record 123';
        controller.relatedRecordId = 'ABC123';
        controller.trackUsage();

        List<EntCrossOrgUsageStats__c> usage = [
            SELECT Id
            FROM EntCrossOrgUsageStats__c
            WHERE Related_Record_Id__c = 'ABC123'
        ];

        // Check for inserted record
        System.assertEquals(1, usage.size());

        // End
        Test.stopTest();
    }

    /**
     * Create the test data
     */
    public static void createTestData() {
        
        // Create test contacts
        List<Contact> internalContacts = TestDataFactory.createContacts(5);
        for (Integer i = 0; i < 5; i++) {
            internalContacts[i].SSB_CRMSYSTEM_Contact_ID__c = '9C7E57CF-2DC7-4C89-B476-11166DED34D' + i;
        }
        insert internalContacts;

        // Insert mocked applications
        List<EA_Learner_Application__x> mockExternalApplications = new List<EA_Learner_Application__x>();
        for (Integer i = 0; i < 5; i++) {
            mockExternalApplications.add(
                new EA_Learner_Application__x(Completed__c = true, Number_of_Credits_Completed__c = 3.0, Number_of_Credits_Needed__c = 12.0, Name__c = 'ELEA-'+i)
            );
        }

        // Insert the mocked data into our cache
        Mock m = new Mock().setDataStore(mockExternalApplications);

        // Set the mocked data
        Query.setMock(m);
    }
}