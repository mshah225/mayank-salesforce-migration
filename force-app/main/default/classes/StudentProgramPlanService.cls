public without sharing class StudentProgramPlanService {
    public static void createSubscribersForNewPlans(List<Student_Program_Plan__c> studentPlans) {
        SubscriberAutoSubscriptionService autoSubscriptionService = new SubscriberAutoSubscriptionService(
            studentPlans,
            'Student_Program_Plan'
        );
        autoSubscriptionService.processStudentProgramPlanRecords();
    }
}