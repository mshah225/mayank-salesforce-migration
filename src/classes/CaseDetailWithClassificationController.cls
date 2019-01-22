global with sharing class CaseDetailWithClassificationController {
    public Id caseRecordId { get; set; }
    public Case caseRecord { get; set; }
    public CaseClassificationPicklistService ccPicklist { get; set; }

    public CaseDetailWithClassificationController(ApexPages.StandardController stdController) {
        caseRecordId = ApexPages.currentPage().getParameters().get('id');
        caseRecord = (Case) stdController.getRecord();
        ccPicklist = new CaseClassificationPicklistService();
    }

    @RemoteAction
    global static void updateCaseWithCaseClassification(Id caseId, Id functionalGroup, Id category, Id subCategory, String caseStatus) {
        update new Case(
            Id = caseId,
            CC_Functional_Group__c = functionalGroup,
            CC_Category__c = category,
            CC_Sub_Category__c = subCategory,
            Status = caseStatus
        );
    }
}