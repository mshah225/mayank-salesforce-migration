/*****************************************
 * File: EdPlusAggregatedNotesControllerTest
 * Author: Carl Hussey, ASU
 * Description: Unit Tests for EdPlusAggregatedNotesController.cls
 ******************************************/
@isTest
public class EdPlusAggregatedNotesControllerTest {
    /**
     * Extend our ExternalObjectQueryService class to mock our external data
     */
    class EdPlusAggregatedNotesControllerMock extends ExternalObjectQueryService {
        final Map<SObjectType, List<SObject>> cache;
        public EdPlusAggregatedNotesControllerMock() {
            cache = new Map<SObjectType, List<SObject>>();
        }
        public Mock setDataStore(List<SObject> records) {
            cache.put(records.getSObjectType(), records);
            return this;
        }
        protected override List<SObject> recordTunnel(List<SObject> records) {
            return cache.get(records.getSObjectType());
        }
    }

    /**
     * Setup the test for the main controller
     */
    public static testMethod void edPlusAggregatedNotesControllerTest() {
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
        PageReference pg = Page.EdPlusAggregatedNotes;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', testContactId);

        // Instantiate the standard Contact controller so we can later instantiate our controller extension
        ApexPages.StandardController stdController = new ApexPages.StandardController(testContact);

        // Begin
        Test.startTest();

        // Instantiate the controller, which will get the Aggregated Task and Event Details
        EdPlusAggregatedNotesController controller = new EdPlusAggregatedNotesController(stdController);

        // There should be 5 records total
        System.assertEquals(5, controller.dataWrapper.size());

        // Populate our picklist with our possible filter values
        controller.getFilterOptions();

        // Confirm that we have the correct picklist values
        System.assertEquals('Created Date', controller.options[0].getLabel());

        // Set up our filter criteria for 'Created Date'
        controller.filterType = 'Created';
        controller.startDate = Date.today().addDays(-5);
        controller.endDate = Date.today().addDays(1);

        // Execute filtering based on 'Created Date'
        controller.getFilterResults();

        // There should be two tasks displayed after filtering
        System.assertEquals(2, controller.filteredDataWrapper.size());

        // Clear the filters
        controller.clearFilter();

        // Confirm that the filters were cleared
        System.assertEquals('Created', controller.filterType);
        System.assertEquals(null, controller.startDate);
        System.assertEquals(null, controller.endDate);

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
        PageReference pg = Page.EdPlusAggregatedNotes;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', testContactId);

        // Instantiate the standard Contact controller so we can later instantiate our controller extension
        ApexPages.StandardController stdController = new ApexPages.StandardController(testContact);

        // Begin
        Test.startTest();

        // Instantiate the controller, which will get the Aggregated Task and Event Details
        EdPlusAggregatedNotesController controller = new EdPlusAggregatedNotesController(stdController);

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

        // Insert mocked tasks
        List<EdPlusTask__x> mockExternalTasks = new List<EdPlusTask__x>();
        for (Integer i = 0; i < 5; i++) {
            mockExternalTasks.add(
                new EdPlusTask__x(Subject_edpl__c = 'Test Task #' + i, Description_edpl__c = 'Test Task Description')
            );
        }

        // Change dates on records for testing
        mockExternalTasks[0].Created_Date_edpl__c = Date.today().addDays(-5);
        mockExternalTasks[4].Created_Date_edpl__c = Date.today().addDays(-2);

        // Insert the mocked data into our cache
        EdPlusAggregatedNotesControllerMock m = new EdPlusAggregatedNotesControllerMock()
            .setDataStore(mockExternalTasks);

        // Set the mocked data
        ExternalObjectQueryService.setMock(m);
    }
}
