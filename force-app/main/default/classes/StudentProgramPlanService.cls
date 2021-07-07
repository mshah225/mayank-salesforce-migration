public without sharing class StudentProgramPlanService {
    public static void createSubscribersForNewPlans(List<Student_Program_Plan__c> studentPlans) {
        AutoSubscriberService autoSubService = new AutoSubscriberService(studentPlans, 'Student_Program_Plan');
        autoSubService.processStudentProgramPlanRecords();
    }
}
