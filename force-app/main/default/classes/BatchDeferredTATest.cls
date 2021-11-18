@isTest
private class BatchDeferredTATest {
    private static List<User> testUsers;

    static void setup() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        testUsers = userCreator.create(2);

        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        for (User u : testUsers) {
            u.ProfileId = saProfile;
        }

        insert testUsers;
    }

    @isTest
    static void testBatchAccountDeferredLeadTA() {
        setup();
        User TestUser = testUsers[0];
        User TestUser2 = testUsers[1];

        Key_Value__c KVHS = new Key_Value__c();
        KVHS.Geomarket_ZIP__c = '84108';
        KVHS.Geomarket_Code__c = 'UT-01';
        insert KVHS;

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        HS.Institution_Type__c = 'HS';
        HS.Territory_Manager__c = TestUser.Id;
        insert HS;

        List<Lead> leadInsertList = new List<Lead>();
        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Type__c = 'First Time Freshman',
                Last_Institution_Attended__c = HS.id
            );
            leadInsertList.add(l);
        }
        insert leadInsertList;

        TerritoryAssignmentAccount.assignTerritoryDone = false;

        HS.Territory_Manager__c = TestUser2.Id;
        update HS;

        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<SObject> leadList = new List<SObject>();
        BatchAccountDeferredLeadTA acctDeferredLeadTA = new BatchAccountDeferredLeadTA();

        QL = acctDeferredLeadTA.start(bc);
        Database.QueryLocatorIterator QLI = QL.iterator();
        while (QLI.hasNext()) {
            Lead l = (Lead) QLI.next();
            System.debug(l);
            leadList.add(l);
        }
        acctDeferredLeadTA.execute(BC, leadList);
        acctDeferredLeadTA.finish(BC);
    }

    @isTest
    static void testBatchAccountDeferredOppTA() {
        setup();
        User TestUser = testUsers[0];
        User TestUser2 = testUsers[1];

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.Institution_Type__c = 'HS';
        HS.Territory_Manager__c = TestUser.Id;
        insert HS;

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        Con.Email = 'test@test.com';
        insert Con;

        Previous_Education__c pe = new Previous_Education__c();
        pe.Contact__c = Con.Id;
        pe.Account__c = HS.Id;
        insert pe;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        Opp.StageName = 'Prospect';
        Opp.Type = 'First Time Freshman';
        Opp.CloseDate = date.today() + 365;
        insert Opp;

        TerritoryAssignmentAccount.assignTerritoryDone = false;

        HS.Territory_Manager__c = TestUser2.Id;
        update HS;

        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<SObject> oppList = new List<SObject>();
        BatchAccountDeferredOppTA acctDeferredOppTA = new BatchAccountDeferredOppTA();

        QL = acctDeferredOppTA.start(bc);
        Database.QueryLocatorIterator QLI = QL.iterator();
        while (QLI.hasNext()) {
            Opportunity o = (Opportunity) QLI.next();
            System.debug(o);
            oppList.add(o);
        }
        acctDeferredOppTA.execute(BC, oppList);
        acctDeferredOppTA.finish(BC);
    }

    @isTest
    static void testBatchTARDeferredLeadTA() {
        setup();
        User TestUser = testUsers[0];
        User TestUser2 = testUsers[1];

        Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
        Atar1.Rule_Type__c = 'Default User';
        Atar1.User__c = TestUser.Id;
        Atar1.Opportunity_Type__c = 'First Time Freshman';
        insert Atar1;

        List<Lead> leadInsertList = new List<Lead>();
        for (Integer i = 0; i < 1; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email',
                Type__c = 'First Time Freshman'
            );
            leadInsertList.add(l);
        }
        insert leadInsertList;

        TerritoryAssignmentRule.assignTerritoryDone = false;

        Atar1.User__c = TestUser2.Id;
        update Atar1;

        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<SObject> leadList = new List<SObject>();
        BatchTARDeferredLeadTA tarDeferredLeadTA = new BatchTARDeferredLeadTA();

        QL = tarDeferredLeadTA.start(bc);
        Database.QueryLocatorIterator QLI = QL.iterator();
        while (QLI.hasNext()) {
            Lead l = (Lead) QLI.next();
            leadList.add(l);
        }
        tarDeferredLeadTA.execute(BC, leadList);
        tarDeferredLeadTA.finish(BC);
    }

    @isTest
    static void testBatchTARDeferredOppTA() {
        setup();
        User TestUser = testUsers[0];
        User TestUser2 = testUsers[1];

        Contact Con = new Contact();
        Con.FirstName = 'TestFirstName';
        Con.LastName = 'TestLastName';
        insert Con;

        Con = [SELECT Id, AccountId FROM Contact WHERE Id = :Con.Id];

        Territory_Assignment_Rule__c Atar1 = new Territory_Assignment_Rule__c();
        Atar1.Rule_Type__c = 'Default User';
        Atar1.User__c = TestUser.Id;
        Atar1.Opportunity_Type__c = 'First Time Freshman';
        insert Atar1;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.StageName = 'Prospect';
        Opp.Type = 'First Time Freshman';
        Opp.CloseDate = date.today() + 365;
        Opp.Contact__c = Con.Id;
        Opp.AccountId = Con.AccountId;
        insert Opp;

        TerritoryAssignmentRule.assignTerritoryDone = false;

        Atar1.User__c = TestUser2.Id;
        update Atar1;

        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<SObject> oppList = new List<SObject>();
        BatchTARDeferredOppTA tarDeferredOppTA = new BatchTARDeferredOppTA();

        QL = tarDeferredOppTA.start(bc);
        Database.QueryLocatorIterator QLI = QL.iterator();
        while (QLI.hasNext()) {
            Opportunity o = (Opportunity) QLI.next();
            oppList.add(o);
        }
        tarDeferredOppTA.execute(BC, oppList);
        tarDeferredOppTA.finish(BC);
    }
}
