@isTest
public with sharing class PersistenceOutlookTriggerTest {
    
    @testSetup
    public static void setup(){
        Contact c = ContactService.createTestContact();
        insert c;

        Persistence_Outlook__c po = new Persistence_Outlook__c(Contact__c = c.Id);
        po.Career_Segment__c = '1';
        insert po;
    }

    @isTest
    public static void testRecordCreation() {
        Persistence_Outlook__c po = [SELECT Id FROM Persistence_Outlook__c WHERE Career_Segment__c = '1'];
        System.assertNotEquals(null, po.Id, 'Persistence outlook record not created.');
    }

    @isTest
    public static void testRecordUpdate() {
        Persistence_Outlook__c po = [SELECT Id, Career_Segment__c FROM Persistence_Outlook__c WHERE Career_Segment__c = '1'];

        // update the record
        po.Career_Segment__c = '2';
        update po;

        Persistence_Outlook__c updatedPo = [SELECT Id, Career_Segment__c FROM Persistence_Outlook__c WHERE Id = :po.Id];
        System.assertEquals('2', updatedPo.Career_Segment__c, 'Persistence outlook record not updated');
    }

    @isTest
    static void testRecordDeleteOnlyCoverage() {
        Persistence_Outlook__c po = [SELECT Id, Career_Segment__c FROM Persistence_Outlook__c WHERE Career_Segment__c = '1'];

        // Delete the record
        delete po;
    }

    @isTest
    static void testRecordUnDeleteOnlyCoverage() {
        Persistence_Outlook__c po = [SELECT Id, Career_Segment__c FROM Persistence_Outlook__c WHERE Career_Segment__c = '1'];

        // Delete the record
        delete po;

        // Undelete the record
        undelete po;
    }

}