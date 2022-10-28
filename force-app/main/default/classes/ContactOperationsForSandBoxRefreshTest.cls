@isTest
private class ContactOperationsForSandBoxRefreshTest {
    private static final Integer CONTACT_NUM = 100;

    @testSetup
    private static void setup() {
        ContactFactory.AllEmailsFilled contactCreator = new ContactFactory.AllEmailsFilled();
        List<Contact> contactsCreatedForTest = contactCreator.create(CONTACT_NUM);

        insert contactsCreatedForTest;
    }

    @isTest
    private static void contactRefreshUAT() {
        Test.startTest();
        ContactOperationsForSandBoxRefresh contactOperator = new ContactOperationsForSandBoxRefresh();
        SandboxRefreshService.orgType = '.uat';
        DataBase.executeBatch(contactOperator);
        Test.stopTest();
        List<Contact> allContacts = [SELECT Email FROM Contact];
        System.assertEquals(CONTACT_NUM, returnCountOfMatchesInString(allContacts, '.uat'));
    }

    @isTest
    private static void contactRefreshQA() {
        Test.startTest();
        ContactOperationsForSandBoxRefresh contactOperator = new ContactOperationsForSandBoxRefresh();
        SandboxRefreshService.orgType = '.qa';
        DataBase.executeBatch(contactOperator);
        Test.stopTest();
        List<Contact> allContacts = [SELECT Email FROM Contact];
        System.assertEquals(CONTACT_NUM, returnCountOfMatchesInString(allContacts, '.qa'));
    }

    @isTest
    private static void contactRefreshDEV() {
        Test.startTest();
        ContactOperationsForSandBoxRefresh contactOperator = new ContactOperationsForSandBoxRefresh();
        SandboxRefreshService.orgType = '.dev';
        DataBase.executeBatch(contactOperator);
        Test.stopTest();
        List<Contact> allContacts = [SELECT Email FROM Contact];
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