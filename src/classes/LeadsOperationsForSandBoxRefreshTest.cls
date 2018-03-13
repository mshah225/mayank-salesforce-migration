@isTest
private class LeadsOperationsForSandBoxRefreshTest {

    private static final Integer LEAD_NUM = 10;
    
	private static testMethod void test() {
        
        //Create Lead Test Data
        List<Lead> lstLead = TestDataFactory.createLeads(LEAD_NUM);
        for (Integer i = 0; i < LEAD_NUM; i++) {
            if (Math.mod(i, 2) == 0) {
                lstLead[i].Status = 'Closed - Converted';
            } else {
                lstLead[i].Status = 'Closed - Converted';
            }
            lstLead[i].Email = 'test' + i + '@test.com';
            lstLead[i].Recruiting_Email__c = 'test' + i + '@test.com';
            lstLead[i].Secondary_Email__c = 'test' + i + '@test.com';
            lstLead[i].Date_of_Birth__c = System.today();
            lstLead[i].LastName = 'Test' + i;
            lstLead[i].Company = 'Test Pvt Ltd';
        }
        
        insert lstLead;
        
        Test.startTest();
            LeadsOperationsForSandBoxRefresh obj = new LeadsOperationsForSandBoxRefresh();
            obj.baseUrl = 'https://asu--roger.UAT.cs53.my.salesforce.com';
            DataBase.executeBatch(obj);
            obj.baseUrl = 'https://asu--roger.QA.cs53.my.salesforce.com';
            DataBase.executeBatch(obj);
            obj.baseUrl = 'https://asu--roger.DEV.cs53.my.salesforce.com';
            DataBase.executeBatch(obj);
        Test.stopTest();
    }
}