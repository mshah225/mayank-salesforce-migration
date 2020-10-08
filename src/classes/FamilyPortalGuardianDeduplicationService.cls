public class FamilyPortalGuardianDeduplicationService implements Queueable {
    private List<Family_Portal_Guardian__c> newlyInsertedGuardians;
    private static List<Family_Portal_Guardian__c> guardiansToDelete;

    public FamilyPortalGuardianDeduplicationService(List<Family_Portal_Guardian__c> newlyInsertedGuardians) {
        this.newlyInsertedGuardians = newlyInsertedGuardians;
    }

    public void execute(QueueableContext context) {
        if (newlyInsertedGuardians.size() > 0) {
            gatherGuardiansAndStartDedup(newlyInsertedGuardians);
            try {
                if (guardiansToDelete != null && !guardiansToDelete.isEmpty()) {
                    delete guardiansToDelete;
                }
            } catch (Exception e) {
                System.debug('Failed to update or delete guardians: ' + e.getMessage());
            }
        }
    }

    public static void gatherGuardiansAndStartDedup(List<Family_Portal_Guardian__c> insertedGuardians) {
        guardiansToDelete = new List<Family_Portal_Guardian__c>();
        List<Family_Portal_Guardian__c> guardiansToCheck;

        for (Family_Portal_Guardian__c insertedGuardian : insertedGuardians) {
            List<Family_Portal_Guardian__c> matchedGuardiansToCheck = [
                SELECT Id, CreatedDate
                FROM Family_Portal_Guardian__c
                WHERE Email__c = :insertedGuardian.Email__c
            ];
            if (matchedGuardiansToCheck.size() > 0) {
                determineGuardiansToDelete(matchedGuardiansToCheck);
            }
        }
    }

    private static void determineGuardiansToDelete(List<Family_Portal_Guardian__c> matchedGuardiansToCheck) {
        Family_Portal_Guardian__c mostRecentGuardian;
        for (Family_Portal_Guardian__c matchedGuardian : matchedGuardiansToCheck) {
            if (mostRecentGuardian == null) {
                mostRecentGuardian = matchedGuardian;
                continue;
            }
            if (mostRecentGuardian.Id == matchedGuardian.Id) {
                continue;
            }
            if (mostRecentGuardian.CreatedDate >= matchedGuardian.CreatedDate) {
                guardiansToDelete.add(matchedGuardian);
            } else if (mostRecentGuardian.CreatedDate < matchedGuardian.CreatedDate) {
                guardiansToDelete.add(mostRecentGuardian);
                mostRecentGuardian = matchedGuardian;
            }
        }
    }
}
