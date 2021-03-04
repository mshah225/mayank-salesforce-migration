public class BatchApplyIerPrivacy implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    private static final Boolean debug = false; // Toggle debug error reporting
    private Set<Id> businessUnitIdSet = new Set<Id>();
    private Set<Id> campaignIdSet = new Set<Id>();
    private Set<Id> subscriptionIdSet = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            'SELECT Id, OwnerId, Apex_Owner_Should_Be__c, Private_in_Salesforce__c, ' +
            'Apex_Private_in_Salesforce_Should_Be__c, ' +
            'et4ae5__SendDefinition__r.et4ae5__Business_Unit__r.IER_Privacy_Changed__c, ' +
            'et4ae5__SendDefinition__r.et4ae5__Business_Unit__c, ' +
            'et4ae5__SendDefinition__r.et4ae5__Campaign__r.IER_Privacy_Changed__c, ' +
            'et4ae5__SendDefinition__r.et4ae5__Campaign__c, ' +
            'et4ae5__SendDefinition__r.et4ae5__Campaign__r.Subscription__r.IER_Privacy_Changed__c, ' +
            'et4ae5__SendDefinition__r.et4ae5__Campaign__r.Subscription__c ' +
            'FROM   et4ae5__IndividualEmailResult__c ' +
            'WHERE  et4ae5__SendDefinition__r.et4ae5__Business_Unit__r.IER_Privacy_Changed__c = true OR ' +
            'et4ae5__SendDefinition__r.et4ae5__Campaign__r.IER_Privacy_Changed__c = true OR ' +
            'et4ae5__SendDefinition__r.et4ae5__Campaign__r.Subscription__r.IER_Privacy_Changed__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<et4ae5__IndividualEmailResult__c> ierUpdateList = new List<et4ae5__IndividualEmailResult__c>();
        // Check each IER record, and set the Owner and Private_In_Salesforce fields to match the values
        // calculated by their corresponding formula fields if they don't match
        for (et4ae5__IndividualEmailResult__c ier : (List<et4ae5__IndividualEmailResult__c>) scope) {
            if (
                ier.OwnerId != ier.Apex_Owner_Should_Be__c ||
                ier.Private_in_Salesforce__c != Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c)
            ) {
                ier.OwnerId = ier.Apex_Owner_Should_Be__c;
                ier.Private_in_Salesforce__c = Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c);
                ierUpdateList.add(ier);
            }
            // Add to the ID sets so we can reset the IER_Privacy_Changed flags in the finish method
            if (ier.et4ae5__SendDefinition__r.et4ae5__Business_Unit__r.IER_Privacy_Changed__c == true) {
                businessUnitIdSet.add(ier.et4ae5__SendDefinition__r.et4ae5__Business_Unit__c);
            }
            if (ier.et4ae5__SendDefinition__r.et4ae5__Campaign__r.IER_Privacy_Changed__c == true) {
                campaignIdSet.add(ier.et4ae5__SendDefinition__r.et4ae5__Campaign__c);
            }
            if (ier.et4ae5__SendDefinition__r.et4ae5__Campaign__r.Subscription__r.IER_Privacy_Changed__c == true) {
                subscriptionIdSet.add(ier.et4ae5__SendDefinition__r.et4ae5__Campaign__r.Subscription__c);
            }
        }
        if (!ierUpdateList.isEmpty()) {
            try {
                update ierUpdateList;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('scope', scope));
                vars.add(ErrorLogger.convertListToJSON('ierUpdateList', ierUpdateList));
                ErrorLogger.log(ex, vars, debug);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Reset all of the IER_Privacy_Changed flags to false
        if (!businessUnitIdSet.isEmpty()) {
            List<et4ae5__Business_Unit__c> businessUnits = new List<et4ae5__Business_Unit__c>();
            for (Id buId : businessUnitIdSet) {
                et4ae5__Business_Unit__c bu = new et4ae5__Business_Unit__c();
                bu.Id = buId;
                bu.IER_Privacy_Changed__c = false;
                businessUnits.add(bu);
            }
            if (!businessUnits.isEmpty()) {
                try {
                    update businessUnits;
                } catch (Exception ex) {
                    List<String> vars = new List<String>();
                    vars.add(ErrorLogger.convertSetToJSON('businessUnitIdSet', businessUnitIdSet));
                    vars.add(ErrorLogger.convertListToJSON('businessUnits', businessUnits));
                    ErrorLogger.log(ex, vars, debug);
                }
            }
        }

        if (!campaignIdSet.isEmpty()) {
            List<Campaign> campaigns = new List<Campaign>();
            for (Id camId : campaignIdSet) {
                Campaign cam = new Campaign();
                cam.Id = camId;
                cam.IER_Privacy_Changed__c = false;
                campaigns.add(cam);
            }
            if (!campaigns.isEmpty()) {
                try {
                    update campaigns;
                } catch (Exception ex) {
                    List<String> vars = new List<String>();
                    vars.add(ErrorLogger.convertSetToJSON('campaignIdSet', campaignIdSet));
                    vars.add(ErrorLogger.convertListToJSON('campaigns', campaigns));
                    ErrorLogger.log(ex, vars, debug);
                }
            }
        }

        if (!subscriptionIdSet.isEmpty()) {
            List<Subscription__c> subscriptions = new List<Subscription__c>();
            for (Id subId : subscriptionIdSet) {
                Subscription__c sub = new Subscription__c();
                sub.Id = subId;
                sub.IER_Privacy_Changed__c = false;
                subscriptions.add(sub);
            }
            if (!subscriptions.isEmpty()) {
                try {
                    update subscriptions;
                } catch (Exception ex) {
                    List<String> vars = new List<String>();
                    vars.add(ErrorLogger.convertSetToJSON('subscriptionIdSet', subscriptionIdSet));
                    vars.add(ErrorLogger.convertListToJSON('subscriptions', subscriptions));
                    ErrorLogger.log(ex, vars, debug);
                }
            }
        }
    }

    public void execute(SchedulableContext sc) {
        BatchApplyIerPrivacy b = new BatchApplyIerPrivacy();
        database.executebatch(b, 200);
    }
}
