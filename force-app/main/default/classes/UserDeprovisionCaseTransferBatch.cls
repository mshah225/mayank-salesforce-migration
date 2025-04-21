public class UserDeprovisionCaseTransferBatch implements Database.Batchable<SObject>, Database.Stateful, Nextable {
    private List<UserDeprovisioner> userDeprovisioners;
    private Map<Id, UserDeprovisioner> userIdToDeprovisionerMp = new Map<Id, UserDeprovisioner>();
    private Map<Id, Integer> countTransferredPerUser = new Map<Id, Integer>();

    public UserDeprovisionCaseTransferBatch(List<UserDeprovisioner> userDeprovisioners) {
        this.userDeprovisioners = userDeprovisioners;

        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            Id userId = userDeprovisioner.getUser().Id;
            userIdToDeprovisionerMp.put(userId, userDeprovisioner);
            countTransferredPerUser.put(userId, 0);
        }
    }

    public Database.Querylocator start(Database.BatchableContext context) {
        List<Id> userIds = new List<Id>(userIdToDeprovisionerMp.keySet());
        String query = 'SELECT Id, OwnerId, CC_Functional_Group__r.Queue_Id__c FROM Case WHERE OwnerId IN :userIds AND CC_Functional_Group__r.Is_Functional_Group_Private__c = TRUE';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {
        UserDeprovisionOrganizer.isDeprovisoning = true;

        Map<Id, List<Case>> userToCasesMp = new Map<Id, List<Case>>();

        try {
            // Collect cases per user and reassign
            for (Case userCase : scope) {
                String userId = userCase.OwnerId;

                // Group by current owner
                if (!userToCasesMp.containsKey(userId))
                    userToCasesMp.put(userId, new List<Case>());
                userToCasesMp.get(userId).add(userCase);

                // Reassign case owner
                userCase.OwnerId = userCase.CC_Functional_Group__r.Queue_Id__c;
                // Increment counter
                countTransferredPerUser.put(userId, countTransferredPerUser.get(userId) + 1);
            }

            // Flatten cases into a list
            List<Case> casesToUpdate = new List<Case>();
            for (List<Case> userCases : userToCasesMp.values())
                casesToUpdate.addAll(userCases);

            update casesToUpdate;
        } catch (Exception e) {
            List<String> vars = new List<String>();
            List<Id> caseIds = new List<Id>();

            for (Id userId : userToCasesMp.keySet()) {
                for (Case userCase : userToCasesMp.get(userId)) {
                    String message = 'Exception Thrown for case ID (' + userCase.Id + ') : ' + e.getMessage();

                    userIdToDeprovisionerMp.get(userId).addToProcessingNotes(message);
                    userIdToDeprovisionerMp.get(userId).addToProcessingNotes(e.getStackTraceString());

                    caseIds.add((userCase.Id));
                }
            }

            vars.add(ErrorLogger.convertSetToJSON('userIds', userToCasesMp.keySet()));
            vars.add(ErrorLogger.convertListToJSON('caseIds', caseIds));

            ErrorLogger.log(e, vars, false);
        }

        UserDeprovisionOrganizer.isDeprovisoning = false;
    }

    public void finish(Database.BatchableContext context) {
        UserDeprovisionOrganizer.isDeprovisoning = true;
        try {
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                Id userId = userDeprovisioner.getUser().Id;
                Integer countTransferred = countTransferredPerUser.get(userId);

                userDeprovisioner.addToProcessingNotes(
                    'Successfully transferred ' + countTransferred + ' private cases to queue.'
                );
            }

            List<User> modifiedUsers = new List<User>();
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                modifiedUsers.add(userDeprovisioner.getUser());
            }
            update modifiedUsers;
        } catch (Exception e) {
            List<String> vars = new List<String>();
            ErrorLogger.log(e, vars, false);
        }
        launchNext();
        UserDeprovisionOrganizer.isDeprovisoning = false;
    }

    /**
     * Nextable implementation
     */
    private NextableDefaultImplementation nextImpl = new NextableDefaultImplementation();
    public void launchNext() {
        nextImpl.launchNext();
    }
    public void enqueueNext(Nextable next) {
        nextImpl.enqueueNext(next);
    }
}