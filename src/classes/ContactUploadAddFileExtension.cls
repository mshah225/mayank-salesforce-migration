public with sharing class ContactUploadAddFileExtension {

	private final Contact_Upload__c myContactUpload;
	public List<Attachment> attachmentList { get; set; }

	public Attachment attachment {
		get {
		  if (attachment == null)
		    attachment = new Attachment();
		  return attachment;
		}
		set;
	}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ContactUploadAddFileExtension(ApexPages.StandardController stdController)
	{
        this.myContactUpload = (Contact_Upload__c)stdController.getRecord();
		queryAttachments();
    }

	private void queryAttachments()
	{
		attachmentList = new List<Attachment>([SELECT Id, Name, Description, CreatedDate, CreatedById, CreatedBy.Name FROM Attachment WHERE ParentId = :myContactUpload.Id]);
	}

	public PageReference upload()
	{

		attachment.OwnerId = UserInfo.getUserId();
		attachment.ParentId = myContactUpload.Id;
		attachment.IsPrivate = true;

		try
		{
			insert attachment;
			queryAttachments();
			BatchContactUpload bcu = new BatchContactUpload(String.valueOf(attachment.Id));
			Database.executeBatch(bcu);
		}
		catch (DMLException e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
			return null;
		}
		finally
		{
			attachment = new Attachment();
		}
		return null;
	}


}