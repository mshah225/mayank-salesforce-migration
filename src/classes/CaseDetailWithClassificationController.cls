global with sharing class CaseDetailWithClassificationController {
    public Id caseRecordId { get; set; }
    public Case caseRecord { get; set; }
    public CaseClassificationPicklistService ccPicklist { get; set; }

    public CaseDetailWithClassificationController(ApexPages.StandardController stdController) {
        caseRecordId = ApexPages.currentPage().getParameters().get('id');
        caseRecord = [
            SELECT CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c, RecordTypeId, Id, Subject, Description
            FROM Case
            WHERE Id = :caseRecordId
        ];
        ccPicklist = new CaseClassificationPicklistService();
        ccPicklist.setCurrentCaseClassification(caseRecord);
    }

    public void saveCase() {
        Case caseToUpdate = new Case(Id = caseRecordId);
        if (caseRecord.Subject == null)
            caseToUpdate.Subject = 'Generated Case Subject (Value was blank) - ' + DateTime.now();
        if (caseRecord.Description == null)
            caseToUpdate.Description = 'Generated Case Description (Value was blank) - ' + DateTime.now();
        ccPicklist.addCaseClassificationToCase(caseToUpdate);
        updateLocalCaseWhenSaved();
        update caseToUpdate;
    }

    private void updateLocalCaseWhenSaved() {
        ccPickList.addCaseClassificationToCase(caseRecord);
    }

    public void resetDetails() {
        ccPicklist.setCurrentCaseClassification(caseRecord);
    }
}
