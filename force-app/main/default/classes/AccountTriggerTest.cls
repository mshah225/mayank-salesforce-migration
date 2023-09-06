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
}