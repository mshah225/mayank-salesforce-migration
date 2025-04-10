@isTest
private class InactiveRelationshipBatchJobTest {
    @testSetup
    static void setupData(){
        Relationships__c partnerRel = new Relationships__c();
        partnerRel.Name = 'Partner';
        partnerRel.Reciprocal__c = 'Partner';
        insert partnerRel;
        
        Account testAccount = new Account(Name = 'Test Account', Website = 'www.example.com');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Relationship__c rel1 = new Relationship__c(
            Related_Account__c = testAccount.Id,
            Active_Relationship__c = true,
            Contact__c = testContact.Id,
            Title__c = 'Test Title',
            Relationship_Type__c = 'Partner',
            Relationship_Start_Date__c = Date.today().addDays(-2),
            Relationship_End_Date__c = Date.today().addDays(-1)
        );
        
        Relationship__c rel2 = new Relationship__c(
            Related_Account__c = testAccount.Id,
            Active_Relationship__c = true,
            Contact__c = testContact.Id,
            Title__c = 'Test Title',
            Relationship_Type__c = 'Partner',
            Relationship_Start_Date__c = Date.today().addDays(-2),
            Relationship_End_Date__c = Date.today()
        );
        
        insert new List<Relationship__c>{ rel1, rel2 };
    }
    
    @isTest
    static void testBatchUpdate(){
        Test.startTest();
        InactiveRelationshipBatchJob batchJob = new InactiveRelationshipBatchJob();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();
        
        List<Relationship__c> updatedRecords = [SELECT Id, Active_Relationship__c
                                                  FROM Relationship__c
                                                  WHERE Relationship_End_Date__c <= :Date.today()];
        for(Relationship__c rel : updatedRecords){
            System.assertEquals(false, rel.Active_Relationship__c);
        }
    }
}
