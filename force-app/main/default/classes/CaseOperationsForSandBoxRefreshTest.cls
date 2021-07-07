@isTest
private class CaseOperationsForSandBoxRefreshTest {
    private static final Integer CASE_NUM = 200;

    @isTest
    private static void verifyCasesAreBeingDeleted() {
        CaseFactory.DefaultCase caseCreator = new CaseFactory.DefaultCase();
        SandboxRefreshService.orgType = '.dev';
        List<Case> createdTestCases = caseCreator.create(CASE_NUM);
        for (Case caseToAdd : createdTestCases) {
            caseToAdd.Status = 'New';
            caseToAdd.Priority = 'Medium';
            caseToAdd.Origin = 'Email';
        }

        insert createdTestCases;

        Test.startTest();
        CaseOperationsForSandBoxRefresh caseOperator = new CaseOperationsForSandBoxRefresh();
        DataBase.executeBatch(caseOperator);
        Test.stopTest();

        List<Case> verifyCasesDeleted = [SELECT Id FROM Case];
        System.assertEquals(0, verifyCasesDeleted.size());
    }
}
