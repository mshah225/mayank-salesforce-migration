public class ContactHashUpdateBatch implements Database.Batchable<sObject> {
    public final String query;

    public ContactHashUpdateBatch() {
        query = 'SELECT Id, HashContactId__c FROM Contact WHERE HashContactId__c = null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for (Contact con : scope) {
            con.HashContactId__c = Hasher.hashId(con.Id);
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }
}
