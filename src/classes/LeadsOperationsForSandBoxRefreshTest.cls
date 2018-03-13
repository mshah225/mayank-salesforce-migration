@isTest
private class LeadsOperationsForSandBoxRefreshTest {

    private static final Integer LEAD_NUM = 11;
    
    @testSetup
    private static void setup() {
        LeadFactory.DefaultLead leadCreator = new LeadFactory.DefaultLead();
        List<Lead> leadsCreatedForTest = leadCreator.create(LEAD_NUM);
        Integer variableNameIterator = 0;
        for (Lead leadToInsert : leadsCreatedForTest) {
            leadToInsert.Email = 'test' + variableNameIterator + '@test.com';
            leadToInsert.Recruiting_Email__c = 'test' + variableNameIterator + '@test.com';
            leadToInsert.Secondary_Email__c = 'test' + variableNameIterator + '@test.com';
            leadToInsert.Date_of_Birth__c = System.today();
            leadToInsert.LastName = 'Test' + variableNameIterator;
            leadToInsert.Company = 'Test Pvt Ltd ' + variableNameIterator;
            variableNameIterator++;
        }
		leadsCreatedForTest[0].Status = 'Closed - Converted';
        
        insert leadsCreatedForTest; 
    }
    
    @isTest
    private static void leadOperationsForUAT() {
        LeadsOperationsForSandBoxRefresh leadOperator = new LeadsOperationsForSandBoxRefresh();
        leadOperator.baseUrl = 'https://asu--roger.UAT.cs53.my.salesforce.com';
        Test.startTest();
            DataBase.executeBatch(leadOperator);
        Test.stopTest();
        List<Lead> allScrambledLeads = [Select Email FROM Lead];
        System.assertEquals(LEAD_NUM - 1, returnCountOfMatchesInString(allScrambledLeads, '.uat'));
    }
    
    @isTest
    private static void leadOperationsForQA() {
        
        LeadsOperationsForSandBoxRefresh leadOperator = new LeadsOperationsForSandBoxRefresh();
        leadOperator.baseUrl = 'https://asu--roger.QA.cs53.my.salesforce.com';
        Test.startTest();
            DataBase.executeBatch(leadOperator);
        Test.stopTest();
        List<Lead> allScrambledLeads = [Select Email FROM Lead];
        System.assertEquals(LEAD_NUM - 1, returnCountOfMatchesInString(allScrambledLeads, '.qa'));
    }
    
    @isTest
    private static void leadOperationsForDEV() {
        
        LeadsOperationsForSandBoxRefresh leadOperator = new LeadsOperationsForSandBoxRefresh();
        leadOperator.baseUrl = 'https://asu--roger.DEV.cs53.my.salesforce.com';
        Test.startTest();
            DataBase.executeBatch(leadOperator);
        Test.stopTest();
        List<Lead> allScrambledLeads = [Select Email FROM Lead];
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