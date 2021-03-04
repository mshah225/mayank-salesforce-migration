@isTest
public class Test_CommunicationHistoryController {
    public static testMethod void CommunicationHistoryControllerTest() {
        // Create a test Contact
        Contact testContact = new Contact(FirstName = 'Donald', LastName = 'Trump');

        // Insert the Contact
        insert testContact;

        // Query the Contact we just inserted so that we can get its ID
        testContact = [SELECT Id FROM Contact WHERE FirstName = 'Donald' AND LastName = 'Trump' LIMIT 1];
        Id testContactId = testContact.Id;

        // Populate the details of several mock Marketing Cloud Emails and their corresponding junction objects
        List<Campaign> testCampaigns = new List<Campaign>();
        List<et4ae5__IndividualEmailResult__c> testIndividualEmailResults = new List<et4ae5__IndividualEmailResult__c>();
        List<et4ae5__SendDefinition__c> testSendDefinitions = new List<et4ae5__SendDefinition__c>();
        List<et4ae5__SendJunction__c> testSendJunctions = new List<et4ae5__SendJunction__c>();

        for (Integer i = 0; i < 5; i++) {
            testCampaigns.add(new Campaign(Name = 'Test Campaign ' + i));
        }

        // Insert the test Campaigns and query for their IDs
        insert testCampaigns;
        testCampaigns = [SELECT Id FROM Campaign];

        for (Integer i = 0; i < 5; i++) {
            testSendDefinitions.add(new et4ae5__SendDefinition__c(et4ae5__Contact__c = testContactId));
        }

        // Insert the test Send Definitions and query for their IDs
        insert testSendDefinitions;
        testSendDefinitions = [SELECT Id FROM et4ae5__SendDefinition__c];

        for (Integer i = 0; i < 5; i++) {
            testIndividualEmailResults.add(
                new et4ae5__IndividualEmailResult__c(
                    et4ae5__FromAddress__c = 'dtrump@cantstump.com',
                    et4ae5__SoftBounce__c = false,
                    et4ae5__HardBounce__c = false,
                    et4ae5__DateSent__c = Date.today().addDays(i - 5),
                    et4ae5__DateOpened__c = Date.today().addDays(i - 2),
                    et4ae5__NumberOfUniqueClicks__c = i + 2,
                    et4ae5__Contact__c = testContactId,
                    et4ae5__SendDefinition__c = testSendDefinitions[i].Id
                )
            );
        }

        for (Integer i = 0; i < 5; i++) {
            testSendJunctions.add(
                new et4ae5__SendJunction__c(
                    et4ae5__SendDefinition__c = testSendDefinitions[i].Id,
                    et4ae5__Campaign__c = testCampaigns[i].Id
                )
            );
        }

        // Scramble the data (for the purpose of testing our filters)
        testIndividualEmailResults[1].et4ae5__DateSent__c = Date.today().addDays(-9);
        testIndividualEmailResults[1].et4ae5__DateOpened__c = Date.today().addDays(-7);
        testIndividualEmailResults[1].et4ae5__SoftBounce__c = true;

        testIndividualEmailResults[3].et4ae5__DateSent__c = Date.today().addDays(-2);
        testIndividualEmailResults[3].et4ae5__DateOpened__c = Date.today().addDays(-1);
        testIndividualEmailResults[3].et4ae5__HardBounce__c = true;

        // Insert the remaining test data
        insert testIndividualEmailResults;
        insert testSendJunctions;

        System.debug('Campaigns: ' + testCampaigns);
        System.debug('Send Definitions: ' + testSendDefinitions);
        System.debug('IERs: ' + testIndividualEmailResults);
        System.debug('Send Junctions: ' + testSendJunctions);

        // Set the necessary parameters on the page
        PageReference pg = Page.CommunicationHistory;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', testContactId);

        // Instantiate the standard Contact controller so we can later instantiate our controller extension
        ApexPages.StandardController stdController = new ApexPages.StandardController(testContact);

        Test.startTest();
        // Instantiate the controller, which will get the MC Communication History
        CommunicationHistoryController controller = new CommunicationHistoryController(stdController);

        // Set up our filter criteria for 'Date Sent'
        controller.filterType = 'Sent';
        controller.startDate = Date.today().addDays(-5);
        controller.endDate = Date.today().addDays(1);

        // There should be five emails total
        System.assertEquals(5, controller.messages.size());

        // Populate our picklist with our possible filter values
        controller.getFilterOptions();

        // Confirm that we have the correct picklist values
        System.assertEquals('Date Sent', controller.options[0].getLabel());
        System.assertEquals('Date Opened', controller.options[1].getLabel());

        // Execute filtering based on 'Date Sent'
        controller.getFilterResults();

        // There should be three emails displayed after filtering
        System.assertEquals(3, controller.filteredMessages.size());

        // Set up filter criteria for 'Date Opened'
        controller.filterType = 'Opened';
        controller.startDate = Date.today().addDays(-3);
        controller.endDate = Date.today().addDays(0);

        // Execute filtering based on 'Date Opened'
        controller.getFilterResults();

        // There should be three emails displayed after filtering
        System.assertEquals(3, controller.filteredMessages.size());

        // Clear the filters
        controller.clearFilter();

        // Confirm that the filters were cleared
        System.assertEquals('Sent', controller.filterType);
        System.assertEquals(null, controller.startDate);
        System.assertEquals(null, controller.endDate);
        System.assertEquals(controller.messages.size(), controller.filteredMessages.size());

        Test.stopTest();
    }
}
