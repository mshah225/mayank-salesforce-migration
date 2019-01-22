global with sharing class CaseDetailWithClassificationController {
    public Id caseRecordId { get; set; }
    public Case caseRecord { get; set; }
    public String caseStatus { get; set; }
    public CaseClassificationPicklistService ccPicklist { get; set; }

    public CaseDetailWithClassificationController(ApexPages.StandardController stdController) {
        caseRecordId = ApexPages.currentPage().getParameters().get('id');
        caseRecord = [
            SELECT CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c, RecordTypeId, Id 
            FROM Case 
            WHERE Id =: caseRecordId
        ];
        ccPicklist = new CaseClassificationPicklistService();
        setCurrentCaseClassification();
        buildCaseStatusPicklist();
    }

    private void setCurrentCaseClassification() {
        
        ccPicklist.selectedFunctionalGroup = caseRecord.CC_Functional_Group__c;
        ccPicklist.updateCategoryAndSubCategory();
        ccPicklist.selectedCategory = caseRecord.CC_Category__c;
        ccPicklist.updateSubCategories();
        ccPicklist.selectedSubCategory = caseRecord.CC_Sub_Category__c;
    }
    
    public void updateCaseWithCaseClassification() {
        update new Case(
            Id = caseRecordId,
            CC_Functional_Group__c = ccPicklist.selectedFunctionalGroup,
            CC_Category__c = ccPicklist.selectedCategory,
            CC_Sub_Category__c = ccPicklist.selectedSubCategory,
            Status = caseStatus
        );
    }
    
    public void buildCaseStatusPicklist() {
        List<String> caseStatuses = new List<String>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/ui-api/object-info/Case/picklist-values/' + caseRecord.RecordTypeId + '/Status');
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        
        HttpResponse res = h.send(req);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        List<Object> responseValues = (List<Object>)responseBody.get('values');
        
        for (Object response : responseValues) {
            Map<String, Object> mappedResponse = (Map<String, Object>)response;
            caseStatuses.add((String)mappedResponse.get('label'));
        }
        
        System.debug(caseStatuses);
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