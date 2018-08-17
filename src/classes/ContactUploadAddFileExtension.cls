public without sharing class ContactUploadAddFileExtension {
    private final Contact_Upload__c myContactUpload;
    private final Integer UPLOAD_BATCH_SIZE = 200;
    private final Integer MATCHER_BATCH_SIZE = 500;
    public List<Attachment> attachmentList { get; set; }
    public Boolean contactIdMatch {
    get {
        if (contactIdMatch == null) {
            contactIdMatch = false;
        }
        return contactIdMatch;
    }
    
    set; 
        
    }
    
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
            if (contactIdMatch) {
                ContactMatcherBatch batch = new ContactMatcherBatch(newAttachment.Id);
                Database.executeBatch(batch, MATCHER_BATCH_SIZE);
            } else {
                ContactUploadBatch batch = new ContactUploadBatch(newAttachment.Id);
                Database.executeBatch(batch, UPLOAD_BATCH_SIZE);
            }
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment: ' + e.getMessage()));
        } finally {
            newAttachment = new Attachment();
        }
        return null;
    }
    
    public void contactUploadButton() {
        contactIdMatch = false;
    }
    
    public void contactMatcherButton() {
        contactIdMatch = true;
    }
}