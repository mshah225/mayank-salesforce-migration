public class FamilyPortalInterestDeduplicationService {
    private List<Family_Portal_Guardian_Interest__c> interestsWithChanges;
    private static List<Family_Portal_Guardian_Interest__c> interestsToDelete;
    private static List<Family_Portal_Guardian_Interest__c> interestsToUpdate;

    public FamilyPortalInterestDeduplicationService(List<Family_Portal_Guardian_Interest__c> interestsWithChanges) {
        this.interestsWithChanges = interestsWithChanges;
    }

    public void initialize() {
        if (interestsWithChanges.size() > 0) {
            gatherInterestsAndStartDedupe(interestsWithChanges);

            Set<Family_Portal_Guardian_Interest__c> interestsToUpdateSet = new Set<Family_Portal_Guardian_Interest__c>();
            interestsToUpdateSet.addAll(interestsToUpdate);
            interestsToUpdate.clear();
            interestsToUpdate.addAll(interestsToUpdateSet);
            try {
                update interestsToUpdate;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('interestsToUpdate', interestsToUpdate));
                ErrorLogger.log(e, vars, false);
            }

            Set<Family_Portal_Guardian_Interest__c> interestsToDeleteSet = new Set<Family_Portal_Guardian_Interest__c>();
            interestsToDeleteSet.addAll(interestsToDelete);
            interestsToDelete.clear();
            interestsToDelete.addAll(interestsToDeleteSet);
            try {
                delete interestsToDelete;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('interestsToDelete', interestsToDelete));
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    public static void gatherInterestsAndStartDedupe(List<Family_Portal_Guardian_Interest__c> updatedInterests) {
        Map<Family_Portal_Guardian_Interest__c, List<Family_Portal_Guardian_Interest__c>> updatedInterestWithMatchedInterests = new Map<Family_Portal_Guardian_Interest__c, List<Family_Portal_Guardian_Interest__c>>();
        interestsToDelete = new List<Family_Portal_Guardian_Interest__c>();
        interestsToUpdate = new List<Family_Portal_Guardian_Interest__c>();

        for (Family_Portal_Guardian_Interest__c updatedInterest : updatedInterests) {
            List<Family_Portal_Guardian_Interest__c> matchedInterestsToCheck = [
                SELECT
                    Id,
                    Active_Interest__c,
                    Chosen_Interest__c,
                    Family_Portal_Guardian__c,
                    Interest_Choices__c,
                    CreatedDate
                FROM Family_Portal_Guardian_Interest__c
                WHERE
                    Family_Portal_Guardian__c = :updatedInterest.Family_Portal_Guardian__c
                    AND Chosen_Interest__c = :updatedInterest.Chosen_Interest__c
                ORDER BY CreatedDate ASC
            ];

            if (matchedInterestsToCheck.size() > 0) {
                updatedInterestWithMatchedInterests.put(updatedInterest, matchedInterestsToCheck);
            }
        }
        deduplicateInterests(updatedInterestWithMatchedInterests);
    }

    private static void deduplicateInterests(
        Map<Family_Portal_Guardian_Interest__c, List<Family_Portal_Guardian_Interest__c>> updatedInterestWithMatchedInterests
    ) {
        for (Family_Portal_Guardian_Interest__c updatedInterest : updatedInterestWithMatchedInterests.keySet()) {
            Family_Portal_Guardian_Interest__c oldestInterest = updatedInterest;
            Family_Portal_Guardian_Interest__c newestInterest = updatedInterest;
            List<Family_Portal_Guardian_Interest__c> relatedInterestsToDelete = new List<Family_Portal_Guardian_Interest__c>();
            List<Family_Portal_Guardian_Interest__c> matchedInterestsToCheck = updatedInterestWithmatchedInterests.get(
                updatedInterest
            );

            Set<Id> interestIdsToDelete = new Set<Id>();
            for (Family_Portal_Guardian_Interest__c interest : interestsToDelete) {
                interestIdsToDelete.add(interest.Id);
            }

            if (interestIdsToDelete.contains(updatedInterest.Id)) {
                continue;
            }
            if (matchedInterestsToCheck.size() == 1 && matchedInterestsToCheck[0].Id == oldestInterest.Id) {
                continue;
            }
            if (matchedInterestsToCheck.size() > 1) {
                oldestInterest = matchedInterestsToCheck[0];
                newestInterest = matchedInterestsToCheck[matchedInterestsToCheck.size() - 1];
            }

            for (Family_Portal_Guardian_Interest__c matchedInterest : matchedInterestsToCheck) {
                if (
                    matchedInterest.Id != oldestInterest.Id &&
                    matchedInterest.Id != newestInterest.Id &&
                    matchedInterest.CreatedDate > oldestInterest.CreatedDate
                ) {
                    relatedInterestsToDelete.add(matchedInterest);
                }
            }

            interestsToDelete.addAll(relatedInterestsToDelete);

            if (newestInterest.Active_Interest__c != null) {
                oldestInterest.Active_Interest__c = newestInterest.Active_Interest__c;
            }
            if (newestInterest.Interest_Choices__c != null) {
                oldestInterest.Interest_Choices__c = newestInterest.Interest_Choices__c;
            }

            if (!interestsToDelete.contains(newestInterest)) {
                interestsToDelete.add(newestInterest);
            }
            if (!interestsToUpdate.contains(oldestInterest)) {
                interestsToUpdate.add(oldestInterest);
            }
        }
    }
}
