@isTest
public with sharing class SuccessStudentTriggerTest {
    private static final Integer COACHING_STUDENTS_TO_CREATE = 10;
    private static final Integer ADVISING_STUDENTS_TO_CREATE = 5;
    private static final String testUserAlias1 = 'testUsr1';
    private static final String testUserAlias2 = 'testUsr2';

    @TestSetup
    private static void setup() {
        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'ASU Coach Outreach',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = 'Ad Hoc',
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;

        List<Contact> contacts = new List<Contact>();
        List<Contact> coachingContacts = new List<Contact>();
        List<Contact> advisingContacts = new List<Contact>();
        Integer emplidNum = 1023952395;
        for (Integer i = 0; i < COACHING_STUDENTS_TO_CREATE; i++) {
            coachingContacts.add(
                new Contact(
                    FirstName = 'Test ' + i,
                    LastName = 'Coaching Contact',
                    Email = 'test.coaching.' + i + '@test.com',
                    EmplId__c = String.valueOf(emplidNum++)
                )
            );
        }
        for (Integer i = 0; i < ADVISING_STUDENTS_TO_CREATE; i++) {
            advisingContacts.add(
                new Contact(
                    FirstName = 'Test ' + i,
                    LastName = 'Advising Contact',
                    Email = 'test.advising.' + i + '@test.com',
                    EmplId__c = String.valueOf(emplidNum++)
                )
            );
        }
        contacts.addAll(coachingContacts);
        contacts.addAll(advisingContacts);
        insert contacts;

        List<User> resourceUsers = new List<User>();
        resourceUsers.add(
            new User(
                FirstName = 'Test1',
                LastName = 'User',
                Username = 'test.user.1@test.test',
                Email = 'test.user.1@test.test',
                Alias = testUserAlias1,
                CommunityNickname = testUserAlias1,
                TimeZoneSidKey = 'America/Phoenix',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                IsActive = true,
                ProfileId = RecordIdHelper.getProfileId('System Administrator')
            )
        );
        resourceUsers.add(
            new User(
                FirstName = 'Test2',
                LastName = 'User',
                Username = 'test.user.2@test.test',
                Email = 'test.user.2@test.test',
                Alias = testUserAlias2,
                CommunityNickname = testUserAlias2,
                TimeZoneSidKey = 'America/Phoenix',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                IsActive = true,
                ProfileId = RecordIdHelper.getProfileId('System Administrator')
            )
        );
        insert resourceUsers;

        List<Success_Resource__c> successResources = new List<Success_Resource__c>();
        for (User u : resourceUsers) {
            successResources.add(
                new Success_Resource__c(
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Coach'),
                    Resource__c = u.Id
                )
            );
        }
        insert successResources;

        List<Success_Student__c> newSuccessStudents = new List<Success_Student__c>();
        for (Contact c : coachingContacts) {
            newSuccessStudents.add(
                new Success_Student__c(
                    Coaching_Student__c = true,
                    Student__c = c.Id,
                    Success_Resource__c = successResources[0].Id,
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach')
                )
            );
        }
        for (Contact c : advisingContacts) {
            newSuccessStudents.add(
                new Success_Student__c(
                    Coaching_Student__c = false,
                    Student__c = c.Id,
                    Success_Resource__c = successResources[0].Id
                )
            );
        }

        insert newSuccessStudents;
    }

    @isTest
    private static void studentTransferTest() {
        User testNonApiUser = new User(
            FirstName = 'Not an API',
            LastName = 'Test User',
            CompanyName = 'Test Company',
            MobilePhone = '123-456-7890',
            Username = 'test.nonAPI.user@test.test',
            Email = 'test.nonAPI.user@test.test',
            Alias = 'testNApi',
            CommunityNickname = 'testNApi',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert testNonApiUser;

        List<Success_Student__c> successStudents = [SELECT Id, Success_Resource__c, OwnerId FROM Success_Student__c];
        Id transferToResourceId = [
            SELECT Id
            FROM Success_Resource__c
            WHERE Id != :successStudents[0].Success_Resource__c
            LIMIT 1
        ]
        .Id;

        for (Success_Student__c successStudent : successStudents) {
            successStudent.Success_Resource__c = transferToResourceId;
        }

        test.startTest();
        System.runAs(testNonApiUser) {
            update successStudents;
        }
        test.stopTest();

        // Generate one case for each updated coaching success student
        System.assertEquals(COACHING_STUDENTS_TO_CREATE, [SELECT Id FROM Case].size());
    }

    @isTest
    private static void studentTransferTestApiUser() {
        User testApiUser = new User(
            FirstName = 'API',
            LastName = 'Test User',
            CompanyName = 'Test Company',
            MobilePhone = '123-456-7890',
            Username = 'test.API.user@test.test',
            Email = 'test.API.user@test.test',
            Alias = 'testApi',
            CommunityNickname = 'testApi',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = RecordIdHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert testApiUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'API_User_Custom_Perm_API_User' LIMIT 1];
            PermissionSetAssignment apiUserPsa = new PermissionSetAssignment(
                AssigneeId = testApiUser.Id,
                PermissionSetId = ps.Id
            );
            insert apiUserPsa;
        }

        List<Success_Student__c> successStudents = [SELECT Id, Success_Resource__c, OwnerId FROM Success_Student__c];
        Id transferToResourceId = [
            SELECT Id
            FROM Success_Resource__c
            WHERE Id != :successStudents[0].Success_Resource__c
            LIMIT 1
        ]
        .Id;

        for (Success_Student__c successStudent : successStudents) {
            successStudent.Success_Resource__c = transferToResourceId;
        }

        test.startTest();
        System.runAs(testApiUser) {
            update successStudents;
        }
        test.stopTest();

        // Generate one case for each updated coaching success student
        System.assertEquals(0, [SELECT Id FROM Case].size());
    }

    @isTest
    private static void deleteOnlyCoverageTest() {
        List<Success_Student__c> successStudents = [SELECT Id, Success_Resource__c, OwnerId FROM Success_Student__c];

        Test.startTest();
        delete successStudents;
        Test.stopTest();

        // No actual code runs - nothing to test
    }

    @isTest
    private static void undeleteOnlyCoverageTest() {
        List<Success_Student__c> successStudents = [SELECT Id, Success_Resource__c, OwnerId FROM Success_Student__c];
        delete successStudents;

        Test.startTest();
        undelete successStudents;
        Test.stopTest();

        // No actual code runs - nothing to test
    }
}
