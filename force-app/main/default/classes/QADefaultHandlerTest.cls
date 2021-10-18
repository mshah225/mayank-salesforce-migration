@isTest
public class QADefaultHandlerTest {
    private static final String userAlias = 'testusr';
    private static final String groupName = 'TestGroupName1';

    @TestSetup
    public static void setup() {
        User runAsUser = new User(Id = UserInfo.getUserId());

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user.Emperor.Of.Byzantium@test.test',
            Email = 'test.user@test.test',
            Recruiter_Email__c = 'recruit.email@test.test',
            Alias = userAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = IDHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Case_Classification__c testAdvFuncGroup = new Case_Classification__c(
            Name = 'ASU Advisor Outreach',
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group'),
            Active__c = true,
            Visible__c = true
        );
        Case_Classification__c testCoachFuncGroup = new Case_Classification__c(
            Name = 'ASU Coach Outreach',
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group'),
            Active__c = true,
            Visible__c = true
        );
        insert new List<Case_Classification__c>{ testAdvFuncGroup, testCoachFuncGroup };

        Case_Classification__c testAdvCategory = new Case_Classification__c(
            Name = 'Test Outreach Category',
            Parent__c = testAdvFuncGroup.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category'),
            Active__c = true,
            Visible__c = true
        );
        Case_Classification__c testCoachCategory = new Case_Classification__c(
            Name = 'Test Outreach Category',
            Parent__c = testCoachFuncGroup.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category'),
            Active__c = true,
            Visible__c = true
        );
        insert new List<Case_Classification__c>{ testAdvCategory, testCoachCategory };

        Group testGroup = new Group(Name = groupName, Type = 'Queue');
        insert testGroup;

        List<QueueSobject> testQueues = new List<QueueSobject>{
            new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Success_Pod__c'),
            new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case')
        };
        System.runAs(runAsUser) {
            // Separate transaction to avoid mixed DML
            insert testQueues;
        }

        Success_Pod__c testPod = new Success_Pod__c(
            OwnerId = testGroup.Id,
            RecordTypeId = IDHelper.getRTID('Success_Pod__c', 'Advisor'),
            Primary_Email__c = testGroup.Name + '@test.asu.edu',
            Name = 'Test Pod 1',
            Committee__c = 'tp1'
        );
        insert testPod;

        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(
                new contact(
                    FirstName = 'TestContact' + i,
                    LastName = testPod.Name,
                    Email = 'test.contact.' + i + '@email.test'
                )
            );
        }
        insert testContacts;

        Id advisorOutReachId = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');
        Id coachOutReachId = IDHelper.getRTID('Case', 'ASU_Coach_Outreach');
        List<Case> testCases = new List<Case>();
        // Advisor Case, Group owned
        testCases.add(
            new Case(
                OwnerId = testGroup.Id,
                RecordTypeId = advisorOutReachId,
                Status = 'Outreach Required',
                CC_Functional_Group__c = testAdvFuncGroup.Id,
                CC_Category__c = testAdvCategory.Id,
                Origin__c = 'Outreach',
                Subject = 'Case Bloat 1',
                Description = 'Case Bloat',
                ContactId = testContacts[0].Id
            )
        );
        // Advisor Case, User owned
        testCases.add(
            new Case(
                OwnerId = testUser.Id,
                RecordTypeId = advisorOutReachId,
                Status = 'Outreach Required',
                CC_Functional_Group__c = testAdvFuncGroup.Id,
                CC_Category__c = testAdvCategory.Id,
                Origin__c = 'Outreach',
                Subject = 'Case Bloat 2',
                Description = 'Case Bloat',
                ContactId = testContacts[1].Id,
                Most_Recent_Queue__c = testGroup.Name
            )
        );
        // Coach Case, User owned
        testCases.add(
            new Case(
                OwnerId = testUser.Id,
                RecordTypeId = coachOutReachId,
                Status = 'Outreach Required',
                CC_Functional_Group__c = testCoachFuncGroup.Id,
                CC_Category__c = testCoachCategory.Id,
                Origin__c = 'Outreach',
                Subject = 'Case Bloat 2',
                Description = 'Case Bloat',
                ContactId = testContacts[2].Id
            )
        );

        insert testCases;
    }

    @isTest
    private static void testOnInitDefaultsForCaseEmail() {
        QADefaultHandler qadh = new QADefaultHandler();
        User testUser = [SELECT Recruiter_Email__c FROM User WHERE Alias = :userAlias];
        Case testCase = [
            SELECT Id, OwnerId
            FROM Case
            WHERE RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Coach_Outreach')
        ];

        // Must store as map and then use serialize/deserialize because
        // normally can't set attributes of this object
        Map<String, Object> caseEmailDefaults = new Map<String, Object>{
            'targetSObject' => new EmailMessage(),
            'contextId' => testCase.Id,
            'actionType' => 'Email',
            'actionName' => 'Case.Email',
            'fromAddressList' => new List<String>{ 'salesforce@test.com' }
        };
        QuickAction.SendEmailQuickActionDefaults defaultsSettingEmail = (QuickAction.SendEmailQuickActionDefaults) JSON.deserialize(
            JSON.serialize(caseEmailDefaults),
            QuickAction.SendEmailQuickActionDefaults.class
        );

        System.runAs(testUser) {
            Test.startTest();
            qadh.onInitDefaults(new List<QuickAction.SendEmailQuickActionDefaults>{ defaultsSettingEmail });
            Test.stopTest();
        }

        System.assertEquals(
            testUser.Recruiter_Email__c,
            ((EmailMessage) defaultsSettingEmail.getTargetSObject()).FromAddress
        );
    }

    @isTest
    private static void testOnInitDefaultsForCaseSendEmail() {
        QADefaultHandler qadh = new QADefaultHandler();
        User testUser = [SELECT Recruiter_Email__c FROM User WHERE Alias = :userAlias];
        Case testCase = [
            SELECT Id, OwnerId
            FROM Case
            WHERE RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Coach_Outreach')
        ];

        // Must store as map and then use serialize/deserialize because
        // normally can't set attributes of this object
        Map<String, Object> caseEmailDefaults = new Map<String, Object>{
            'targetSObject' => new EmailMessage(),
            'contextId' => testCase.Id,
            'actionType' => 'SendEmail',
            'actionName' => 'Case.New_Send_Email',
            'fromAddressList' => new List<String>{ 'salesforce@test.com' }
        };
        QuickAction.SendEmailQuickActionDefaults defaultsSettingEmail = (QuickAction.SendEmailQuickActionDefaults) JSON.deserialize(
            JSON.serialize(caseEmailDefaults),
            QuickAction.SendEmailQuickActionDefaults.class
        );

        System.runAs(testUser) {
            Test.startTest();
            qadh.onInitDefaults(new List<QuickAction.SendEmailQuickActionDefaults>{ defaultsSettingEmail });
            Test.stopTest();
        }

        System.assertEquals(
            testUser.Recruiter_Email__c,
            ((EmailMessage) defaultsSettingEmail.getTargetSObject()).FromAddress
        );
    }

    @isTest
    private static void testGetEmailFromAddressGroupAdvisorCase() {
        QADefaultHandler qadh = new QADefaultHandler();
        EmailMessage em = new EmailMessage();
        Case testCase = [
            SELECT Id, OwnerId
            FROM Case
            WHERE RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Advisor_Outreach') AND Owner.Name = :groupName
        ];
        Success_Pod__c testPod = [SELECT Primary_Email__c FROM Success_Pod__c WHERE OwnerId = :testCase.OwnerId];

        Test.startTest();
        qadh.setEmailFromAndToAddress(testCase.Id, em);
        Test.stopTest();

        System.assertEquals(testPod.Primary_Email__c, em.FromAddress);
    }

    @isTest
    private static void testGetEmailFromAddressUserAdvisorCase() {
        QADefaultHandler qadh = new QADefaultHandler();
        EmailMessage em = new EmailMessage();
        Case testCase = [
            SELECT Id, Most_Recent_Queue__c
            FROM Case
            WHERE RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Advisor_Outreach') AND Owner.Alias = :userAlias
        ];
        Success_Pod__c testPod = [
            SELECT Primary_Email__c
            FROM Success_Pod__c
            WHERE Owner_Name__c = :testCase.Most_Recent_Queue__c
        ];

        Test.startTest();
        qadh.setEmailFromAndToAddress(testCase.Id, em);
        Test.stopTest();

        System.assertEquals(testPod.Primary_Email__c, em.FromAddress);
    }

    @isTest
    private static void testGetEmailFromAddressCoachCase() {
        QADefaultHandler qadh = new QADefaultHandler();
        EmailMessage em = new EmailMessage();
        User testUser = [SELECT Recruiter_Email__c FROM User WHERE Alias = :userAlias];
        Case testCase = [
            SELECT Id, Most_Recent_Queue__c
            FROM Case
            WHERE RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Coach_Outreach')
        ];

        System.runAs(testUser) {
            Test.startTest();
            qadh.setEmailFromAndToAddress(testCase.Id, em);
            Test.stopTest();
        }

        System.assertEquals(testUser.Recruiter_Email__c, em.FromAddress);
    }

    @isTest
    private static void testNullCcAddress() {
        QADefaultHandler qadh = new QADefaultHandler();
        EmailMessage em = new EmailMessage();
        User testUser = [SELECT Recruiter_Email__c FROM User WHERE Alias = :userAlias];
        Case testCase = [
            SELECT Id, Most_Recent_Queue__c
            FROM Case
            WHERE RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Coach_Outreach')
        ];

        em.CcAddress = testUser.Recruiter_Email__c;
        System.runAs(testUser) {
            Test.startTest();
            qadh.setEmailFromAndToAddress(testCase.Id, em);
            Test.stopTest();
        }

        System.assertEquals(null, em.CcAddress);
    }

    @isTest
    private static void testIsAdvisorCase() {
        QADefaultHandler qadh = new QADefaultHandler();
        Case advisorCase = new Case(
            RecordTypeId = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach'),
            Subject = 'Advisor Case',
            Description = 'Advisor Case'
        );
        Case notAdvisorCase = new Case(
            RecordTypeId = IDHelper.getRTID('Case', 'ASU_Coach_Outreach'),
            Subject = 'Not Advisor Case',
            Description = 'Not Advisor Case'
        );

        System.assert(qadh.isAdvisorCase(advisorCase));
        System.assert(!qadh.isAdvisorCase(notAdvisorCase));
    }

    @isTest
    private static void testCaseOwnedByGroup() {
        QADefaultHandler qadh = new QADefaultHandler();
        User testUser = [SELECT Id FROM User WHERE Alias = :userAlias];
        Group testGroup = [SELECT Id FROM Group WHERE Name = :groupName];

        Case userCase = new Case(OwnerId = testUser.Id, Subject = 'User Case', Description = 'User Case');
        Case groupCase = new Case(OwnerId = testGroup.Id, Subject = 'Group Case', Description = 'Group Case');

        System.assert(!qadh.caseOwnedByGroup(userCase));
        System.assert(qadh.caseOwnedByGroup(groupCase));
    }

    @isTest
    private static void testNullContextId() {
        QADefaultHandler qadh = new QADefaultHandler();
        qadh.setEmailFromAndToAddress(null, null);
        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        System.assertEquals(1, errorList.size());
    }
}
