@isTest
private class CaseClassificationPicklistTest {
    private static CaseClassificationPicklistService picklistService;

    @testSetup
    private static void setUpTest() {
        CaseClassificationFactory ccMaker = new CaseClassificationFactory();
        ccMaker.createAndInsertSetOfCaseClassification();
    }

    @isTest
    private static void testInitialSetUp() {
        picklistService = new CaseClassificationPicklistService();

        System.assertEquals(2, picklistService.functionalGroupOptions.size());
        System.assertEquals(1, picklistService.categoryOptions.size());
        System.assertEquals(1, picklistService.subCategoryOptions.size());
    }

    @isTest
    private static void testChangeFunctionalGroup() {
        picklistService = new CaseClassificationPicklistService();
        Map<String, Case_Classification__c> caseClassificationMap = getCaseClassificationData();
        picklistService.selectedFunctionalGroup = caseClassificationMap.get('Test Functional Group0').Id;

        System.assertEquals(2, picklistService.functionalGroupOptions.size());
        System.assertEquals(2, picklistService.categoryOptions.size());
        System.assertEquals(1, picklistService.subCategoryOptions.size());
    }

    @isTest
    private static void testChangeCategory() {
        picklistService = new CaseClassificationPicklistService();
        Map<String, Case_Classification__c> caseClassificationMap = getCaseClassificationData();
        picklistService.selectedFunctionalGroup = caseClassificationMap.get('Test Functional Group0').Id;
        picklistService.selectedCategory = caseClassificationMap.get('Test Category0').Id;

        System.assertEquals(2, picklistService.functionalGroupOptions.size());
        System.assertEquals(2, picklistService.categoryOptions.size());
        System.assertEquals(2, picklistService.subCategoryOptions.size());
    }

    @isTest
    private static void testAddDetailsToCase() {
        picklistService = new CaseClassificationPicklistService();
        CaseFactory.DefaultCase caseMaker = new CaseFactory.DefaultCase();
        Case createdCase = (Case) caseMaker.create(1)[0];

        Map<String, Case_Classification__c> caseClassificationMap = getCaseClassificationData();
        picklistService.selectedFunctionalGroup = caseClassificationMap.get('Test Functional Group0').Id;
        picklistService.selectedCategory = caseClassificationMap.get('Test Category0').Id;
        picklistService.selectedSubCategory = caseClassificationMap.get('Test Sub Category0').Id;
        picklistService.addCaseClassificationToCase(createdCase);

        System.assertEquals(createdCase.CC_Functional_Group__c, caseClassificationMap.get('Test Functional Group0').Id);
        System.assertEquals(createdCase.CC_Category__c, caseClassificationMap.get('Test Category0').Id);
        System.assertEquals(createdCase.CC_Sub_Category__c, caseClassificationMap.get('Test Sub Category0').Id);
    }

    private static Map<String, Case_Classification__c> getCaseClassificationData() {
        List<Case_Classification__c> allCaseClassification = [SELECT Id, Name FROM Case_Classification__c];

        Map<String, Case_Classification__c> nameToCC = new Map<String, Case_Classification__c>();

        for (Case_Classification__c caseClassificationToMap : allCaseClassification) {
            nameToCC.put(caseClassificationToMap.Name, caseClassificationToMap);
        }

        return nameToCC;
    }
}
