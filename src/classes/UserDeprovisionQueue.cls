public without sharing class UserDeprovisionQueue implements Queueable {
    private List<Case> updatedUserCases;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private Map<Id, Id> caseToUserMap;
    private Map<Id, String> userToOldProcessingNotes;

    private static Boolean debug = false;

    public void setUpdatedUserCases(List<Case> updatedUserCases) {
        this.updatedUserCases = updatedUserCases;
    }

    public void setAllUserChatterGroupMemberships(List<CollaborationGroupMember> allUserChatterGroupMemberships) {
        this.allUserChatterGroupMemberships = allUserChatterGroupMemberships;
    }

    public void setCaseToUserMap(Map<Id, Id> caseToUserMap) {
        this.caseToUserMap = caseToUserMap;
    }

    public void setUserToOldProcessingNotes(Map<Id, String> userToOldProcessingNotes) {
        this.userToOldProcessingNotes = userToOldProcessingNotes;
    }

    public void execute(QueueableContext context) {
        if (!updatedUserCases.isEmpty()) {
            updateCases();
        }
        if (!allUserChatterGroupMemberships.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords(
                'MemberId',
                allUserChatterGroupMemberships,
                userToOldProcessingNotes
            );
        }
    }

    private void updateCases() {
        List<User> usersWithErrors = new List<User>();

        Database.SaveResult[] saveResult = Database.update(updatedUserCases, false);

        for (Integer i = 0; i < saveResult.size(); i++) {
            if (!saveResult[i].isSuccess()) {
                String processingNotes;
                String errorNote = 'The following errors have occurred:';
                for (Database.Error err : saveResult[i].getErrors()) {
                    errorNote += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    errorNote += '\nUser fields that affected this error: ' + err.getFields();
                }

                Id userId = caseToUserMap.get(updatedUserCases[i].Id);
                if (userToOldProcessingNotes != null && userToOldProcessingNotes.get(userId) != null) {
                    processingNotes = userToOldProcessingNotes.get(userId) + '\n---\n' + errorNote;
                } else {
                    processingNotes = errorNote;
                }

                usersWithErrors.add(new User(Id = userId, Processing_Notes__c = processingNotes));

                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertIdToJSON('userId', userId));
                vars.add(ErrorLogger.convertStringToJSON('processingNotes', processingNotes));
                ErrorLogger.log(new DatabaseErrorException(errorNote), vars, debug);
            }
        }
        update usersWithErrors;
    }

    private class DatabaseErrorException extends Exception {
    }
}
