public with sharing class CaseShowAllAttachmentsControllerExt {
    private final Case theCase;
    public string attId{get;set;}
    public Attachment[] allAttachments;
    
    public CaseShowAllAttachmentsControllerExt(ApexPages.StandardController stdController) {
        this.theCase = [SELECT Id, ParentId, Contact.Name
            FROM Case 
            WHERE Id = :stdController.getRecord().Id];
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
