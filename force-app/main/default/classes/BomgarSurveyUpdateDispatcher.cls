public class BomgarSurveyUpdateDispatcher implements TriggerDispatcherInterface {
    private List<bomgar__SurveyData__c> newList;
    private Map<Id, bomgar__SurveyData__c> newMap;
    private List<bomgar__SurveyData__c> oldList;
    private Map<Id, bomgar__SurveyData__c> oldMap;

    public BomgarSurveyUpdateDispatcher(
        List<bomgar__SurveyData__c> newList,
        Map<Id, bomgar__SurveyData__c> newMap,
        List<bomgar__SurveyData__c> oldList,
        Map<Id, bomgar__SurveyData__c> oldMap
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
        BomgarSurveyUpdateService.processSurveyData(newList);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
    }
    public void afterUndelete() {
    }
}
