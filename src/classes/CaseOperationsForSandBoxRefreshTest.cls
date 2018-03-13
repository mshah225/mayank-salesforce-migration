@isTest
private class CaseOperationsForSandBoxRefreshTest {

    private static final Integer CASE_NUM = 200;
    
	private static testMethod void test() {
        
        //Create Case Test Data
        List<Case> lstCase = TestDataFactory.createCases(CASE_NUM);
        for (Case caseToAdd : lstCase) {
            caseToAdd.Status ='New'; 
            caseToAdd.Priority = 'Medium';
            caseToAdd.Origin = 'Email';
        } 
        
        insert lstCase;
    
        Test.startTest();
            CaseOperationsForSandBoxRefresh obj = new CaseOperationsForSandBoxRefresh();
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}