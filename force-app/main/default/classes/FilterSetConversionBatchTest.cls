@isTest
public class FilterSetConversionBatchTest {
    private static final String testUserAlias = 'testUsr1';

    @TestSetup
    private static void setup() {
        // Test user
        User testUser = new User(
            FirstName = 'Test User Richard',
            LastName = 'McKinnon',
            Email = 'richard.mckinnon@test.asu.edu',
            Username = 'richard.mckinnon@test.asu.edu',
            Alias = testUserAlias,
            ProfileId = RecordIdHelper.getProfileId('ASU Read Only'),
            TimeZoneSidKey = 'America/Phoenix',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = null
        );
        insert testUser;

        // Create success resources
        Success_Resource__c sucRes1 = new Success_Resource__c(
            Resource__c = testUser.Id,
            Role__c = 'College Manager',
            IsActive__c = true,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor'),
            Default_Filter__c = '{"career":"GRD","caseTypeState":"ProactiveCasesState","caseStatus":"Outreach Required"}'
        );

        Success_Resource__c sucRes2 = new Success_Resource__c(
            Resource__c = testUser.Id,
            Role__c = 'User',
            IsActive__c = false,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor'),
            Default_Filter__c = '{"career":"GRD","caseTypeState":"ProactiveCasesState","caseStatus":"Outreach Required"}'
        );

        insert new List<Success_Resource__c>{ sucRes1, sucRes2 };
    }

    @isTest
    private static void testConversion() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Test.startTest();
        Database.executeBatch(new FilterSetConversionBatch(), 50);
        Test.stopTest();

        List<Filter_Set_User_Association__c> fsuas = [
            SELECT Id, User__c, Filter_Set__r.Value__c, Filter_Set__r.OwnerId, Filter_Set__r.Name
            FROM Filter_Set_User_Association__c
            WHERE User__c = :testUser.Id
        ];

        // Created
        Assert.areEqual(1, fsuas.size());
        // Has correct owner and User__c
        Assert.areEqual(testUser.Id, fsuas[0].User__c);
        Assert.areEqual(testUser.Id, fsuas[0].Filter_Set__r.OwnerId);
        // Correct name
        Assert.areEqual('Saved default filter', fsuas[0].Filter_Set__r.Name);
        // Correct values
        Assert.isTrue(fsuas[0].Filter_Set__r.Value__c.contains('"version":"v3"'), 'Filter set should have version=v3');
        Assert.isTrue(fsuas[0].Filter_Set__r.Value__c.contains('"career":"GRD"'), 'Filter set should have career=GRD');
        Assert.isTrue(
            fsuas[0].Filter_Set__r.Value__c.contains('"caseTypeState":"ProactiveCasesState"'),
            'Filter set should have caseTypeState=ProactiveCasesState'
        );
        Assert.isTrue(
            fsuas[0].Filter_Set__r.Value__c.contains('"caseStatus":"Outreach Required"'),
            'Filter set should have caseStatus=Outreach Required'
        );
    }
}