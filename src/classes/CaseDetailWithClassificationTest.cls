@IsTest
private class CaseDetailWithClassificationTest {
    
    @testSetup 
    static void setup() {
		CaseClassificationFactory ccCreator = new CaseClassificationFactory();
        List<Case_Classification__c> listOfCreatedCaseClassifications = ccCreator.createAndInsertSetOfCaseClassification();
        
        CaseFactory.DefaultCaseWithStatus caseCreator = new CaseFactory.DefaultCaseWithStatus();
        Case caseToUpdate = (Case)caseCreator.create(1)[0];
        caseToUpdate.CC_Functional_Group__c = listOfCreatedCaseClassifications[0].Id;
        insert caseToUpdate;
	}	
    
    @IsTest
    private static void caseUpdate() {
        Test.setMock(HttpCalloutMock.class, new CaseStatusHttpMockCallout());
        Case createdCase = [SELECT Id, Status FROM Case LIMIT 1];
        List<Case_Classification__c> listOfCreatedCaseClassifications = [SELECT Id FROM Case_Classification__c];
		ApexPages.currentPage().getParameters().put('id', createdCase.Id);

                
        Test.startTest();
        ApexPages.StandardController caseController = new ApexPages.StandardController(createdCase);
        CaseDetailWithClassificationController cdwcc = new CaseDetailWithClassificationController(caseController);
        cdwcc.selectedStatus = 'Open';
        cdwcc.saveCase();
        Test.stopTest();
        
        createdCase = [
            SELECT Id, Status
            FROM Case 
            LIMIT 1
        ];
        
        System.assertEquals('Open', cdwcc.selectedStatus);
    }
}