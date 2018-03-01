public with sharing class CaseShowAllAttachmentsControllerExt {
    
    public String caseId { get; private set; }
    private String caseParentId { get; private set; }
    
    public String attId { get; set; }
    private final String STANDARD_PREFIX = '--c';
    private final String ATTACHMENT_PACKAGE_PREFIX = '--attachmentzip';

    public List<Attachment> allAttachmentsOnCaseOrEmailMessageOrCaseParent;
    public String baseUrlForAttachmentIntegration { get; private set; }
    
    public CaseShowAllAttachmentsControllerExt(ApexPages.StandardController stdController) {
        
        List<Case> currentCaseOnPage = [SELECT Id, ParentId, Contact.Name
            FROM Case 
            WHERE Id = :stdController.getRecord().Id];
        
        caseId = currentCaseOnPage[0].Id;
        caseParentId = currentCaseOnPage[0].ParentId;
        baseUrlForAttachmentIntegration = constructAttachmentPackageUrl();
    }
    
    public List<Attachment> getAllAttachments() {
        
        Set<Id> emailMessageIdsOnCase = new Set<Id>();
        for (EmailMessage eachEmailMessage : [
            SELECT Id 
            FROM EmailMessage
            WHERE (
                    ParentId = :caseId 
                    OR ParentId = :caseParentId
            )
            ]) {
            emailMessageIdsOnCase.add(eachEmailMessage.Id);
        }
        
        allAttachmentsOnCaseOrEmailMessageOrCaseParent = [
            SELECT Id, Name, LastModifiedDate, CreatedBy.Name, BodyLength
            FROM Attachment
            WHERE (
                ParentId = :caseId
                OR ParentId IN :emailMessageIdsOnCase 
                OR ParentId = :caseParentId
            )
            ORDER BY LastModifiedDate
        ];
        
        return allAttachmentsOnCaseOrEmailMessageOrCaseParent;
    }
    
    private String constructAttachmentPackageUrl() {
        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        return baseUrl.replace(STANDARD_PREFIX, ATTACHMENT_PACKAGE_PREFIX);
    }
    
    public PageReference deleteAttachment(){
        Attachment objAtt = new Attachment(Id = attId);
        
        try {
            delete objAtt;
        } catch(Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'There was a problem deleting the attachment. Please try again or contact the administrator.' ));
        }
        return null;
    }
    
}