@isTest
private class StudentProfileControllerTest {
    private static Contact studentProfileContact;
    
    @isTest
    private static void methodCoverage() {
        Test.setCurrentPage(Page.studentProfile);
        ApexPages.currentPage().getParameters().put('contactId', '1203436008');

        StudentProfileController controller = new StudentProfileController();
        ContactService.createTestContacts(2);
        ContactService.generateRandomPin(Date.today());
        ContactService.isPinValid(444, Date.Today());
        CaseService.CaseFieldsToString();
        CaseService.createTestCases(2, new Contact());
        List<Contact> testContacts = new List<Contact>();
        Contact c = new Contact(FirstName = 'TestF', LastName = 'TestL');
        insert c;
        testContacts.add(c);

        try {
            ContactService.getContactInformation('003623467232dd8', '');
        } catch (Exception e) {}

        try {
            ContactService.getContactToViewAs('x');
        } catch (Exception e) {}

        try {
            ContactService.getLoggedInContact();
        } catch (Exception e) {}

        try {
            CaseService.getCaseDetails(ObjectService.getFakeId(Case.getSObjectType()));
        } catch (Exception e) {}

        try {
            CaseService.getCaseEmailMessages(Date.Today(), ObjectService.getFakeId(Case.getSObjectType()), new List<String>());
        } catch (Exception e) {}

        try {
            CaseService.getVisibleOpenCases(testContacts);
        } catch (Exception e) {}
        
        try {
            CaseService.getVisibleClosedCases(testContacts);
        } catch (Exception e) {}

        try {
            CaseService.getCaseInformation(ObjectService.getFakeId(Case.getSObjectType()));
        } catch (Exception e) {}

        try {
            ObjectService.ObjectFieldsToString('Case');
        } catch (Exception e) {}

        try {
            ObjectService.getFieldLabelsToList('Case');
        } catch (Exception e) {}

        StudentProfileController.getSunCardPhotoRa('asurite', '1203436008');
        StudentProfileController.sortExams('sortBy', new List<PS_ASU_SP_TRNSFR_V__x>(), true);
        StudentProfileController.sortTransfers('sortBy', new List<JBT_RET_CLASS_XFER__x>(), true);
        StudentProfileController.createCase('Description', 'Subject', '1203436008');
    }
    
    @isTest
    private static void initCoverage() {
        createTestData();
        
        PageReference studentProfile = Page.StudentProfile;
        studentProfile.getParameters().put('contactId',  studentProfileContact.Id);
        Test.setCurrentPage(studentProfile);
        
        StudentProfileController controller = new StudentProfileController();
        controller.init();
    }

    @isTest
    private static void financialNeedLevelDisplaySuccess() {
        createTestData();
        
        PageReference studentProfile = Page.StudentProfile;
        studentProfile.getParameters().put('contactId',  studentProfileContact.Id);
        Test.setCurrentPage(studentProfile);
        
        StudentProfileController controller = new StudentProfileController();
        controller.init();

        System.assertEquals('2000', controller.getAidYear());
        System.assertEquals('Moderate', controller.financialAidPackage.EFC_Range__c);

    }
    
    private static void createTestData() {
        ContactFactory.DefaultContact contactBuilder = new ContactFactory.DefaultContact();
        studentProfileContact = (Contact) contactBuilder.create()[0];
        insert studentProfileContact;
        insert new StudentTerm__c(CurrTerm__c = '2000', PrevTerm__c = '1000', NextTerm__c = '3000'); 
        insert new Term__c(Name = 'Test 2000', PeopleSoft_Code__c = '2000', Year__c = '2019', Aid_Year__c = '2000');
        insert new Financial_Aid_Package__c(Aid_Year__c = '2000', Contact__c = studentProfileContact.Id, EFC_Range__c = 'Moderate');
    }
    
    @isTest
    private static void coverageForGetters() {
        StudentProfileController controller = new StudentProfileController();
        System.debug(controller.theContact);
        System.debug(controller.openCases);
        System.debug(controller.sGroupList);
        System.debug(controller.ugProgramPlans);
        System.debug(controller.gradProgramPlans);
        System.debug(controller.studentProgram);
        System.debug(controller.ugStudentProgram);
        System.debug(controller.gradStudentProgram);
        System.debug(controller.suncardPhotoURL);
        System.debug(controller.deceased);
        System.debug(controller.currentTerm);
        System.debug(controller.currentTermName);
        System.debug(controller.nextTermName);
        
        System.debug(controller.serviceIndicators);
        System.debug(controller.ugStudentProgramAdvisors);
        System.debug(controller.gradStudentProgramAdvisors);
        System.debug(controller.studentAccount);
        System.debug(controller.financialAidPackage);
        System.debug(controller.me3Results);
        System.debug(controller.me3HighSchoolResults);
        System.debug(controller.studentMilestonesUGrad);
        System.debug(controller.studentMilestonesGrad);
        System.debug(controller.faWrapper);
        System.debug(controller.testUndergradScoreList);
        System.debug(controller.testGradScoreList);
    }
    
    @isTest
    private static void coverageForComparables() {
        SortableTransferWork work = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(), '');
        work.compareTo(work);
        
        SortableClass sortClass = new SortableClass(new PS_ASU_SP_CLASS_V__x(), '');
        sortClass.compareTo(sortClass);
        
        SortableCreditByExam exam = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(), '');
        exam.compareTo(exam);
    }

    @IsTest
    private static void getWICHE() {
        Contact testContact = new Contact(
                FirstName = 'Super',
                LastName = 'Gary',
                EMPLID__c = '1234567890'
        );
        Database.insert(testContact);

        Student_Group__c testGroup = new Student_Group__c(
                SG_Contact__c = testContact.Id,
                SG_PeopleSoft_Code__c = 'WRGP',
                SG_Status__c = true
        );
        Database.insert(testGroup);

        Test.startTest();
        Test.setCurrentPage(Page.studentProfile);
        ApexPages.currentPage().getParameters().put(
                'contactId', testContact.Id
        );
        StudentProfileController profile = new StudentProfileController();
        profile.init();
        Boolean result = profile.getWICHE();
        Test.stopTest();

        System.assert(result, 'WICHE was not detected correctly');
    }
}
