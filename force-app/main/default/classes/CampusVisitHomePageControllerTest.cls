@isTest
public with sharing class CampusVisitHomePageControllerTest {

    @isTest
    private static void testGetCampaignMember() {
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        Contact c = new Contact(FirstName = 'John', LastName = 'Jones');
        insert c;

        
        Account acc = new Account(Name = 'Arizona State University', Type = 'HS');
        insert acc;

        Program__c testProgram = new Program__c(Name = 'Test Program', Program_Code__c = 'TPRG');
        insert testProgram;

        Opportunity testOppo = new Opportunity(
            Contact__c = c.Id,
            Career__c = 'Undergraduate',
            AccountId = acc.Id,
            Name = 'TestOppo',
            StageName = 'TestOppo',
            CloseDate = Date.newInstance(2023, 9, 12),
            College__c = testProgram.Id
        );
        insert testOppo;


        CampaignMember cm = new CampaignMember(ContactId = c.Id, Opportunity__c = testOppo.Id, CampaignId = testCampaign.Id, Status = 'Sent');
        insert cm;

        List<CampaignMember> pageResult = CampusVisitHomePageController.getCampaignMembers(testCampaign.Id, new List<String>{'Sent'});

        System.assertEquals(1, pageResult.size());        

        pageResult = CampusVisitHomePageController.searchCampaignMembers('John', new List<String>{'Sent'}, testCampaign.Id);

        System.assertEquals(1, pageResult.size());   

        pageResult = CampusVisitHomePageController.searchCampaignMembers('Doug', new List<String>{'Sent'}, testCampaign.Id);

        System.assertEquals(0, pageResult.size());   
    }
}