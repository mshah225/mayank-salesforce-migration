public with sharing class CaseShowAllAttachmentsControllerExt {
    private final Case theCase;
    public string attId{get;set;}
    private final String STANDARD_PREFIX = '--c';
    private final String ATTACHMENT_PACKAGE_PREFIX = '--attachmentzip';
    public Attachment[] allAttachments;
    public String baseUrlForAttachmentIntegration {get; private set;}
    
    public CaseShowAllAttachmentsControllerExt(ApexPages.StandardController stdController) {
        this.theCase = [SELECT Id, ParentId, Contact.Name
            FROM Case 
            WHERE Id = :stdController.getRecord().Id];
        
        baseUrlForAttachmentIntegration = constructAttachmentPackageUrl();
    }
    
    public Attachment[] getAllAttachments() {
        Map<Id, SObject> caseEmailMap = new Map<Id, SObject>([
            SELECT Id 
            FROM EmailMessage
            WHERE (
                ParentId = :this.theCase.Id 
                OR ParentId = :this.theCase.parentId
            )
        ]);
        
        allAttachments = [
            SELECT Id, Name, LastModifiedDate, CreatedBy.Name, BodyLength
            FROM Attachment
            WHERE (
                ParentId = :this.theCase.Id 
                OR ParentId IN :caseEmailMap.keySet() 
                OR ParentId = :this.theCase.parentId
            )
            ORDER BY LastModifiedDate
        ];
        
        return allAttachments;
    }
    
    public String getContactName() {
        return this.theCase.Contact.Name;
    }
    
    private String constructAttachmentPackageUrl() {
        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        return baseUrl.replace(STANDARD_PREFIX, ATTACHMENT_PACKAGE_PREFIX);
    }
    
    public PageReference deleteAttachment(){
        try{
            Attachment objAtt = new Attachment(id=attId);
            delete objAtt;
        }
        catch(Exception e){
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'There was a problem deleting the attachment. Please try again or contact the administrator.' ));
        }
        return null;
    }
}