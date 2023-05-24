public class BatchDeprovisionUserCase implements Database.Batchable<SObject>{
    private List<Id> userToDeprovisionIds;
    private Map<Id, List<Case>> userToCaseMap; 


    public BatchDeprovisionUserCase(List<Id> userToDeprovisionIds, Map<Id, List<Case>> userToCaseMap) {
        this.userToDeprovisionIds = userToDeprovisionIds;
        this.userToCaseMap = userToCaseMap;
    }

    public Database.Querylocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, OwnerId, CC_Functional_Group__c, CC_Functional_Group__r.Name, CC_Functional_Group__r.Queue_Id__c, CC_Functional_Group__r.Is_Functional_Group_Private__c FROM Case WHERE OwnerId IN :userToDeprovisionIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {
        for(Case userCase : scope) {
            if(!this.userToCaseMap.containsKey(userCase.OwnerId)){
                userToCaseMap.put(userCase.OwnerId, new List<Case>());
            }
            userToCaseMap.get(userCase.OwnerId).add(userCase);
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Batch fetch records completed successfully.');
    }

    public Map<Id, List<Case>> getUpdatedUserToCaseMap() {
        return this.userToCaseMap;
    }
}