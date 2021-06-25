@isTest
public class SubscriberFactory {
    public class DefaultSubscriber extends TestFactory {
        public DefaultSubscriber() {
            super(new Subscriber__c(Subscriber_Status__c = 'Unsubscribed', OwnerId = UserInfo.getUserId()));
        }
    }
}
