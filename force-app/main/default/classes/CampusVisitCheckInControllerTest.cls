@isTest
public class CampusVisitCheckInControllerTest {

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


        CampaignMember cm = new CampaignMember(ContactId = c.Id, Opportunity__c = testOppo.Id, CampaignId = testCampaign.Id);
        insert cm;

        CampaignMember pageResult = CampusVisitCheckInController.getCampaignMember(cm.Id);

        System.assertEquals('John Jones', pageResult.Name);

        System.assertEquals('Test Program', pageResult.Opportunity__r.College__r.Name);
        
    }

    @isTest
    private static void testGetOtherEvents() {
        Campaign testCampaign = new Campaign(Name = 'Test Campaign', Event_Start_Date__c  = Date.today());
        insert testCampaign;

        Campaign testCampaignTwo = new Campaign(Name = 'Test Campaign Two', Event_Start_Date__c  = Date.today());
        insert testCampaignTwo;

        Contact c = new Contact(FirstName = 'John', LastName = 'Jones');
        insert c;
        
        Account acc = new Account(Name = 'Arizona State University', Type = 'HS');
        insert acc;

        Opportunity testOppo = new Opportunity(
            Contact__c = c.Id,
            Career__c = 'Undergraduate',
            AccountId = acc.Id,
            Name = 'TestOppo',
            StageName = 'TestOppo',
            CloseDate = Date.newInstance(2023, 9, 12)
        );
        insert testOppo;

        CampaignMember cmOne = new CampaignMember(ContactId = c.Id, Opportunity__c = testOppo.Id, CampaignId = testCampaign.Id);
        insert cmOne;

        CampaignMember cmTwo = new CampaignMember(ContactId = c.Id, Opportunity__c = testOppo.Id, CampaignId = testCampaignTwo.Id);
        insert cmTwo;

        List<CampusVisitCheckInController.EventWrapper> pageResult = CampusVisitCheckInController.getOtherEvents(c.Id, cmOne.Id, Date.today());

        System.assertEquals(1, pageResult.size());

        
    }
}