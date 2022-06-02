@isTest
public class DeferredTABatchSchedulerTest {
    private static final String testUserAlias = 'testUsr';
    private static final String testUserAlias2 = 'testUsr2';

    @TestSetup
    private static void setup() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.test',
            Email = 'test.user@test.test',
            Alias = testUserAlias,
            CommunityNickname = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User')
        );
        User testUser2 = new User(
            FirstName = 'Test 2',
            LastName = 'User',
            Username = 'test.user.2@test.test',
            Email = 'test.user.2@test.test',
            Alias = testUserAlias2,
            CommunityNickname = testUserAlias2,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User')
        );
        insert new List<User>{ testUser, testUser2 };

        List<Key_Value__c> geomarketCodes = new List<Key_Value__c>();
        String r = RecordIdHelper.getRecordTypeId('Key_Value__c', 'Geomarket_Code_Map');
        Key_Value__c geoMarket51 = new Key_Value__c(
            Geomarket_Code__c = 'US-51',
            Geomarket_ZIP__c = '50001',
            RecordTypeId = r
        );
        Key_Value__c geoMarket52 = new Key_Value__c(
            Geomarket_Code__c = 'US-52',
            Geomarket_ZIP__c = '50002',
            RecordTypeId = r
        );
        Key_Value__c geoMarket53 = new Key_Value__c(
            Geomarket_Code__c = 'US-53',
            Geomarket_ZIP__c = '50003',
            RecordTypeId = r
        );
        Key_Value__c geoMarket61 = new Key_Value__c(
            Geomarket_Code__c = 'US-61',
            Geomarket_ZIP__c = '60001',
            RecordTypeId = r
        );
        Key_Value__c geoMarket62 = new Key_Value__c(
            Geomarket_Code__c = 'US-62',
            Geomarket_ZIP__c = '60002',
            RecordTypeId = r
        );
        Key_Value__c geoMarket63 = new Key_Value__c(
            Geomarket_Code__c = 'US-63',
            Geomarket_ZIP__c = '60003',
            RecordTypeId = r
        );
        geomarketCodes.add(geoMarket51);
        geomarketCodes.add(geoMarket52);
        geomarketCodes.add(geoMarket53);
        geomarketCodes.add(geoMarket61);
        geomarketCodes.add(geoMarket62);
        geomarketCodes.add(geoMarket63);
        insert geomarketCodes;

        Account testAcc = new Account(
            Name = 'Test HS Account',
            Institution_Type__c = 'HS',
            Defer_Territory_Assignment__c = false,
            ShippingPostalCode = geoMarket51.Geomarket_ZIP__c,
            Previous_Territory_Manager_ID__c = testUser.Id,
            Territory_Manager__c = testUser.Id
        );
        insert testAcc;

        Territory_Assignment_Rule__c testTAR = new Territory_Assignment_Rule__c(
            Rule_Type__c = 'Geomarket',
            Opportunity_Type__c = 'Transfer',
            Geomarket__c = geoMarket61.Geomarket_Code__c,
            User__c = testUser.Id
        );
        insert testTAR;

        Contact testContact = new Contact(
            FirstName = 'Test Contact',
            LastName = 'rtn-deferredTABatchSceduler',
            Last_HS_Attended__c = testAcc.Id,
            Email = 'test@email.rtn.test',
            EmplId__c = '13001'
        );
        Contact testContact2 = new Contact(
            FirstName = 'Test Contact 2',
            LastName = 'rtn-deferredTABatchSceduler',
            Email = 'test2@email.rtn.test',
            EmplId__c = '13002',
            Geomarket_Code__c = geoMarket61.Geomarket_Code__c,
            MailingPostalCode = geoMarket61.Geomarket_ZIP__c
        );
        insert new List<Contact>{ testContact, testContact2 };

        Opportunity testOpp = new Opportunity(
            Contact__c = testContact.Id,
            Career__c = 'Undergraduate',
            Type = 'First Time Freshman',
            AccountId = testAcc.Id,
            Name = 'TestOppo',
            StageName = 'TestOppo',
            CloseDate = Date.newInstance(2025, 9, 12)
        );
        Opportunity testOpp2 = new Opportunity(
            Contact__c = testContact2.Id,
            Career__c = 'Undergraduate',
            Type = 'Transfer',
            AccountId = testAcc.Id,
            Name = 'TestOppo',
            StageName = 'TestOppo',
            CloseDate = Date.newInstance(2025, 9, 12)
        );
        insert new List<Opportunity>{ testOpp, testOpp2 };

        Lead testLead = new Lead(
            FirstName = 'Test Lead',
            LastName = 'rtn-deferredTABatchSceduler',
            Company = 'Company',
            Email = 'test@email.rtn.test',
            LeadSource = 'Email',
            Type__c = 'First Time Freshman',
            Last_Institution_Attended__c = testAcc.id
        );
        Lead testLead2 = new Lead(
            FirstName = 'Test Lead 2',
            LastName = 'rtn-deferredTABatchSceduler',
            Company = 'Company 2',
            Email = 'test2@email.rtn.test',
            LeadSource = 'Email',
            Type__c = 'Transfer',
            Geomarket_Code__c = geoMarket61.Geomarket_Code__c
        );
        insert new List<Lead>{ testLead, testLead2 };
    }

    // Change the territory manager for a Contact's last high school. If the contact's opportunities were territory
    // assigned based to the old territory manager then we expect them to be updated when the scheduled job runs.
    @isTest
    private static void testAccountDeferredOpportunity() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        Account testAcc = [SELECT Id, Territory_Manager__c FROM Account WHERE Territory_Manager__c = :testUser.Id];

        testAcc.Territory_Manager__c = testUser2.Id;
        update testAcc; // change account territory manager

        Opportunity testOpp = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Last Attended High School'
            LIMIT 1
        ];

        System.assertEquals(testUser.Id, testOpp.OwnerId); // owner should start as user 1

        Test.startTest();
        DeferredTABatchScheduler schedulable = new DeferredTABatchScheduler();
        schedulable.execute(null); // use this instead of System.schedule to ensure that the batch class are run when we call Test.stopTest()
        Test.stopTest();

        testOpp = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Last Attended High School'
            LIMIT 1
        ];

        System.assertEquals(testUser2.Id, testOpp.OwnerId); // changed owner to user 2
    }

    // Change the territory manager for a Lead's Last_Institution_Attended__c. If the lead was territory
    // assigned based to the old territory manager then we expect them to be updated when the scheduled job runs.
    @isTest
    private static void testAccountDeferredLead() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        Account testAcc = [SELECT Id, Territory_Manager__c FROM Account WHERE Territory_Manager__c = :testUser.Id];

        testAcc.Territory_Manager__c = testUser2.Id;
        update testAcc; // change account territory manager

        Lead testLead = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Lead
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Last Institution Attended'
            LIMIT 1
        ];

        System.assertEquals(testUser.Id, testLead.OwnerId); // owner should start as user 1

        Test.startTest();
        DeferredTABatchScheduler schedulable = new DeferredTABatchScheduler();
        schedulable.execute(null); // use this instead of System.schedule to ensure that the batch class are run when we call Test.stopTest()
        Test.stopTest();

        testLead = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Lead
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Last Institution Attended'
            LIMIT 1
        ];

        System.assertEquals(testUser2.Id, testLead.OwnerId); // changed owner to user 2
    }

    // Change the territory manager for a Contact's geomarket. If the contact's opportunities were territory
    // assigned based to the old territory manager then we expect them to be updated when the scheduled job runs.
    @isTest
    private static void testTARDeferredOpportunity() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        Territory_Assignment_Rule__c testTAR = [
            SELECT Id, User__c
            FROM Territory_Assignment_Rule__c
            WHERE User__c = :testUser.Id
        ];

        testTAR.User__c = testUser2.Id;
        update testTAR; // change TAR owner

        Opportunity testOpp = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer'
            LIMIT 1
        ];

        System.assertEquals(testUser.Id, testOpp.OwnerId); // owner should start as user 1

        Test.startTest();
        DeferredTABatchScheduler schedulable = new DeferredTABatchScheduler();
        schedulable.execute(null); // use this instead of System.schedule to ensure that the batch class are run when we call Test.stopTest()
        Test.stopTest();

        testOpp = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer'
            LIMIT 1
        ];

        System.assertEquals(testUser2.Id, testOpp.OwnerId); // changed owner to user 2
    }

    // Change the territory manager for a Leads's geomarket. If the lead's opportunities were territory
    // assigned based to the old territory manager then we expect them to be updated when the scheduled job runs.
    @isTest
    private static void testTARDeferredLead() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2 LIMIT 1];
        Territory_Assignment_Rule__c testTAR = [
            SELECT Id, User__c
            FROM Territory_Assignment_Rule__c
            WHERE User__c = :testUser.Id
        ];

        testTAR.User__c = testUser2.Id;
        update testTAR; // change TAR owner

        Lead testLead = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Lead
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer'
            LIMIT 1
        ];

        System.assertEquals(testUser.Id, testLead.OwnerId); // owner should start as user 1

        Test.startTest();
        DeferredTABatchScheduler schedulable = new DeferredTABatchScheduler();
        schedulable.execute(null); // use this instead of System.schedule to ensure that the batch class are run when we call Test.stopTest()
        Test.stopTest();

        testLead = [
            SELECT Id, OwnerId, Territory_Assignment_Last_Rule_Type__c
            FROM Lead
            WHERE Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer'
            LIMIT 1
        ];

        System.assertEquals(testUser2.Id, testLead.OwnerId); // changed owner to user 2
    }
}
