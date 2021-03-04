@isTest
public class Test_AdvisorPortalMainPage {
    private static Integer numberOfPods;
    private static Integer numberOfCases;
    private static Integer numberOfStudents;
    private static Integer numberOfTabsForUser;
    private static Integer numberOfBlankOptionsForUser;
    private static Integer numberOfTabsForManager;
    private static Integer numberOfBlankOptionsForManager;
    private static Integer numbeOfAdvisorsForManager;
    private static AdvisorPortalMainPageController apmpc;

    /*
     * Static initialization code to mimize repeat code between test methods
     * values take into consideration user having themselves as a viewAsOptions
     * for success resources of type 'User'
     */
    static {
        numberOfPods = 3;
        numberOfCases = 1;
        numberOfStudents = 10;
        numberOfTabsForUser = 2;
        numberOfBlankOptionsForUser = 1;
        numberOfTabsForManager = 3;
        numberOfBlankOptionsForManager = 2;
        numbeOfAdvisorsForManager = 1;
        apmpc = new AdvisorPortalMainPageController();
    }

    @isTest
    private static void checkUserViewAsOptions() {
        UserFactory.makeMeAnAdvisorUser(numberOfPods, numberOfCases, numberOfStudents);

        Test.startTest();
        List<SelectOption> listToTest = apmpc.viewAsOptions;
        Test.stopTest();

        validateUserOptionsSize(listToTest);
        validateCurrentUserOption(listToTest);
        validateBlankOptionsForUser(listToTest);
        validateTabsForUser(listToTest);
        validateCommitteesGroupId(listToTest);
    }

    @isTest
    private static void Test_allowedToMassTransfer() {
        User allowedUser1 = TestDataFactory.createUser(
            'test-mass-transfer-r1',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        User allowedUser2 = TestDataFactory.createUser(
            'test-mass-transfer-r2',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        User unallowedUser1 = TestDataFactory.createUser(
            'test-mass-transfer-r3',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        User unallowedUser2 = TestDataFactory.createUser(
            'test-mass-transfer-r4',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        User unallowedUser3 = TestDataFactory.createUser(
            'test-mass-transfer-r5',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        insert new List<User>{ allowedUser1, allowedUser2, unallowedUser1, unallowedUser2, unallowedUser3 };

        Success_Resource__c allowedUser1Resource = new Success_Resource__c(
            Resource__c = allowedUser1.Id,
            Role__c = 'Department Manager',
            IsActive__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c allowedUser2Resource = new Success_Resource__c(
            Resource__c = allowedUser2.Id,
            Role__c = 'College Manager',
            IsActive__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c unallowedUserResource = new Success_Resource__c(
            Resource__c = unallowedUser1.Id,
            Role__c = 'User',
            IsActive__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c unallowedUserResource2 = new Success_Resource__c(
            Resource__c = unallowedUser2.Id,
            Role__c = 'College Manager',
            IsActive__c = false,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        insert new List<Success_Resource__c>{
            allowedUser1Resource,
            allowedUser2Resource,
            unallowedUserResource,
            unallowedUserResource2
        };

        System.runAs(allowedUser1) {
            apmpc = new AdvisorPortalMainPageController();
            System.assert(apmpc.allowedToMassTransfer, 'Department Manager\'s should be allowed to use this feature');
        }
        System.runAs(allowedUser2) {
            apmpc = new AdvisorPortalMainPageController();
            System.assert(apmpc.allowedToMassTransfer, 'College Manager\'s should be allowed to use this feature');
        }
        System.runAs(unallowedUser1) {
            apmpc = new AdvisorPortalMainPageController();
            System.assert(!apmpc.allowedToMassTransfer, 'User\'s should not be allowed to use this feature');
        }
        System.runAs(unallowedUser2) {
            apmpc = new AdvisorPortalMainPageController();
            System.assert(!apmpc.allowedToMassTransfer, 'Should not consider inactive Success_Resources');
        }
        System.runAs(unallowedUser3) {
            apmpc = new AdvisorPortalMainPageController();
            System.assert(!apmpc.allowedToMassTransfer, 'Default (if no Success_Resources) should be to not allow');
        }
    }

    /*
     * As of right now the answer to this question should always be true.
     * We need to figure out under what circumstances the view as functionality should
     * be displayed and update the controller method.
     */
    public static testMethod void Test_getHasViewAs() {
        system.assert(true, apmpc.hasViewAs);
    }

    /*
     * MimicId has basic getter and setter. We still need to test for code coverate.
     *
     * <p>
     * This may seem simple and unecessary; however, if the getter/setter changes in the future,
     * this will ensure that the new getter/setter are compatible with existing functionality.
     * </p>
     */
    public static testMethod void Test_getSetMimicId() {
        apmpc.OwnerId = UserInfo.getUserId();
        system.assertEquals(UserInfo.getUserId(), apmpc.OwnerId);
    }

    public static testMethod void Test_getAdvisorEmailRTID() {
        system.assertEquals(IDHelper.getRTID('Portal_Email__c', 'Advisor'), apmpc.advisorEmailRTID);
    }

    public static testMethod void Test_getAdvisorProactiveCaseRTID() {
        system.assertEquals(IDHelper.getRTID('Case', 'ASU_Advisor_Outreach'), apmpc.AdvisorProactiveCaseRTID);
    }

    public static testMethod void Test_getAdvisorReactiveCaseRTID() {
        system.assertEquals(IDHelper.getRTID('Case', 'ASU_Service'), apmpc.AdvisorReactiveCaseRTID);
    }

    public static testMethod void Test_getQueries() {
        apmpc.ownerId = UserInfo.getUserId();

        system.assert(apmpc.myProactiveQuery.contains((String) apmpc.OwnerId));
        system.assert(apmpc.myWatchlistQuery.contains((String) apmpc.OwnerId));
        system.assert(apmpc.myStudentsQuery.contains((String) apmpc.OwnerId));
    }

    @isTest
    private static void checkDepartmentManagerViewAsOptions() {
        UserFactory.makeMeAnAdvisorDepartmentManager(numberOfPods, numberOfCases, numberOfStudents);

        Test.startTest();
        List<SelectOption> listToTest = apmpc.viewAsOptions;
        Test.stopTest();

        validateManagerOptionsSize(listToTest);
        validateCurrentUserOption(listToTest);
        validateBlankOptionsForManager(listToTest);
        validateTabsForDepartmentManager(listToTest);
        validateCommitteesGroupId(listToTest);
    }

    @isTest
    private static void checkCollegeManagerViewAsOptions() {
        UserFactory.makeMeAnAdvisorCollegeManager(numberOfPods, numberOfCases, numberOfStudents);

        Test.startTest();
        List<SelectOption> listToTest = apmpc.viewAsOptions;
        Test.stopTest();

        validateManagerOptionsSize(listToTest);
        validateCurrentUserOption(listToTest);
        validateBlankOptionsForManager(listToTest);
        validateTabsForCollegeManager(listToTest);
        validateCommitteesGroupId(listToTest);
    }

    private static void validateUserOptionsSize(List<SelectOption> listToTest) {
        System.assertEquals(numberOfTabsForUser + numberOfBlankOptionsForUser + numberOfPods, listToTest.size());
    }

    private static void validateManagerOptionsSize(List<SelectOption> listToTest) {
        System.assertEquals(
            numberOfTabsForManager +
            numberOfBlankOptionsForManager +
            numbeOfAdvisorsForManager +
            numberOfPods,
            listToTest.size()
        );
    }

    private static void validateCurrentUserOption(List<SelectOption> listToTest) {
        System.assertEquals(UserInfo.getName(), listToTest[0].getLabel());
        System.assertEquals(UserInfo.getUserId(), listToTest[0].getValue());
    }

    private static void validateBlankOptionsForUser(List<SelectOption> listToTest) {
        System.assertEquals('', listToTest[1].getLabel());
        System.assertEquals('', listToTest[1].getValue());
        System.assert(listToTest[1].getDisabled());
    }

    private static void validateBlankOptionsForManager(List<SelectOption> listToTest) {
        System.assertEquals('', listToTest[1].getLabel());
        System.assertEquals('', listToTest[1].getValue());
        System.assert(listToTest[1].getDisabled());

        System.assertEquals('', listToTest[6].getLabel());
        System.assertEquals('', listToTest[6].getValue());
        System.assert(listToTest[6].getDisabled());
    }

    private static void validateTabsForUser(List<SelectOption> listToTest) {
        System.assertEquals('--My Committees--', listToTest[2].getLabel());
        System.assertEquals('', listToTest[2].getValue());
        System.assert(listToTest[2].getDisabled());
    }

    private static void validateTabsForDepartmentManager(List<SelectOption> listToTest) {
        System.assertEquals('--Department Committees--', listToTest[2].getLabel());
        System.assertEquals('', listToTest[2].getValue());
        System.assert(listToTest[2].getDisabled());

        System.assertEquals('--Department Advisors--', listToTest[7].getLabel());
        System.assertEquals('', listToTest[7].getValue());
        System.assert(listToTest[7].getDisabled());
    }

    private static void validateTabsForCollegeManager(List<SelectOption> listToTest) {
        System.assertEquals('--College Advisors--', listToTest[7].getLabel());
        System.assertEquals('', listToTest[7].getValue());
        System.assert(listToTest[7].getDisabled());
    }

    private static void validateCommitteesGroupId(List<SelectOption> listToTest) {
        Validator.setPrefix(Group.class);
        Integer firstCommitteeOptionIndex = 3;
        for (Integer i = firstCommitteeOptionIndex; i < firstCommitteeOptionIndex + numberOfPods; i++) {
            System.assert(Validator.validateId(listToTest[i].getValue()));
        }
    }
}
