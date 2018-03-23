public class SuccessStudentDispatcher implements IDispatch {
    Map<Id, Success_Student__c> newMap;
    Map<id, Success_Student__c> oldMap;
    
    public SuccessStudentDispatcher(Map<Id, Success_Student__c> newMap, Map<id, Success_Student__c> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    
    public void afterUpdate() {
        List<Success_Student__c> studentsRequiringOutreach = SuccessStudentService.getStudentsRequiringOutreach(newMap, oldMap);
        List<Case> newOutreachCases = SuccessStudentService.createOutreachCases(studentsRequiringOutreach);
        insert newOutreachCases;
    }
    
    public void beforeInsert() {}
    public void beforeUpdate() {}
    public void beforeDelete() {}
    public void afterInsert() {}
    public void afterDelete() {}
    public void afterUndelete() {}
}