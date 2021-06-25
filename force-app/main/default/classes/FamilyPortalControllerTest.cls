@isTest
private class FamilyPortalControllerTest {
    @isTest
    private static void testExistingGuardian() {
        Family_Portal_Guardian__c guardian = new Family_Portal_Guardian__c();
        guardian.First_Name__c = 'Testy';
        guardian.Middle_Name__c = 'Tom';
        guardian.Last_Name__c = 'McTesterson';
        guardian.Email__c = UserInfo.getUserEmail();
        guardian.Phone__c = '5555555555';
        guardian.ASU_Alumni__c = 'Yes';
        guardian.Country__c = 'United States';
        guardian.Street__c = '123 Test St';
        guardian.City__c = 'Cityville';
        guardian.State__c = 'Alaska';
        guardian.Zip_Code__c = '88888';
        guardian.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        insert guardian;

        FamilyPortalController controller = new FamilyPortalController();

        Test.setCurrentPage(Page.FamilyPortalStep1);

        ApexPages.currentPage().getParameters().put('hid', 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5');
        ApexPages.currentPage().getParameters().put('bu', 'businessunit');

        Test.setCurrentPage(Page.FamilyPortalStep2);

        Family_Portal_Guardian__c fpg = controller.familyPortalGuardian;
        fpg.First_Name__c = 'Testy';
        fpg.Middle_Name__c = 'Tom';
        fpg.Last_Name__c = 'McTesterson';
        fpg.Email__c = UserInfo.getUserEmail();
        fpg.Phone__c = '5555555555';
        fpg.ASU_Alumni__c = 'Yes';
        fpg.Country__c = 'United States';
        fpg.Street__c = '123 Test St';
        fpg.City__c = 'Cityville';
        fpg.State__c = 'Alaska';
        fpg.Zip_Code__c = '88888';
        fpg.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        controller.hashId = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        insert fpg;
    }

    @isTest
    private static void testMethods() {
        FamilyPortalController controller = new FamilyPortalController();
        controller.getCountryCodePicklistValues();
        controller.getGuardianCountryOptions();
        controller.getGuardianInterestChoices();
        controller.getGuardianStateOptions();

        Test.setCurrentPage(Page.FamilyPortalStep4);
        controller.addStudentRow();
        ApexPages.currentPage().getParameters().put('index', '0');
        controller.removeStudentRow();
    }

    @isTest
    private static void testVariables() {
        FamilyPortalController controller = new FamilyPortalController();
        Family_Portal_Guardian__c guardian = new Family_Portal_Guardian__c();
        guardian.Country__c = 'United States';
        Boolean guardianSelectedCountryIsCanada = controller.guardianSelectedCountryIsCanada;
        Boolean guardianSelectedCountryIsUS = controller.guardianSelectedCountryIsUS;
        Boolean guardianSelectedCountryIsUnitedStatesOrCanada = controller.guardianSelectedCountryIsUnitedStatesOrCanada;
        guardian.Country__c = 'Canada';
        guardianSelectedCountryIsCanada = controller.guardianSelectedCountryIsCanada;
        guardianSelectedCountryIsUS = controller.guardianSelectedCountryIsUS;
        guardianSelectedCountryIsUnitedStatesOrCanada = controller.guardianSelectedCountryIsUnitedStatesOrCanada;
        guardian.Country__c = 'Germany';
        guardianSelectedCountryIsCanada = controller.guardianSelectedCountryIsCanada;
        guardianSelectedCountryIsUS = controller.guardianSelectedCountryIsUS;
        guardianSelectedCountryIsUnitedStatesOrCanada = controller.guardianSelectedCountryIsUnitedStatesOrCanada;

        controller.guardianSelectedInterests = new List<String>{ 'Mentoring', 'ASU Athletics' };
        List<String> guardianSelectedInterests = controller.guardianSelectedInterests;
    }

    @isTest
    private static void testSetExistingGuardianData() {
        FamilyPortalController controller = new FamilyPortalController();
        Family_Portal_Guardian__c guardian = new Family_Portal_Guardian__c();
        guardian.ASURITE_ID__c = 'tmct';
        guardian.EMPLID__c = '111111111';
        guardian.Business_Unit_Source__c = 'bu';
        guardian.First_Name__c = 'Testy';
        guardian.Middle_Name__c = 'Tom';
        guardian.Last_Name__c = 'McTesterson';
        guardian.Email__c = 'tmct@asu.edu.dev';
        guardian.Phone__c = '5555555555';
        guardian.ASU_Alumni__c = 'Yes';
        guardian.Country__c = 'United States';
        guardian.Street__c = '123 Test St';
        guardian.City__c = 'Cityville';
        guardian.State__c = 'Alaska';
        guardian.Zip_Code__c = '88888';
        guardian.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        insert guardian;

        controller.hashId = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        controller.setExistingGuardianData(guardian);
        controller.prepopulateExistingGuardianData();

        Family_Portal_Student__c fps = new Family_Portal_Student__c();
        fps.Enrollment_Status__c = 'K-12 Student';
        fps.Enrollment_Status_Year__c = '2040';
        fps.Family_Portal_Guardian__c = guardian.Id;
        insert fps;

        Family_Portal_Student__c fps2 = new Family_Portal_Student__c();
        fps2.Enrollment_Status__c = 'K-12 Student';
        fps2.Enrollment_Status_Year__c = '2042';
        fps2.Family_Portal_Guardian__c = guardian.Id;
        insert fps2;

        controller.setExistingStudents(guardian);
    }

    @isTest
    private static void testPageSequence() {
        FamilyPortalController controller = new FamilyPortalController();
        Family_Portal_Guardian__c fpg = controller.familyPortalGuardian;
        Family_Portal_Guardian_Interest__c fpgi = controller.familyPortalGuardianInterest;
        List<FamilyPortalController.FamilyPortalStudentWrapper> studentWrapperList = controller.studentWrapperList;

        Test.setCurrentPage(controller.familyPortalStep1());
        controller.familyPortalStep1OnLoad();

        Test.setCurrentPage(controller.familyPortalStep2());
        controller.familyPortalStep2OnLoad();
        fpg.First_Name__c = 'Testy';
        fpg.Middle_Name__c = 'Tom';
        fpg.Last_Name__c = 'McTesterson';
        fpg.Email__c = 'tmct@asu.edu.dev';
        fpg.Phone__c = '5555555555';
        fpg.ASU_Alumni__c = 'Yes';
        fpg.Country__c = 'United States';
        fpg.Street__c = '123 Test St';
        fpg.City__c = 'Cityville';
        fpg.State__c = 'Alaska';
        fpg.Zip_Code__c = '88888';

        Test.setCurrentPage(controller.familyPortalStep3());
        controller.familyPortalStep3OnLoad();
        fpgi.Interest_Choices__c = 'Mentoring;ASU Athletics';
        fpgi.Chosen_Interest__c = 'Mentoring';
        fpgi.Active_Interest__c = true;

        Test.setCurrentPage(controller.familyPortalStep4());
        controller.familyPortalStep4OnLoad();
        Family_Portal_Student__c familyPortalStudentObj = new Family_Portal_Student__c();
        familyPortalStudentObj.Active_Relationship__c = true;
        familyPortalStudentObj.Enrollment_Status__c = 'K-12 Student';
        familyPortalStudentObj.Enrollment_Status_Year__c = '2040';
        FamilyPortalController.FamilyPortalStudentWrapper fpsw = new FamilyPortalController.FamilyPortalStudentWrapper(
            familyPortalStudentObj,
            0
        );
        studentWrapperList.add(fpsw);

        Test.setCurrentPage(controller.familyPortalStep5());
        controller.familyPortalStep5OnLoad();

        Test.setCurrentPage(controller.sendUserToLoginScreen());
    }
}
