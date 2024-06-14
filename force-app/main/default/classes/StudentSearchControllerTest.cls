@isTest
public class StudentSearchControllerTest {
    @isTest
    static void testStudentSearchController() {
        Test.startTest();
        StudentSearchController controller = new StudentSearchController();
        controller.init();
        controller.setStudentProfileGlobalMessages();
        Test.stopTest();
    }
}