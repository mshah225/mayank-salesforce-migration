public with sharing class FeedbackController
{	
	private ServiceCenter sc;

	public Case c { get;set; }
	public Contact feedbackContact { get;set; }
	public Group queue { get;set; }
	public String comments { get;set; }
	public String userAlias;

	public FeedbackController(ServiceCenter sc)
	{
		this.sc = sc;
		c = new Case();	
		feedbackContact = sc.userContact;
		Queue = new Group();
	}

	public PageReference submit() 
	{
		if (sc.viewingAs)
		{
			PageReference go = new PageReference(ApexPages.currentPage().getUrl());
			go.getParameters().put('masqScopeIdCookie', sc.masqScopeIdCookie);
			go.setRedirect(true);
			return go;
		}

		try
		{
			Queue = [SELECT Id
					 FROM Group 
					 WHERE Name = 'Student-Centric Initiatives (Case)' 
					 AND Type = 'Queue'];
			c.OwnerId = Queue.Id;
			c.Subject = 'MyASU Service Center Feedback';
			c.Description = comments;
			if (comments == '' || comments == null)
			{
				return null;
			}

			if (feedbackContact != null)
			{
				c.ContactId = feedbackContact.Id;
			}

			c.Functional_Group__c = 'Student-Centric Initiatives';
			c.Category__c = 'Service Center Feedback';
			c.Origin__c = 'My ASU';
			c.Visible_by_Contact__c = false;
			insert c;
		}
		catch(Exception e)
		{

		}

		PageReference submit = new PageReference('/studentSC?Confirm=feedback');
		submit.setRedirect(true);
		return submit;
	}
}