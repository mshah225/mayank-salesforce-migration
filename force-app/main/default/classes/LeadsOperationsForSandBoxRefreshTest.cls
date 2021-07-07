@isTest
private class LeadsOperationsForSandBoxRefreshTest {
    private static final Integer LEAD_NUM = 11;

    @testSetup
    private static void setup() {
        LeadFactory.AllEmailAndBirthdayLead leadCreator = new LeadFactory.AllEmailAndBirthdayLead();
        List<Lead> leadsCreatedForTest = leadCreator.create(LEAD_NUM);
        leadsCreatedForTest[0].Status = 'Closed - Converted';

        insert leadsCreatedForTest;
    }

    @isTest
    private static void leadOperationsForUAT() {
        LeadsOperationsForSandBoxRefresh leadOperator = new LeadsOperationsForSandBoxRefresh();
        SandboxRefreshService.orgType = '.uat';
        Test.startTest();
        DataBase.executeBatch(leadOperator);
        Test.stopTest();
        List<Lead> allScrambledLeads = [SELECT Email FROM Lead];
        System.assertEquals(LEAD_NUM - 1, returnCountOfMatchesInString(allScrambledLeads, '.uat'));
    }

    @isTest
    private static void leadOperationsForQA() {
        LeadsOperationsForSandBoxRefresh leadOperator = new LeadsOperationsForSandBoxRefresh();
        SandboxRefreshService.orgType = '.qa';
        Test.startTest();
        DataBase.executeBatch(leadOperator);
        Test.stopTest();
        List<Lead> allScrambledLeads = [SELECT Email FROM Lead];
        System.assertEquals(LEAD_NUM - 1, returnCountOfMatchesInString(allScrambledLeads, '.qa'));
    }

    @isTest
    private static void leadOperationsForDEV() {
        LeadsOperationsForSandBoxRefresh leadOperator = new LeadsOperationsForSandBoxRefresh();
        SandboxRefreshService.orgType = '.dev';
        Test.startTest();
        DataBase.executeBatch(leadOperator);
        Test.stopTest();
        List<Lead> allScrambledLeads = [SELECT Email FROM Lead];
        System.debug(allScrambledLeads);
        System.assertEquals(LEAD_NUM - 1, returnCountOfMatchesInString(allScrambledLeads, '.dev'));
    }

    private static Integer returnCountOfMatchesInString(List<Lead> leadsWithModifiedEmails, String wordToSearch) {
        Integer countOfMatches = 0;
        for (Lead leadToSearch : leadsWithModifiedEmails) {
            System.debug(leadToSearch.email);
            if (leadToSearch.Email.contains(wordToSearch)) {
                countOfMatches++;
            }
        }
        return countOfMatches;
    }
}
