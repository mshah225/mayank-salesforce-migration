@isTest
private class HelpDeskControllerTest {
    private static void setUpTest() {
        List<Contact> testContacts = ContactService.createTestContacts(2);

        testContacts[0].Phone = '1111111111';
        testContacts[0].EMPLID__c = '1111111111';

        testContacts[1].FirstName = 'Non-Affiliate';
        testContacts[1].LastName = 'Caller';

        insert testContacts;

        TestDataFactory.createFunctionalGroup('Help Desk');
    }

    @isTest
    private static void testCreateContactCreateCaseSaveCase() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        List<Case> caseList = CaseService.createTestCases(2, testContact);

        insert caseList;

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        HelpDeskController controller = new HelpDeskController();

        // Test cancel new contact after case selection
        controller.selectedContactId = testContact.Id;
        controller.selectedCaseId = caseList[0].Id;
        controller.setAsCase();
        controller.newContact();
        controller.cancelNewContact();

        // Clear out search
        controller.clearContactSearch();

        // Create the new contact.
        controller.newContact();
        controller.mycontact.lastname = 'Doe';
        controller.saveContact();

        // Create the new Case and back out for coverage.
        controller.newCase();
        controller.cancelCase();

        // This flags an error on sub and desc.
        controller.newCase();
        controller.saveCase();

        // Fill out the sub and desc to properly save the case.
        controller.mycase.Subject = 'test';
        controller.mycase.Description = 'test';
        controller.saveCase();

        Test.stopTest();

        PageReference control = new PageReference('/' + controller.mycase.Id);

        System.assertEquals(control.getUrl(), controller.saveCase().getUrl());
    }

    @isTest
    private static void testCreateCaseSaveAndClose() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        HelpDeskController controller = new HelpDeskController();

        // Flip these just to render the page back and forth.
        controller.newContact();
        controller.cancelNewContact();
        controller.setAsHelpDeskProvidedPhone();

        // Test null search
        controller.buildSearchString();

        // Search phone sizes.
        ApexPages.currentPage().getParameters().put('birthdate', '08/12/1989');
        ApexPages.currentPage().getParameters().put('phone', '111');
        controller.buildSearchString();

        ApexPages.currentPage().getParameters().put('phone', '1111');
        controller.buildSearchString();

        // Search name only.
        ApexPages.currentPage().getParameters().put('ANI', '');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', 'test');
        ApexPages.currentPage().getParameters().put('lastname', 'test');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');
        controller.buildSearchString();

        // Search phone only.
        ApexPages.currentPage().getParameters().put('ANI', '');
        ApexPages.currentPage().getParameters().put('phone', '1111111111');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');
        controller.buildSearchString();

        // Search email fields.
        ApexPages.currentPage().getParameters().put('ANI', '');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', 'test@nomail.com');
        ApexPages.currentPage().getParameters().put('personalemail', 'test@nomail.com');
        controller.buildSearchString();

        // Test full date search
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('phone', '1111111111');
        ApexPages.currentPage().getParameters().put('birthdate', '08/12/1989');
        ApexPages.currentPage().getParameters().put('firstname', 'test');
        ApexPages.currentPage().getParameters().put('lastname', 'test');
        ApexPages.currentPage().getParameters().put('asuriteid', 'testtest');
        ApexPages.currentPage().getParameters().put('emplid', '1111111111');
        ApexPages.currentPage().getParameters().put('directoryemail', 'test@nomail.com');
        ApexPages.currentPage().getParameters().put('personalemail', 'test@nomail.com');
        controller.buildSearchString();
        controller.sortField = 'firstname';
        controller.toggleSort();

        // Test full no date search
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('phone', '1111111111');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', 'test');
        ApexPages.currentPage().getParameters().put('lastname', 'test');
        ApexPages.currentPage().getParameters().put('asuriteid', 'testtest');
        ApexPages.currentPage().getParameters().put('emplid', '1111111111');
        ApexPages.currentPage().getParameters().put('directoryemail', 'test@nomail.com');
        ApexPages.currentPage().getParameters().put('personalemail', 'test@nomail.com');
        controller.buildSearchString();

        // Create new case to save and close
        controller.newCase();

        // Get sub and desc error to trigger
        controller.saveAndCloseCase();
        controller.cancelCloseCase();

        // Add sub and desc to save
        controller.mycase.Subject = 'Test';
        controller.mycase.Description = 'Testing';
        controller.saveAndCloseCase();

        // Get index 1 for close status, so its not --Select--
        List<SelectOption> closeStatuses = controller.getcloseCaseStatusOptions();
        controller.saveAndCloseCase();

        Test.stopTest();

        PageReference queuePage = new PageReference('/500?fcf=00Bd0000005TDlX');

        System.assertNotEquals(closeStatuses.size(), 0);

        List<Case> testCase1 = [SELECT Id, Status FROM Case WHERE Id = :controller.mycase.Id];

        if (testCase1.size() > 0) {
            System.assert(testCase1[0].Status.contains('Closed'));
        }
    }

    @isTest
    private static void testSetAsCaseForArticlePop() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        List<Case> caseList = CaseService.createTestCases(3, testContact);

        insert caseList;

        // Create a test FAQ
        FAQ__kav testFAQ = new FAQ__kav(
            Title = 'Testing a FAQ for the test',
            Answer__c = 'This is the body of the FAQ',
            UrlName = 'Testing-a-FAQ-for-the-test'
        );

        insert testFAQ;

        // After insert, query back for the KnowlegeArticleId
        FAQ__kav faqArticle = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :testFAQ.id];

        // Publish said FAQ
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        // Create a new CaseArticle with the FAQ and Case
        CaseArticle art = new CaseArticle(CaseId = caseList[0].Id, KnowledgeArticleId = faqArticle.KnowledgeArticleId);

        insert art;

        Test.startTest();

        HelpDeskController controller = new HelpDeskController();
        controller.selectedCaseId = caseList[0].Id;
        controller.setAsCase();

        // Make this fail with no sub and des
        controller.mycase.Subject = '';
        controller.mycase.Description = '';
        controller.saveAndTransferCase();

        // Add sub and desc and save again
        controller.mycase.Subject = 'Test';
        controller.mycase.Description = 'Testing desc';
        controller.saveAndTransferCase();

        Test.stopTest();

        PageReference control = new PageReference('/apex/CaseTransfer?id=' + controller.mycase.Id);
        System.assertEquals(control.getUrl(), controller.saveAndTransferCase().getUrl());
    }

    @isTest
    private static void testKnowledgeSearchAttachAndRemove() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        List<Case> caseList = CaseService.createTestCases(3, testContact);

        insert caseList;

        // Create a test FAQ
        FAQ__kav testFAQ = new FAQ__kav(
            Title = 'Testing FAQ for Articles',
            Answer__c = 'This is the body of the FAQ',
            UrlName = 'Testing-FAQ-for-Articles'
        );

        insert testFAQ;

        // After insert, query back for the KnowlegeArticleId
        FAQ__kav faqArticle = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :testFAQ.id];

        // Publish said FAQ
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        // Create a second FAQ for testing the search params.
        testFAQ = new FAQ__kav(
            Title = 'Testing FAQ for Articles2',
            Answer__c = 'This is the body of the FAQ',
            UrlName = 'Testing-FAQ-for-Articles2'
        );

        insert testFAQ;

        // After insert, query back for the KnowlegeArticleId
        faqArticle = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :testFAQ.id];

        // Publish said FAQ
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        // Create a new CaseArticle with the FAQ and Case
        CaseArticle art = new CaseArticle(CaseId = caseList[0].Id, KnowledgeArticleId = faqArticle.KnowledgeArticleId);

        insert art;

        // Set the results for the SOSL search to the contact and FAQ
        Id[] fixedSearchResults = new Id[2];
        fixedSearchResults[0] = testContact.Id;
        fixedSearchResults[1] = faqArticle.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.setAsContact();
        controller.selectedCaseId = caseList[0].Id;
        controller.setAsCase();

        // Test null search for knowledge
        controller.knowledgeSearch();

        // Test with string
        controller.knowString = 'test';
        controller.knowledgeSearch();
        controller.selectedKnowledgeArticleId = faqArticle.KnowledgeArticleId;
        controller.articleDetails();
        controller.attachArticleToCase();
        controller.removeArticleFromCase();

        Test.stopTest();

        List<CaseArticle> caseArtList = [SELECT Id FROM CaseArticle WHERE CaseId = :caseList[0].Id];

        System.assertEquals(0, caseArtList.size());
    }

    @isTest
    private static void testCreateContactCreateCaseSaveCaseWithForwardToUnitError() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        List<Case> caseList = CaseService.createTestCases(2, testContact);
        insert caseList;

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.selectedCaseId = caseList[0].Id;
        controller.setAsCase();

        controller.myCase.Subject = 'test';
        controller.myCase.Description = 'test';
        controller.myCase.Status = 'Closed: Forwarded';

        Test.startTest();
        controller.saveCase();
        Test.stopTest();

        Boolean foundError = false;
        for (ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Closed: Forwarded')) {
                foundError = true;
            }
        }
        System.assert(
            foundError,
            'Forward to Unit is required, so the validation rule should have shown up as a Page error.'
        );
    }

    @isTest
    private static void testCreateContactCreateCaseSaveCaseWithForwardToEmailError() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        List<Case> caseList = CaseService.createTestCases(2, testContact);
        insert caseList;

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.selectedCaseId = caseList[0].Id;
        controller.setAsCase();

        controller.myCase.Subject = 'test';
        controller.myCase.Description = 'test';
        controller.myCase.Status = 'Closed: Forwarded';
        controller.myCase.Forward_To_Unit__c = 'Other Unit';

        Test.startTest();
        controller.saveCase();
        Test.stopTest();

        Boolean foundError = false;
        for (ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Closed: Forwarded')) {
                foundError = true;
            }
        }
        System.assert(
            foundError,
            'Forward to Unit should have been required, so the validation rule should have shown up as a Page error.'
        );
    }

    @isTest
    private static void testCreateContactCreateCaseSaveCaseWithServiceNowError() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        List<Case> caseList = CaseService.createTestCases(2, testContact);
        insert caseList;

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.selectedCaseId = caseList[0].Id;
        controller.setAsCase();

        controller.myCase.Subject = 'test';
        controller.myCase.Description = 'test';
        controller.myCase.Status = 'Closed: Forwarded';
        controller.myCase.Forward_To_Unit__c = 'ServiceNow';

        Test.startTest();
        controller.saveCase();
        Test.stopTest();

        Boolean foundError = false;
        for (ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('ServiceNow')) {
                foundError = true;
            }
        }
        System.assert(
            foundError,
            'ServiceNow Ticket Number field should have been required, so the validation rule should have shown up as a Page error.'
        );
    }

    @isTest
    private static void createNewCaseCloseSaveAndTransferErrorBug() {
        setUpTest();
        Test.setCurrentPage(Page.HelpDesk);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.newCase();

        controller.myCase.Subject = 'test';
        controller.myCase.Description = 'test';
        controller.myCase.Status = 'Closed: Forwarded';
        controller.myCase.Forward_To_Unit__c = 'ServiceNow';
        controller.myCase.ServiceNow_Ticket_Number__c = 'sn-1212';

        Test.startTest();
        controller.saveAndTransferCase();
        Test.stopTest();
    }

    @isTest
    private static void saveAndCloseCaseStatusChanged() {
        setUpTest();
        Test.setCurrentPage(Page.HelpDesk);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.newCase();

        controller.myCase.Subject = 'test to close';
        controller.myCase.Description = 'test';

        Test.startTest();
        controller.saveAndCloseCase();
        Test.stopTest();

        Case savedCase = [SELECT Status FROM Case WHERE Subject = 'test to close' LIMIT 1];

        System.assertEquals('Closed: Resolved', savedCase.Status);
    }

    @isTest
    private static void saveAndCloseCaseStatusUnchangedWhenClosed() {
        setUpTest();
        Test.setCurrentPage(Page.HelpDesk);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.newCase();

        controller.myCase.Subject = 'test to close';
        controller.myCase.Description = 'test';
        controller.myCase.Status = 'Closed: Forwarded';
        controller.myCase.Forward_To_Unit__c = 'ServiceNow';
        controller.myCase.ServiceNow_Ticket_Number__c = 'sn-1212';

        Test.startTest();
        controller.saveAndCloseCase();
        Test.stopTest();

        Case savedCase = [SELECT Status FROM Case WHERE Subject = 'test to close' LIMIT 1];

        System.assertNotEquals('Closed: Resolved', savedCase.Status);
        System.assertEquals(controller.myCase.Status, savedCase.Status);
    }

    @isTest
    private static void selectCaseEditCancelChangesCleared() {
        setUpTest();
        Test.setCurrentPage(Page.HelpDesk);

        Contact testContact = [SELECT Id, Name, Phone, EMPLID__c FROM Contact WHERE EMPLID__c = '1111111111'];

        CaseFactory.DefaultCase factory = new CaseFactory.DefaultCase();
        factory.setRelatedObject('ContactId', testContact);
        Integer numberOfCases = 2;
        List<Case> cases = factory.create(numberOfCases);
        insert cases;

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        HelpDeskController controller = new HelpDeskController();
        controller.selectedContactId = testContact.Id;
        controller.setAsContact();

        controller.selectedCaseId = cases[0].Id;
        controller.setAsCase();

        String originalSubject = controller.myCase.Subject;
        String originalStatus = controller.myCase.Status;

        String testValue = 'TestStringValue Should Not Be Changed';
        controller.myCase.Subject = testValue;
        controller.myCase.Status = testValue;

        Test.startTest();
        controller.cancelCase();
        Test.stopTest();

        controller.selectedCaseId = cases[0].Id;
        controller.setAsCase();

        System.assertNotEquals(testValue, controller.myCase.Subject);
        System.assertNotEquals(testValue, controller.myCase.Status);
        System.assertEquals(originalSubject, controller.myCase.Subject);
        System.assertEquals(originalStatus, controller.myCase.Status);

        List<Case> totalCases = [SELECT Id FROM Case];
        System.assertEquals(numberOfCases, totalCases.size());
    }

    @isTest
    private static void redirectedByCustomConfiguration() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        List<Help_Desk_Caller_Settings__mdt> config = [
            SELECT Destination__c, DNIS__c
            FROM Help_Desk_Caller_Settings__mdt
            WHERE MasterLabel = 'DEI Participant'
        ];

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('DNIS', config[0].DNIS__c);
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        HelpDeskController controller = new HelpDeskController();
        PageReference pre;

        Test.startTest();
        pre = controller.preCheck();
        Test.stopTest();

        System.assertEquals(config[0].Destination__c, pre.getUrl());
    }

    @isTest
    private static void notRedirectedByCustomConfiguration() {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters/set empty fields.
        ApexPages.currentPage().getParameters().put('ANI', '1111111111');
        ApexPages.currentPage().getParameters().put('DNIS', '4802291234');
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        HelpDeskController controller = new HelpDeskController();
        PageReference pre;

        Test.startTest();
        pre = controller.preCheck();
        Test.stopTest();

        System.assertEquals(null, pre);
    }
}
