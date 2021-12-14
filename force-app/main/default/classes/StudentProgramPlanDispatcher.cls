public with sharing class StudentProgramPlanDispatcher implements TriggerDispatcherInterface {
    private List<Student_Program_Plan__c> newList;
    private Map<Id, Student_Program_Plan__c> newMap;
    private List<Student_Program_Plan__c> oldList;
    private Map<Id, Student_Program_Plan__c> oldMap;

    public StudentProgramPlanDispatcher(
        List<Student_Program_Plan__c> newList,
        Map<Id, Student_Program_Plan__c> newMap,
        List<Student_Program_Plan__c> oldList,
        Map<Id, Student_Program_Plan__c> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
    }

    public void beforeUpdate() {
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
        StudentProgramPlanService.createSubscribersForNewPlans(newList);
    }

    public void afterUpdate() {
    }

    public void afterDelete() {
    }

    public void afterUndelete() {
    }
}
