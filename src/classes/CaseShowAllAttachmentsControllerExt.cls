public with sharing class CaseShowAllAttachmentsControllerExt {
    private final Case theCase;
    public Attachment[] allAttachments;
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public CaseShowAllAttachmentsControllerExt(ApexPages.StandardController stdController) {
        this.theCase = (Case)stdController.getRecord();
        
    }
    
    public Attachment[] getAllAttachments() {
        Map<Id, SObject> caseEmailMap = new Map<Id, SObject>([SELECT Id FROM EmailMessage WHERE ParentId = :this.theCase.Id]);
        allAttachments = [SELECT Id, Name, LastModifiedDate, CreatedBy.Name, BodyLength FROM Attachment WHERE (ParentId = :this.theCase.Id OR ParentId IN :caseEmailMap.keySet()) ORDER BY LastModifiedDate];
		return allAttachments;
    }
    
    public String getContactName() {
    	return this.theCase.Contact.Name;
    }

}