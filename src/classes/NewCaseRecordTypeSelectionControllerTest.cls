@isTest
public class NewCaseRecordTypeSelectionControllerTest {

    @isTest
    private static void checkCorrectRedirectUrl() {

        Id advisorOutReachId = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');

        CaseClassificationFactory ccCreator = new CaseClassificationFactory();
        List<Case_Classification__c> listOfCreatedCaseClassifications = ccCreator.createAndInsertSetOfCaseClassification();

        Case caseObject = new Case();
        ApexPages.StandardController controller = new ApexPages.StandardController(caseObject);
		
        NewCaseRecordTypeSelectionController nCRTSController = new NewCaseRecordTypeSelectionController(controller);
        nCRTSController.ccPicklist.selectedFunctionalGroup = listOfCreatedCaseClassifications[0].Id;
        nCRTSController.ccPicklist.updateCategoryAndSubCategory();
        nCRTSController.ccPicklist.selectedCategory = listOfCreatedCaseClassifications[1].Id;
        nCRTSController.ccPicklist.updateSubCategories();
        nCRTSController.ccPicklist.selectedSubCategory = listOfCreatedCaseClassifications[2].Id;
        nCRTSController.selectedRecordType = advisorOutReachId;

        PageReference currentPage = Page.NewCaseRecordTypeSelectionPage;
        Test.setCurrentPage(currentPage);
        currentPage.getParameters().put('retURL', '/500/o');

        PageReference editPageURL;
        Test.startTest();
        List<SelectOption> optionsToAssert = nCRTSController.getRecordTypeOptions();
        editPageURL = nCRTSController.redirect();
        Test.stopTest();

        String functionalGroupLookupFieldId = 'CF00N0W000008yd9U_lkid';
        String categoryLookupFieldId = 'CF00N0W000008yd9T_lkid';
        String subCategoryLookupFieldId = 'CF00N0W000008yd9W_lkid';
        String functionalGroupLookupFieldName = 'CF00N0W000008yd9U';
        String categoryLookupFieldName = 'CF00N0W000008yd9T';
        String subCategoryLookupFieldName = 'CF00N0W000008yd9W';

        for (SelectOption option : optionsToAssert) {
            System.assert(option.getLabel() != 'Master', 'Master Record Type option should have been removed.');
        }

        System.assertEquals(currentPage.getParameters().get('retURL'), '/500/o');
        System.assertEquals(editPageURL.getParameters().get('RecordType'), advisorOutReachId);
        System.assertEquals(editPageURL.getParameters().get(functionalGroupLookupFieldId), String.valueOf(listOfCreatedCaseClassifications[0].Id));
        System.assertEquals(editPageURL.getParameters().get(functionalGroupLookupFieldName), listOfCreatedCaseClassifications[0].Name);
        System.assertEquals(editPageURL.getParameters().get(categoryLookupFieldId), String.valueOf(listOfCreatedCaseClassifications[1].Id));
        System.assertEquals(editPageURL.getParameters().get(categoryLookupFieldName), listOfCreatedCaseClassifications[1].Name);
        System.assertEquals(editPageURL.getParameters().get(subCategoryLookupFieldId), String.valueOf(listOfCreatedCaseClassifications[2].Id));
        System.assertEquals(editPageURL.getParameters().get(subCategoryLookupFieldName), listOfCreatedCaseClassifications[2].Name);
    }

    @isTest
    private static void checkCorrectCancelUrl() {
        Case caseObject = new Case();
        ApexPages.StandardController controller = new ApexPages.StandardController(caseObject);

        NewCaseRecordTypeSelectionController nCRTSController = new NewCaseRecordTypeSelectionController(controller);

        PageReference currentPage = Page.NewCaseRecordTypeSelectionPage;
        Test.setCurrentPage(currentPage);
        currentPage.getParameters().put('retURL', '/500/o');

        PageReference returnURL;
        Test.startTest();
        returnURL = nCRTSController.cancel();
        Test.stopTest();

        System.assertEquals(returnURL.getUrl(), '/500/o');
    }
}