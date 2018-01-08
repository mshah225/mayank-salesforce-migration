global class BatchApplySubscriberPrivacy implements Database.Batchable<sObject>, Database.Stateful {
	private static final boolean debug = false; // Toggle debug error reporting
	Set<Id> subscriptionIdSet = new Set<Id>();

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, OwnerId, Apex_Owner_Should_Be__c, Private_in_Salesforce__c, Apex_Private_in_Salesforce_Should_Be__c, Subscription__c ' +
					   'FROM Subscriber__c WHERE Subscription__r.Subscriber_Privacy_Changed__c = true';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Subscriber__c> subUpdateList = new List<Subscriber__c>();
		// Check each Subscriber record, and set the Owner and Private_In_Salesforce fields to match the values
		// calculated by their corresponding formula fields if they don't match
		for (SObject so: scope) {
			Subscriber__c sub = (Subscriber__c)so;
			if (sub.OwnerId != sub.Apex_Owner_Should_Be__c || sub.Private_in_Salesforce__c != Boolean.valueOf(sub.Apex_Private_in_Salesforce_Should_Be__c)) {
				sub.OwnerId = sub.Apex_Owner_Should_Be__c;
				sub.Private_in_Salesforce__c = Boolean.valueOf(sub.Apex_Private_in_Salesforce_Should_Be__c);
				subUpdateList.add(sub);
			}
			// Add to the ID set so we can reset the Subscriber_Privacy_Changed flags in the finish method
			subscriptionIdSet.add(sub.Subscription__c);
		}
		if (!subUpdateList.isEmpty()) {
			try {
				update subUpdateList;
			}
			catch (Exception ex) {
	            List<String> vars = new List<String>();
				vars.add(ErrorLogger.convertListToJSON('scope', scope));
	            vars.add(ErrorLogger.convertListToJSON('subUpdateList', subUpdateList));

	            ErrorLogger.log(ex, vars, debug);
			}
        }
	}

	global void finish(Database.BatchableContext BC) {
		// Reset all of the Subscriber_Privacy_Changed flags to false
		List<Subscription__c> subscriptions = ([SELECT Id, Subscriber_Privacy_Changed__c FROM Subscription__c WHERE Id IN :subscriptionIdSet]);
		for (Subscription__c sub: subscriptions) {
			sub.Subscriber_Privacy_Changed__c = false;
		}
		if (subscriptions != null) {
			try {
				update subscriptions;
			}
			catch (Exception ex) {
	            List<String> vars = new List<String>();
				vars.add(ErrorLogger.convertListToJSON('subscriptions', subscriptions));

	            ErrorLogger.log(ex, vars, debug);
			}
		}
	}

}