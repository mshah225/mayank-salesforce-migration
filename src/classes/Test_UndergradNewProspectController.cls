@isTest
private class Test_UndergradNewProspectController {
    
    static testMethod void testUndergradController() {
    	UndergradNewProspectController ug = new UndergradNewProspectController();
    	
        Test.startTest();
    	Contact contact = ug.getContact();
    	Opportunity opportunity = ug.getOpportunity();
    	Previous_Education__c previousEducation = ug.getPreviousEducation();
    	CampaignMember camMemInterest = ug.getCampaignMemberInterest();
    	CampaignMember camMemEvent = ug.getCampaignMemberEvent();
    	Case c = ug.getC(); 
    	
    	ug.elId = null;
    	ug.eventSearchString = 'test';
    	ug.eventSearch();
    	ug.getEventList();
    	
    	ug.instSearch();
    	ug.getInstList();
    	
    	ug.originSelection = 'Incoming Call';
    	ug.pickSelection = 'Academic';
    	ug.selectedInterestId = '701J0000001aNeKIAU';
    	ug.phoneOrig = '701J0000001aMrCIAU';
    	previousEducation.Account__c = 'a0HJ0000006K225MAC';
    	
    	contact.FirstName = 'Jonny';
	    contact.LastName = 'Tester';
	    contact.MobilePhone = '923-345-3456';
	    contact.MailingStreet = '123 Sky Blvd.';
	    contact.MailingCity = 'Tempe';
	    contact.MailingPostalCode = '85281';
	    
	    ug.setContact(contact);
    	ug.setOpportunity(opportunity);
    	ug.setPreviousEducation(previousEducation);
    	ug.setCampaignMemberInterest(camMemInterest);
    	ug.setCampaignMemberEvent(camMemEvent);
    	ug.setCase(c);
    	
    	List<SelectOption> asuLocationIntList = ug.getASULocationIntList();
    	List<SelectOption> academicIntList = ug.getAcademicIntList();
    	List<SelectOption> asuCollegesIntList = ug.getASUCollegesIntList();
    	    	
    	System.Debug(ug.originSelection);
    	System.Debug(ug.pickSelection);

        PageReference s = ug.SavePage();

		Contact[] jonny = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contact.Id];

    	System.assertEquals('Jonny', jonny[0].FirstName);
  		System.assertEquals(null, s);
  		Test.stopTest();
    }
}