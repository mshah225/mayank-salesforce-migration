@isTest
public class SubscriptionFactory {
    public class DefaultSubscription extends TestFactory {
        public DefaultSubscription() {
            super(
                new Subscription__c(
                    Name = 'Test Subscription',
                    Subscription_Type__c = 'List',
                    Subscriber_Private_in_Salesforce__c = false
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class ParentSubscription extends TestFactory {
        public ParentSubscription() {
            super(
                new Subscription__c(
                    Subscription_Type__c = 'Business Unit',
                    Name = 'ParentSub',
                    Subscription_Description__c = 'Parent Sub Description',
                    Available_for_Opt_In__c = true,
                    Subscriber_Private_in_Salesforce__c = false
                )
            );
            this.addToFieldsToIncrement('Name');
            this.addToFieldsToIncrement('Subscription_Description__c');
        }
    }
}
