global with sharing class CaseDetailWithClassificationController {
    public Id caseRecordId { get; set; }
    public Case caseRecord { get; set; }
    public String caseStatus { get; set; }
    public CaseClassificationPicklistService ccPicklist { get; set; }
    public List<SelectOption> statusOptions { get; set; }
    public String selectedStatus { get; set; }

    public CaseDetailWithClassificationController(ApexPages.StandardController stdController) {
        caseRecordId = ApexPages.currentPage().getParameters().get('id');
        caseRecord = [
            SELECT CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c, RecordTypeId, 
            	Status, Id 
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
    
    public void saveCase() {
        Case caseToUpdate = new Case(Id = caseRecordId);
        if (selectedStatus != null) {
            caseToUpdate.Status = selectedStatus;
        }
        ccPicklist.addCaseClassificationToCase(caseToUpdate);
        System.debug(caseToUpdate);
        update caseToUpdate;
    }
    
    public void buildCaseStatusPicklist() {
        List<String> caseStatuses = makeCalloutToGetStatusOptions();
        createSelectOptions(caseStatuses);
        setSelectedStatus();
    }
    
    public void resetDetails() {
        setCurrentCaseClassification();
        setSelectedStatus();
    }
    
    private List<String> makeCalloutToGetStatusOptions() {
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
            caseStatuses.add((String)mappedResponse.get('value'));
        }
        
        return caseStatuses;
    }
    
    private void createSelectOptions(List<String> optionsToAdd) {
        List<CaseStatus> nonClosedStatuses = [SELECT ApiName, MasterLabel FROM CaseStatus WHERE IsClosed = FALSE];
        List<String> availableStatuses = new List<String>();
        for (CaseStatus nonClosedStatus : nonClosedStatuses) {
            availableStatuses.add(nonClosedStatus.ApiName);
        }
        statusOptions = new List<SelectOption>();
        for (String optionName : optionsToAdd) {
            if (availableStatuses.contains(optionName)) {
            	statusOptions.add(new SelectOption(optionName, optionName, false));
            }
        }
    }
    
    private void setSelectedStatus() {
        selectedStatus = caseRecord.Status;
    }
}