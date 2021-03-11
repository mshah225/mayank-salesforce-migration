public with sharing class CaseDetailWithRelatedCasesController {
    public Integer relatedCaseCount { get; set; }

    public CaseDetailWithRelatedCasesController(ApexPages.StandardController stdController) {
        String caseRecordId = ApexPages.currentPage().getParameters().get('id');

        Case thisCase = [SELECT CC_Functional_Group__c, ContactId, Id FROM Case WHERE Id = :caseRecordId];

        String thisContact = thisCase.ContactId != null ? (String) thisCase.ContactId : '';
        String thisFunctionalGrp = thisCase.CC_Functional_Group__c != null
            ? (String) thisCase.CC_Functional_Group__c
            : '';

        if (thisContact != '' && thisFunctionalGrp != '') {
            relatedCaseCount = (Integer) [
                    SELECT COUNT(Id)
                    FROM Case
                    WHERE
                        ContactId = :thisContact
                        AND CC_Functional_Group__c = :thisFunctionalGrp
                        AND IsClosed = FALSE
                        AND Id != :caseRecordId
                ][0]
                .get('expr0');
        } else {
            relatedCaseCount = 0;
        }
    }
}
