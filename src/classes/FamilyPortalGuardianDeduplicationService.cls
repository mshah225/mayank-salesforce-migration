public with sharing class FamilyPortalGuardianDeduplicationService implements Queueable {
    private Set<Id> guardianIds;
    private static List<Family_Portal_Guardian__c> guardiansToDelete;
    private static List<Family_Portal_Guardian__c> guardiansToUpdate;

    public FamilyPortalGuardianDeduplicationService(List<Family_Portal_Guardian__c> insertedGuardians) {
        guardianIds = new Set<Id>();
        for (Family_Portal_Guardian__c insertedGuardian : insertedGuardians) {
            guardianIds.add(insertedGuardian.Id);
        }
    }

    public void execute(QueueableContext context) {
        if (!guardianIds.isEmpty() && guardianIds != null) {
            gatherGuardiansAndStartDedup(guardianIds);
            try {
                if (guardiansToUpdate != null && !guardiansToUpdate.isEmpty()) {
                    update guardiansToUpdate;
                }
                if (guardiansToDelete != null && !guardiansToDelete.isEmpty()) {
                    delete guardiansToDelete;
                }
            } catch (Exception e) {
                System.debug('Failed to update or delete guardians: ' + e.getMessage());
            }
        }
    }

    public static void gatherGuardiansAndStartDedup(Set<Id> guardianIds) {
        guardiansToDelete = new List<Family_Portal_Guardian__c>();
        guardiansToUpdate = new List<Family_Portal_Guardian__c>();

        List<Family_Portal_Guardian__c> guardianList = [
            SELECT First_Name__c, Email__c, CreatedDate, Id
            FROM Family_Portal_Guardian__c
            WHERE Id IN: guardianIds
            ORDER By First_Name__c
        ];

        if (!guardianList.isEmpty() && guardianList != null) {
            List<Family_Portal_Guardian__c> guardiansToCheck;
            
            for (Family_Portal_Guardian__c guardian : guardianList) {
                List<Family_Portal_Guardian__c> matchedGuardiansToCheck = [
                    SELECT First_Name__c, Email__c, CreatedDate, Id
                    FROM Family_Portal_Guardian__c
                    WHERE Email__c =: guardian.Email__c
                        AND First_Name__c =: guardian.First_Name__c
                ];
                matchedGuardiansToCheck.add(guardian);
                sortGuardiansToDeleteAndUpdate(matchedGuardiansToCheck);
            }
        }
    }
  
    private static void sortGuardiansToDeleteAndUpdate(List<Family_Portal_Guardian__c> duplicateGuardians) {
        Family_Portal_Guardian__c currentBestChoice;

        for (Family_Portal_Guardian__c duplicateGuardian : duplicateGuardians) {
            if (currentBestChoice == null) {
                currentBestChoice = duplicateGuardian;
                continue;
            }

            if (currentBestChoice.Id == duplicateGuardian.Id) {
                break;
            }

            if (currentBestChoice.CreatedDate > duplicateGuardian.CreatedDate) {
                guardiansToDelete.add(currentBestChoice);

                List<Family_Portal_Guardian_Interest__c> duplicateGuardianInterestList = [
                    SELECT Id, Chosen_Interest__c
                    FROM Family_Portal_Guardian_Interest__c
                    WHERE Family_Portal_Guardian__c =: duplicateGuardian.Id
                ];

                if (!duplicateGuardianInterestList.isEmpty()) {
                    delete duplicateGuardianInterestList;
                }
                
                List<Family_Portal_Student__c> duplicateGuardianStudentList = [
                    SELECT Id, Enrollment_Status__c, Enrollment_Status_Year__c
                    FROM Family_Portal_Student__c
                    WHERE Family_Portal_Guardian__c =: duplicateGuardian.Id
                ];

                if (!duplicateGuardianStudentList.isEmpty()) {
                    delete duplicateGuardianStudentList;
                }

                List<Family_Portal_Guardian_Interest__c> currentBestChoiceInterestList = [
                    SELECT Id, Chosen_Interest__c
                    FROM Family_Portal_Guardian_Interest__c
                    WHERE Family_Portal_Guardian__c =: currentBestChoice.Id
                ];

                for (Family_Portal_Guardian_Interest__c interestToChange : currentBestChoiceInterestList) {
                    interestToChange.Family_Portal_Guardian__c = duplicateGuardian.Id;
                }

                List<Family_Portal_Student__c> currentBestChoiceStudentList = [
                    SELECT Id, Enrollment_Status__c, Enrollment_Status_Year__c
                    FROM Family_Portal_Student__c
                    WHERE Family_Portal_Guardian__c =: currentBestChoice.Id
                ];

                for (Family_Portal_Student__c studentsToChange : duplicateGuardianStudentList) {
                    studentsToChange.Family_Portal_Guardian__c = duplicateGuardian.Id;
                }

                currentBestChoice = duplicateGuardian;
            } else if (currentBestChoice.CreatedDate < duplicateGuardian.CreatedDate) {
                guardiansToDelete.add(currentBestChoice);
                currentBestChoice = duplicateGuardian;
            } else {
                guardiansToDelete.add(duplicateGuardian);
            }
        }

        guardiansToUpdate.add(currentBestChoice);

        for (Family_Portal_Guardian__c guardian : guardiansToUpdate) {
            if (guardiansToDelete.contains(guardian)) {
                guardiansToDelete.remove(guardiansToDelete.indexOf(guardian));
            }
        }
    }
}