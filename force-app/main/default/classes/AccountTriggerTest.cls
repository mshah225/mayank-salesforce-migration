@isTest
private class AccountTriggerTest {
    @isTest
    private static void testCreateAndUpdateAccount() {
        Account acc = new Account();
        acc.Name = 'Testaccount';
        insert acc;

        acc.Name = 'Testaccount2';
        update acc;

        System.assertEquals(acc.Name, 'Testaccount2');

        delete acc;
        undelete acc;
    }

    @isTest
    private static void testAccountGeomarketCodeAssignment() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        testUser.ProfileId = saProfile;
        insert testUser;

        Account highSchool = new Account();
        highSchool.Name = 'Test High School';
        insert highSchool;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.MailingPostalCode = '90210';
        con.Geomarket_Code__c = 'CA-01';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Key_Value__c KV = new Key_Value__c();
        KV.Geomarket_ZIP__c = '85287';
        KV.Geomarket_Code__c = 'GM-01';
        insert KV;

        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.Contact__c = con.Id;
        Opp.AccountId = con.AccountID;
        Opp.StageName = 'Prospect';
        Opp.CloseDate = date.today() + 365;
        Opp.Type = 'First Time Freshman';
        Opp.OwnerId = TestUser.Id;
        insert Opp;

        AccountService.assignTerritoryDone = false;

        Test.startTest();
        highSchool.ShippingPostalCode = '85287';
        highSchool.Territory_Manager__c = TestUser.Id;
        update highSchool;
        Test.stopTest();

        String accountGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Account WHERE Id = :highSchool.Id LIMIT 1]
        .Geomarket_Code__c;

        System.assert(
            accountGeoCodeAfterUpdate == KV.Geomarket_Code__c,
            'Account Geomarket Code did not match by ZIP code'
        );
    }

    @isTest
    private static void testOrgOrPerson() {
        String rtIdOrgExtMastered = RecordIdHelper.getRecordTypeId('Account', 'External_Mastered_Org');
        String rtIdOrgSFMastered = RecordIdHelper.getRecordTypeId('Account', 'SF_Mastered_Org');
        String rtIdPersonExtMastered = RecordIdHelper.getRecordTypeId('Account', 'External_Mastered_Contact');
        String rtIdPersonSFMastered = RecordIdHelper.getRecordTypeId('Account', 'SF_Mastered_Contact');

        Account accOrgExtMastered = new Account(Name = 'Test Ext Mst Org', RecordTypeId = rtIdOrgExtMastered);
        Account accOrgSFMastered = new Account(Name = 'Test SF Mst Org', RecordTypeId = rtIdOrgSFMastered);
        Account accPersonExtMastered = new Account(Name = 'Test Ext Mst Person', RecordTypeId = rtIdPersonExtMastered);
        Account accPersonSFMastered = new Account(Name = 'Test SF Mst Person', RecordTypeId = rtIdPersonSFMastered);

        FeatureFlagService.overrideTestDefault('Account Trigger', 'Organization or Person', true);

        Test.startTest();
        insert new List<Account>{ accOrgExtMastered, accOrgSFMastered, accPersonExtMastered, accPersonSFMastered };
        Test.stopTest();

        Map<Id, Account> testAccountMp = new Map<Id, Account>([SELECT Id, Organization_or_Person__c FROM Account]);
        accOrgExtMastered = testAccountMp.get(accOrgExtMastered.Id);
        accOrgSFMastered = testAccountMp.get(accOrgSFMastered.Id);
        accPersonExtMastered = testAccountMp.get(accPersonExtMastered.Id);
        accPersonSFMastered = testAccountMp.get(accPersonSFMastered.Id);

        Assert.areEqual('Organization', accOrgExtMastered.Organization_or_Person__c);
        Assert.areEqual('Organization', accOrgSFMastered.Organization_or_Person__c);
        Assert.areEqual('Person', accPersonExtMastered.Organization_or_Person__c);
        Assert.areEqual('Person', accPersonSFMastered.Organization_or_Person__c);
    }

    @isTest
    private static void testOrgOrPersonChangeRecordType() {
        String rtIdOrgSFMastered = RecordIdHelper.getRecordTypeId('Account', 'SF_Mastered_Org');
        String rtIdPersonSFMastered = RecordIdHelper.getRecordTypeId('Account', 'SF_Mastered_Contact');

        Account testAcc = new Account(Name = 'Test Ext Mst Org', RecordTypeId = rtIdOrgSFMastered);

        FeatureFlagService.overrideTestDefault('Account Trigger', 'Organization or Person', true);

        Test.startTest();
        insert testAcc;
        testAcc.RecordTypeId = rtIdPersonSFMastered;
        update testAcc;
        Test.stopTest();

        testAcc = [SELECT Id, Organization_or_Person__c FROM Account WHERE Id = :testAcc.Id];

        Assert.areEqual('Person', testAcc.Organization_or_Person__c);
    }
}
