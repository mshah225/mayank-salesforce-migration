@isTest(seeAllData = true)
private class Test_AutoCompleteController {

    private static ServiceCenter sc;
    private static AKBController akb;
    
    private static void setUp() {

    	/*
    	* Setup the ServiceCenter
    	*/
    	Term__c termAC = new Term__c();
    	Date dT = Date.today().adddays(30);
    	termAC.Session_A_C_Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
    	termAC.Year__c = '2015';
    	insert termAC;
    	
        Term__c termB = new Term__c();
        dT = Date.today().adddays(40);
    	termB.Session_B_Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
    	termB.Year__c = '2015';
    	insert termB;
    	
     	Contact testContact = new Contact();
     	testContact.FirstName = 'Jonny';
     	testContact.LastName = 'Test';
     	insert testContact;
     	
     	User testUser = new User();
    	testUser.FirstName = 'Jonny';
    	testUser.LastName = 'Test';
    	testUser.Username = 'username@test.com';
    	testUser.Email = 'test@nomail.com';
    	testUser.Alias = 'jontest';
    	testUser.CommunityNickname = 'jontestComm';
    	testUser.TimeZoneSidKey = 'America/Phoenix';
    	testUser.LocaleSidKey = 'en_US';
    	testUser.EmailEncodingKey = 'ISO-8859-1';
    	testUser.LanguageLocaleKey = 'en_US';
    	testUser.ProfileId = '00ed00000019z5nAAA';
    	testuser.ContactId = testContact.Id;
    	insert testUser;
    	
     	sc = new ServiceCenter();
     	
     	List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' LIMIT 1];
    	PageReference akbPage = Page.akb;
  		Test.setCurrentPage(akbPage);
    	ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
    	akb = new AKBController();
    }
    
    private testMethod static void testSearchArticle() {
    	AutoCompleteController acc = new AutoCompleteController(sc);
    	Contact con = new Contact();
    	ApexPages.StandardController standard = new ApexPages.StandardController(con);
    	acc = new AutoCompleteController(standard);
    	setUp();
		Test.startTest();
		List<KnowledgeArticleVersion> result = AutoCompleteController.searchArticle('test');
		System.AssertNotEquals(null, result);
		Test.stopTest();
	}
}