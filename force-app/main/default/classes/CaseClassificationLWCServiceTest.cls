@IsTest
private class CaseClassificationLWCServiceTest{

    @testSetup 
    static void setup() {
        CaseClassificationFactory ccFactory = new CaseClassificationFactory();
        List<Case_Classification__c> classifications = ccFactory.createAndInsertSetOfCaseClassification();
        classifications[0].Name = 'Initial Test Functional Group';
        classifications[1].Name = 'Initial Test Category';
        classifications[2].Name = 'Initial Test Sub Category';

        update classifications;

	}
    
    @IsTest
    private static void testGetActiveClassifications() {
        List<Case_Classification__c> classifications;

        Test.startTest();
            classifications  = CaseClassificationLWCService.getClassifications();
        Test.stopTest();

        System.assertEquals('Initial Test Functional Group', classifications[0].Name);
        System.assertEquals(classifications[0].Id, classifications[1].Parent__c);
    }
}