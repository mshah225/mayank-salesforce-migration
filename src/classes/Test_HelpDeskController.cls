@isTest
private class Test_HelpDeskController
{
    private static void setUpTest()
    {
        List<Contact> testContacts = ContactService.createTestContacts(2);

        testContacts[0].Phone = '1111111111';
        testContacts[0].EMPLID__c = '1111111111';

        testContacts[1].FirstName = 'Non-Affiliate';
        testContacts[1].LastName = 'Caller';

        insert testContacts;

        TestDataFactory.createFunctionalGroup('Help Desk');

    }

    @isTest static void testCreateContactCreateCaseSaveCase()
    {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = [
            SELECT Id, Name, Phone, EMPLID__c
            FROM Contact
            WHERE EMPLID__c = '1111111111'
        ];

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

    @isTest static void testCreateCaseSaveAndClose()
    {
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

        Contact testContact = [
            SELECT Id, Name, Phone, EMPLID__c
            FROM Contact
            WHERE EMPLID__c = '1111111111'
        ];

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
        controller.selectedCloseCaseStatusOption = closeStatuses[1].getValue();
        controller.saveCloseCase();

        Test.stopTest();

        PageReference queuePage = new PageReference('/500?fcf=00Bd0000005TDlX');

        System.assertNotEquals(closeStatuses.size(), 0);

        List<Case> testCase1 = [
            SELECT Id, Status
            FROM Case
            WHERE Id = :controller.mycase.Id
        ];

        if (testCase1.size() > 0)
        {
            System.assert(testCase1[0].Status.contains('Closed'));
        }
    }

    @isTest static void testSetAsCaseForArticlePop()
    {
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

        Contact testContact = [
            SELECT Id, Name, Phone, EMPLID__c
            FROM Contact
            WHERE EMPLID__c = '1111111111'
        ];

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
        FAQ__kav faqArticle = [
            SELECT KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id = :testFAQ.id
        ];

        // Publish said FAQ
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        // Create a new CaseArticle with the FAQ and Case
        CaseArticle art = new CaseArticle(
            CaseId = caseList[0].Id,
            KnowledgeArticleId = faqArticle.KnowledgeArticleId
        );

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

    @isTest static void testKnowledgeSearchAttachAndRemove()
    {
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

        Contact testContact = [
            SELECT Id, Name, Phone, EMPLID__c
            FROM Contact
            WHERE EMPLID__c = '1111111111'
        ];

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
        FAQ__kav faqArticle = [
            SELECT KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id = :testFAQ.id
        ];

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
        faqArticle = [
            SELECT KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id = :testFAQ.id
        ];

        // Publish said FAQ
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        // Create a new CaseArticle with the FAQ and Case
        CaseArticle art = new CaseArticle(
            CaseId = caseList[0].Id,
            KnowledgeArticleId = faqArticle.KnowledgeArticleId
        );

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

        List<CaseArticle> caseArtList = [
            SELECT Id
            FROM CaseArticle
            WHERE CaseId = :caseList[0].Id
        ];

        System.assertEquals(0, caseArtList.size());
    }

    @isTest
    private static void caseClassificationCorrectSelectOptions() {
       HelpDeskController controller = new HelpDeskController();

       CaseClassificationFactory ccMaker = new CaseClassificationFactory();
       ccMaker.createAndInsertSetOfCaseClassification();
       Case myCase = new Case();
       myCase.CC_Functional_Group__r = [SELECT Id, Name FROM Case_Classification__c
                                        WHERE RecordType.Name = 'Functional Group'
                                        AND Name = 'Test Functional Group0'
                                        LIMIT 1];
       myCase.CC_Functional_Group__r.Name='Help Desk';
       update myCase.CC_Functional_Group__r;
        
       Case_Classification__c categoryCreated = [SELECT Id, Name FROM Case_Classification__c WHERE Name = 'Test Category0'];

       controller.newCase();

       controller.selectedCategory = categoryCreated.Id;

       System.assertEquals(1, controller.functionalGroupOptions.size());
       System.assertEquals(2, controller.categoryOptions.size());
       System.assertEquals(2, controller.subCategoryOptions.size());

       Test.startTest();
       controller.selectedCategory = '--';
       controller.updateCategoryAndSubCategory();
       Test.stopTest();

       System.assertEquals(1, controller.functionalGroupOptions.size());
       System.assertEquals(2, controller.categoryOptions.size());
       System.assertEquals(1, controller.subCategoryOptions.size());
    }

    @isTest
    private static void noVisibleCategoriesUnderFunctionalGroup() {
       HelpDeskController controller = new HelpDeskController();

       CaseClassificationFactory ccMaker = new CaseClassificationFactory();
       ccMaker.createAndInsertSetOfCaseClassification();
       ccMaker.createAndInsertSetOfNotVisibleCaseClassification();
       Case myCase = new Case();
       myCase.CC_Functional_Group__r = [SELECT Id, Name FROM Case_Classification__c
                                        WHERE RecordType.Name = 'Functional Group'
                                        AND Name = 'Not Visible Functional Group0'
                                        LIMIT 1];
       myCase.CC_Functional_Group__r.Visible__c=true;
       update myCase.CC_Functional_Group__r;
       controller.myCase=myCase;

       controller.selectedFunctionalGroup = 'Not Visible Functional Group0';
       controller.selectedCategory= '--';

       System.assertEquals(2, controller.functionalGroupOptions.size());
       System.assertEquals(1, controller.categoryOptions.size());
       System.assertEquals(1, controller.subCategoryOptions.size());

       Test.startTest();
       controller.updateCategoryAndSubCategory();
       Test.stopTest();

       System.assertEquals('Not Visible Functional Group0', controller.functionalGroupOptions.get(0).getValue());
       System.assertEquals('--', controller.categoryOptions.get(0).getValue());
       System.assertEquals('--', controller.subCategoryOptions.get(0).getValue());
    }

    @isTest static void testCreateContactCreateCaseSaveCaseWithErrors()
    {
        setUpTest();
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = [
            SELECT Id, Name, Phone, EMPLID__c
            FROM Contact
            WHERE EMPLID__c = '1111111111'
        ];

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
        controller.mycontact.LastName = 'Doe';
        controller.saveContact();

        // Create the new Case and back out for coverage.
        controller.newCase();
        controller.cancelCase();

        // This flags an error on sub and desc.
        controller.newCase();
        controller.saveCase();

        // Fill out the sub and desc, move status to Closed Forwarded to error on Forward To Unit Required.
        controller.myCase.Subject = 'test';
        controller.myCase.Description = 'test';
        controller.myCase.Status = 'Closed: Forwarded';
        controller.saveCase();

        Boolean foundError = false;
        for (ApexPages.Message msg : ApexPages.getMessages()) if (msg.getDetail().contains('Forward to Unit is required')) foundError = true;
        System.assert(foundError, '\'Forward to Unit is required\' should have shown up as a Page error.');

        controller.myCase.Forward_To_Unit__c = 'Other Unit';
        controller.saveCase();

        foundError = false;
        for (ApexPages.Message msg : ApexPages.getMessages()) if (msg.getDetail().contains('Forward to Email is required')) foundError = true;
        System.assert(foundError, '\'Forward to Email is required\' should have shown up as a Page error.');

        controller.myCase.Forward_To_Unit__c = 'ServiceNow';
        controller.saveCase();

        foundError = false;
        for (ApexPages.Message msg : ApexPages.getMessages()) if (msg.getDetail().contains('Service Now Ticket Number is required')) foundError = true;
        System.assert(foundError, '\'Service Now Ticket Number is required\' should have shown up as a Page error.');

        controller.myCase.Forward_To_Unit__c = 'Other Unit';
        controller.myCase.Forward_To_Email__c = 'someforward@nomail.com';
        controller.saveCase();

        Test.stopTest();

        PageReference control = new PageReference('/' + controller.mycase.Id);

        System.assertEquals(control.getUrl(), controller.saveCase().getUrl());
    }
}
