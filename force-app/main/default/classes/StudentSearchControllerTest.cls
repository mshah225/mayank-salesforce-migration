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
}