@isTest
public class StudentSearchControllerTest {
    // Tests the StudentSearchController initialization with access to Student 360
    @isTest
    static void testStudentSearchControllerWithAccess() {
        Test.startTest();
        StudentSearchController controller = new StudentSearchController();
        controller.hasStudent360Access = true;
        controller.init();
        Test.stopTest();
    }

    // Tests the StudentSearchController initialization without access to Student 360
    @isTest
    static void testStudentSearchControllerWithoutAccess() {
        Test.startTest();
        StudentSearchController controller = new StudentSearchController();
        controller.hasStudent360Access = false;
        controller.init();
        Test.stopTest();
    }

    // Test padding
    @isTest
    private static void testPadding() {
        Test.startTest();
        StudentSearchController controller = new StudentSearchController();
        controller.init();
        Test.stopTest();

        Boolean a1 = controller.showRestrictedStudent360ToSubstituteUser;
        Boolean a2 = controller.substituteUserHasStudent360Access;
        Boolean a3 = controller.loggedInUserHasStudent360Access;
        UserHelper.SubstituteUserWrapper a4 = controller.substituteUser;
    }

    // Test get messages
    @isTest
    private static void testStudentSearchMessages() {
        Test.startTest();
        StudentSearchController controllerStd = new StudentSearchController();
        controllerStd.fakeStudentSearchMessages = true;
        controllerStd.init();
        Test.stopTest();

        Assert.areEqual(1, controllerStd.studentSearchMessages?.size());
        Assert.areEqual(0, controllerStd.studentSearchRestrictedMessages?.size());
    }

    // Test get messages
    @isTest
    private static void testStudentSearchMessagesError() {
        Test.startTest();
        StudentSearchController controllerErr = new StudentSearchController();
        controllerErr.errorDuringSetStudentSearchMessages = true;
        controllerErr.init();
        Test.stopTest();

        Assert.areEqual(0, controllerErr.studentSearchMessages?.size());
        Assert.areEqual(0, controllerErr.studentSearchRestrictedMessages?.size());

        List<Case> errorLoggerCases = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE Subject LIKE '%IllegalArgumentException%'
        ];
        Assert.areNotEqual(0, errorLoggerCases.size());
    }

    // Test checking if a student has classes
    @isTest
    private static void testHasClasses() {
        // Mock response
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        Boolean hasClasses = StudentSearchController.hasClasses('1234567890');

        Assert.isTrue(hasClasses, 'Expected student to be reported as having classes, but DPL said they had none');
    }

    // Test checking if a student has classes, but if DPL returns an error
    @isTest
    private static void testHasClassesDplError() {
        // Mock response
        StudentProfileCalloutMock mockCallout = new StudentProfileCalloutMock();
        mockCallout.dplPermission = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Exception thrownError = null;

        // Main test
        Test.startTest();
        try {
            Boolean hasClasses = StudentSearchController.hasClasses('1234567890');
        } catch (Exception ex) {
            thrownError = ex;
        }
        Test.stopTest();

        Assert.isInstanceOfType(
            thrownError,
            DataPotluck.DPLException.class,
            'Expected to throw an exception of type DataPotluck.DPLException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('unauthorized'),
            'Expected error message to contain "unauthorized", but it instead said "' + thrownError?.getMessage() + '"'
        );
        // Error logged
        Case errorLoggerCase = [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        Assert.isTrue(
            errorLoggerCase?.Subject?.contains('DataPotluck.DPLException'),
            'Expected error logger case for DataPotluck.DPLException, but subject instead said: "' +
                errorLoggerCase?.Subject +
                '"'
        );
    }
}
