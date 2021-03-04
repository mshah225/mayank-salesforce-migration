@isTest
private class Test_UndergradNewProspectController {
    private static UndergradNewProspectController ug;

    @testSetup
    static void setUpTest() {
        Account testAccount = new Account(Name = 'Test School');
        insert testAccount;

        Campaign testEventCam = new Campaign(
            Name = 'ASU Test Event',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event']
            .Id
        );
        insert testEventCam;

        Campaign testEmailCam = new Campaign(
            Name = 'Email',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Event']
            .Id
        );
        insert testEmailCam;

        Campaign testIntCam = new Campaign(
            Name = 'ASU Test Interest',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Interest']
            .Id
        );
        insert testIntCam;

        Case_Classification__c cc = new Case_Classification__c();
        cc.Name = 'Business';
        cc.Active__c = true;
        cc.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Functional Group')
            .getRecordTypeId();
        insert cc;
    }

    private static void setUpController() {
        ug = new UndergradNewProspectController();
        ug.getContact();
        ug.getOpportunity();
        ug.getPreviousEducation();
        ug.getCampaignMemberEvent();
        ug.getCampaignMemberInterest();
        ug.getC();
        ug.setContact(ug.contact);
        ug.setOpportunity(ug.opportunity);
        ug.setPreviousEducation(ug.previousEducation);
        ug.setCampaignMemberEvent(ug.camMemEvent);
        ug.setCampaignMemberInterest(ug.camMemInterest);
        ug.setCase(ug.c);
        ug.eventSearchString = 'ASU Test';
        ug.eventSearch();
        ug.getEventList();
        ug.instSearch();
        ug.getInstList();
        ug.getASULocationIntList();
        ug.getAcademicIntList();
        ug.getASUCollegesIntList();
    }

    @isTest
    static void testCaseCreation() {
        Test.startTest();
        setUpController();

        // Page selections
        ug.originSelection = 'Email';
        ug.pickSelection = '--Select--';

        // Create case
        ug.c.CC_Functional_Group__c = [
            SELECT ID
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE
            LIMIT 1
        ]
        .ID;
        ug.c.Subject = 'Test Subject';

        // Create contact
        ug.contact.FirstName = 'Test';
        ug.contact.LastName = 'Contact';
        ug.contact.Lead_Email__c = 'test@email.com';
        ug.contact.Phone = '(484) 484-4848';

        // Create previous education
        Id testSchool = [SELECT Id FROM Account WHERE Name = 'Test School'].Id;
        ug.previousEducation.Account__c = testSchool;
        ug.savePage();
        Test.stopTest();

        System.assertNotEquals(null, ug.contact);
        System.assertNotEquals(null, ug.c);
    }

    @isTest
    static void testOptionalInterest() {
        Campaign interestTestCam = [SELECT Id, Name FROM Campaign WHERE Name = 'ASU Test Interest'];
        Id testSchool = [SELECT Id FROM Account WHERE Name = 'Test School'].Id;

        setUpController();

        Test.startTest();

        // Page selections
        ug.originSelection = 'Email';
        ug.pickSelection = interestTestCam.Name;
        ug.selectedInterestId = interestTestCam.Id;

        // Create case
        ug.c.CC_Functional_Group__c = [
            SELECT ID
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE
            LIMIT 1
        ]
        .ID;
        ug.c.Subject = 'Test Subject';

        // Create contact
        ug.contact.FirstName = 'Test';
        ug.contact.LastName = 'Contact';
        ug.contact.Lead_Email__c = 'test@email.com';
        ug.contact.Phone = '(484) 484-4848';

        // Create previous education
        ug.previousEducation.Account__c = testSchool;
        ug.savePage();

        Test.stopTest();

        System.assertNotEquals(null, ug.contact);
        System.assertNotEquals(null, ug.camMemInterest);
    }

    @isTest
    static void testSaveErrors() {
        Test.setCurrentPage(Page.UndergradNewProspect);
        setUpController();
        ug.originSelection = 'Nothing';
        ug.pickSelection = '--Select--';
        Id testEl = [SELECT Id FROM Campaign WHERE Name = 'ASU Test Event'].Id;
        ug.elId = testEl;
        ug.savePage();
        ApexPages.Message[] msgs = ApexPages.getMessages();
        Boolean found = false;
        for (ApexPages.Message msg : msgs) {
            if (msg.getSummary() == 'You must select either ONE case OR ONE event.') {
                found = true;
            }
        }
        System.assert(found);

        ug.originSelection = '--Select--';
        ug.elId = null;
        ug.savePage();
        msgs = ApexPages.getMessages();
        found = false;
        for (ApexPages.Message msg : msgs) {
            if (msg.getSummary() == 'You must select either ONE case OR ONE event.') {
                found = true;
            }
        }
        System.assert(found);

        ug.originSelection = 'Email';
        ug.pickSelection = 'Something';
        ug.elId = null;
        ug.savePage();
        msgs = ApexPages.getMessages();
        found = false;
        for (ApexPages.Message msg : msgs) {
            if (msg.getSummary() == 'After selecting a type of interest, you must select an interest.') {
                found = true;
            }
        }
        System.assert(found);

        ug.originSelection = 'Email';
        ug.pickSelection = '--Select--';
        ug.c.CC_Functional_Group__c = null;
        ug.elId = null;
        ug.savePage();
        msgs = ApexPages.getMessages();
        found = false;
        for (ApexPages.Message msg : msgs) {
            if (msg.getSummary() == 'When selecting an Origin, you must also select a Functional Group.') {
                found = true;
            }
        }
        System.assert(found);
    }

    @isTest
    static void testContactValidation() {
        setUpController();

        ug.originSelection = 'Email';
        ug.pickSelection = '--Select--';

        ug.c.CC_Functional_Group__c = [
            SELECT ID
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE
            LIMIT 1
        ]
        .ID;
        ug.c.Subject = 'Test Subject';

        ug.contact.FirstName = 'Test';
        ug.contact.LastName = 'Contact';
        ug.contact.Email = 'test@nomail.com';
        ug.contact.MailingPostalCode = null;
        ug.contact.Phone = null;

        Id testSchool = [SELECT Id FROM Account WHERE Name = 'Test School'].Id;
        ug.previousEducation.Account__c = testSchool;
        ug.savePage();

        ApexPages.Message[] msgs = ApexPages.getMessages();
        Boolean found = false;
        for (ApexPages.Message msg : msgs) {
            if (
                msg.getSummary() ==
                'You must fill out these required fields in order to save the contact: First Name, Last Name, Email, and one of these two fields: Phone or Zip Code.'
            ) {
                found = true;
            }
        }
        System.assert(found);
    }
}
