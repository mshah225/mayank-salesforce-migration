@isTest
private class SuccessPortal_SearchPageController_Tests
{
	
    private static void setUpTest()
    {
        List<Contact> testContacts = ContactService.createTestContacts(2);

        testContacts[0].Phone = '1111111111';
        testContacts[0].EMPLID__c = '1111111111';

        testContacts[1].FirstName = 'Non-Affiliate';
        testContacts[1].LastName = 'Caller';

        insert testContacts;
    }

    @isTest static void testCreateContactCreateCaseSaveCase()
    {
        setUpTest();
        PageReference pageRef = Page.SuccessPortal_SearchPage;
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

        SuccessPortal_SearchPageController spc = new SuccessPortal_SearchPageController();

        // Test cancel new contact after case selection
        spc.selectedContactId = testContact.Id;
        spc.selectedCaseId = caseList[0].Id;
        spc.setAsCase();
        spc.newContact();
        spc.cancelNewContact();

        // Clear out search
        spc.clearContactSearch();

        // Create the new contact.
        spc.newContact();
        spc.mycontact.lastname = 'Doe';
        spc.saveContact();

        // Create the new Case and back out for coverage.
        spc.newCase();
        spc.cancelCase();

        // This flags an error on sub and desc.
        spc.newCase();
        spc.saveCase();

        // Fill out the sub and desc to properly save the case.
        spc.mycase.Subject = 'test';
        spc.mycase.Description = 'test';
        spc.saveCase();

        Test.stopTest();

        PageReference control = new PageReference('/' + spc.mycase.Id);

        System.assertEquals(control.getUrl(), spc.saveCase().getUrl());
    }

    @isTest static void testCreateCaseSaveAndClose()
    {
        setUpTest();
        PageReference pageRef = Page.SuccessPortal_SearchPage;
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

        SuccessPortal_SearchPageController spc = new SuccessPortal_SearchPageController();

        // Flip these just to render the page back and forth.
        spc.newContact();
        spc.cancelNewContact();
        spc.setAsHelpDeskProvidedPhone();

        // Test null search
        spc.buildSearchString();

        // Search phone sizes.
        ApexPages.currentPage().getParameters().put('birthdate', '08/12/1989');
        ApexPages.currentPage().getParameters().put('phone', '111');
        spc.buildSearchString();

        ApexPages.currentPage().getParameters().put('phone', '1111');
        spc.buildSearchString();

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
        spc.buildSearchString();

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
        spc.buildSearchString();

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
        spc.buildSearchString();

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
        spc.buildSearchString();
        spc.sortField = 'firstname';
        spc.toggleSort();

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
        spc.buildSearchString();

        // Create new case to save and close
        spc.newCase();

        // Get sub and desc error to trigger
        spc.saveAndCloseCase();
        spc.cancelCloseCase();

        // Add sub and desc to save
        spc.mycase.Subject = 'Test';
        spc.mycase.Description = 'Testing';
        spc.saveAndCloseCase();

        // Get index 1 for close status, so its not --Select--
        List<SelectOption> closeStatuses = spc.getcloseCaseStatusOptions();
        spc.selectedCloseCaseStatusOption = closeStatuses[1].getValue();
        spc.saveCloseCase();

        Test.stopTest();

        PageReference queuePage = new PageReference('/500?fcf=00Bd0000005TDlX');

        System.assertNotEquals(closeStatuses.size(), 0);

        List<Case> testCase1 = [
            SELECT Id, Status
            FROM Case
            WHERE Id = :spc.mycase.Id
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

        SuccessPortal_SearchPageController spc = new SuccessPortal_SearchPageController();
        spc.selectedCaseId = caseList[0].Id;
        spc.setAsCase();

        // Make this fail with no sub and des
        spc.mycase.Subject = '';
        spc.mycase.Description = '';
        spc.saveAndTransferCase();

        // Add sub and desc and save again
        spc.mycase.Subject = 'Test';
        spc.mycase.Description = 'Testing desc';
        spc.saveAndTransferCase();

        Test.stopTest();

        PageReference control = new PageReference('/apex/CaseTransfer?id=' + spc.mycase.Id);
        System.assertEquals(control.getUrl(), spc.saveAndTransferCase().getUrl());
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

        SuccessPortal_SearchPageController spc = new SuccessPortal_SearchPageController();
        spc.selectedContactId = testContact.Id;
        spc.setAsContact();
        spc.selectedCaseId = caseList[0].Id;
        spc.setAsCase();

        // Test null search for knowledge
        spc.knowledgeSearch();

        // Test with string
        spc.knowString = 'test';
        spc.knowledgeSearch();
        spc.selectedKnowledgeArticleId = faqArticle.KnowledgeArticleId;
        spc.articleDetails();
        spc.attachArticleToCase();
        spc.removeArticleFromCase();

        Test.stopTest();

        List<CaseArticle> caseArtList = [
            SELECT Id
            FROM CaseArticle
            WHERE CaseId = :caseList[0].Id
        ];

        System.assertEquals(0, caseArtList.size());
    }
}