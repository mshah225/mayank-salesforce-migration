public class BatchDeprovisionUserCase implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> userToDeprovisionIds;
    private Integer totalCasesTransferred;
    private Map<Id, Integer> countTransferredPerUser;
    private Boolean errorOccurred = false;

    public BatchDeprovisionUserCase(List<Id> userToDeprovisionIds) {
        this.userToDeprovisionIds = userToDeprovisionIds;
        this.totalCasesTransferred = 0;
        this.countTransferredPerUser = new Map<Id, Integer>();
    }

    public Database.Querylocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, OwnerId, CC_Functional_Group__c, CC_Functional_Group__r.Name, CC_Functional_Group__r.Queue_Id__c, CC_Functional_Group__r.Is_Functional_Group_Private__c FROM Case WHERE OwnerId IN :userToDeprovisionIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();

        for(Case userCase : scope) {

            if(!countTransferredPerUser.keySet().contains(userCase.OwnerId)){
                countTransferredPerUser.put(userCase.OwnerId, 0);
            }

            String deprovisionedUserId = userCase.OwnerId;
            try{
                if(userCase!= null) {
                    if(userCase.CC_Functional_Group__r.Is_Functional_Group_Private__c) {
                        userCase.OwnerId = userCase.CC_Functional_Group__r.Queue_Id__c;

                        casesToUpdate.add(userCase);

                        totalCasesTransferred++;
                        
                        countTransferredPerUser.put(deprovisionedUserId, countTransferredPerUser.get(deprovisionedUserId) + 1);
                    }
                }
            } catch (Exception e) {
                System.debug(e);
                this.errorOccurred = true;
                throw new DeprovisionUserException('Could not transfer cases. QueueId on case\'s functional group may be invalid.');
            }
        }
        update casesToUpdate;
    }

    public void finish(Database.BatchableContext context) {
        if(errorOccurred == false){
            System.debug('Successfully transferred ' + totalCasesTransferred + ' cases.');
            for(Id userId : countTransferredPerUser.keySet()){
                Integer countTransferred = countTransferredPerUser.get(userId);

                String message = 'Successfully transferred ' + countTransferred + ' cases.';
                updateProcessingNotes(userId, message);
            }
        }
    }

    private void updateProcessingNotes(Id userId, String message) {
        User deprovisionedUser = [SELECT Id, Processing_Notes__c FROM User WHERE Id = :userId];
        String processingNotes = deprovisionedUser.Processing_Notes__c + message + '\n';
        deprovisionedUser.Processing_Notes__c = processingNotes;
        update deprovisionedUser;
    }

    public class DeprovisionUserException extends Exception {
    }
}