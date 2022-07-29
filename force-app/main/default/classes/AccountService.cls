public with sharing class AccountService {
    public static void updateCorrespondingContact(List<Case> updatedCases, Map<Id, Case> previousCasesMap) {
        Map<Id, Id> accountsToNewContacts = new Map<Id, Id>();
        for (Case updatedCase : updatedCases) {
            Case previousCase = previousCasesMap.get(updatedCase.Id);

            if (previousCase.ContactId != updatedCase.ContactId) {
                accountsToNewContacts.put(updatedCase.AccountId, updatedCase.ContactId);
            }
        }
        updateAccountContact(accountsToNewContacts);
    }

    public static void updateCorrespondingContact(
        List<Opportunity> updatedOpportunities,
        Map<Id, Opportunity> previousOpportunitiesMap
    ) {
        Map<Id, Id> accountsToNewContacts = new Map<Id, Id>();
        for (Opportunity updatedOpportunity : updatedOpportunities) {
            Opportunity previousOpportunity = previousOpportunitiesMap.get(updatedOpportunity.Id);

            if (previousOpportunity.Contact__c != updatedOpportunity.Contact__c) {
                accountsToNewContacts.put(updatedOpportunity.AccountId, updatedOpportunity.Contact__c);
            }
        }
        updateAccountContact(accountsToNewContacts);
    }

    private static void updateAccountContact(Map<Id, Id> accountsToNewContacts) {
        List<Account> accountsToUpdate = new List<Account>();
        for (Account accountToUpdate : [
            SELECT Id, Contact__c
            FROM Account
            WHERE Id IN :accountsToNewContacts.keySet()
        ]) {
            accountToUpdate.Contact__c = accountsToNewContacts.get(accountToUpdate.Id);
            accountsToUpdate.add(accountToUpdate);
        }

        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
    }
}
