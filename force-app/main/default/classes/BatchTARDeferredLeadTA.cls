global class BatchTARDeferredLeadTA implements Database.Batchable<sObject> {
    String query;
    static List<Territory_Assignment_Rule__c> tarList = new List<Territory_Assignment_Rule__c>();

    global BatchTARDeferredLeadTA() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        tarList = [
            SELECT Id, Previous_User_ID__c, Defer_Territory_Assignment__c
            FROM Territory_Assignment_Rule__c
            WHERE Defer_Territory_Assignment__c = TRUE AND Previous_User_ID__c != NULL
        ];

        Set<Id> previousTmUserIds = new Set<Id>();
        for (Territory_Assignment_Rule__c tar : tarList) {
            previousTmUserIds.add(ID.valueOf(tar.Previous_User_ID__c));
        }

        query = 'SELECT Id, Territory_Assignment_Required__c FROM Lead WHERE OwnerId IN :previousTmUserIds AND Territory_Assignment_Last_Rule_Type__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (sObject s : scope) {
            s.put('Territory_Assignment_Required__c', true);
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        tarList = [
            SELECT Id, Previous_User_ID__c, Defer_Territory_Assignment__c
            FROM Territory_Assignment_Rule__c
            WHERE Defer_Territory_Assignment__c = TRUE AND Previous_User_ID__c != NULL
        ];
        for (Territory_Assignment_Rule__c tar : tarList) {
            tar.Defer_Territory_Assignment__c = false;
        }
        update tarList;
    }
}
