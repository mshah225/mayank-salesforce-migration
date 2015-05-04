@isTest
private class Test_AutoCompleteController 
{
    private static Contact testContact;
    private static User testUser;
    private static Profile p;
    private static Term__c termAC;
    private static Term__c termB;
    private static ServiceCenter sc;
    private static AKBController akb;
    
    private static void setUp() 
    {
        p = [SELECT Id FROM Profile WHERE Name='ASU Community'];

        termAC = new Term__c();
    	Date dT = Date.today().adddays(30);
    	termAC.Session_A_C_Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
    	termAC.Year__c = '2015';
    	insert termAC;
    	
        termB = new Term__c();
        dT = Date.today().adddays(40);
    	termB.Session_B_Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
    	termB.Year__c = '2015';
    	insert termB;
    	
     	testContact = ContactService.createTestContact();
     	insert testContact;
     	
     	testUser = new User();
    	testUser.FirstName = 'Jonny';
    	testUser.LastName = 'Test';
    	testUser.Username = 'username@test.com';
    	testUser.Email = 'test@nomail.com';
    	testUser.Alias = testContact.ASURite_ID__c;
    	testUser.CommunityNickname = 'jontestComm';
    	testUser.TimeZoneSidKey = 'America/Phoenix';
    	testUser.LocaleSidKey = 'en_US';
    	testUser.EmailEncodingKey = 'ISO-8859-1';
    	testUser.LanguageLocaleKey = 'en_US';
    	testUser.ProfileId = p.Id;
    	testuser.ContactId = testContact.Id;
    	insert testUser;

        FAQ__kav faqArticle = new FAQ__kav(
            Title = 'testFAQ',
            Summary = 'test from apex',
            Answer__c = 'test',
            Question__c = 'test',
            Language = 'en_US',
            IsVisibleInPKB = true,
            IsVisibleInCsp = true,
            IsVisibleInPrm = true,
            URLName = 'test-FAQ');
        insert faqArticle;

        faqArticle = [SELECT KnowledgeArticleId
                      FROM FAQ__kav
                      WHERE Id = :faqArticle.id];
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
    }
    
    @isTest static void testSearchArticle() 
    {
        setUp();
        Test.startTest();
        System.runAs(testUser)
        {
            sc = new ServiceCenter();
            AutoCompleteController acc = new AutoCompleteController(sc);
            akb = new AKBController();
            AutoCompleteController acc2 = new AutoCompleteController(akb);
            ApexPages.StandardController standard = new ApexPages.StandardController(testContact);
            AutoCompleteController acc3 = new AutoCompleteController(standard);
    		List<KnowledgeArticleVersion> result = AutoCompleteController.searchArticle('test');
    		System.AssertNotEquals(null, result);
        }
		Test.stopTest();
	}
}