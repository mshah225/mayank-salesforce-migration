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
            EMPLID__c = '9999999999',
            Email = 'test.contact@test.test'
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
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Associate_Case_to_Active_Opportunity__c = true,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Opportunity Association');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, Opportunity__c FROM Case WHERE Id = :newCase.Id];
        System.assertNotEquals(null, newCase.Opportunity__c, 'Case was not associated with Opportunity');
    }

    @isTest
    private static void testAdmissionsCaseTerritoryManagerAssignment() {
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.OwnerId = TMUser.Id;
        update testOpp;

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Associate_Case_to_Active_Opportunity__c = true,
            Type_of_Additional_Assignment_Needed__c = 'Territory Manager',
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Territory Manager Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(
            TMUser.Id,
            newCase.OwnerId,
            'Case owner was not assigned to Opportunity owner (Territory Manager)'
        );
    }

    @isTest
    private static void testAdmissionsCaseEnrollmentCoachAssignment() {
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.Enrollment_Coach__c = TMUser.Id;
        update testOpp;

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Associate_Case_to_Active_Opportunity__c = true,
            Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Enrollment Coach Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(TMUser.Id, newCase.OwnerId, 'Case owner was not assigned to Opportunity Enrollment Coach');
    }

    @isTest
    private static void testAdmissionsCaseWebformCARAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
        }

        String queueId = String.valueOf(testGroup.Id).substring(0, 15);
        String templateId = String.valueOf(e.Id).substring(0, 15);

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
            CC_Functional_Group__c = fgId,
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
            CC_Functional_Group__c = fgId,
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            CC_Functional_Group__c = fgId,
            CC_Category__c = catId,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform CAR Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, CC_Category__c, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(TMUser.Id, newCase.OwnerId, 'Case owner was not assigned to CAR Queue/User');
        System.assertEquals(catId, newCase.CC_Category__c, 'Case Category was not assigned to CAR Category');
    }

    @isTest
    private static void testAdmissionsCaseWebformECAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        User ECUser = [SELECT Id FROM User WHERE Alias = :ECUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
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
            CC_Functional_Group__c = fgId,
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
            CC_Functional_Group__c = fgId,
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.Enrollment_Coach__c = ECUser.Id;
        testOpp.OwnerId = TMUser.Id;
        update testOpp;

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform EC Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, CC_Category__c, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(ECUser.Id, newCase.OwnerId, 'Case owner was not assigned to Enrollment Coach');
    }

    @isTest
    private static void testAdmissionsCaseWebformTMAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        User ECUser = [SELECT Id FROM User WHERE Alias = :ECUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
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
            CC_Functional_Group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            Type_of_Additional_Assignment_Needed__c = 'Territory Manager',
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            customer_notice_email_from_name__c = 'Default Test Service',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_Functional_Group__c = fgId,
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.Enrollment_Coach__c = ECUser.Id;
        testOpp.OwnerId = TMUser.Id;
        update testOpp;

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform TM Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, CC_Category__c, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(TMUser.Id, newCase.OwnerId, 'Case owner was not assigned to Territory Manager');
    }

    @isTest
    private static void testAdmissionsCaseWebformCARFunctionalGroup() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
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
            CC_Functional_Group__c = fgId,
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
            CC_Functional_Group__c = fgId,
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            CC_Functional_Group__c = fgId,
            CC_Category__c = catId,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, CC_Functional_Group__c, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(TMUser.Id, newCase.OwnerId, 'Case owner was not assigned to CAR Queue/User');
        System.assertEquals(
            fgId,
            newCase.CC_Functional_Group__c,
            'Case Functional Group was not assigned to CAR Functional Group'
        );
    }

    @isTest
    private static void testAdmissionsCaseWebformDefaultCARAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
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
            CC_Functional_Group__c = fgId,
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
            CC_Functional_Group__c = fgId,
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.CloseDate = Date.today();
        testOpp.OwnerId = TMUser.Id;
        update testOpp;

        TMUser.IsActive = false;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            update TMUser;
        }

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Default CAR Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(APIUser.Id, newCase.OwnerId, 'Case owner was not assigned to Default CAR Queue/User');
    }

    @isTest
    private static void testAdmissionsCaseWebformDefaultCAR_ECAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        User ECUser = [SELECT Id FROM User WHERE Alias = :ECUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
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
            CC_Functional_Group__c = fgId,
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
            CC_Functional_Group__c = fgId,
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.CloseDate = Date.today();
        testOpp.OwnerId = TMUser.Id;
        testOpp.Enrollment_Coach__c = ECUser.Id;
        update testOpp;

        TMUser.IsActive = false;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            update TMUser;
        }

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Default CAR EC Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(
            ECUser.Id,
            newCase.OwnerId,
            'Case owner was not assigned to Enrollment Coach User as specified by Default CAR'
        );
    }

    @isTest
    private static void testAdmissionsCaseWebformTAR_TMAssignment() {
        User APIUser = [SELECT Id FROM User WHERE Alias = :APIUserAlias LIMIT 1];
        User TMUser = [SELECT Id FROM User WHERE Alias = :TMUserAlias LIMIT 1];
        User ECUser = [SELECT Id FROM User WHERE Alias = :ECUserAlias LIMIT 1];

        // Set up Case Assignment Rules
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate e;
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

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead');
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
            CC_Functional_Group__c = fgId,
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
            CC_Functional_Group__c = fgId,
            CC_category__c = catId,
            CC_sub_category__c = subcatId,
            Type_of_Additional_Assignment_Needed__c = 'Territory Manager',
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

        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Territory_Assignment_Rule__c tar = new Territory_Assignment_Rule__c(
            Rule_Type__c = 'Default User',
            Opportunity_Type__c = 'First Time Freshman',
            User__c = TMUser.Id
        );
        insert tar;

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.CloseDate = Date.today();
        testOpp.OwnerId = TMUser.Id;
        testOpp.Enrollment_Coach__c = ECUser.Id;
        update testOpp;

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Case_Source__c = camp.Id,
            Associate_Case_to_Active_Opportunity__c = false,
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Default CAR EC Assignment');
        System.runAs(APIUser) {
            insert newCase;
        }
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        //List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        newCase = [SELECT Id, OwnerId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(
            TMUser.Id,
            newCase.OwnerId,
            'Case owner was not assigned to Enrollment Coach User as specified by Default CAR'
        );
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
    private static void testMostRecentFunctionalGroupInsert() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Map<String, String> functionalGroups = ObjectService.getPicklistChoicesMap('Case', 'Functional_Group__c');
        String caseFuncGrp = null;
        for (String key : functionalGroups.keySet()) {
            String value = functionalGroups.get(key);
            if (value == 'External Unit') {
                continue;
            }
            if (caseFuncGrp == null) {
                caseFuncGrp = value;
                break;
            }
        }
        System.assertNotEquals(null, caseFuncGrp); // Need a functional group

        Id funcGrpId1 = createClassifications(caseFuncGrp, null, null)[0];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = funcGrpId1,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, Most_Recent_Functional_Group__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(caseFuncGrp, newCase.Most_Recent_Functional_Group__c);
    }

    @isTest
    private static void testMostRecentFunctionalGroupUpdate() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Map<String, String> functionalGroups = ObjectService.getPicklistChoicesMap('Case', 'Functional_Group__c');
        String caseFuncGrp1 = null;
        String caseFuncGrp2 = null;
        for (String key : functionalGroups.keySet()) {
            String value = functionalGroups.get(key);
            if (value == 'External Unit') {
                continue;
            }
            if (caseFuncGrp1 == null) {
                caseFuncGrp1 = value;
            } else if (caseFuncGrp2 == null) {
                caseFuncGrp2 = value;
                break;
            }
        }
        System.assertNotEquals(null, caseFuncGrp1); // Need a functional group
        System.assertNotEquals(null, caseFuncGrp2); // Need at least 2 functional groups

        Id funcGrpId1 = createClassifications(caseFuncGrp1, null, null)[0];
        Id funcGrpId2 = createClassifications(caseFuncGrp2, null, null)[0];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = funcGrpId1,
            Description = 'Test Desc',
            Status = 'In Progress'
        );
        insert newCase;

        newCase.CC_Functional_Group__c = funcGrpId2;

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        update newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, Most_Recent_Functional_Group__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(caseFuncGrp2, newCase.Most_Recent_Functional_Group__c);
    }

    @isTest
    private static void testCCFunctionalGroupAndFunctionalGroupConsistent() {
        // This test gets code coverage for the stuff using the CaseClassifier to find missing classifications
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Map<String, String> functionalGroups = ObjectService.getPicklistChoicesMap('Case', 'Functional_Group__c');
        String caseFuncGrp = null;
        for (String key : functionalGroups.keySet()) {
            String value = functionalGroups.get(key);
            if (value == 'External Unit') {
                continue;
            }
            if (caseFuncGrp == null) {
                caseFuncGrp = value;
                break;
            }
        }
        System.assertNotEquals(null, caseFuncGrp); // Need a functional group

        Map<String, String> categories = ObjectService.getPicklistChoicesMap('Case', 'Category__c');
        String caseCategory = null;
        for (String key : categories.keySet()) {
            String value = categories.get(key);
            if (caseCategory == null) {
                caseCategory = value;
                break;
            }
        }
        System.assertNotEquals(null, caseCategory); // Need a functional group

        Map<String, String> subcategories = ObjectService.getPicklistChoicesMap('Case', 'Sub_Category__c');
        String caseSubCategory = null;
        for (String key : subcategories.keySet()) {
            String value = subcategories.get(key);
            if (caseSubCategory == null) {
                caseSubCategory = value;
                break;
            }
        }
        System.assertNotEquals(null, caseSubCategory); // Need a functional group

        List<Id> createClassificationIds = createClassifications(caseFuncGrp, caseCategory, caseSubCategory);

        Id funcGrpId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subcatId = createClassificationIds[2];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = funcGrpId,
            CC_Category__c = catId,
            CC_Sub_Category__c = subcatId,
            Description = 'Test Desc',
            Status = 'In Progress'
        );
        insert newCase;

        newCase.CC_Functional_Group__c = null;
        newCase.CC_Category__c = null;
        newCase.CC_Sub_Category__c = null;

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        update newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [
            SELECT Id, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c
            FROM Case
            WHERE Id = :newCase.Id
        ];

        System.assertEquals(funcGrpId, newCase.CC_Functional_Group__c);
        System.assertEquals(catId, newCase.CC_Category__c);
        System.assertEquals(subcatId, newCase.CC_Sub_Category__c);
    }

    @isTest
    private static void testMostRecentQueueInsert() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Group testGroup;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testGroup;

            insert new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
        }

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            OwnerId = testGroup.Id,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, Most_Recent_Queue__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(testGroup.Name, newCase.Most_Recent_Queue__c);
    }

    @isTest
    private static void testMostRecentQueueUpdate() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Group testGroup, testGroup2;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
            testGroup2 = new Group(Name = 'TestQueue2', Type = 'Queue');
            insert new List<Group>{ testGroup, testGroup2 };

            insert new List<QueueSObject>{
                new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case'),
                new QueueSObject(QueueId = testGroup2.Id, SobjectType = 'Case')
            };
        }

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            OwnerId = testGroup.Id,
            Description = 'Test Desc',
            Status = 'In Progress'
        );
        insert newCase;

        newCase.OwnerId = testGroup2.Id;

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        update newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, Most_Recent_Queue__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(testGroup2.Name, newCase.Most_Recent_Queue__c);
    }

    @isTest
    private static void testAssignRecordTypeAdvisorOutreach() {
        Id fgId = createClassifications('ASU Advisor Outreach', null, null)[0];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, RecordTypeId FROM Case];
        System.assertEquals(IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'), newCase.RecordTypeId);
    }

    @isTest
    private static void testAssignRecordTypeCoachOutreach() {
        Id fgId = createClassifications('ASU Coach Outreach', null, null)[0];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, RecordTypeId FROM Case];
        System.assertEquals(IDHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach'), newCase.RecordTypeId);
    }

    @isTest
    private static void testAssignRecordTypeAdmissionService() {
        List<Id> createClassificationIds = createClassifications('Admission Services', null, null);
        Id fgId1 = createClassificationIds[0];

        createClassificationIds = createClassifications('Not Admission Services', 'Recruitment', null);
        Id fgId2 = createClassificationIds[0];
        Id catId2 = createClassificationIds[1];

        createClassificationIds = createClassifications('Not Admission Services v2', 'Not Recruit', 'Recruitment');
        Id fgId3 = createClassificationIds[0];
        Id catId3 = createClassificationIds[1];
        Id subcatId3 = createClassificationIds[2];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        // Test when functional group is Admission Services
        Case admissionServicesFuncGrpCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Service'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId1,
            Description = 'Test Desc',
            Status = 'In Progress'
        );
        Case recruitmentCategoryCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Service'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId2,
            CC_Category__c = catId2,
            Description = 'Test Desc',
            Status = 'In Progress'
        );
        Case recruitmentSubCategoryCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Service'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId3,
            CC_Category__c = catId3,
            CC_Sub_Category__c = subcatId3,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert new List<Case>{ admissionServicesFuncGrpCase, recruitmentCategoryCase, recruitmentSubCategoryCase };
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        admissionServicesFuncGrpCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :admissionServicesFuncGrpCase.Id];
        recruitmentCategoryCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :recruitmentCategoryCase.Id];
        recruitmentSubCategoryCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :recruitmentSubCategoryCase.Id];

        System.assertEquals(
            IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            admissionServicesFuncGrpCase.RecordTypeId
        );
        System.assertEquals(
            IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            recruitmentCategoryCase.RecordTypeId
        );
        System.assertEquals(
            IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            recruitmentSubCategoryCase.RecordTypeId
        );
    }

    @isTest
    private static void testAssignRecordTypeService() {
        List<Id> createClassificationIds = createClassifications(
            'ASU Salesforce Support',
            'Test Category',
            'Test Subcategory'
        );
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];
        Id subCatId = createClassificationIds[2];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Admission_Services'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId,
            CC_Category__c = catId,
            CC_Sub_Category__c = subcatId,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :newCase.Id];

        System.assertEquals(IDHelper.getRecordTypeId('Case', 'ASU_Service'), newCase.RecordTypeId);
    }

    @isTest
    private static void testAssignRecordTypeStudentOutreach() {
        List<Id> createClassificationIds = createClassifications('Financial Aid', 'Outreach', null);
        Id fgId = createClassificationIds[0];
        Id catId = createClassificationIds[1];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Case newCase = new Case(
            ContactId = con.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Retention_Outreach'),
            Subject = 'Test Subject',
            CC_Functional_Group__c = fgId,
            CC_Category__c = catId,
            Description = 'Test Desc',
            Status = 'In Progress'
        );

        Test.startTest();
        LogSuite.activateTestFlowSuite('Test Admissions Case Webform Functional Group Assignment');
        insert newCase;
        LogSuite.deactivateTestFlowSuite();
        Test.stopTest();

        newCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :newCase.Id];

        System.assertEquals(IDHelper.getRecordTypeId('Case', 'ASU_Student_Outreach'), newCase.RecordTypeId);
    }

    @isTest
    private static void testClosedForwardCaseSendsEmailNew() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate emt;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            emt = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert emt;
        }

        List<Case_Forwarding_Settings__c> cfsList = new List<Case_Forwarding_Settings__c>();
        cfsList.add(new Case_Forwarding_Settings__c(Name = 'Email Template ID', Value__c = String.valueOf(emt.Id)));
        cfsList.add(new Case_Forwarding_Settings__c(Name = 'Dummy Contact ID', Value__c = String.valueOf(con.Id)));
        insert cfsList;

        Case newCase = new Case(
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'Closed: Forwarded',
            Forward_To_Email__c = 'test@example.com'
        );

        Integer numberOfEmailsBefore = [SELECT Id FROM EmailMessage].size();

        Test.startTest();
        insert newCase;
        Test.stopTest();

        Integer numberOfEmailsAfter = [SELECT Id FROM EmailMessage].size();

        System.assert(CaseUtilities.emailForwarded);
        System.assert(numberOfEmailsAfter > numberOfEmailsBefore);
    }

    @isTest
    private static void testClosedForwardCaseSendsEmailUpdate() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];

        EmailTemplate emt;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            emt = new EmailTemplate(
                developerName = 'test',
                TemplateType = 'Text',
                Name = 'test',
                FolderId = f.Id,
                isActive = true
            );
            insert emt;
        }

        List<Case_Forwarding_Settings__c> cfsList = new List<Case_Forwarding_Settings__c>();
        cfsList.add(new Case_Forwarding_Settings__c(Name = 'Email Template ID', Value__c = String.valueOf(emt.Id)));
        cfsList.add(new Case_Forwarding_Settings__c(Name = 'Dummy Contact ID', Value__c = String.valueOf(con.Id)));
        insert cfsList;

        Case newCase = new Case(
            Subject = 'Test Subject',
            Description = 'Test Desc',
            Status = 'New',
            Forward_To_Email__c = 'test@example.com'
        );
        insert newCase;

        newCase.Status = 'Closed: Forwarded';

        Integer numberOfEmailsBefore = [SELECT Id FROM EmailMessage].size();

        Test.startTest();
        update newCase;
        Test.stopTest();

        Integer numberOfEmailsAfter = [SELECT Id FROM EmailMessage].size();

        System.assert(CaseUtilities.emailForwarded);
        System.assert(numberOfEmailsAfter > numberOfEmailsBefore);
    }

    @isTest
    private static void padTests() {
        Case c = new Case(Subject = 'Test Case');

        Test.startTest();
        insert c;
        delete c;
        undelete c;
        Test.stopTest();

        c = [SELECT Id FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, c.Id);
    }
}
