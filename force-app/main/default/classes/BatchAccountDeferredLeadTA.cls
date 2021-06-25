global class BatchAccountDeferredLeadTA implements Database.Batchable<sObject> {
    String query;
    List<Account> accountList = new List<Account>();

    global BatchAccountDeferredLeadTA() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        accountList = [
            SELECT Id, Previous_Territory_Manager_ID__c, Defer_Territory_Assignment__c
            FROM Account
            WHERE Defer_Territory_Assignment__c = TRUE AND Previous_Territory_Manager_ID__c != NULL
        ];

        Set<Id> previousTmUserIds = new Set<Id>();
        for (Account a : accountList) {
            previousTmUserIds.add(ID.valueOf(a.Previous_Territory_Manager_ID__c));
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
        accountList = [
            SELECT Id, Previous_Territory_Manager_ID__c
            FROM Account
            WHERE Defer_Territory_Assignment__c = TRUE AND Previous_Territory_Manager_ID__c != NULL
        ];
        for (Account a : accountList) {
            a.Defer_Territory_Assignment__c = false;
        }
        update accountList;
    }
}
