@isTest
private class Test_SearchUsers {

    private static SearchUsers su;
    private static User testUser;
    private static Contact testContact;
    
    static testMethod void setUp() {
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
    	
    	PageReference searchUsers = Page.searchUsers;
  		Test.setCurrentPage(searchUsers);
     	su = new SearchUsers();
    }
    
    static testMethod void getUListTest() {
    	setUp();
    	Test.startTest();
     	System.AssertNotEquals(null, su.getUList());
    	Test.stopTest();
    }
    
    static testMethod void searchTest() {
    	setUp();
    	Test.startTest();
    	su.searchString = 'test';
    	su.search();
    	System.AssertNotEquals(null, su.getUList());
    	Test.stopTest();
    }
    
    static testMethod void clearSearchTest() {
    	setUp();
    	Test.startTest();
    	su.clear();
    	System.AssertNotEquals(null, su.getUList());
    	Test.stopTest();
    }
    
    static testMethod void noResultsTest() {
    	setUp();
    	Test.startTest();
    	su.searchString = '!';
    	su.search();
    	System.AssertEquals(true, su.getNoResults());
    	Test.stopTest();	
    }
    
    static testMethod void resultsTest() {
    	setUp();
    	Test.startTest();
    	su.searchString = 'test';
    	su.search();
    	su.getUList();
    	System.AssertEquals(false, su.getNoResults());
    	Test.stopTest();	
    }
}