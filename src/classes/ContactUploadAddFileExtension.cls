public with sharing class ContactUploadAddFileExtension {
    private final Contact_Upload__c myContactUpload;
    public List<Attachment> attachmentList { get; set; }

    public Attachment newAttachment {
        get {
            if (newAttachment == null) {
                newAttachment = new Attachment();
            }
            return newAttachment;
        }
        set;
    }

    /** 
    * The extension constructor initializes the private member
    * variable mysObject by using the getRecord method from the standard
    * controller.
    */
    public ContactUploadAddFileExtension(ApexPages.StandardController stdController) {
        this.myContactUpload = (Contact_Upload__c) stdController.getRecord();
        queryAttachments();
    }

    private void queryAttachments() {
        attachmentList = new List<Attachment>([
            SELECT Id, Name, Description, CreatedDate, CreatedById, CreatedBy.Name 
            FROM Attachment 
            WHERE ParentId = :myContactUpload.Id
        ]);
    }

    public PageReference upload() {
        newAttachment.OwnerId = UserInfo.getUserId();
        newAttachment.ParentId = myContactUpload.Id;
        newAttachment.IsPrivate = true;

        try {
            insert newAttachment;
            queryAttachments();
            BatchContactUpload bcu = new BatchContactUpload(newAttachment.Id);
            Database.executeBatch(bcu);
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } finally {
            newAttachment = new Attachment();
        }
        return null;
    }
}