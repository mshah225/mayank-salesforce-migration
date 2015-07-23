@isTest
private class Test_UnifiedProspectPageController 
{
    private static UnifiedProspectPageController uppc;
    private static Contact contact;
    private static Opportunity opportunity;
    private static Case c;

    @testSetup static void setUpTest() 
    {   
        Account testAccount = new Account(
            Name = 'Test School'
        );
        insert testAccount;

        Campaign testEventCam = new Campaign(
            Name = 'ASU Test Event',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id
        );
        insert testEventCam;

        Campaign testEmailCam = new Campaign(
            Name = 'Email',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id
        );
        insert testEmailCam;

        Campaign testIntCam = new Campaign(
            Name = 'ASU Test Interest',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id
        );
        insert testIntCam;

        Term__c testTerm = new Term__c(
        	Name = 'Spring 2017',
			Year__c = '2017'
    	);
    	insert testTerm;
    } 

    private static void setUpController() 
    {
        uppc = new UnifiedProspectPageController();
        contact = uppc.getContact();
        opportunity = uppc.getOpportunity();
        c = uppc.getC();
        contact.FirstName = 'Test';
        contact.LastName = 'Testerson';
        contact.Lead_Email__c = 'test@asu.edu';
        contact.Phone = '4803805555';
        contact.MobilePhone = '4803806666';
        uppc.smsText = TRUE;
    }

    private static testmethod void testUndergradCaseCreationCaseNoInterest()
    {
    	Test.startTest();	
    	setUpController();

    	uppc.career = 'undergraduate';
    	Term__c testTerm = [SELECT Id FROM Term__c WHERE Name = 'Spring 2017' LIMIT 1];
    	opportunity.Term__c = testTerm.Id;
    	opportunity.Type = 'First Time Freshman';

    	uppc.originSelection = 'Email';
    	c.Functional_Group__c = 'ASU Online';
    	c.Category__c = 'Admissions';
    	c.Sub_Category__c = 'International';

    	uppc.setContact(contact);
    	uppc.setOpportunity(opportunity);
    	uppc.setCase(c);

    	uppc.pickSelection = '--Select--';

    	Boolean result = uppc.save();

    	Test.stopTest();

    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	System.debug('msgs ' + msgs);

    	System.assert(result == true);

    	contact = [SELECT Id, SF_First_Name__c, SMS_Phone__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];
    	System.assert(contact.SF_First_Name__c == 'TEST');
    	System.assert(contact.SMS_Phone__c == '4803806666');

    	opportunity = [SELECT RecordTypeId, Contact__c, International_Student__c, Term__c FROM Opportunity WHERE Term__c = :testTerm.Id LIMIT 1];
    	System.assert(opportunity.RecordTypeID == '012d0000000x3xyAAA');
    	System.assert(opportunity.Contact__c == contact.Id);
    	System.assert(opportunity.International_Student__c == false);

    	c = [SELECT Subject, Status, Case_Source__c, Origin__c FROM Case WHERE Functional_Group__c = 'ASU Online' LIMIT 1];
        Campaign emailCamp = [SELECT Id FROM Campaign WHERE Name = 'Email' LIMIT 1];
    	System.assert(c.Status == 'Closed: Resolved'); System.assert(c.Case_Source__c == emailCamp.Id); System.assert(c.Origin__c == 'Email');
        String termName = [SELECT Term__r.Name FROM Opportunity WHERE Term__c = :opportunity.Term__c LIMIT 1].Term__r.Name;
    	System.assert(c.Subject == c.Origin__c + ' Submission - ' + termName);
    }

    private static testmethod void testUndergradCaseCreationEventInterest()
    {
    	Test.startTest();	
    	setUpController();

    	uppc.career = 'undergraduate';
    	Term__c testTerm = [SELECT Id FROM Term__c WHERE Name = 'Spring 2017' LIMIT 1];
    	opportunity.Term__c = testTerm.Id;
    	opportunity.Type = 'First Time Freshman';

    	uppc.setContact(contact);
    	uppc.setOpportunity(opportunity);
        Campaign eventCampaign = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Event' LIMIT 1];
    	uppc.originSelection = '--Select--';
    	uppc.elId = eventCampaign.Id;
    	System.debug('EVENT CAMPAIGN ' + eventCampaign.Id);

    	uppc.pickSelection = 'Not Null';
    	Campaign interestTestCam = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Interest' LIMIT 1];
    	uppc.selectedInterestId = interestTestCam.Id;

    	Boolean result = uppc.save();

    	Test.stopTest();

    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	System.debug('msgs ' + msgs);

    	System.assert(result == true);

    	contact = [SELECT Id, SF_First_Name__c, SMS_Phone__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];
    	System.assert(contact.SF_First_Name__c == 'TEST');
    	System.assert(contact.SMS_Phone__c == '4803806666');

    	opportunity = [SELECT Id, RecordTypeId, Contact__c, International_Student__c, Term__c FROM Opportunity WHERE Term__c = :testTerm.Id LIMIT 1];
    	System.assert(opportunity.RecordTypeID == '012d0000000x3xyAAA');
    	System.assert(opportunity.Contact__c == contact.Id);
    	System.assert(opportunity.International_Student__c == false);

    	//CampaignMember camMemEvent = [SELECT Status, Opportunity__c FROM CampaignMember WHERE ContactId = :contact.Id AND CampaignId = :uppc.elId LIMIT 1];
    	CampaignMember camMemEvent = [SELECT Inbound_Interaction__c, Opportunity__c FROM CampaignMember WHERE Id = :uppc.camMemEvent.Id LIMIT 1];
    	System.debug('EVENT ' + camMemEvent);
    	System.assert(camMemEvent.Inbound_Interaction__c == true);
    	System.assert(camMemEvent.Opportunity__c == opportunity.Id);

    	CampaignMember camMemInterest = [SELECT CampaignId, ContactId FROM CampaignMember WHERE Id = :uppc.camMemInterest.Id LIMIT 1];
    	System.assert(camMemInterest.CampaignId == uppc.selectedInterestId);
        System.assert(camMemInterest.ContactId == contact.Id);
	}

	private static testmethod void testGetContact()
	{
    	Test.startTest();	
    	uppc = new UnifiedProspectPageController();
    	Contact con = uppc.getContact();
    	Test.stopTest();
    	System.assert(con.Id == null);
	}

	private static testmethod void testGetOpportunity()
	{
    	Test.startTest();	
    	uppc = new UnifiedProspectPageController();
    	Opportunity op = uppc.getOpportunity();
    	Id oppRecType = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;
    	Test.stopTest();
    	System.assert(op.RecordTypeId == oppRecType);
	}

	private static testmethod void testGetCase()
	{
		Test.startTest();
    	uppc = new UnifiedProspectPageController();
    	c = uppc.getC();
    	Id asuAdmissionRecId = [SELECT Id, Name FROM RecordType WHERE Name = 'ASU Admission Services' LIMIT 1].Id;
        System.assert(c.RecordTypeId == asuAdmissionRecId);
	}

	private static testmethod void testGetPreviousEducation()
	{
    	Test.startTest();	
    	uppc = new UnifiedProspectPageController();
    	Previous_Education__c pe = uppc.getPreviousEducation();
    	Test.stopTest();
    	System.assert(pe.Id == null);
	}
	
	private static testmethod void testGetCampaignMemberInterest()
	{
    	Test.startTest();	
    	uppc = new UnifiedProspectPageController();
    	CampaignMember cmi = uppc.getCampaignMemberInterest();
    	Test.stopTest();
    	System.assert(cmi.Id == null);
	}
	
	private static testmethod void testGetCampaignMemberEvent()
	{
    	Test.startTest();	
    	uppc = new UnifiedProspectPageController();
    	CampaignMember cme = uppc.getCampaignMemberEvent();
    	Test.stopTest();
    	System.assert(cme.Id == null);
	}

	private static testmethod void getProgramList()
	{
    	Test.startTest();	
    	uppc = new UnifiedProspectPageController();

    	Program__c prog = new Program__c(
    		Name = 'Test Undergrad Program',
    		Career__c = 'undergraduate',
    		Program_Code__c = '0'
		);

    	Program__c prog2 = new Program__c(
    		Name = 'Test Grad Program',
    		Career__c = 'graduate',
    		Program_Code__c = '1'
		);

    	Program__c prog3 = new Program__c(
    		Name = 'Test Law Program',
    		Career__c = 'law',
    		Program_Code__c = '2'
		);

    	List<Program__c> progList = new List<Program__c>{prog, prog2, prog3};
    	insert progList;
		
    	uppc.career = 'undergraduate';
		List<SelectOption> selProg = uppc.ProgramList;		    	
		System.debug(selProg);
	}
}