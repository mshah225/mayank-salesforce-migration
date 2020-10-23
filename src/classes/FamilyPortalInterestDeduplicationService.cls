public class FamilyPortalInterestDeduplicationService implements Queueable {
    private List<Family_Portal_Guardian__c> recentlyUpdatedInterests;
    private static List<Family_Portal_Guardian_Interest__c> interestsToDelete;
    private static List<Family_Portal_Guardian_Interest__c> interestsToUpdate;

    public FamilyPortalInterestDeduplicationService(List<Family_Portal_Guardian__c> recentlyUpdatedInterests) {
        this.recentlyUpdatedInterests = recentlyUpdatedInterests;
    }

    public void execute(QueueableContext context) {
    }
}
