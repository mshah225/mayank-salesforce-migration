public class FamilyPortalInterestDeduplicationService implements Queueable {
    private List<Family_Portal_Guardian_Interest__c> recentlyUpdatedInterests;
    private static List<Family_Portal_Guardian_Interest__c> interestsToDelete;
    private static List<Family_Portal_Guardian_Interest__c> interestsToUpdate;

    public FamilyPortalInterestDeduplicationService(List<Family_Portal_Guardian_Interest__c> recentlyUpdatedInterests) {
        this.recentlyUpdatedInterests = recentlyUpdatedInterests;
    }

    public void execute(QueueableContext context) {
        if (recentlyUpdatedInterests.size() > 0) {
            gatherInterestsAndStartDedupe(recentlyUpdatedInterests);
            try {
                if (interestsToUpdate != null && !interestsToUpdate.isEmpty()) {
                    Set<Family_Portal_Guardian_Interest__c> interestsToUpdateSet = new Set<Family_Portal_Guardian_Interest__c>();
                    interestsToUpdateSet.addAll(interestsToUpdate);
                    interestsToUpdate.clear();
                    interestsToUpdate.addAll(interestsToUpdateSet);
                    update interestsToUpdate;
                }
            } catch (DmlException e) {
                Set<Family_Portal_Guardian_Interest__c> interestsToUpdateSet = new Set<Family_Portal_Guardian_Interest__c>();
                interestsToUpdateSet.addAll(interestsToUpdate);
                interestsToUpdate.clear();
                interestsToUpdate.addAll(interestsToUpdateSet);
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('interestsToUpdate', interestsToUpdate));
                ErrorLogger.log(e, vars, false);
            }
            try {
                if (interestsToDelete != null && !interestsToDelete.isEmpty()) {
                    Set<Family_Portal_Guardian_Interest__c> interestsToDeleteSet = new Set<Family_Portal_Guardian_Interest__c>();
                    interestsToDeleteSet.addAll(interestsToDelete);
                    interestsToDelete.clear();
                    interestsToDelete.addAll(interestsToDeleteSet);
                    delete interestsToDelete;
                }
            } catch (DmlException e) {
                Set<Family_Portal_Guardian_Interest__c> interestsToDeleteSet = new Set<Family_Portal_Guardian_Interest__c>();
                interestsToDeleteSet.addAll(interestsToDelete);
                interestsToDelete.clear();
                interestsToDelete.addAll(interestsToDeleteSet);
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('interestsToDelete', interestsToDelete));
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    public static void gatherInterestsAndStartDedupe(List<Family_Portal_Guardian_Interest__c> updatedInterests) {
        Map<Family_Portal_Guardian_Interest__c, List<Family_Portal_Guardian_Interest__c>> updatedInterestWithMatchedInterests = new Map<Family_Portal_Guardian_Interest__c, List<Family_Portal_Guardian_Interest__c>>();
        List<Family_Portal_Guardian_Interest__c> guardiansToCheck;
        interestsToDelete = new List<Family_Portal_Guardian_Interest__c>();
        interestsToUpdate = new List<Family_Portal_Guardian_Interest__c>();

        for (Family_Portal_Guardian_Interest__c updatedInterest : updatedInterests) {
            List<Family_Portal_Guardian_Interest__c> matchedInterestsToCheck = [
                SELECT Id, Active_Interest__c, Chosen_Interest__c, Family_Portal_Guardian__c, Interest_Choices__c, Name
                FROM Family_Portal_Guardian_Interest__c
                WHERE
                    Family_Portal_Guardian__c = :updatedInterest.Family_Portal_Guardian__c
                    AND Chosen_Interest__c = :updatedInterest.Chosen_Interest__c
            ];

            if (matchedInterestsToCheck.size() > 0) {
                updatedInterestWithMatchedInterests.put(updatedInterest, matchedInterestsToCheck);
            }
        }

        if (updatedInterestWithMatchedInterests.size() > 0) {
            deduplicateInterests(updatedInterestWithMatchedInterests);
        }
    }

    private static void deduplicateInterests(
        Map<Family_Portal_Guardian_Interest__c, List<Family_Portal_Guardian_Interest__c>> updatedInterestWithMatchedInterests
    ) {
        for (Family_Portal_Guardian_Interest__c updatedInterest : updatedInterestWithMatchedInterests.keySet()) {
            Family_Portal_Guardian_Interest__c oldestGuardian;
            Family_Portal_Guardian_Interest__c newestGuardian = insertedGuardian;
            List<Family_Portal_Guardian_Interest__c> relatedinterestsToDelete = new List<Family_Portal_Guardian_Interest__c>();
            Map<Id, List<Family_Portal_Guardian_Interest__c>> relatedGuardianIdsWithinterestsToDelete = new Map<Id, List<Family_Portal_Guardian_Interest__c>>();
            List<Family_Portal_Guardian_Interest__c> matchedGuardiansToCheck = insertedGuardianWithMatchedGuardians.get(
                insertedGuardian
            );

            for (Family_Portal_Guardian__c matchedGuardian : matchedGuardiansToCheck) {
                if (oldestGuardian == null) {
                    oldestGuardian = matchedGuardian;
                    continue;
                }
                if (oldestGuardian.Id == matchedGuardian.Id) {
                    continue;
                }

                if (oldestGuardian.CreatedDate < matchedGuardian.CreatedDate) {
                    relatedinterestsToDelete.add(matchedGuardian);
                } else if (oldestGuardian.CreatedDate >= matchedGuardian.CreatedDate) {
                    relatedinterestsToDelete.add(oldestGuardian);
                    oldestGuardian = matchedGuardian;
                }
            }
            interestsToDelete.addAll(relatedinterestsToDelete);

            for (Family_Portal_Guardian__c relatedinterestsToDelete : relatedinterestsToDelete) {
                relatedGuardianIdsWithinterestsToDelete.put(relatedinterestsToDelete.Id, relatedinterestsToDelete);
            }

            for (Family_Portal_Guardian_Interest__c interestToReparent : [
                SELECT Id, Active_Interest__c, Family_Portal_Guardian__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c IN :relatedGuardianIdsWithinterestsToDelete.keySet()
            ]) {
                interestToReparent.Active_Interest__c = false;
                interestToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                guardianInterestsToUpdate.add(interestToReparent);
            }

            if (newestGuardian.ASU_Alumni__c != null) {
                oldestGuardian.ASU_Alumni__c = newestGuardian.ASU_Alumni__c;
            }
            if (newestGuardian.ASURITE_ID__c != null) {
                oldestGuardian.ASURITE_ID__c = newestGuardian.ASURITE_ID__c;
            }
            if (newestGuardian.Business_Unit_Source__c != null) {
                oldestGuardian.Business_Unit_Source__c = newestGuardian.Business_Unit_Source__c;
            }
            if (newestGuardian.City__c != null) {
                oldestGuardian.City__c = newestGuardian.City__c;
            }
            if (newestGuardian.Contact__c != null) {
                oldestGuardian.Contact__c = newestGuardian.Contact__c;
            }
            if (newestGuardian.Country__c != null) {
                oldestGuardian.Country__c = newestGuardian.Country__c;
            }
            if (newestGuardian.Email__c != null) {
                oldestGuardian.Email__c = newestGuardian.Email__c;
            }
            if (newestGuardian.EMPLID__c != null) {
                oldestGuardian.EMPLID__c = newestGuardian.EMPLID__c;
            }
            if (newestGuardian.First_Name__c != null) {
                oldestGuardian.First_Name__c = newestGuardian.First_Name__c;
            }
            if (newestGuardian.Last_Name__c != null) {
                oldestGuardian.Last_Name__c = newestGuardian.Last_Name__c;
            }
            if (newestGuardian.Middle_Name__c != null) {
                oldestGuardian.Middle_Name__c = newestGuardian.Middle_Name__c;
            }
            if (newestGuardian.OwnerId != null) {
                oldestGuardian.OwnerId = newestGuardian.OwnerId;
            }
            if (newestGuardian.Phone__c != null) {
                oldestGuardian.Phone__c = newestGuardian.Phone__c;
            }
            if (newestGuardian.State__c != null) {
                oldestGuardian.State__c = newestGuardian.State__c;
            }
            if (newestGuardian.Street__c != null) {
                oldestGuardian.Street__c = newestGuardian.Street__c;
            }
            if (newestGuardian.Zip_Code__c != null) {
                oldestGuardian.Zip_Code__c = newestGuardian.Zip_Code__c;
            }

            for (Family_Portal_Guardian_Interest__c interestToSetInactive : [
                SELECT Id, Family_Portal_Guardian__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c = :oldestGuardian.Id
            ]) {
                interestToSetInactive.Active_Interest__c = false;
                guardianInterestsToUpdate.add(interestToSetInactive);
            }

            for (Family_Portal_Guardian_Interest__c interestToReparent : [
                SELECT Id, Family_Portal_Guardian__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c = :newestGuardian.Id
            ]) {
                interestToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                guardianInterestsToUpdate.add(interestToReparent);
            }

            if (!interestsToDelete.contains(newestGuardian)) {
                interestsToDelete.add(newestGuardian);
            }
            if (!interestsToUpdate.contains(oldestGuardian)) {
                interestsToUpdate.add(oldestGuardian);
            }
        }
    }
}
