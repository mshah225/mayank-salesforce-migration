public class UserDeprovisionCaseTransferBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> userToDeprovisionIds;
    private Map<User, Boolean> userDeprovisionCapabilityMap;
    private Map<Id, User> userIdToUserMap;
    Map<Id, String> userToProcessingNotesMap;
    private Integer totalCasesTransferred;
    private Map<Id, Integer> countTransferredPerUser;

    public UserDeprovisionCaseTransferBatch(Map<User, Boolean> userDeprovisionCapabilityMap) {
        this.userDeprovisionCapabilityMap = userDeprovisionCapabilityMap;
        this.userIdToUserMap = new Map<Id, User>();
        this.userToDeprovisionIds = new List<Id>();
        this.userToProcessingNotesMap = new Map<Id, String>();
        this.countTransferredPerUser = new Map<Id, Integer>();
        this.totalCasesTransferred = 0;

        for (User userToDeprovision : userDeprovisionCapabilityMap.keySet()) {
            if (userDeprovisionCapabilityMap.get(userDeprovisioner) == true) {
                this.userToDeprovisionIds.add(userToDeprovision.Id);
            }
            this.userIdToUserMap.put(userToDeprovision.Id, userToDeprovision);
        }
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
                String message = 'Exception Thrown for case ID (' + userCase.Id + ') : ' + e.getMessage();
                addToProcessingNotes(userCase.OwnerId, message)
                addToProcessingNotes(userCase.OwnerId, e.getStackTraceString());

                List<String> vars = new List<String>();

                vars.add(ErrorLogger.convertIdToJSON('deprovisionedUser.Id', userCase.OwnerId));
                ErrorLogger.ErrorLoggerQueue logQueue = new ErrorLogger.ErrorLoggerQueue(e, vars, false, true);
                System.enqueueJob(logQueue);
            }
        }
        Database.update(casesToUpdate, false);
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Successfully transferred ' + totalCasesTransferred + ' cases.');
        for (Id userId : countTransferredPerUser.keySet()) {
            Integer countTransferred = countTransferredPerUser.get(userId);

            String message = 'Successfully transferred ' + countTransferred + ' cases.';
            addToProcessingNotes(userId, message);
        }

        for(Id userId : userIdToUserMap.keySet()) {
            userToProcessingNotesMap.put(userId, userIdToUserMap.get(userId).Processing_Notes__c);
        }

        UserDeprovisionerOrganizer.updateSobjectRecords('Id', userIdToUserMap.values(), userToProcessingNotes);
    }

    public void addToProcessingNotes(Id userId, String message) {
        if (userIdToUserMap.containsKey(userId)){
            User userToUpdate = userIdToUserMap.get(userId);
            String updatedProcessingNotes = userToUpdate.Processing_Notes__c + message + '\n';
            userToUpdate.Processing_Notes__c = updatedProcessingNotes;
        }
    }

    public class DeprovisionUserException extends Exception {
    }
}