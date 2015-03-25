public with sharing class FeedbackController {
	
	public Case c { get;set; }
	public Contact contact { get;set; }
	public Group queue { get;set; }
	public String comments { get;set; }
	public String userAlias;

	public FeedbackController() {
		c = new Case();	
		contact = new Contact();
		queue = new Group();
	}

	public PageReference submit() {
		try {
			queue = [SELECT Id 
					 FROM Group 
					 WHERE Name = 'Student-Centric Initiatives (Case)' 
					 AND Type = 'Queue'];
			userAlias = [SELECT Alias 
                     	 FROM User 
                     	 WHERE Id = :UserInfo.getUserId()].Alias;
	        contact = [SELECT Id 
	                   FROM Contact 
	                   WHERE ASURITE_Id__c = :userAlias];
		} catch(Exception e) {

		}
		c.OwnerId = queue.Id;
		c.Subject = comments;
		if(c.Subject != null && c.Subject.length() > 255){
            c.Subject = c.Subject.substring(0,254);
        }
		c.Description = comments;
		if(contact != null) {
			c.ContactId = contact.Id;
		}
		c.Functional_Group__c = 'Student-Centric Initiatives';
		c.Category__c = 'Service Center Feedback';
		c.Origin__c = 'My ASU';
		c.Visible_by_Contact__c = false;
		insert c;

		PageReference submit = new PageReference('/studentSC?Confirm=feedback');
		submit.setRedirect(true);
		return submit;
	}
}