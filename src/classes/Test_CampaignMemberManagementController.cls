@isTest
private class Test_CampaignMemberManagementController {

    private static ApexPages.standardController std;
    private static CampaignMemberManagementController cm;
    
    static void setUp() { 
    	//Set up contact
    	Contact testContact = new Contact();
        testContact.FirstName = 'Jonny';
        testContact.LastName = 'Test';
        insert testContact;        
		Test.setCurrentPage(Page.CampaignMemberManagement);
		System.currentPageReference().getParameters().put('Id', testContact.Id);
		std = new ApexPages.standardController(testContact);
		cm = new CampaignMemberManagementController(std);
    }
    
    static testMethod void Test_CampaignMemberMangementController() {
        //CampaignMemberManagementController cm = new CampaignMemberManagementController();
        setUp();
        Test.startTest();
        Campaign interest = new Campaign();
        interest.Name = 'Test campaign';
        insert interest;
        cm.intId = interest.Id;
		cm.getContId();
		cm.iSearchString = 'Test';
		cm.eSearchString= 'Test';
		cm.doInterestSearch();
		cm.doEventSearch();
		cm.getEventSearchResults();
		cm.getInterestSearchResults();
		cm.AddInterest();
		CampaignMember camMemInterest = cm.getCampaignMemberInterest();
		cm.setCampaignMemberInterest(camMemInterest);
        List<CampaignMember> eventList = cm.getEventList();
	    List<CampaignMember> interestList = cm.getInterestList();
	    List<CampaignMember> scholarList = cm.getScholarList();
	    List<CampaignMember> cohortList = cm.getCohortList();
	    List<CampaignMember> oSourceList = cm.getOSourceList();
	    List<CampaignMember> markCommList = cm.getMarkCommList();
	    PageReference expected = new PageReference('/00v/e?c_id=' + cm.elId + '&parent_id=' + cm.contId + '&retURL=%2F' + cm.contId);
	    PageReference result = cm.AddToEvent();
	    System.AssertEquals(expected.getURL(), result.getURL());
	    System.AssertNotEquals(null, eventList);
	    Test.stopTest();
    }
}