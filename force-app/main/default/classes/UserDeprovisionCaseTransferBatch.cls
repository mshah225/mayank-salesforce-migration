public class UserDeprovisionCaseTransferBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> userToDeprovisionIds;
    private Map<User, Boolean> userDeprovisionCapabilityMap;
    private Map<Id, User> userIdToUserMap;
    Map<Id, String> userToProcessingNotesMap;
    private Integer totalCasesTransferred;
    private Map<Id, Integer> countTransferredPerUser;
    private Boolean errorOccurred = false;

    public UserDeprovisionCaseTransferBatch(Map<User, Boolean> userDeprovisionCapabilityMap) {
        this.userDeprovisionCapabilityMap = userDeprovisionCapabilityMap;
        this.userIdToUserMap = new Map<Id, User>();
        this.userToProcessingNotesMap = new Map<Id, String>();
        for (User userToDeprovision : userDeprovisionCapabilityMap.keySet()) {
            if (userDeprovisionCapabilityMap.get(userDeprovisioner) == true) {
                this.userToDeprovisionIds.add(userToDeprovision.Id);
            }
            this.userIdToUserMap.put(userToDeprovision.Id, userToDeprovision);
        }
        this.totalCasesTransferred = 0;
        this.countTransferredPerUser = new Map<Id, Integer>();
    }

    public Database.Querylocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, OwnerId, CC_Functional_Group__c, CC_Functional_Group__r.Name, CC_Functional_Group__r.Queue_Id__c, CC_Functional_Group__r.Is_Functional_Group_Private__c FROM Case WHERE OwnerId IN :userToDeprovisionIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();

        for (Case userCase : scope) {
            if (!countTransferredPerUser.keySet().contains(userCase.OwnerId)) {
                countTransferredPerUser.put(userCase.OwnerId, 0);
            }

            String deprovisionedUserId = userCase.OwnerId;
            try {
                if (userCase != null) {
                    if (userCase.CC_Functional_Group__r.Is_Functional_Group_Private__c) {
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
        Database.update(casesToUpdate, false);
    }

    public void finish(Database.BatchableContext context) {
        if (errorOccurred == false) {
            System.debug('Successfully transferred ' + totalCasesTransferred + ' cases.');
            for (Id userId : countTransferredPerUser.keySet()) {
                Integer countTransferred = countTransferredPerUser.get(userId);

                String message = 'Successfully transferred ' + countTransferred + ' cases.';
                if (userIdToUserMap.containsKey(userId)){
                    User userToUpdate = userIdToUserMap.get(userId);
                    String processingNotes = userToUpdate.Processing_Notes__c + message + '\n';
                    userToUpdate.Processing_Notes__c = processingNotes;
                }
            }

            for(Id userId : userIdToUserMap.keySet()) {
                userToProcessingNotesMap.put(userId, userIdToUserMap.get(userId).Processing_Notes__c);
            }

            UserDeprovisionerOrganizer.updateSobjectRecords('Id', userIdToUserMap.values(), userToProcessingNotes);
        }
    }

    private void updateProcessingNotes(Id userId, String message) {
        // for every single user id got, check in usertodeprovisionmap - update processing notes - later prepare userid to processing notes map
        User deprovisionedUser = [SELECT Id, Processing_Notes__c FROM User WHERE Id = :userId];
        String processingNotes = deprovisionedUser.Processing_Notes__c + message + '\n';
        deprovisionedUser.Processing_Notes__c = processingNotes;
        update deprovisionedUser;
    }

    public class DeprovisionUserException extends Exception {
    }
}