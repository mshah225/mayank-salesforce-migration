@isTest
private class Test_ServiceCenter {

    private static ServiceCenter sc;
    private static User testUser;
    private static Contact testContact;
    
    private static void setUp() {
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
    	
     	testContact = new Contact();
     	testContact.FirstName = 'Jonny';
     	testContact.LastName = 'Test';
     	insert testContact;
     	
     	testUser = new User();
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
    	
    	PageReference serviceCenter = Page.studentSC;
  		Test.setCurrentPage(serviceCenter);
     	sc = new ServiceCenter();
    }
    
    static testMethod void submitCaseTest() {
    	setUp();
    	Test.startTest();
     	System.runAs(testUser) {
	    	Case c = sc.c;
	     	c.Subject = 'Test case';
	     	c.Description= 'here\'s my test';
	     	sc.c = c;
	     	PageReference confirmCaseTest = sc.SubmitCase();
	     	PageReference confirmCase = new PageReference('/studentSC?Confirm=case');
	     	sc.SubmitCase();
	     	System.AssertEquals(confirmCaseTest.getURL(), confirmCase.getURL());
  		}
    	Test.stopTest();
    }  
    
    static testMethod void testCases() {
    	setUp();
    	Test.startTest();
    	System.runAs(testUser) {
    		Case c = sc.c;
	     	c.Subject = 'Test case';
	     	c.Description= 'here\'s my test';
	     	sc.c = c;
	     	sc.SubmitCase();
    		sc.getMyCases();
    		sc.getClosedCases();
    		sc.getCaseFeed();
    		System.AssertNotEquals(null, sc.getMyCases());
    	}
    	Test.stopTest();
    } 
    
    static testMethod void getBoxes() {
    	setUp();
    	Test.startTest();
    	System.runAs(testUser) {
    		System.AssertEquals(true, sc.getNormalPhone());
    		System.AssertEquals(false, sc.getRoverPhone());
    		System.AssertEquals(true, sc.getHelpBox());
    		System.AssertEquals(false, sc.getQuestionsBox());
    		System.AssertEquals(true, sc.getMyCasesBox());
    	}
    	Test.stopTest();
    }
    
    /*static testMethod void getBoxesACStudent() {
    	setUp();
    	
    	Account testAccount = new Account();
    	testAccount.Name = 'Jonny Test';
    	insert testAccount;
    	
    	Opportunity testOpp = new Opportunity();
     	testOpp.Contact__c = testContact.Id;
     	testOpp.Name = 'Jonny Test';
     	Date dT = Date.today().adddays(365);
    	testOpp.CloseDate = date.newinstance(dT.year(), dT.month(), dT.day());
     	testOpp.AccountId = testContact.AccountId;
     	testOpp.StageName = 'Enrolled';
     	testOpp.Career__c = 'Undergraduate';
     	testOpp.Admitted_Session__c = 'A/C';
     	insert testOpp;
     	
     	Test.startTest();
     	System.runAs(testUser) {
    		System.AssertEquals(true, sc.getNormalPhone());
    		System.AssertEquals(false, sc.getRoverPhone());
    		System.AssertEquals(false, sc.getHelpBox());
    		System.AssertEquals(true, sc.getQuestionsBox());
    		System.AssertEquals(false, sc.getMyCasesBox());
    	}
    	Test.stopTest();
    }
  
    static testMethod void removeParamTest() {
    	setUp();
    	Test.startTest();
    	System.runAs(testUser) {
			PageReference confirmRemoveParamTest = sc.removeParam();
	     	PageReference confirmRemoveParam = new PageReference('/studentSC');
	     	System.AssertEquals(confirmRemoveParamTest.getURL(), confirmRemoveParam.getURL());	
    	}
    	Test.stopTest();
    }*/
    
    static testMethod void testCaseDetails() {
    	setUp();
    	Test.startTest();
    	System.runAs(testUser) {
			Case c = sc.c;
	     	c.Subject = 'Test case';
	     	c.Description= 'here\'s my test';
	     	sc.c = c;
	     	sc.SubmitCase();
			System.currentPageReference().getParameters().put('id', c.Id);
			System.AssertNotEquals(null, sc.getCaseDetails());
    	}
    	Test.stopTest();
    } 
     
    /*static testMethod void viewCaseTest() {
    	setUp();
    	Test.startTest();
    	System.runAs(testUser) {
	    
	     	
			System.currentPageReference().getParameters().put('id', c.Id);
			PageReference confirmViewCaseTest = sc.viewCase();
	     	PageReference confirmViewCase = new PageReference('/viewcase?id=' + c.Id);
	     	System.AssertEquals(confirmViewCaseTest.getURL(), confirmViewCase.getURL());	
    	}
    	Test.stopTest();
    }*/
}