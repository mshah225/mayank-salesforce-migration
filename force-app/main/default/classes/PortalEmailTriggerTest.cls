@isTest
public class PortalEmailTriggerTest {
    private static final String testUserAlias = 'testUsr';
    private static final String testGroupName = 'testGrp';

    @TestSetup
    public static void setup() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.example.com',
            Email = 'test.user@test.example.com',
            Recruiter_Email__c = 'test.user.recruiter.email@test.test',
            Alias = testUserAlias,
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('System Administrator')
        );
        insert testUser;

        Success_Resource__c testSuccessResource = new Success_Resource__c(
            IsActive__c = true,
            Role__c = 'User',
            Resource__c = testUser.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        insert testSuccessResource;

        Group testGroup = new Group(Name = testGroupName, Type = 'Queue');
        insert testGroup;

        List<QueueSobject> testQueues = new List<QueueSobject>{
            new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Success_Pod__c'),
            new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case')
        };
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueues;
        }

        Success_Pod__c testSuccessPodNotOwnedByGroup = new Success_Pod__c(
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor'),
            Primary_Email__c = 'owned.by.no.one@test.asu.edu',
            Name = 'Test Pod',
            Committee__c = 'tp'
        );
        Success_Pod__c testSuccessPodOwnedByGroup = new Success_Pod__c(
            OwnerId = testGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor'),
            Primary_Email__c = testGroup.Name + '@test.asu.edu',
            Name = 'Test Pod',
            Committee__c = 'tp'
        );
        insert new List<Success_Pod__c>{ testSuccessPodNotOwnedByGroup, testSuccessPodOwnedByGroup };

        Contact testContact = new Contact(FirstName = 'TestContact', LastName = 'TestContact');
        insert testContact;

        Success_Student__c testSuccessStudent = new Success_Student__c(
            Is_Active__c = true,
            Success_Pod__c = testSuccessPodNotOwnedByGroup.Id,
            Student__c = testContact.Id,
            Coaching_Student__c = false
        );
        insert testSuccessStudent;

        Case testCase = new Case(
            OwnerId = testGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'),
            Status = 'Outreach Required',
            Origin__c = 'Outreach',
            Subject = 'Test Case Subject',
            Description = 'Test Case Description',
            ContactId = testSuccessStudent.Student__c,
            Most_Recent_Queue__c = testGroup.Name
        );
        insert testCase;
    }

    @isTest
    private static void testDefaultSubject() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Portal_Email__c testPortalEmailSpecifySubject = new Portal_Email__c(
            Subject__c = 'Test Subject',
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com'
        );
        Portal_Email__c testPortalEmailEmptySubject = new Portal_Email__c(
            Subject__c = '',
            Additional_Message_Text__c = '',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com'
        );
        Portal_Email__c testPortalEmailNoSubject = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com'
        );

        Test.startTest();
        System.runAs(testUser) {
            insert new List<Portal_Email__c>{
                testPortalEmailSpecifySubject,
                testPortalEmailEmptySubject,
                testPortalEmailNoSubject
            };
        }
        Test.stopTest();

        testPortalEmailSpecifySubject = [
            SELECT Subject__c
            FROM Portal_Email__c
            WHERE Id = :testPortalEmailSpecifySubject.Id
        ];
        testPortalEmailEmptySubject = [
            SELECT Subject__c
            FROM Portal_Email__c
            WHERE Id = :testPortalEmailEmptySubject.Id
        ];
        testPortalEmailNoSubject = [SELECT Subject__c FROM Portal_Email__c WHERE Id = :testPortalEmailNoSubject.Id];

        System.assertEquals('Test Subject', testPortalEmailSpecifySubject.Subject__c);
        System.assertEquals('A Message from your College and Department', testPortalEmailEmptySubject.Subject__c);
        System.assertEquals('A Message from your College and Department', testPortalEmailNoSubject.Subject__c);
    }

    @isTest
    private static void testBodyStatusRelation() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        String notCancelled;
        Map<String, String> allStatusOptions = ObjectService.getPicklistChoicesMap('Portal_Email__c', 'Status__c');
        for (String key : allStatusOptions.keySet()) {
            String value = allStatusOptions.get(key);
            if (value != 'Cancelled') {
                notCancelled = value;
                break;
            }
        }

        Portal_Email__c testPortalEmailSpecifyBody = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com',
            Status__c = notCancelled
        );
        Portal_Email__c testPortalEmailEmptyBody = new Portal_Email__c(
            Additional_Message_Text__c = '',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com',
            Status__c = notCancelled
        );
        Portal_Email__c testPortalEmailNoBody = new Portal_Email__c(
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com',
            Status__c = notCancelled
        );

        Test.startTest();
        System.runAs(testUser) {
            insert new List<Portal_Email__c>{
                testPortalEmailSpecifyBody,
                testPortalEmailEmptyBody,
                testPortalEmailNoBody
            };
        }
        Test.stopTest();

        testPortalEmailSpecifyBody = [SELECT Status__c FROM Portal_Email__c WHERE Id = :testPortalEmailSpecifyBody.Id];
        testPortalEmailEmptyBody = [SELECT Status__c FROM Portal_Email__c WHERE Id = :testPortalEmailEmptyBody.Id];
        testPortalEmailNoBody = [SELECT Status__c FROM Portal_Email__c WHERE Id = :testPortalEmailNoBody.Id];

        System.assertNotEquals('Cancelled', testPortalEmailSpecifyBody.Status__c);
        System.assertEquals('Cancelled', testPortalEmailEmptyBody.Status__c);
        System.assertEquals('Cancelled', testPortalEmailNoBody.Status__c);
    }

    @isTest
    private static void testSetFromAddressAdvsiorUsingSuccessStudent() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Success_Student__c testSuccessStudent = [
            SELECT Id, Success_Pod__r.Primary_Email__c, Success_Pod__r.Email_Template__c
            FROM Success_Student__c
            LIMIT 1
        ];

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Change owner of case to a user so queue doesn't override success_student
        testCase.OwnerId = testUser.Id;
        update testCase;

        Portal_Email__c testPortalEmail = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            Success_Student__c = testSuccessStudent.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com',
            Case__c = testCase.Id
        );

        Test.startTest();
        insert testPortalEmail;
        Test.stopTest();

        testPortalEmail = [
            SELECT From_Address__c, Email_Template_Name__c
            FROM Portal_Email__c
            WHERE Id = :testPortalEmail.Id
            LIMIT 1
        ];

        System.assertEquals(testSuccessStudent.Success_Pod__r.Primary_Email__c, testPortalEmail.From_Address__c);
        System.assertEquals(
            testSuccessStudent.Success_Pod__r.Email_Template__c,
            testPortalEmail.Email_Template_Name__c
        );

        EmailMessage em = [SELECT Id, FromAddress FROM EmailMessage LIMIT 1];
        System.assertEquals(testPortalEmail.From_Address__c, em.FromAddress);
    }

    @isTest
    private static void testSetFromAddressAdvsiorUsingCaseQueueWhenGroupOwner() {
        Group testGroup = [SELECT Id FROM Group WHERE Name = :testGroupName];

        Success_Student__c testSuccessStudent = [
            SELECT Id, Success_Pod__c, Success_Pod__r.Primary_Email__c, Success_Pod__r.Email_Template__c
            FROM Success_Student__c
            LIMIT 1
        ];
        Success_Pod__c testPodOwnedByGroup = [
            SELECT Primary_Email__c, Email_Template__c
            FROM Success_Pod__c
            WHERE OwnerId = :testGroup.Id
        ];

        Case testCase = [SELECT Id FROM Case WHERE OwnerId = :testGroup.Id LIMIT 1];

        Portal_Email__c testPortalEmail = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com',
            Case__c = testCase.Id
        );

        Test.startTest();
        insert testPortalEmail;
        Test.stopTest();

        testPortalEmail = [
            SELECT From_Address__c, Email_Template_Name__c
            FROM Portal_Email__c
            WHERE Id = :testPortalEmail.Id
            LIMIT 1
        ];

        System.assertEquals(testPodOwnedByGroup.Primary_Email__c, testPortalEmail.From_Address__c);
        System.assertEquals(testPodOwnedByGroup.Email_Template__c, testPortalEmail.Email_Template_Name__c);

        EmailMessage em = [SELECT Id, FromAddress FROM EmailMessage LIMIT 1];
        System.assertEquals(testPortalEmail.From_Address__c, em.FromAddress);
    }

    @isTest
    private static void testSetFromAddressAdvsiorUsingCaseMostRecentQueueWhenUserOwner() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];
        Group testGroup = [SELECT Id FROM Group WHERE Name = :testGroupName];

        Success_Student__c testSuccessStudent = [
            SELECT Id, Success_Pod__c, Success_Pod__r.Primary_Email__c, Success_Pod__r.Email_Template__c
            FROM Success_Student__c
            LIMIT 1
        ];
        Success_Pod__c testPodOwnedByGroup = [
            SELECT Primary_Email__c, Email_Template__c
            FROM Success_Pod__c
            WHERE OwnerId = :testGroup.Id
        ];

        Case testCase = [SELECT Id FROM Case WHERE OwnerId = :testGroup.Id LIMIT 1];

        // Change owner of case to a user so you must look at most recent queue field
        testCase.OwnerId = testUser.Id;
        update testCase;

        Portal_Email__c testPortalEmail = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor'),
            From_Address__c = 'abc123@test.com',
            Case__c = testCase.Id
        );

        Test.startTest();
        insert testPortalEmail;
        Test.stopTest();

        testPortalEmail = [
            SELECT From_Address__c, Email_Template_Name__c
            FROM Portal_Email__c
            WHERE Id = :testPortalEmail.Id
            LIMIT 1
        ];

        System.assertEquals(testPodOwnedByGroup.Primary_Email__c, testPortalEmail.From_Address__c);
        System.assertEquals(testPodOwnedByGroup.Email_Template__c, testPortalEmail.Email_Template_Name__c);

        EmailMessage em = [SELECT Id, FromAddress FROM EmailMessage LIMIT 1];
        System.assertEquals(testPortalEmail.From_Address__c, em.FromAddress);
    }

    @isTest
    private static void testSetFromAddressCoach() {
        User testUser = [SELECT Id, Recruiter_Email__c FROM User WHERE Alias = :testUserAlias];

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Portal_Email__c testPortalEmail = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Coach'),
            From_Address__c = 'abc123@test.com',
            Case__c = testCase.Id
        );

        Test.startTest();
        System.runAs(testUser) {
            insert testPortalEmail;
        }
        Test.stopTest();

        testPortalEmail = [SELECT From_Address__c FROM Portal_Email__c WHERE Id = :testPortalEmail.Id LIMIT 1];
        System.assertEquals(testUser.Recruiter_Email__c, testPortalEmail.From_Address__c);

        EmailMessage em = [SELECT Id, FromAddress FROM EmailMessage LIMIT 1];
        System.assertEquals(testUser.Recruiter_Email__c, em.FromAddress);
    }

    @isTest
    private static void testErrorLogNullCoach() {
        Test.startTest();
        PortalEmailService.enqueueCoach(null);
        Test.stopTest();

        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        System.assertEquals(1, errorList.size());
    }

    @isTest
    private static void testErrorLogNullAdvisor() {
        Test.startTest();
        PortalEmailService.enqueueAdvisor(null);
        Test.stopTest();

        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        System.assertEquals(1, errorList.size());
    }

    // Pads test coverage by running delete/undelete
    @isTest
    private static void padTests() {
        Portal_Email__c testPortalEmail = new Portal_Email__c(
            Additional_Message_Text__c = 'Hello World',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Coach'),
            From_Address__c = 'abc123@test.com'
        );

        Test.startTest();
        insert testPortalEmail;
        Test.stopTest();

        delete testPortalEmail;
        undelete testPortalEmail;
    }
}
