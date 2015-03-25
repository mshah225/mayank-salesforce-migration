@isTest
private class Test_UndergradNewProspectController {
    
    private static Contact contact;
    private static Opportunity opportunity;
    private static Previous_Education__c previousEducation;
    private static CampaignMember camMemInterest;
    private static CampaignMember camMemEvent;
    private static Case c;
    private static UndergradNewProspectController ug;
    private static Campaign testEventCam;
    private static Campaign testIntCam;
    private static Account testAccount;

    private static void setUp() {
        ug = new UndergradNewProspectController();
        contact = new Contact();
        opportunity = new Opportunity();
        previousEducation = new Previous_Education__c();
        camMemInterest = new CampaignMember();
        camMemEvent = new CampaignMember();
        c = new Case();
        testEventCam = new Campaign();
        testIntCam = new Campaign();
        testAccount = new Account();
        
        contact.FirstName = 'Jonny';
        contact.LastName = 'Tester';
        contact.MobilePhone = '923-345-3456';
        contact.MailingStreet = '123 Sky Blvd.';
        contact.MailingCity = 'Tempe';
        contact.MailingPostalCode = '85281';
        ug.setContact(contact);

        testAccount.Name = 'Test School';
        insert testAccount;

        opportunity.AccountId = testAccount.Id;
        opportunity.Name = contact.FirstName + ' ' + contact.LastName;
        opportunity.CloseDate = System.Today() + 365;
        opportunity.Contact__c = contact.Id;
        ug.setOpportunity(opportunity);

        previousEducation.Account__c = testAccount.Id;
        ug.setPreviousEducation(previousEducation);

        ug.setCampaignMemberInterest(camMemInterest);

        ug.setCampaignMemberEvent(camMemEvent);

        ug.setCase(c);

        testEventCam.Name = 'ASU Test Event';
        testEventCam.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id;
        insert testEventCam;

        testIntCam.Name = 'ASU Test Interest';
        insert testIntCam;

        ug.getContact();
        ug.getOpportunity();
        ug.getPreviousEducation();
        ug.getCampaignMemberInterest();
        ug.getCampaignMemberEvent();
        ug.getC();

        List<SelectOption> asuLocationIntList = ug.getASULocationIntList();
        List<SelectOption> academicIntList = ug.getAcademicIntList();
        List<SelectOption> asuCollegesIntList = ug.getASUCollegesIntList();
    } 

    static testMethod void testUndergradControllerSearch() {
        setUp();

    	ug.elId = testEventCam.Id;
        ug.smsText = true;
        ug.eventSearchString = 'test';
        ug.eventSearch();
        ug.getEventList();
        
        ug.instSearch();
        ug.getInstList();
        
        ug.originSelection = '--Select--';
        ug.pickSelection = 'Academic';
        ug.selectedInterestId = testIntCam.Id;
        ug.phoneOrig = testIntCam.Id;

        PageReference s = ug.savePage(); 
        PageReference save = new PageReference('/' + opportunity.Id);
        System.assertNotEquals(save, s);       
    }

    static testMethod void testCampaignEvent() {
        setUp();

        ug.smsText = true;
        ug.originSelection = '--Select--';
        ug.elId = testEventCam.Id;

        PageReference s = ug.savePage(); 
        System.assertEquals(ug.elId, testEventCam.Id);         
    }

    static testMethod void testCaseCreation() {
        setUp();

        c.Functional_Group__c = 'Tech Studio';

        ug.originSelection = 'Email';
        ug.elId = null;
        ug.pickSelection = '--Select--';
        ug.selectedInterestId = null;
        ug.instId = null;
        ug.emailOrig = testEventCam.Id;

        PageReference s = ug.savePage();
        System.assertEquals(c.Status, 'Closed: Resolved');  
    }
}