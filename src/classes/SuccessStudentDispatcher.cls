public class SuccessStudentDispatcher implements IDispatch {
    Map<Id, Success_Student__c> newMap;
    Map<id, Success_Student__c> oldMap;

    public SuccessStudentDispatcher(Map<Id, Success_Student__c> newMap, Map<id, Success_Student__c> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public void afterUpdate() {
        SuccessStudentOutreachCaseCreator caseCreator = new SuccessStudentOutreachCaseCreator(newMap, oldMap);
        List<Case> newOutreachCases = caseCreator.getOutreachCases();
        insert newOutreachCases;
    }

    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
