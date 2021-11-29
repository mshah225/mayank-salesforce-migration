@isTest
public with sharing class CaseTriggerTest {
    private static final String APIUserAlias = 'testUsrA';
    private static final String TMUserAlias = 'testUsrT';
    private static final String ECUserAlias = 'testUsrE';

    @TestSetup
    static void setup() {
        // All test users
        User APIUser = new User(
            FirstName = 'API',
            LastName = 'Test User',
            CompanyName = 'Test Company',
            MobilePhone = '123-456-7890',
            Username = 'test.API.user@test.test',
            Email = 'test.API.user@test.test',
            Alias = APIUserAlias,
            CommunityNickname = APIUserAlias,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = IDHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        User TMUser = new User(
            FirstName = 'Test TM',
            LastName = 'Test User',
            CompanyName = 'Test Company',
            MobilePhone = '123-456-7890',
            Username = 'test.TM.user@test.test',
            Email = 'test.TM.user@test.test',
            Alias = TMUserAlias,
            CommunityNickname = TMUserAlias,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = IDHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        User ECUser = new User(
            FirstName = 'Test EC',
            LastName = 'Test User',
            CompanyName = 'Test Company',
            MobilePhone = '123-456-7890',
            Username = 'test.EC.user@test.test',
            Email = 'test.EC.user@test.test',
            Alias = ECUserAlias,
            CommunityNickname = ECUserAlias,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = IDHelper.getProfileId('System Administrator'),
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert new List<User>{ APIUser, TMUser, ECUser };

        // Test contact
        Contact testContact = new Contact(
            FirstName = 'TestContact',
            LastName = 'TestContact',
            EMPLID__c = '9999999999'
        );
        insert testContact;
        testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        // Opportunity for the contact
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opp',
            Contact__c = testContact.Id,
            AccountId = testContact.AccountId,
            StageName = 'Prospect',
            CloseDate = System.today() + 365,
            Type = 'First Time Freshman'
        );
        insert testOpp;
    }

    // Created per test since need such a widely varying set of classifications for different test conditions
    private static List<Id> createClassifications(String funcGrpName, String categoryName, String subCategoryName) {
        List<Id> classificationIds = new List<Id>();
        if (funcGrpName != null) {
            Case_Classification__c funcGrp = new Case_Classification__c(
                RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group'),
                Name = funcGrpName,
                Record_Types__c = 'ASU Service',
                Active__c = true,
                Visible__c = true
            );
            insert funcGrp;
            classificationIds.add(funcGrp.Id);

            if (categoryName != null) {
                Case_Classification__c category = new Case_Classification__c(
                    RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category'),
                    Name = categoryName,
                    Parent__c = funcGrp.Id,
                    Active__c = true,
                    Visible__c = true
                );
                insert category;
                classificationIds.add(category.Id);

                if (subCategoryName != null) {
                    Case_Classification__c subCategory = new Case_Classification__c(
                        RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category'),
                        Name = subCategoryName,
                        Parent__c = category.Id,
                        Active__c = true,
                        Visible__c = true
                    );
                    insert subCategory;
                    classificationIds.add(subCategory.Id);
                }
            }
        }
        return classificationIds;
    }

    @isTest
    private static void testAdmissionsCaseOpportunityAssociation() {
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Associate_Case_to_Active_Opportunity__c = true,
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Opportunity Association');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, Opportunity__c FROM Case WHERE ContactId IN :contactIds]);
        for (Case ca : newCaseList) {
            System.assertNotEquals(null, ca.Opportunity__c, 'Case was not associated with Opportunity');
        }
    }

    @isTest
    private static void testAdmissionsCaseTerritoryManagerAssignment() {
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        for (Opportunity o : oppList) {
            o.OwnerId = TMUser.Id;
        }
        update oppList;

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Associate_Case_to_Active_Opportunity__c = true,
                Type_of_Additional_Assignment_Needed__c = 'Territory Manager',
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Territory Manager Assignment');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
        for (Case ca : newCaseList) {
            System.assertEquals(
                TMUser.Id,
                ca.OwnerId,
                'Case owner was not assigned to Opportunity owner (Territory Manager)'
            );
        }
    }

    @isTest
    private static void testAdmissionsCaseEnrollmentCoachAssignment() {
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        for (Opportunity o : oppList) {
            o.Enrollment_Coach__c = TMUser.Id;
        }
        update oppList;

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Associate_Case_to_Active_Opportunity__c = true,
                Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Enrollment Coach Assignment');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
        for (Case ca : newCaseList) {
            System.assertEquals(TMUser.Id, ca.OwnerId, 'Case owner was not assigned to Opportunity Enrollment Coach');
        }
    }

    @isTest
    private static void testAdmissionsCaseWebformCARAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
        QueueSobject testQueue;
        Group testGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert e;

            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testGroup;

            testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
            insert testQueue;
        }

        string queueId = String.valueOf(testGroup.Id).substring(0, 15);
        string templateId = String.valueOf(e.Id).substring(0, 15);

        List<Id> createClassificationIds = createClassifications(
            'Admission Services',
            'Test Category',
            'Test Subcategory'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            customer_notice_email_from_name__c = 'Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            customer_notice_email_from_name__c = 'Default Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 999
        );
        insert carDefault;

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = IDHelper.getRecordTypeId('Campaign', 'Other_Source'),
            Case_Assignment_Rule__c = car.Id,
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                CC_Functional_Group__c = fgId,
                CC_Category__c = catId,
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform CAR Assignment');
        System.runAs(APIUser) {
            insert caseList;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>(
            [SELECT Id, CC_Category__c, OwnerId FROM Case WHERE ContactId IN :contactIds]
        );
        for (Case ca : newCaseList) {
            System.assertEquals(TMUser.Id, ca.OwnerId, 'Case owner was not assigned to CAR Queue/User');
            System.assertEquals(catId, ca.CC_Category__c, 'Case Category was not assigned to CAR Category');
        }
    }

    @isTest
    private static void testAdmissionsCaseWebformECAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        User ECUser = [SELECT Id FROM User WHERE Alias = :ECUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
        QueueSobject testQueue;
        Group testGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert e;

            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testGroup;

            testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
            insert testQueue;
        }

        string queueId = String.valueOf(testGroup.Id).substring(0, 15);
        string templateId = String.valueOf(e.Id).substring(0, 15);

        List<Id> createClassificationIds = createClassifications(
            'Admission Services - Undergraduate',
            'Test Category',
            'Test Subcategory'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            customer_notice_email_from_name__c = 'Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            customer_notice_email_from_name__c = 'Default Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 999
        );
        insert carDefault;

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = IDHelper.getRecordTypeId('Campaign', 'Other_Source'),
            Case_Assignment_Rule__c = car.Id,
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        for (Opportunity o : oppList) {
            o.Enrollment_Coach__c = ECUser.Id;
            o.OwnerId = TMUser.Id;
        }
        update oppList;

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform EC Assignment');
        System.runAs(APIUser) {
            insert caseList;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>(
            [SELECT Id, CC_Category__c, OwnerId FROM Case WHERE ContactId IN :contactIds]
        );
        for (Case ca : newCaseList) {
            System.assertEquals(ECUser.Id, ca.OwnerId, 'Case owner was not assigned to Enrollment Coach');
        }
    }

    @isTest
    private static void testAdmissionsCaseWebformCARFunctionalGroup() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
        QueueSobject testQueue;
        Group testGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert e;

            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testGroup;

            testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
            insert testQueue;
        }

        string queueId = String.valueOf(testGroup.Id).substring(0, 15);
        string templateId = String.valueOf(e.Id).substring(0, 15);

        List<Id> createClassificationIds = createClassifications(
            'Admission Services',
            'Recruitment - Cat',
            'Recruitment - Sub Cat'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            customer_notice_email_from_name__c = 'Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            //origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            customer_notice_email_from_name__c = 'Default Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 999
        );
        insert carDefault;

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = IDHelper.getRecordTypeId('Campaign', 'Other_Source'),
            Case_Assignment_Rule__c = car.Id,
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                CC_Functional_Group__c = fgId,
                CC_Category__c = catId,
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        System.runAs(APIUser) {
            insert caseList;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>(
            [SELECT Id, CC_functional_group__c, OwnerId FROM Case WHERE ContactId IN :contactIds]
        );
        for (Case ca : newCaseList) {
            System.assertEquals(TMUser.Id, ca.OwnerId, 'Case owner was not assigned to CAR Queue/User');
            System.assertEquals(
                fgId,
                ca.CC_functional_group__c,
                'Case Functional Group was not assigned to CAR Functional Group'
            );
        }
    }

    @isTest
    private static void testAdmissionsCaseWebformDefaultCARAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
        QueueSobject testQueue;
        Group testGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert e;

            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testGroup;

            testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
            insert testQueue;
        }

        string queueId = String.valueOf(testGroup.Id).substring(0, 15);
        string templateId = String.valueOf(e.Id).substring(0, 15);

        List<Id> createClassificationIds = createClassifications(
            'Admission Services - Undergraduate',
            'Test Category',
            'Test Subcategory'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            customer_notice_email_from_name__c = 'Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            customer_notice_email_from_name__c = 'Default Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 999
        );
        insert carDefault;

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = IDHelper.getRecordTypeId('Campaign', 'Other_Source'),
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        for (Opportunity o : oppList) {
            o.CloseDate = Date.today();
            o.OwnerId = TMUser.Id;
        }
        update oppList;

        TMUser.IsActive = false;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            update TMUser;
        }

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Default CAR Assignment');
        System.runAs(APIUser) {
            insert caseList;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
        for (Case ca : newCaseList) {
            System.assertEquals(APIUser.Id, ca.OwnerId, 'Case owner was not assigned to Default CAR Queue/User');
        }
    }

    @isTest
    private static void testAdmissionsCaseWebformDefaultCAR_ECAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        User ECUser = [SELECT Id FROM User WHERE Alias = :ECUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
        QueueSobject testQueue;
        Group testGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            e = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert e;

            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testGroup;

            testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
            insert testQueue;
        }

        string queueId = String.valueOf(testGroup.Id).substring(0, 15);
        string templateId = String.valueOf(e.Id).substring(0, 15);

        List<Id> createClassificationIds = createClassifications(
            'Admission Services - Undergraduate',
            'Test Category',
            'Test Subcategory'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            customer_notice_email_from_name__c = 'Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            customer_notice_email_from_name__c = 'Default Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
            priority__c = 999
        );
        insert carDefault;

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = IDHelper.getRecordTypeId('Campaign', 'Other_Source'),
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact con : contactList) {
            contactIds.add(con.Id);
        }

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        for (Opportunity o : oppList) {
            o.CloseDate = Date.today();
            o.OwnerId = TMUser.Id;
            o.Enrollment_Coach__c = ECUser.Id;
        }
        update oppList;

        TMUser.IsActive = false;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            update TMUser;
        }

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                Subject = 'Test Subject',
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Default CAR EC Assignment');
        System.runAs(APIUser) {
            insert caseList;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, OwnerId FROM Case WHERE ContactId IN :contactIds]);
        for (Case ca : newCaseList) {
            System.assertEquals(
                ECUser.Id,
                ca.OwnerId,
                'Case owner was not assigned to Enrollment Coach User as specified by Default CAR'
            );
        }
    }

    @isTest
    private static void financialAidChangeStateWithSufficientLinks() {
        Id financialAidQueue = [SELECT Id FROM Group WHERE Name = 'Financial Aid (Case)' AND Type = 'Queue' LIMIT 1].Id;
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];

        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:' +
                testContact.EMPLID__c +
                '%Queue:' +
                financialAidQueue +
                '%First:' +
                testContact.FirstName +
                '%Last:' +
                testContact.LastName,
            Description = 'Test Description',
            Status = 'Processing'
        );
        insert caseUnderTest;
        caseUnderTest.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        caseUnderTest.Number_of_Files__c = '3';

        Test.startTest();
        update caseUnderTest;
        Test.stopTest();

        caseUnderTest = [SELECT Status, Visible_by_Contact__c FROM Case WHERE Id = :caseUnderTest.Id LIMIT 1];
        System.assertEquals(CaseWebformCloser.CASE_CLOSE_WEBFORM_STATUS, caseUnderTest.Status);
        System.assertEquals(false, caseUnderTest.Visible_by_Contact__c);
    }

    @isTest
    private static void createWebformsCase() {
        Id registrarQueue = [
            SELECT Id
            FROM Group
            WHERE Name = 'University Registrar Services (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];
        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:' +
                testContact.EMPLID__c +
                '%Queue:' +
                registrarQueue +
                '%First:' +
                testContact.FirstName +
                '%Last:' +
                testContact.LastName,
            Description = 'Test Description',
            Status = 'Processing'
        );

        Test.startTest();
        insert caseUnderTest;
        Test.stopTest();

        caseUnderTest = [
            SELECT ContactId, Status, Visible_by_Contact__c
            FROM Case
            WHERE Id = :caseUnderTest.Id
            LIMIT 1
        ];
        System.assertEquals(testContact.Id, caseUnderTest.ContactId);
    }

    @isTest
    private static void createWebformsCaseCreateContact() {
        Id registrarQueue = [
            SELECT Id
            FROM Group
            WHERE Name = 'University Registrar Services (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];
        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:1234567890%Queue:' + registrarQueue + '%First:Test%Last:Contact',
            Description = 'Test Description',
            Status = 'Processing'
        );

        Test.startTest();
        insert caseUnderTest;
        Test.stopTest();

        caseUnderTest = [
            SELECT ContactId, Status, Visible_by_Contact__c
            FROM Case
            WHERE Id = :caseUnderTest.Id
            LIMIT 1
        ];
        testContact = [SELECT FirstName, LastName FROM Contact WHERE Id = :caseUnderTest.ContactId LIMIT 1];
        System.assertNotEquals(null, caseUnderTest.ContactId);
        System.assertEquals('Test', testContact.FirstName);
        System.assertEquals('Contact', testContact.LastName);
    }

    @isTest
    private static void createWebformsCaseNoContact() {
        Id registrarQueue = [
            SELECT Id
            FROM Group
            WHERE Name = 'University Registrar Services (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];

        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:%Queue:' + registrarQueue + '%First:%Last:',
            Description = 'Test Description',
            Status = 'Processing'
        );

        Test.startTest();
        insert caseUnderTest;
        Test.stopTest();

        caseUnderTest = [
            SELECT ContactId, Status, Visible_by_Contact__c
            FROM Case
            WHERE Id = :caseUnderTest.Id
            LIMIT 1
        ];

        System.assertEquals(null, caseUnderTest.ContactId);
    }

    @isTest
    private static void registrarChangeStateWithSufficientLinks() {
        Id registrarQueue = [
            SELECT Id
            FROM Group
            WHERE Name = 'University Registrar Services (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];
        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:' +
                testContact.EMPLID__c +
                '%Queue:' +
                registrarQueue +
                '%First:' +
                testContact.FirstName +
                '%Last:' +
                testContact.LastName,
            Description = 'Test Description',
            Status = 'Processing'
        );
        insert caseUnderTest;
        caseUnderTest.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        caseUnderTest.Number_of_Files__c = '3';

        Test.startTest();
        update caseUnderTest;
        Test.stopTest();

        caseUnderTest = [SELECT Status, Visible_by_Contact__c FROM Case WHERE Id = :caseUnderTest.Id LIMIT 1];

        System.assertEquals('New', caseUnderTest.Status);
        System.assertEquals(true, caseUnderTest.Visible_by_Contact__c);
    }

    @isTest
    private static void noChangeStateWithoutSufficientLinks() {
        Id registrarQueue = [
            SELECT Id
            FROM Group
            WHERE Name = 'University Registrar Services (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];
        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:' +
                testContact.EMPLID__c +
                '%Queue:' +
                registrarQueue +
                '%First:' +
                testContact.FirstName +
                '%Last:' +
                testContact.LastName,
            Description = 'Test Description',
            Status = 'Processing'
        );
        insert caseUnderTest;
        caseUnderTest.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        caseUnderTest.Number_of_Files__c = '5';

        Test.startTest();
        update caseUnderTest;
        Test.stopTest();

        caseUnderTest = [SELECT Status FROM Case WHERE Id = :caseUnderTest.Id LIMIT 1];
        System.assertEquals('Processing', caseUnderTest.Status);
    }

    @isTest
    private static void rejectWebformsCaseReopen() {
        Id financialAidQueue = [SELECT Id FROM Group WHERE Name = 'Financial Aid (Case)' AND Type = 'Queue' LIMIT 1].Id;
        User apiDrupalUser = [SELECT Id FROM User WHERE Name = 'API ASU DRUPAL'];

        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];
        Case caseUnderTest = new Case(
            Subject = 'Test Subject%ASURITE:' +
                testContact.EMPLID__c +
                '%Queue:' +
                financialAidQueue +
                '%First:' +
                testContact.FirstName +
                '%Last:' +
                testContact.LastName,
            Description = 'Test Description',
            Status = 'Processing'
        );
        insert caseUnderTest;
        caseUnderTest.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        caseUnderTest.Number_of_Files__c = '3';
        update caseUnderTest;

        caseUnderTest.Subject =
            'Test Subject%ASURITE:' +
            testContact.EMPLID__c +
            '%Queue:' +
            financialAidQueue +
            '%First:' +
            testContact.FirstName +
            '%Last:' +
            testContact.LastName;
        caseUnderTest.Status = 'Processing';
        caseUnderTest.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        Test.startTest();
        System.runAs(apiDrupalUser) {
            update caseUnderTest;
        }
        Test.stopTest();

        caseUnderTest = [SELECT Status, Subject FROM Case WHERE Id = :caseUnderTest.Id LIMIT 1];

        System.assertEquals(CaseWebformCloser.CASE_CLOSE_WEBFORM_STATUS, caseUnderTest.Status);
        System.assertEquals('Test Subject', caseUnderTest.Subject);
    }

    @isTest
    private static void testAssignRTAdOutreach() {
        List<Id> createClassificationIds = createClassifications('ASU Advisor Outreach', null, null);
        Id fgId = createClassificationIds[0];

        List<Contact> contactList = [SELECT Id FROM Contact];

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Subject = 'Test Subject',
                CC_functional_group__c = fgId,
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, CC_functional_group__c, RecordTypeId FROM Case]);
        for (Case ca : newCaseList) {
            System.assertEquals(ca.RecordTypeId, IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'));
        }
    }

    @isTest
    private static void testAssignRTCoachOutreach() {
        List<Id> createClassificationIds = createClassifications('ASU Coach Outreach', null, null);
        Id fgId = createClassificationIds[0];

        List<Contact> contactList = [SELECT Id FROM Contact];

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Subject = 'Test Subject',
                CC_functional_group__c = fgId,
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, CC_functional_group__c, RecordTypeId FROM Case]);
        for (Case ca : newCaseList) {
            System.assertEquals(ca.RecordTypeId, IDHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach'));
        }
    }

    @isTest
    private static void testAssignRTAdService() {
        List<Id> createClassificationIds = createClassifications('Admission Services', null, null);
        Id fgId = createClassificationIds[0];

        List<Contact> contactList = [SELECT Id FROM Contact];

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Subject = 'Test Subject',
                CC_functional_group__c = fgId,
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, CC_functional_group__c, RecordTypeId FROM Case]);
        for (Case ca : newCaseList) {
            System.assertEquals(ca.RecordTypeId, IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'));
        }
    }

    @isTest
    private static void testAssignRTService() {
        List<Id> createClassificationIds = createClassifications(
            'ASU Salesforce Support',
            'Test Category',
            'Test Subcategory'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        List<Contact> contactList = [SELECT Id FROM Contact];

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
                Subject = 'Test Subject',
                CC_functional_group__c = fgId,
                CC_Category__c = catId,
                CC_Sub_Category__c = subcatId,
                Description = 'Test Desc',
                Status = 'In Progress'
            );
            caseList.add(ca);
        }

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert caseList;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        List<Case> newCaseList = new List<Case>([SELECT Id, CC_functional_group__c, RecordTypeId FROM Case]);
        for (Case ca : newCaseList) {
            System.assertEquals(ca.RecordTypeId, IDHelper.getRecordTypeId('Case', 'ASU_Service'));
        }
    }

    @isTest
    private static void newClosedForwardCaseSendsEmailOnSave() {
        Case testCase = createTestCaseToForward();
        testCase.Status = 'Closed: Forwarded';
        testCase.Forward_To_Email__c = 'test@example.com';

        Test.startTest();
        insert testCase;
        Test.stopTest();

        System.assert(CaseUtilities.emailForwarded);
    }

    private static Case createTestCaseToForward() {
        Contact testContact = [SELECT Id, FirstName, LastName, EMPLID__c FROM Contact LIMIT 1];
        CaseFactory caseMaker = new CaseFactory(CaseFactory.DEFAULT_CASE);
        Case testCase = caseMaker.createOne();
        testCase.Status = 'New';
        return testCase;
    }

    @isTest
    private static void updateToClosedForwardCaseSendsEmailOnSave() {
        Case testCase = createTestCaseToForward();
        insert testCase;

        testCase.Status = 'Closed: Forwarded';
        testCase.Forward_To_Email__c = 'test@example.com';

        Test.startTest();
        update testCase;
        Test.stopTest();

        System.assert(CaseUtilities.emailForwarded);
    }
}
