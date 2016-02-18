@isTest
private class Test_HelpDeskController
{
    @isTest static void testCreateContactCreateCaseSaveCase()
    {
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters
        ApexPages.currentPage().getParameters().put('ANI', '4805551213');
        ApexPages.currentPage().getParameters().put('phone', '4805551213');
        ApexPages.currentPage().getParameters().put('birthdate', '12/12/1970');
        ApexPages.currentPage().getParameters().put('firstname', 'John');
        ApexPages.currentPage().getParameters().put('lastname', 'Doe');
        ApexPages.currentPage().getParameters().put('asuriteid', 'jdoe');
        ApexPages.currentPage().getParameters().put('emplid', '1111111');
        ApexPages.currentPage().getParameters().put('directoryemail', 'noone@asu.edu');
        ApexPages.currentPage().getParameters().put('personalemail', 'noone@asu.edu');


        HelpDeskController controller = new HelpDeskController();
        controller.runSearch();
        controller.toggleSort();
        controller.clearContactSearch();
        controller.newContact();
        controller.cancelNewContact();
        controller.newContact();
        controller.mycontact.lastname = 'Doe';
        controller.saveContact();
        controller.newCase();
        controller.cancelCase();
        controller.newCase();
        controller.saveCase();
        controller.mycase.Subject = 'test';
        controller.mycase.Description = 'test';
        controller.saveCase();
    }

    @isTest static void testCreateContactCreateCaseSaveAndCloseCase()
    {
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters
        ApexPages.currentPage().getParameters().put('ANI', '4805551213');
        ApexPages.currentPage().getParameters().put('phone', '4805551213');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('lastname', '');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');


        HelpDeskController controller = new HelpDeskController();

        // Search phone fields.
        controller.runSearch();

        // Search birthdate (SOQL).
        ApexPages.currentPage().getParameters().put('phone', '');
        ApexPages.currentPage().getParameters().put('birthdate', '12/12/1970');
        controller.runSearch();

        // Search name fields.
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', 'John');
        controller.runSearch();

        // Search email fields.
        ApexPages.currentPage().getParameters().put('firstname', '');
        ApexPages.currentPage().getParameters().put('directoryemail', 'noone@asu.edu');
        controller.runSearch();

        controller.toggleSort();
        controller.clearContactSearch();
        controller.newContact();
        controller.cancelNewContact();
        controller.newContact();
        controller.mycontact.lastname = 'Doe';
        controller.saveContact();
        controller.newCase();
        controller.cancelCase();
        controller.newCase();
        controller.saveAndCloseCase();
        controller.cancelCloseCase();
        controller.saveAndCloseCase();
        List<SelectOption> closeStatuses = new List<SelectOption>();
        closeStatuses = controller.getcloseCaseStatusOptions();

        System.assertNotEquals(closeStatuses.size(), 0);
        controller.selectedCloseCaseStatusOption = closeStatuses[0].getValue();
        controller.saveCloseCase();
    }

    @isTest static void testCreateContactCreateCaseSaveAndTransferCase()
    {
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        // Populate some initial Contact search parameters
        ApexPages.currentPage().getParameters().put('ANI', '4805551213');
        ApexPages.currentPage().getParameters().put('phone', '4805551213');
        ApexPages.currentPage().getParameters().put('birthdate', '12/12/1970');
        ApexPages.currentPage().getParameters().put('firstname', 'John');
        ApexPages.currentPage().getParameters().put('lastname', 'Doe');
        ApexPages.currentPage().getParameters().put('asuriteid', 'jdoe');
        ApexPages.currentPage().getParameters().put('emplid', '1111111');
        ApexPages.currentPage().getParameters().put('directoryemail', 'noone@asu.edu');
        ApexPages.currentPage().getParameters().put('personalemail', 'noone@asu.edu');


        HelpDeskController controller = new HelpDeskController();
        controller.runSearch();
        controller.toggleSort();
        controller.clearContactSearch();
        controller.newContact();
        controller.cancelNewContact();
        controller.newContact();
        controller.mycontact.FirstName = 'John';
        controller.mycontact.LastName = 'Doe';
        controller.mycontact.Email = 'test@nomail.com';
        controller.mycontact.MailingPostalCode = '11111';
        controller.saveContact();
        controller.newCase();
        controller.cancelCase();
        controller.newCase();
        controller.saveAndCloseCase();
        controller.cancelCloseCase();
        PageReference failPage = controller.saveAndTransferCase();
        controller.mycase.Subject = 'test';
        controller.mycase.Description = 'test';
        PageReference pr = controller.saveAndTransferCase();

        System.assertNotEquals(pr, null);
    }

    @isTest static void testSearchExistingContactExistingCase()
    {
        PageReference pageRef = Page.HelpDesk;
        Test.setCurrentPage(pageRef);

        Contact testContact = new Contact(
            Firstname = 'John',
            Lastname = 'Doe',
            Phone = '(480) 555-1213',
            Email = 'noone@asu.edu'
        );

        insert testContact;

        Case testCase = new Case(
            Subject = 'test subject',
            Description = 'test description',
            ContactId = testContact.Id
        );

        insert testCase;

        // Populate some initial Contact search parameters
        ApexPages.currentPage().getParameters().put('ANI', '4805551213');
        ApexPages.currentPage().getParameters().put('phone', '4805551213');
        ApexPages.currentPage().getParameters().put('birthdate', '');
        ApexPages.currentPage().getParameters().put('firstname', 'John');
        ApexPages.currentPage().getParameters().put('lastname', 'Doe');
        ApexPages.currentPage().getParameters().put('asuriteid', '');
        ApexPages.currentPage().getParameters().put('emplid', '');
        ApexPages.currentPage().getParameters().put('directoryemail', '');
        ApexPages.currentPage().getParameters().put('personalemail', '');

        HelpDeskController controller = new HelpDeskController();
        controller.runSearch();
        controller.toggleSort();
        controller.selectedContactId = testContact.Id;
        controller.contacts.add(testContact);
        controller.setAsContact();
        controller.setAsHelpDeskProvidedPhone();
        controller.mycase = testCase;
        controller.selectedCaseId = testCase.Id;

        HelpDeskController.CaseWrapper mycasewrapper = new HelpDeskController.CaseWrapper(
            controller.mycase
        );

        controller.cases.add(mycasewrapper);
        controller.setAsCase();
        PageReference transferCasePage = controller.saveAndTransferCase();
    }
}