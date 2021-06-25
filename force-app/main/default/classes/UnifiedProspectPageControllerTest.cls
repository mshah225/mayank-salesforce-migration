@isTest
private class UnifiedProspectPageControllerTest {
    private static UnifiedProspectPageController uppc;
    private static Contact contact;
    private static Opportunity opportunity;
    private static Case c;
    private static Case_Classification__c fgroup;

    @testSetup
    static void setUpTest() {
        CaseClassificationFactory ccMaker = new CaseClassificationFactory();
        ccMaker.createAndInsertSetOfCaseClassification();

        Account testAccount = new Account(Name = 'Test School');
        insert testAccount;

        Campaign testASUCollege = new Campaign(
            Name = 'ASU Test College',
            IsActive = true,
            Type = 'ASU Colleges',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Interest']
            .Id
        );
        insert testASUCollege;

        Campaign testASULocation = new Campaign(
            Name = 'ASU Test Location',
            IsActive = true,
            Type = 'ASU Location',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Interest']
            .Id
        );
        insert testASULocation;

        Campaign testAcademic = new Campaign(
            Name = 'ASU Test Academic',
            IsActive = true,
            Type = 'Academic',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Interest']
            .Id
        );
        insert testAcademic;

        Campaign testEventCam = new Campaign(
            Name = 'ASU Test Event',
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event']
            .Id
        );
        insert testEventCam;

        Campaign testPhoneCallCampaign = new Campaign(
            Name = 'Phone Call',
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event']
            .Id
        );
        insert testPhoneCallCampaign;

        Campaign testEmailCam = new Campaign(
            Name = 'Email',
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event']
            .Id
        );
        insert testEmailCam;

        Campaign testWalkInCam = new Campaign(
            Name = 'Walk In',
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event']
            .Id
        );
        insert testWalkInCam;

        Campaign testIntCam = new Campaign(
            Name = 'ASU Test Interest',
            IsActive = true,
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Interest']
            .Id
        );
        insert testIntCam;

        Term__c testTerm = new Term__c(
            Name = 'Spring 2017',
            Year__c = '2017',
            Session_A_C_Start_Date__c = Date.Today()
        );
        insert testTerm;

        Program__c prog = new Program__c(
            Name = 'Test Undergrad Program',
            Career__c = 'undergraduate',
            Program_Code__c = '0',
            Program_Status__c = true
        );

        Program__c prog2 = new Program__c(
            Name = 'Test Grad Program',
            Career__c = 'graduate',
            Program_Code__c = '1',
            Program_Status__c = true
        );

        Program__c prog3 = new Program__c(
            Name = 'Test Law Program',
            Career__c = 'law',
            Program_Code__c = '2',
            Program_Status__c = true
        );

        List<Program__c> progList = new List<Program__c>{ prog, prog2, prog3 };
        insert progList;

        Plan__c plan = new Plan__c(
            Name = 'Test Undergrad Plan',
            Plan_Code__c = '0',
            Program__c = prog.Id,
            Plan_Effective_Date__c = Date.today(),
            Available_in_Degree_Search__c = true,
            Degree_Search_Name__c = 'Test Undergrad Plan'
        );

        Plan__c plan2 = new Plan__c(
            Name = 'Test Grad Plan',
            Plan_Code__c = '1',
            Program__c = prog2.Id,
            Plan_Effective_Date__c = Date.today(),
            Available_in_Degree_Search__c = true,
            Degree_Search_Name__c = 'Test Grad Plan'
        );

        Plan__c plan3 = new Plan__c(
            Name = 'Test Law Plan',
            Plan_Code__c = '2',
            Program__c = prog3.Id,
            Plan_Effective_Date__c = Date.today(),
            Available_in_Degree_Search__c = true,
            Degree_Search_Name__c = 'Test Law Plan'
        );

        List<Plan__c> planList = new List<Plan__c>{ plan, plan2, plan3 };
        insert planList;
    }

    private static void setUpController() {
        uppc = new UnifiedProspectPageController();
        contact = uppc.getContact();
        opportunity = uppc.getOpportunity();
        c = uppc.getCaseC();
        contact.FirstName = 'Test';
        contact.LastName = 'Testerson';
        contact.Lead_Email__c = 'test@asu.edu';
        contact.Phone = '4803805555';
        contact.MobilePhone = '4803806666';
        uppc.smsText = true;
        fGroup = [SELECT Id, Name FROM Case_Classification__c WHERE Name = 'Test Functional Group0' LIMIT 1];
    }

    private static testMethod void testUndergradCaseCreationCaseNoInterest() {
        Test.startTest();
        setUpController();

        uppc.career = 'undergraduate';
        Term__c testTerm = [SELECT Id FROM Term__c WHERE Name = 'Spring 2017' LIMIT 1];
        opportunity.Term__c = testTerm.Id;
        opportunity.Type = 'First Time Freshman';

        uppc.originSelection = 'Email';
        c.Subject = 'Test';
        c.Description = 'Test';
        c.CC_Functional_Group__c = fgroup.Id;
        c.Category__c = 'Admissions';
        c.Sub_Category__c = 'International';

        uppc.setContact(contact);
        uppc.setOpportunity(opportunity);
        uppc.setCaseC(c);

        uppc.pickSelection = '--Select--';

        Boolean result = uppc.save();

        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(result == true);

        contact = [SELECT Id, SF_First_Name__c, SMS_Phone__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        System.assert(contact.SF_First_Name__c == 'TEST');
        System.assert(contact.SMS_Phone__c == '4803806666');

        opportunity = [
            SELECT College__c, Academic_Plan__c, RecordTypeId, Contact__c, International_Student__c, Term__c
            FROM Opportunity
            WHERE Term__c = :testTerm.Id
            LIMIT 1
        ];

        System.assert(
            opportunity.RecordTypeID == [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id
        );

        System.assert(opportunity.Contact__c == contact.Id);
        System.assert(opportunity.International_Student__c == false);

        c = [
            SELECT Subject, Status, Case_Source__c, Origin__c
            FROM Case
            WHERE CC_Functional_Group__c = :fgroup.id
            LIMIT 1
        ];

        Campaign emailCamp = [SELECT Id FROM Campaign WHERE Name = 'Email' LIMIT 1];
        System.assert(c.Status == 'Closed: Resolved');
        System.assert(c.Case_Source__c == emailCamp.Id);
        System.assert(c.Origin__c == 'Email');

        String termName = [SELECT Term__r.Name FROM Opportunity WHERE Term__c = :opportunity.Term__c LIMIT 1]
        .Term__r.Name;

        System.assert(c.Subject == 'Test');
    }

    private static testMethod void testUndergradCaseCreationEventInterest() {
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
        uppc.getSelectedEventCamMemStatuses();

        // This emulates the Sent status picklist on the page. Because Visualforce calls
        // the getter method automatically, we'll need to call it here manually.
        uppc.getCamMemEvent();
        uppc.camMemEvent.Status = 'Sent';

        uppc.pickSelection = 'Not Null';
        Campaign interestTestCam = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Interest' LIMIT 1];

        uppc.selectedInterestId = interestTestCam.Id;
        uppc.instSearch();

        // Get page messages to pop up

        // Must select a career
        uppc.career = '--Select--';
        uppc.save();
        uppc.career = 'undergraduate';

        // Must provide phone or zip
        uppc.contact.Phone = null;
        uppc.contact.MailingPostalCode = null;
        uppc.save();
        uppc.contact.Phone = '5785785789';
        uppc.contact.MailingPostalCode = '45656';

        // Graduate career and collegeselected 0
        uppc.career = 'graduate';
        uppc.collegeSelected = '0';
        uppc.save();

        // Graduate career and term null
        uppc.opportunity.Term__c = null;
        uppc.save();
        uppc.career = 'undergraduate';
        uppc.opportunity.Term__c = testTerm.Id;

        // origin select and elId not null
        uppc.originSelection = 'something else';
        uppc.save();
        uppc.originSelection = '--Select--';

        // Origin selected null and elId null
        uppc.elId = null;
        uppc.save();
        uppc.elId = eventCampaign.Id;

        // selectedInterestId null
        uppc.selectedInterestId = null;
        uppc.save();
        uppc.selectedInterestId = interestTestCam.Id;

        PageReference referenceToCheck = uppc.savePage();

        Test.stopTest();

        PageReference control = new PageReference('/' + opportunity.Id);

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(referenceToCheck.getURL(), control.getURL());

        contact = [SELECT Id, SF_First_Name__c, SMS_Phone__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        System.assert(contact.SF_First_Name__c == 'TEST');
        System.assert(contact.SMS_Phone__c == '4803806666');

        opportunity = [
            SELECT College__c, Academic_Plan__c, RecordTypeId, Contact__c, International_Student__c, Term__c
            FROM Opportunity
            WHERE Term__c = :testTerm.Id
            LIMIT 1
        ];

        System.assert(
            opportunity.RecordTypeID == [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id
        );

        System.assert(opportunity.Contact__c == contact.Id);
        System.assert(opportunity.International_Student__c == false);

        CampaignMember camMemEvent = [
            SELECT Inbound_Interaction__c, Opportunity__c
            FROM CampaignMember
            WHERE Id = :uppc.camMemEvent.Id
            LIMIT 1
        ];

        System.assert(camMemEvent.Inbound_Interaction__c == true);
        System.assert(camMemEvent.Opportunity__c == opportunity.Id);

        uppc.setCamMemEvent(camMemEvent);
        System.assert(uppc.camMemEvent.Id == camMemEvent.Id);

        CampaignMember camMemInterest = [
            SELECT CampaignId, ContactId
            FROM CampaignMember
            WHERE Id = :uppc.camMemInterest.Id
            LIMIT 1
        ];

        System.assert(camMemInterest.CampaignId == uppc.selectedInterestId);
        System.assert(camMemInterest.ContactId == contact.Id);

        uppc.setCamMemInterest(camMemInterest);
        System.assert(uppc.camMemInterest.Id == camMemInterest.Id);
    }

    private static testMethod void testGradCaseCreation() {
        Test.startTest();
        setUpController();

        Program__c prog2 = [SELECT Id FROM Program__c WHERE Name = 'Test Grad Program' LIMIT 1];
        Plan__c plan2 = [SELECT Id FROM Plan__c WHERE Name = 'Test Grad Plan' LIMIT 1];

        uppc.career = 'graduate';
        uppc.getDepartmentsColleges();
        Term__c testTerm = [SELECT Id FROM Term__c WHERE Name = 'Spring 2017' LIMIT 1];
        opportunity.Term__c = testTerm.Id;
        opportunity.Type = 'Transfer';
        opportunity.LeadSource = 'Advertisement';
        opportunity.Lead_Source_Subtype__c = 'USA Today';
        uppc.collegeSelected = prog2.Id;
        uppc.planSelected = plan2.Id;

        uppc.originSelection = 'Incoming Call';
        c.Subject = 'Test';
        c.Description = 'Test';
        c.CC_Functional_Group__c = fgroup.Id;
        c.Category__c = 'Admissions';
        c.Sub_Category__c = 'International';

        uppc.setContact(contact);
        uppc.setOpportunity(opportunity);
        uppc.setCaseC(c);

        uppc.pickSelection = '--Select--';

        // Get page messages to pop up

        // Fail on case creation
        uppc.originSelection = '';
        uppc.caseC.CC_Functional_Group__c = null;
        uppc.save();
        uppc.originSelection = 'Incoming Call';
        uppc.caseC.CC_Functional_Group__c = fgroup.Id;

        PageReference referenceToCheck = uppc.saveAndNew();

        Test.stopTest();

        PageReference control = new PageReference('/apex/Unified_Prospect_Page?saved=true');

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(referenceToCheck.getURL(), control.getURL());

        contact = [SELECT Id, SF_First_Name__c, SMS_Phone__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        System.assert(contact.SF_First_Name__c == 'TEST');
        System.assert(contact.SMS_Phone__c == '4803806666');

        opportunity = [
            SELECT College__c, Academic_Plan__c, RecordTypeId, Contact__c, International_Student__c, Term__c
            FROM Opportunity
            WHERE Term__c = :testTerm.Id
            LIMIT 1
        ];

        System.assert(
            opportunity.RecordTypeID == [SELECT Id FROM RecordType WHERE Name = 'Graduate Prospect' LIMIT 1].Id
        );

        System.assert(opportunity.Contact__c == contact.Id);
        System.assert(opportunity.International_Student__c == false);
        System.assert(opportunity.College__c == prog2.Id);
        System.assert(opportunity.Academic_Plan__c == plan2.Id);

        c = [
            SELECT Subject, Status, Case_Source__c, Origin__c
            FROM Case
            WHERE CC_Functional_Group__c = :fgroup.Id
            LIMIT 1
        ];

        Campaign phoneCamp = [SELECT Id FROM Campaign WHERE Name = 'Phone Call' LIMIT 1];
        System.assert(c.Status == 'Closed: Resolved');
        System.assert(c.Case_Source__c == phoneCamp.Id);
        System.assert(c.Origin__c == 'Incoming Call');
        String termName = [SELECT Term__r.Name FROM Opportunity WHERE Term__c = :opportunity.Term__c LIMIT 1]
        .Term__r.Name;

        System.assert(c.Subject == 'Test');
    }

    private static testMethod void testLawCaseCreation() {
        Test.startTest();
        setUpController();

        Program__c prog3 = [SELECT Id FROM Program__c WHERE Name = 'Test Law Program' LIMIT 1];
        Plan__c plan3 = [SELECT Id FROM Plan__c WHERE Name = 'Test Law Plan' LIMIT 1];

        uppc.career = 'law';
        Term__c testTerm = [SELECT Id FROM Term__c WHERE Name = 'Spring 2017' LIMIT 1];
        opportunity.Term__c = testTerm.Id;
        opportunity.Type = 'Transfer';
        opportunity.LeadSource = 'Advertisement';
        opportunity.Lead_Source_Subtype__c = 'USA Today';
        uppc.collegeSelected = prog3.Id;
        uppc.planSelected = plan3.Id;

        uppc.originSelection = 'Walk In';
        c.Subject = 'Test';
        c.Description = 'Test';
        c.CC_Functional_Group__c = fgroup.Id;
        c.Category__c = 'Admissions';
        c.Sub_Category__c = 'International';

        uppc.setContact(contact);
        uppc.setOpportunity(opportunity);
        uppc.setCaseC(c);

        uppc.pickSelection = '--Select--';

        Boolean result = uppc.save();

        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(result == true);

        contact = [SELECT Id, SF_First_Name__c, SMS_Phone__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        System.assert(contact.SF_First_Name__c == 'TEST');
        System.assert(contact.SMS_Phone__c == '4803806666');

        opportunity = [
            SELECT College__c, Academic_Plan__c, RecordTypeId, Contact__c, International_Student__c, Term__c
            FROM Opportunity
            WHERE Term__c = :testTerm.Id
            LIMIT 1
        ];

        System.assert(
            opportunity.RecordTypeID == [SELECT Id FROM RecordType WHERE Name = 'Graduate Prospect' LIMIT 1].Id
        );

        System.assert(opportunity.Contact__c == contact.Id);
        System.assert(opportunity.International_Student__c == false);
        System.assert(opportunity.College__c == prog3.Id);
        System.assert(opportunity.Academic_Plan__c == plan3.Id);

        c = [
            SELECT Subject, Status, Case_Source__c, Origin__c
            FROM Case
            WHERE CC_Functional_Group__c = :fgroup.Id
            LIMIT 1
        ];

        Campaign phoneCamp = [SELECT Id FROM Campaign WHERE Name = 'Walk In' LIMIT 1];
        System.assert(c.Status == 'Closed: Resolved');
        System.assert(c.Case_Source__c == phoneCamp.Id);
        System.assert(c.Origin__c == 'Walk In');

        String termName = [SELECT Term__r.Name FROM Opportunity WHERE Term__c = :opportunity.Term__c LIMIT 1]
        .Term__r.Name;

        System.assert(c.Subject == 'Test');
    }

    private static testMethod void testGetContact() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();
        Contact con = uppc.getContact();
        Test.stopTest();
        System.assert(con.Id == null);
    }

    private static testMethod void testGetOpportunity() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();
        Opportunity op = uppc.getOpportunity();
        Id oppRecType = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;

        Test.stopTest();
        System.assert(op.RecordTypeId == oppRecType);
    }

    private static testMethod void testGetCase() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();
        c = uppc.getCaseC();
        Id asuAdmissionRecId = [SELECT Id, Name FROM RecordType WHERE Name = 'ASU Admission Services' LIMIT 1].Id;

        System.assert(c.RecordTypeId == asuAdmissionRecId);
    }

    private static testMethod void testGetPreviousEducation() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();
        Previous_Education__c pe = uppc.getPreviousEducation();
        Test.stopTest();
        System.assert(pe.Id == null);
    }

    private static testMethod void testGetCampaignMemberInterest() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();
        CampaignMember cmi = uppc.getCamMemInterest();
        Test.stopTest();
        System.assert(cmi.Id == null);
    }

    private static testMethod void testGetCampaignMemberEvent() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();
        CampaignMember cme = uppc.getCamMemEvent();
        Test.stopTest();
        System.assert(cme.Id == null);
    }

    private static testMethod void testGetProgramList() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();

        Program__c prog = [SELECT Id FROM Program__c WHERE Name = 'Test Undergrad Program' LIMIT 1];
        Program__c prog2 = [SELECT Id FROM Program__c WHERE Name = 'Test Grad Program' LIMIT 1];
        Program__c prog3 = [SELECT Id FROM Program__c WHERE Name = 'Test Law Program' LIMIT 1];

        uppc.career = 'undergraduate';
        List<SelectOption> selProg = uppc.ProgramList;
        System.assert(selProg.get(0).getValue() == '0');
        System.assert(selProg.get(1).getValue() == prog.Id);

        uppc.career = 'graduate';
        selProg = uppc.ProgramList;
        System.assert(selProg.get(0).getValue() == '0');
        System.assert(selProg.get(1).getValue() == prog2.Id);

        uppc.career = 'law';
        selProg = uppc.ProgramList;
        System.assert(selProg.get(0).getValue() == '0');
        System.assert(selProg.get(1).getValue() == prog3.Id);
    }

    private static testMethod void testGetplanList() {
        Test.startTest();
        uppc = new UnifiedProspectPageController();

        Program__c prog = [SELECT Id FROM Program__c WHERE Name = 'Test Undergrad Program' LIMIT 1];
        Program__c prog2 = [SELECT Id FROM Program__c WHERE Name = 'Test Grad Program' LIMIT 1];
        Program__c prog3 = [SELECT Id FROM Program__c WHERE Name = 'Test Law Program' LIMIT 1];

        Plan__c plan = [SELECT Id FROM Plan__c WHERE Name = 'Test Undergrad Plan' LIMIT 1];
        Plan__c plan2 = [SELECT Id FROM Plan__c WHERE Name = 'Test Grad Plan' LIMIT 1];
        Plan__c plan3 = [SELECT Id FROM Plan__c WHERE Name = 'Test Law Plan' LIMIT 1];

        uppc.collegeSelected = prog.Id;
        List<SelectOption> selPlan = uppc.planList;
        System.assert(selPlan.get(0).getValue() == '0');
        System.assert(selPlan.get(1).getValue() == plan.Id);

        uppc.collegeSelected = prog2.Id;
        selPlan = uppc.planList;
        System.assert(selPlan.get(0).getValue() == '0');
        System.assert(selPlan.get(1).getValue() == plan2.Id);

        uppc.collegeSelected = prog3.Id;
        selPlan = uppc.planList;
        System.assert(selPlan.get(0).getValue() == '0');
        System.assert(selPlan.get(1).getValue() == plan3.Id);
    }

    private static testMethod void testSetPrevEducation() {
        setUpController();
        insert contact;

        Previous_Education__c prevEd = new Previous_Education__c(Contact__c = contact.Id);
        insert prevEd;

        uppc = new UnifiedProspectPageController();
        uppc.setPreviousEducation(prevEd);
        System.assert(uppc.previousEducation.Id == prevEd.Id);
    }

    private static testMethod void testEventList() {
        Campaign tempEvent = [SELECT Id, Name FROM Campaign WHERE Name = 'ASU Test Event'];

        Id[] fixedSearchResults = new List<Id>(1);
        fixedSearchResults[0] = tempEvent.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        uppc = new UnifiedProspectPageController();
        uppc.eventSearchString = 'ASU Test Event';
        uppc.eventSearch();

        Campaign testEvent = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Event' LIMIT 1];
        System.assert(uppc.getEventList().size() == 1);
        System.assert(uppc.getEventList().get(0).Id == testEvent.Id);
    }

    private static testMethod void testASUCollegesIntList() {
        uppc = new UnifiedProspectPageController();
        List<SelectOption> asuCollegesIntList = uppc.getASUCollegesIntList();

        Campaign testASUCollege = [SELECT Id FROM Campaign WHERE Name = 'ASU Test College' LIMIT 1];

        System.assert(asuCollegesIntList.size() == 2);
        System.assert(asuCollegesIntList.get(1).getValue() == testASUCollege.Id);
    }

    private static testMethod void testASULocationIntList() {
        uppc = new UnifiedProspectPageController();
        List<SelectOption> asuLocationIntList = uppc.getASULocationIntList();

        Campaign testASULocation = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Location' LIMIT 1];

        System.assert(asuLocationIntList.size() == 2);
        System.assert(asuLocationIntList.get(1).getValue() == testASULocation.Id);
    }

    private static testMethod void testASUAcademicIntList() {
        uppc = new UnifiedProspectPageController();
        List<SelectOption> asuAcademicIntList = uppc.getAcademicIntList();

        Campaign testASUAcademic = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Academic' LIMIT 1];

        System.assert(asuAcademicIntList.size() == 2);
        System.assert(asuAcademicIntList.get(1).getValue() == testASUAcademic.Id);
    }
}
