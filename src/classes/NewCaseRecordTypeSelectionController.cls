public with sharing class NewCaseRecordTypeSelectionController {

    private ApexPages.StandardController controller;

    public Id selectedRecordType {get; set;}
    public String selectedFunctionalGroupId {get; set;}
    public String selectedCategoryId {get; set;}
    public String selectedSubCategoryId {get; set;}
    public String selectedFunctionalGroupName {get; set;}
    public String selectedCategoryName {get; set;}
    public String selectedSubCategoryName {get; set;}
    public String functionalGroupLookupFieldId;
    public String categoryLookupFieldId;
    public String subCategoryLookupFieldId;
    public String functionalGroupLookupFieldName;
    public String categoryLookupFieldName;
    public String subCategoryLookupFieldName;
    public String contactId;
    public CaseClassificationPicklistService ccPicklist {get; set;}

    public NewCaseRecordTypeSelectionController(ApexPages.StandardController controller) {
        this.controller = controller;
        ccPicklist = new CaseClassificationPicklistService();
        functionalGroupLookupFieldId = 'CF00N0W000008yd9U_lkid';
        categoryLookupFieldId = 'CF00N0W000008yd9T_lkid';
        subCategoryLookupFieldId = 'CF00N0W000008yd9W_lkid';
        functionalGroupLookupFieldName = 'CF00N0W000008yd9U';
        categoryLookupFieldName = 'CF00N0W000008yd9T';
        subCategoryLookupFieldName = 'CF00N0W000008yd9W';
        contactId = ApexPages.currentPage().getParameters().get('cas3_lkid');
    }

    public List<SelectOption> getRecordTypeOptions() {
        List<SelectOption> recordTypes = new List<SelectOption>();
        for (RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (info.isAvailable()) {
                if (info.getName() == 'Master') {
                    continue;
                } else {
                    recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                }
            }
        }
        return recordTypes;
    }

    public PageReference redirect() {
        PageReference editPageURL;

        editPageURL = new PageReference('/500/e');

        editPageURL.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        editPageURL.getParameters().put('nooverride', '1');
        editPageURL.getParameters().put('RecordType',selectedRecordType);

        Map<Id, Case_Classification__c> caseClassificationNames = ccPicklist.getCCNames();
        
        editPageURL.getParameters().put(functionalGroupLookupFieldId, ccPicklist.selectedFunctionalGroup);
        editPageURL.getParameters().put(functionalGroupLookupFieldName, caseClassificationNames.get(ccPicklist.selectedFunctionalGroup).Name);

        if (!ccPicklist.selectedCategory.equals('--')) {
            editPageURL.getParameters().put(categoryLookupFieldId, ccPicklist.selectedCategory);
            editPageURL.getParameters().put(categoryLookupFieldName, caseClassificationNames.get(ccPicklist.selectedCategory).Name);
        }

        if (!ccPicklist.selectedSubCategory.equals('--')) {
            editPageURL.getParameters().put(subCategoryLookupFieldId, ccPicklist.selectedSubCategory);
            editPageURL.getParameters().put(subCategoryLookupFieldName, caseClassificationNames.get(ccPicklist.selectedSubCategory).Name);
        }

        if (!String.isEmpty(contactId)) {
            editPageURL.getParameters().put('cas3_lkid', contactId);
        }

        editPageURL.setRedirect(true);
        return editPageURL;

    }

    public PageReference cancel() {
        PageReference returnURL;

        returnURL = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        return returnURL;
    }
}