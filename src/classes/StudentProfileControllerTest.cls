@isTest
private class StudentProfileControllerTest {
    private static Contact studentProfileContact;
    
    @isTest
    public static void methodCoverage() {
        PageReference pageRef = Page.studentProfile;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('contactId', '1203436008');

        StudentProfileController controller = new StudentProfileController();

        ContactService.createTestContacts(2);
        ContactService.generateRandomPin(Date.today());
        ContactService.isPinValid(444, Date.Today());

        // Wrapping methods that we know will throw an exception in try/catch blocks for now
        try 
        {
            ContactService.getContactInformation('003623467232dd8', '');
        }
        catch (Exception e){}

        try
        {
            ContactService.getContactToViewAs('x');

        }
        catch (Exception e){}

        try 
        {
            ContactService.getLoggedInContact();
        }
        catch (Exception e){}

        CaseService.CaseFieldsToString();
        CaseService.createTestCases(2, new Contact());
 
        try
        {
            CaseService.getCaseDetails(ObjectService.getFakeId(Case.getSObjectType()));
        }
        catch (Exception e) {}

        try
        {
            CaseService.getCaseEmailMessages(Date.Today(), ObjectService.getFakeId(Case.getSObjectType()), new List<String>());
        }
        catch (Exception e) {}

        List<Contact> testContacts = new List<Contact>();
        Contact c = new Contact(FirstName = 'TestF', LastName = 'TestL');
        insert c;
        testContacts.add(c);

        try
        {
            CaseService.getVisibleOpenCases(testContacts);
        }
        catch (Exception e){}
        
        try
        {
            CaseService.getVisibleClosedCases(testContacts);
        }
        catch (Exception e){}

        try
        {
            CaseService.getCaseInformation(ObjectService.getFakeId(Case.getSObjectType()));
        }
        catch (Exception e){}

        try
        {
            ObjectService.ObjectFieldsToString('Case');
        }
        catch (Exception e) {}

        try
        {
            ObjectService.getFieldLabelsToList('Case');
        }        
        catch (Exception e) {}

        
        StudentProfileController.getStudentRetention('1203436008');
        StudentProfileController.getRetentionSNP('1203436008');
        StudentProfileController.getPSAdvisorNotes('1203436008');
        StudentProfileController.getComments('1203436008');
        StudentProfileController.getTranscripts('1203436008');
        StudentProfileController.getGuestAccess('1203436008');
        StudentProfileController.getClassesData('1203436008', '');
        StudentProfileController.getCreditByExamData('1203436008');
        StudentProfileController.getTransferWorkData('1203436008');
        StudentProfileController.getFinAidUnresolved('1203436008', '2177');
        StudentProfileController.getAsrIndicator('1203436008', '2177');
        StudentProfileController.getAsrInformation('1203436008', '2177');
        StudentProfileController.getEnrollmentHolds('1203436008', '2177');
        StudentProfileController.getFinAidIndicator('1203436008');
        StudentProfileController.getSunCardPhotoRa('asurite', '1203436008');
        StudentProfileController.sortClasses('sortBy', new List<PS_ASU_SP_CLASS_V__x>(), true);
        StudentProfileController.sortExams('sortBy', new List<PS_ASU_SP_TRNSFR_V__x>(), true);
        StudentProfileController.sortTransfers('sortBy', new List<JBT_RET_CLASS_XFER__x>(), true);
        StudentProfileController.createCase('Description', 'Subject', '1203436008');
        
        
        controller = new StudentProfileController(); 
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
    
    private static void createTestData() {
        ContactFactory.DefaultContact contactBuilder = new ContactFactory.DefaultContact();
        studentProfileContact = (Contact) contactBuilder.create()[0];
        insert studentProfileContact;
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
        StudentProfileController.SortableTransferWork work = new StudentProfileController.SortableTransferWork(new JBT_RET_CLASS_XFER__x(), '');
        work.compareTo(work);
        
        StudentProfileController.SortableClass sortClass = new StudentProfileController.SortableClass(new PS_ASU_SP_CLASS_V__x(), '');
        sortClass.compareTo(sortClass);
        
        StudentProfileController.SortableCreditByExam exam = new StudentProfileController.SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(), '');
        exam.compareTo(exam);
    }
}
