@isTest
public with sharing class CampusVisitWalkInFormControllerTest {
    @isTest
    private static void testGetCampaign() {
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        Campaign pageResultCampaign = CampusVisitWalkInFormController.searchCampaign(testCampaign.Id);

        System.assertEquals('Test Campaign', pageResultCampaign.Name);
        
    }

    @isTest
    private static void testGetContacts() {
        Contact c = new Contact(FirstName = 'John', LastName = 'Jones', ASURite_ID__c = 'jjones', Phone = '4801112222', MailingPostalCode = '85000');
        insert c;

        Contact searchContact = new Contact(ASURite_ID__c = 'jjones');

        List<Contact> pageResultContacts = CampusVisitWalkInFormController.searchContact(searchContact);

        System.assertEquals(1, pageResultContacts.size());

        searchContact = new Contact(FirstName = 'John', LastName = 'Jones');

        pageResultContacts = CampusVisitWalkInFormController.searchContact(searchContact);

        System.assertEquals(1, pageResultContacts.size());

        searchContact = new Contact(FirstName = 'John', LastName = 'Jones', Phone = '4802223333');

        pageResultContacts = CampusVisitWalkInFormController.searchContact(searchContact);

        System.assertEquals(null, pageResultContacts);
        
    }

    @isTest
    private static void testCreateRecords() {
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        Term__c testTerm = TermService.createTestTerm();
        insert testTerm;

        Account acc = new Account(Name = 'Arizona State University', Type = 'HS');
        insert acc;  
        
        Program__c testProgram = new Program__c(Name = 'Test Program', Program_Code__c = 'TPRG');
        insert testProgram;

        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Jones', AccountId = acc.Id);

        Opportunity testOppo = new Opportunity(
            Career__c = 'Undergraduate',
            College__c = testProgram.Id
        );

        CampaignMember testCampaignMember = new CampaignMember(Status = 'Sent', CampaignId = testCampaign.Id);

        String pageResult = CampusVisitWalkInFormController.submitRecordsForWalkin(testContact, testCampaignMember, testOppo);

        System.assertEquals(null, pageResult);

    }
}