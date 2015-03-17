@isTest
private class Test_CampaignMemberManagementController {

    private static ApexPages.standardController std;
    private static CampaignMemberManagementController cm;
    private static Contact testContact;
    private static Campaign interest;
    private static Campaign event;
    
    static void setUp() { 
    	testContact = new Contact();
        testContact.FirstName = 'Jonny';
        testContact.LastName = 'Test';
        insert testContact;        

        interest = new Campaign();
        interest.Name = 'Test interest';
        insert interest;

        event = new Campaign();
        event.Name = 'Test event';
        insert event;

		Test.setCurrentPage(Page.CampaignMemberManagement);
		System.currentPageReference().getParameters().put('Id', testContact.Id);
		std = new ApexPages.standardController(testContact);
		cm = new CampaignMemberManagementController(std);
    }
    
    static testMethod void Test_CampaignMemberMangementController() {
        setUp();        
        cm.intId = interest.Id;
        cm.elId = event.Id;
		cm.getContId();
		cm.iSearchString = 'Test';
		cm.eSearchString= 'Test';
		cm.doInterestSearch();
		cm.doEventSearch();
		cm.getEventSearchResults();
		cm.getInterestSearchResults();
		CampaignMember camMemEvent = cm.getCampaignMemberEvent();
		cm.setCampaignMemberEvent(camMemEvent);
		CampaignMember camMemInterest = cm.getCampaignMemberInterest();
		cm.setCampaignMemberInterest(camMemInterest);

		cm.camMemEvent.CampaignId = interest.Id;
		cm.camMemEvent.ContactId = testContact.Id;
		cm.AddInterest();

		cm.camMemEvent.CampaignId = event.Id;
		cm.camMemEvent.ContactId = testContact.Id;
		cm.AddToEvent();

        List<CampaignMember> eventList = cm.getEventList();
	    List<CampaignMember> interestList = cm.getInterestList();
	    List<CampaignMember> scholarList = cm.getScholarList();
	    List<CampaignMember> cohortList = cm.getCohortList();
	    List<CampaignMember> oSourceList = cm.getOSourceList();
	    List<CampaignMember> markCommList = cm.getMarkCommList();

	    Test.startTest();
	    CampaignMember checkEventTestContact = [SELECT Id, ContactId, CampaignId FROM CampaignMember WHERE ContactId = :testContact.Id AND CampaignId = :event.Id];
	    CampaignMember checkIntTestContact = [SELECT Id, ContactId, CampaignId FROM CampaignMember WHERE ContactId = :testContact.Id AND CampaignId = :interest.Id];
	    System.AssertEquals(checkEventTestContact.ContactId, testContact.Id);
	    System.AssertEquals(checkIntTestContact.ContactId, testContact.Id);
	    Test.stopTest();
    }
}