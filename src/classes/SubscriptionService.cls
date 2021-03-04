public class SubscriptionService {
    @future
    public static void setHashId(List<Id> subIdList) {
        List<Subscription__c> subList = new List<Subscription__c>();
        for (Id i : subIdList) {
            Subscription__c c = new Subscription__c(Id = i, HashSubscriptionID__c = Hasher.hashId(i));
            subList.add(c);
        }
        update subList;
    }
}
