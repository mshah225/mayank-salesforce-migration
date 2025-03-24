@IsTest
public class FilterSetControllerTest {
    public static final String testUserAlias1 = 'testUsr1';
    public static final String testUserAlias2 = 'testUsr2';
    public static final String testUserAlias3 = 'testUsr3';

    @TestSetup
    static void setup() {
        User runAsUser = new User(Id = UserInfo.getUserId());

        // Create all the users
        User testUser1 = createUser(testUserAlias1, '1');
        User testUser2 = createUser(testUserAlias2, '2');
        User testUser3 = createUser(testUserAlias3, '3');
        System.runAs(runAsUser) {
            insert new List<User>{ testUser1, testUser2, testUser3 };
        }

        // Make the success resource for each user
        String sucResrcUgradRecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor');
        Success_Resource__c sucRes1 = createSuccessResource(testUser1, 'User', sucResrcUgradRecordTypeId);
        Success_Resource__c sucRes2 = createSuccessResource(testUser2, 'User', sucResrcUgradRecordTypeId);
        Success_Resource__c sucRes3 = createSuccessResource(testUser3, 'College Manager', sucResrcUgradRecordTypeId);
        System.runAs(runAsUser) {
            insert new List<Success_Resource__c>{ sucRes1, sucRes2, sucRes3 };
        }

        // Success pods
        Success_Pod__c sucPod1 = new Success_Pod__c(
            OwnerId = testUser3.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor'),
            Name = 'Test Pod',
            Committee__c = 'tp-01'
        );

        System.runAs(runAsUser) {
            insert new List<Success_Pod__c>{ sucPod1 };
        }

        // Success Resource Pod Associations
        Success_Resource_Pod_Association__c sr1p1a = createSRPA(sucRes1, sucPod1);
        Success_Resource_Pod_Association__c sr2p1a = createSRPA(sucRes2, sucPod1);
        Success_Resource_Pod_Association__c sr3p1a = createSRPA(sucRes3, sucPod1);
        System.runAs(runAsUser) {
            insert new List<Success_Resource_Pod_Association__c>{ sr1p1a, sr2p1a, sr3p1a };
        }
    }

    @isTest
    private static void testUser1CannotShare() {
        // Test user 1 should not be allowed to share
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias1];

        Boolean canShare = null;
        System.runAs(testUser) {
            canShare = FilterSetController.checkIfCanShare();
        }
        Assert.areEqual(false, canShare);
    }

    @isTest
    private static void testUser2CannotShare() {
        // Test user 2 should not be allowed to share
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2];

        Boolean canShare = null;
        System.runAs(testUser) {
            canShare = FilterSetController.checkIfCanShare();
        }
        Assert.areEqual(false, canShare);
    }

    @isTest
    private static void testUser3CanShare() {
        // Test user 3 should be allowed to share
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias3];

        Boolean canShare = null;
        System.runAs(testUser) {
            canShare = FilterSetController.checkIfCanShare();
        }
        Assert.areEqual(true, canShare);
    }

    @isTest
    private static void testUser3Options() {
        // Test user 3 should be allowed to share
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias3];

        List<LabelValue> shareOptions = null;
        System.runAs(testUser) {
            shareOptions = FilterSetController.getShareOptions();
        }

        User testUser1 = [SELECT Id FROM User WHERE Alias = :testUserAlias1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2];

        Assert.areEqual(2, shareOptions.size());
        Assert.areEqual('Test-1 User - testUsr1', shareOptions[0].label);
        Assert.areEqual(testUser1.Id, shareOptions[0].value);
        Assert.areEqual('Test-2 User - testUsr2', shareOptions[1].label);
        Assert.areEqual(testUser2.Id, shareOptions[1].value);
    }

    private static User createUser(String alias, String indx) {
        return new User(
            FirstName = 'Test-' + indx,
            LastName = 'User',
            Username = 'test-' + indx + '.user@test.test',
            Email = 'test-' + indx + '.user@test.test',
            Alias = alias,
            CommunityNickname = alias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User')
        );
    }

    private static Success_Resource__c createSuccessResource(User u, String role, String recordTypeId) {
        return new Success_Resource__c(
            Role__c = role,
            Resource__c = u.Id,
            IsActive__c = true,
            RecordTypeId = recordTypeId
        );
    }

    private static Success_Resource_Pod_Association__c createSRPA(Success_Resource__c sucRes, Success_Pod__c sucPod) {
        return new Success_Resource_Pod_Association__c(Success_Resource__c = sucRes.Id, Success_Pod__c = sucPod.Id);
    }
}