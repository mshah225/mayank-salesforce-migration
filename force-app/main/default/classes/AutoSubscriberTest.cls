@isTest
private class AutoSubscriberTest {
    @isTest
    private static void newStudentProgramPlanForGradCollege() {
        Contact newStudent = new Contact();
        newStudent.FirstName = 'Tester';
        newStudent.LastName = 'McTesterson';

        insert newStudent;

        Student_Program_Plan__c programPlan = new Student_Program_Plan__c();
        programPlan.Career__c = 'Graduate';
        programPlan.Status__c = 'Active In Program';
        programPlan.Plan_Code__c = 'test';
        programPlan.Plan_Description__c = 'test';

        insert programPlan;
    }
}
