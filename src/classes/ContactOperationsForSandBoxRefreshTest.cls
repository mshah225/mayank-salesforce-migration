@isTest
private class ContactOperationsForSandBoxRefreshTest {

    private static final Integer ACCOUNT_NUM = 1;
    private static final Integer CONTACT_NUM = 100;
    
    @testSetup
    private static void setup() {
        AccountFactory.DefaultAccount accountCreator = new AccountFactory.DefaultAccount();
        List<Account> accountToLinkToContact = accountCreator.create(ACCOUNT_NUM);
        insert accountToLinkToContact;
        Id accountIdForContact = accountToLinkToContact[0].id;
        
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        List<Contact> contactsCreatedForTest = contactCreator.create(CONTACT_NUM);
        for (Contact contactToCustomize : contactsCreatedForTest) {
            contactToCustomize.AccountId = accountIdForContact;
            contactToCustomize.LastName = 'Test';
            contactToCustomize.Corporate_Relations_Email__c = 'Test@Test.com';
            contactToCustomize.EPO_Email__c = 'Test@Test.com';
            contactToCustomize.ASU_Email__c = 'Test@Test.com';
            contactToCustomize.Last_Case_Email_Used__c = 'Test@Test.com';
            contactToCustomize.Lead_Email__c = 'Test@Test.com';
            contactToCustomize.Lead_Secondary_Email__c = 'Test@Test.com';
            contactToCustomize.Parent_Email__c = 'Test@Test.com';
            contactToCustomize.Personal_Email__c = 'Test@Test.com';
            contactToCustomize.Birthdate = system.today();
        } 
        
        insert contactsCreatedForTest;
    }
    
    @isTest
	private static void contactRefreshUAT() {
        Test.startTest();
            ContactOperationsForSandBoxRefresh contactOperator = new ContactOperationsForSandBoxRefresh();
            contactOperator.baseUrl = 'https://asu--roger.UAT.cs53.my.salesforce.com';
            DataBase.executeBatch(contactOperator);
        Test.stopTest();
        List<Contact> allContacts = [Select Email FROM Contact];
        System.assertEquals(CONTACT_NUM, returnCountOfMatchesInString(allContacts, '.uat'));
    }
    
    @isTest
	private static void contactRefreshQA() {
        Test.startTest();
            ContactOperationsForSandBoxRefresh contactOperator = new ContactOperationsForSandBoxRefresh();
            contactOperator.baseUrl = 'https://asu--roger.QA.cs53.my.salesforce.com';
            DataBase.executeBatch(contactOperator);
        Test.stopTest();
        List<Contact> allContacts = [Select Email FROM Contact];
        System.assertEquals(CONTACT_NUM, returnCountOfMatchesInString(allContacts, '.qa'));
    }
    
    @isTest
	private static void contactRefreshDEV() {
        Test.startTest();
            ContactOperationsForSandBoxRefresh contactOperator = new ContactOperationsForSandBoxRefresh();
            contactOperator.baseUrl = 'https://asu--roger.DEV.cs53.my.salesforce.com';
            DataBase.executeBatch(contactOperator);
        Test.stopTest();
        List<Contact> allContacts = [Select Email FROM Contact];
        System.assertEquals(CONTACT_NUM, returnCountOfMatchesInString(allContacts, '.dev'));
    }
    
    private static Integer returnCountOfMatchesInString(List<Contact> contactsWithModifiedEmails, String wordToSearch) {
        Integer countOfMatches = 0;
        for (Contact contactToSearch : contactsWithModifiedEmails) {
            if (contactToSearch.Email.contains(wordToSearch)) {
                countOfMatches++;
            }
        }
        return countOfMatches;
    }
}