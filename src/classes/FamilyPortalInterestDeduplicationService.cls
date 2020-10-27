public class FamilyPortalInterestDeduplicationService {
    private List<Family_Portal_Guardian_Interest__c> updatedInterests;
    private static List<Family_Portal_Guardian_Interest__c> interestsToDelete;
    private static List<Family_Portal_Guardian_Interest__c> interestsToUpdate;

    public FamilyPortalInterestDeduplicationService(List<Family_Portal_Guardian_Interest__c> updatedInterests) {
        this.updatedInterests = updatedInterests;
    }

    public void initialize() {
        if (updatedInterests.size() > 0) {
            gatherInterestsAndStartDedupe(updatedInterests);

            if (interestsToUpdate != null && !interestsToUpdate.isEmpty()) {
                Set<Family_Portal_Guardian_Interest__c> interestsToUpdateSet = new Set<Family_Portal_Guardian_Interest__c>();
                interestsToUpdateSet.addAll(interestsToUpdate);
                interestsToUpdate.clear();
                interestsToUpdate.addAll(interestsToUpdateSet);

                Set<Id> interestsToUpdateIds = new Set<Id>();
                for (Family_Portal_Guardian_Interest__c interest : interestsToUpdate) {
                    interestsToUpdateIds.add(interest.Id);
                }
                if (!System.isFuture()) {
                    updateInterests(interestsToUpdateIds);
                }
            }

            if (interestsToDelete != null && !interestsToDelete.isEmpty()) {
                Set<Family_Portal_Guardian_Interest__c> interestsToDeleteSet = new Set<Family_Portal_Guardian_Interest__c>();
                interestsToDeleteSet.addAll(interestsToDelete);
                interestsToDelete.clear();
                interestsToDelete.addAll(interestsToDeleteSet);

                Set<Id> interestsToDeleteIds = new Set<Id>();
                for (Family_Portal_Guardian_Interest__c interest : interestsToDelete) {
                    interestsToDeleteIds.add(interest.Id);
                }
                if (!System.isFuture()) {
                    deleteInterests(interestsToDeleteIds);
                }
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
                SELECT
                    Id,
                    Active_Interest__c,
                    Chosen_Interest__c,
                    Family_Portal_Guardian__c,
                    Interest_Choices__c,
                    Name,
                    CreatedDate
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
            Family_Portal_Guardian_Interest__c oldestInterest;
            List<Family_Portal_Guardian_Interest__c> relatedInterestsToDelete = new List<Family_Portal_Guardian_Interest__c>();
            Map<Id, List<Family_Portal_Guardian_Interest__c>> relatedInterestIdsWithInterestsToDelete = new Map<Id, List<Family_Portal_Guardian_Interest__c>>();
            List<Family_Portal_Guardian_Interest__c> matchedInterestsToCheck = updatedInterestWithmatchedInterests.get(
                updatedInterest
            );

            for (Family_Portal_Guardian_Interest__c matchedInterest : matchedInterestsToCheck) {
                if (oldestInterest == null) {
                    oldestInterest = matchedInterest;
                    continue;
                }
                if (oldestInterest.Id == matchedInterest.Id) {
                    continue;
                }

                if (oldestInterest.CreatedDate < matchedInterest.CreatedDate) {
                    relatedInterestsToDelete.add(matchedInterest);
                } else if (oldestInterest.CreatedDate >= matchedInterest.CreatedDate) {
                    relatedInterestsToDelete.add(oldestInterest);
                    oldestInterest = matchedInterest;
                }
            }
            interestsToDelete.addAll(relatedInterestsToDelete);

            if (updatedInterest.Active_Interest__c != null) {
                oldestInterest.Active_Interest__c = updatedInterest.Active_Interest__c;
            }
            if (updatedInterest.Interest_Choices__c != null) {
                oldestInterest.Interest_Choices__c = updatedInterest.Interest_Choices__c;
            }

            if (!interestsToDelete.contains(updatedInterest)) {
                interestsToDelete.add(updatedInterest);
            }
            if (!interestsToUpdate.contains(oldestInterest)) {
                interestsToUpdate.add(oldestInterest);
            }
        }
    }

    @future
    public static void updateInterests(Set<Id> interestIds) {
        List<Family_Portal_Guardian_Interest__c> interests = [
            SELECT Id
            FROM Family_Portal_Guardian_Interest__c
            WHERE Id IN :interestIds
        ];
        if (interests.size() > 0) {
            update interests;
        }
    }

    @future
    public static void deleteInterests(Set<Id> interestIds) {
        List<Family_Portal_Guardian_Interest__c> interests = [
            SELECT Id
            FROM Family_Portal_Guardian_Interest__c
            WHERE Id IN :interestIds
        ];
        if (interests.size() > 0) {
            delete interests;
        }
    }
}
