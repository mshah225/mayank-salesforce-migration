@isTest
public with sharing class CaseTriggerTest {
    private static Id registrarQueue;
    private static Id financialAidQueue;

    private static void setfinancialAidQueue() {
        financialAidQueue = [SELECT Id FROM Group WHERE Name = 'Financial Aid (Case)' AND Type = 'Queue' LIMIT 1].Id;
    }

    private static void setRegistrarQueue() {
        registrarQueue = [
            SELECT Id
            FROM Group
            WHERE Name = 'University Registrar Services (Case)' AND Type = 'Queue'
            LIMIT 1
        ]
        .Id;
    }

    private static List<Contact> createContacts(Integer qty) {
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < qty; i++) {
            Contact con = new Contact();
            con.FirstName = 'FName' + i;
            con.LastName = 'LName' + i;
            contactList.add(con);
        }

        return contactList;
    }

    private static List<Opportunity> createOpportunities(List<Contact> contactList) {
        List<Opportunity> oppList = new List<Opportunity>();

        for (Contact c : contactList) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.Contact__c = c.Id;
            opp.AccountId = c.AccountId;
            opp.StageName = 'Prospect';
            opp.CloseDate = date.today() + 365;
            opp.Type = 'First Time Freshman';
            oppList.add(opp);
        }

        return oppList;
    }

    private static Case createCase(Id queue_id, Contact con) {
        Case newCase = new Case(
            Subject = 'Test Subject%ASURITE:' +
                con.EMPLID__c +
                '%Queue:' +
                queue_id +
                '%First:' +
                con.FirstName +
                '%Last:' +
                con.LastName,
            Description = 'Test Description',
            Status = 'Processing'
        );

        insert newCase;
        return newCase;
    }

    private static Contact createContact() {
        Contact newContact = new Contact(LastName = 'Contact', EMPLID__c = '9999999999');
        insert newContact;
        return newContact;
    }

    private static testMethod void testAdmissionsCaseOpportunityAssociation() {
        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
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
            system.assert(ca.Opportunity__c != null, 'Case was not associated with Opportunity');
        }
    }

    private static testMethod void testAdmissionsCaseTerritoryManagerAssignment() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User TMUser = new User();
        TMUser.FirstName = 'Test';
        TMUser.LastName = 'Name';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive@test.test';
        TMUser.Email = 'testUser-Inactive@test.test';
        TMUser.Alias = 'testXX';
        TMUser.CommunityNickname = 'test1';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            o.OwnerId = TMUser.Id;
        }
        insert oppList;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
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
            system.assert(
                ca.OwnerId == TMUser.Id,
                'Case owner was not assigned to Opportunity owner (Territory Manager)'
            );
        }
    }

    private static testMethod void testAdmissionsCaseEnrollmentCoachAssignment() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User TMUser = new User();
        TMUser.FirstName = 'Test';
        TMUser.LastName = 'Name';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive@test.test';
        TMUser.Email = 'testUser-Inactive@test.test';
        TMUser.Alias = 'testXX';
        TMUser.CommunityNickname = 'test1';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            o.Enrollment_Coach__c = TMUser.Id;
        }
        insert oppList;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
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
            system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to Opportunity Enrollment Coach');
        }
    }

    private static testMethod void testAdmissionsCaseWebformCARAssignment() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User APIUser = new User();
        APIUser.FirstName = 'API';
        APIUser.LastName = 'LName';
        APIUser.CompanyName = 'Test Company';
        APIUser.MobilePhone = '123-456-7890';
        APIUser.Username = 'testUser-Inactive@test.test';
        APIUser.Email = 'testUser-Inactive@test.test';
        APIUser.Alias = 'testXX';
        APIUser.CommunityNickname = 'test1';
        APIUser.TimeZoneSidKey = 'America/New_York';
        APIUser.LocaleSidKey = 'en_US';
        APIUser.EmailEncodingKey = 'UTF-8';
        APIUser.ProfileId = saProfile.Id;
        APIUser.LanguageLocaleKey = 'en_US';
        APIUser.IsActive = true;
        insert APIUser;

        User TMUser = new User();
        TMUser.FirstName = 'FName';
        TMUser.LastName = 'LName';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive2@test.test';
        TMUser.Email = 'testUser-Inactive2@test.test';
        TMUser.Alias = 'testXX2';
        TMUser.CommunityNickname = 'test2';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

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

        TestDataFactory.createFunctionalGroupWithCategory('Admission Services', 'Test Category', 'Test Subcategory');
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Admission Services'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];
        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 999
        );
        insert carDefault;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign;
        Map<String, Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
            Case_Assignment_Rule__c = car.Id,
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            //          o.Enrollment_Coach__c = TMUser.Id;
        }
        insert oppList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                CC_Functional_Group__c = fg.Id,
                CC_Category__c = cat.Id,
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
            system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to CAR Queue/User');
            system.assert(ca.CC_Category__c == cat.Id, 'Case Category was not assigned to CAR Category');
        }
    }

    private static testMethod void testAdmissionsCaseWebformECAssignment() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User APIUser = new User();
        APIUser.FirstName = 'API';
        APIUser.LastName = 'LName';
        APIUser.CompanyName = 'Test Company';
        APIUser.MobilePhone = '123-456-7890';
        APIUser.Username = 'testUser-Inactive@test.test';
        APIUser.Email = 'testUser-Inactive@test.test';
        APIUser.Alias = 'testXX';
        APIUser.CommunityNickname = 'test1';
        APIUser.TimeZoneSidKey = 'America/New_York';
        APIUser.LocaleSidKey = 'en_US';
        APIUser.EmailEncodingKey = 'UTF-8';
        APIUser.ProfileId = saProfile.Id;
        APIUser.LanguageLocaleKey = 'en_US';
        APIUser.IsActive = true;
        insert APIUser;

        User TMUser = new User();
        TMUser.FirstName = 'FName';
        TMUser.LastName = 'LName';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive2@test.test';
        TMUser.Email = 'testUser-Inactive2@test.test';
        TMUser.Alias = 'testXX2';
        TMUser.CommunityNickname = 'test2';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

        User ECUser = new User();
        ECUser.FirstName = 'FName';
        ECUser.LastName = 'LName';
        ECUser.CompanyName = 'Test Company';
        ECUser.MobilePhone = '123-456-7890';
        ECUser.Username = 'testUser-Inactive3@test.test';
        ECUser.Email = 'testUser-Inactive3@test.test';
        ECUser.Alias = 'testXX2';
        ECUser.CommunityNickname = 'test3';
        ECUser.TimeZoneSidKey = 'America/New_York';
        ECUser.LocaleSidKey = 'en_US';
        ECUser.EmailEncodingKey = 'UTF-8';
        ECUser.ProfileId = saProfile.Id;
        ECUser.LanguageLocaleKey = 'en_US';
        ECUser.IsActive = true;
        insert ECUser;

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

        TestDataFactory.createFunctionalGroupWithCategory(
            'Admission Services - Undergraduate',
            'Test Category',
            'Test Subcategory'
        );
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Functional Group'
                AND Active__c = TRUE
                AND Name = 'Admission Services - Undergraduate'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 999
        );
        insert carDefault;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign;
        Map<String, Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
            Case_Assignment_Rule__c = car.Id,
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            o.Enrollment_Coach__c = ECUser.Id;
            o.OwnerId = TMUser.Id;
        }
        insert oppList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
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
            system.assert(ca.OwnerId == ECUser.Id, 'Case owner was not assigned to Enrollment Coach');
        }
    }

    private static testMethod void testAdmissionsCaseWebformCARFunctionalGroup() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User APIUser = new User();
        APIUser.FirstName = 'API';
        APIUser.LastName = 'LName';
        APIUser.CompanyName = 'Test Company';
        APIUser.MobilePhone = '123-456-7890';
        APIUser.Username = 'testUser-Inactive@test.test';
        APIUser.Email = 'testUser-Inactive@test.test';
        APIUser.Alias = 'testXX';
        APIUser.CommunityNickname = 'test1';
        APIUser.TimeZoneSidKey = 'America/New_York';
        APIUser.LocaleSidKey = 'en_US';
        APIUser.EmailEncodingKey = 'UTF-8';
        APIUser.ProfileId = saProfile.Id;
        APIUser.LanguageLocaleKey = 'en_US';
        APIUser.IsActive = true;
        insert APIUser;

        User TMUser = new User();
        TMUser.FirstName = 'FName';
        TMUser.LastName = 'LName';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive2@test.test';
        TMUser.Email = 'testUser-Inactive2@test.test';
        TMUser.Alias = 'testXX2';
        TMUser.CommunityNickname = 'test2';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

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

        TestDataFactory.createFunctionalGroupWithCategory(
            'Admission Services',
            'Recruitment - Cat',
            'Recruitment - Sub Cat'
        );
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Admission Services'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Category'
                AND Active__c = TRUE
                AND Name = 'Recruitment - Cat'
                AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Recruitment - Sub Cat'
                AND Parent__c = :cat.Id
        ];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            //origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(TMUser.Id).subString(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 999
        );
        insert carDefault;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign;
        Map<String, Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
            Case_Assignment_Rule__c = car.Id,
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            //          o.Enrollment_Coach__c = TMUser.Id;
        }
        insert oppList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
                Case_Source__c = camp.Id,
                Associate_Case_to_Active_Opportunity__c = false,
                CC_Functional_Group__c = fg.Id,
                CC_Category__c = cat.Id,
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
            system.assert(ca.OwnerId == TMUser.Id, 'Case owner was not assigned to CAR Queue/User');
            system.assert(
                ca.CC_functional_group__c == fg.Id,
                'Case Functional Group was not assigned to CAR Functional Group'
            );
        }
    }

    private static testMethod void testAdmissionsCaseWebformDefaultCARAssignment() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User APIUser = new User();
        APIUser.FirstName = 'API';
        APIUser.LastName = 'LName';
        APIUser.CompanyName = 'Test Company';
        APIUser.MobilePhone = '123-456-7890';
        APIUser.Username = 'testUser-Inactive@test.test';
        APIUser.Email = 'testUser-Inactive@test.test';
        APIUser.Alias = 'testXX';
        APIUser.CommunityNickname = 'test1';
        APIUser.TimeZoneSidKey = 'America/New_York';
        APIUser.LocaleSidKey = 'en_US';
        APIUser.EmailEncodingKey = 'UTF-8';
        APIUser.ProfileId = saProfile.Id;
        APIUser.LanguageLocaleKey = 'en_US';
        APIUser.IsActive = true;
        insert APIUser;

        User TMUser = new User();
        TMUser.FirstName = 'FName';
        TMUser.LastName = 'LName';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive2@test.test';
        TMUser.Email = 'testUser-Inactive2@test.test';
        TMUser.Alias = 'testXX2';
        TMUser.CommunityNickname = 'test2';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

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

        TestDataFactory.createFunctionalGroupWithCategory(
            'Admission Services - Undergraduate',
            'Test Category',
            'Test Subcategory'
        );
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Functional Group'
                AND Active__c = TRUE
                AND Name = 'Admission Services - Undergraduate'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 999
        );
        insert carDefault;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign;
        Map<String, Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            o.CloseDate = Date.today();
            o.OwnerId = TMUser.Id;
        }
        insert oppList;

        TMUser.IsActive = false;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            update TMUser;
        }

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
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
            system.assert(ca.OwnerId == APIUser.Id, 'Case owner was not assigned to Default CAR Queue/User');
        }
    }

    private static testMethod void testAdmissionsCaseWebformDefaultCAR_ECAssignment() {
        Profile saProfile = [SELECT id FROM profile WHERE name = 'System Administrator'];

        User APIUser = new User();
        APIUser.FirstName = 'API';
        APIUser.LastName = 'LName';
        APIUser.CompanyName = 'Test Company';
        APIUser.MobilePhone = '123-456-7890';
        APIUser.Username = 'testUser-Inactive@test.test';
        APIUser.Email = 'testUser-Inactive@test.test';
        APIUser.Alias = 'testXX';
        APIUser.CommunityNickname = 'test1';
        APIUser.TimeZoneSidKey = 'America/New_York';
        APIUser.LocaleSidKey = 'en_US';
        APIUser.EmailEncodingKey = 'UTF-8';
        APIUser.ProfileId = saProfile.Id;
        APIUser.LanguageLocaleKey = 'en_US';
        APIUser.IsActive = true;
        insert APIUser;

        User TMUser = new User();
        TMUser.FirstName = 'FName';
        TMUser.LastName = 'LName';
        TMUser.CompanyName = 'Test Company';
        TMUser.MobilePhone = '123-456-7890';
        TMUser.Username = 'testUser-Inactive2@test.test';
        TMUser.Email = 'testUser-Inactive2@test.test';
        TMUser.Alias = 'testXX2';
        TMUser.CommunityNickname = 'test2';
        TMUser.TimeZoneSidKey = 'America/New_York';
        TMUser.LocaleSidKey = 'en_US';
        TMUser.EmailEncodingKey = 'UTF-8';
        TMUser.ProfileId = saProfile.Id;
        TMUser.LanguageLocaleKey = 'en_US';
        TMUser.IsActive = true;
        insert TMUser;

        User ECUser = new User();
        ECUser.FirstName = 'FName';
        ECUser.LastName = 'LName';
        ECUser.CompanyName = 'Test Company';
        ECUser.MobilePhone = '123-456-7890';
        ECUser.Username = 'testUser-Inactive3@test.test';
        ECUser.Email = 'testUser-Inactive3@test.test';
        ECUser.Alias = 'testXX2';
        ECUser.CommunityNickname = 'test3';
        ECUser.TimeZoneSidKey = 'America/New_York';
        ECUser.LocaleSidKey = 'en_US';
        ECUser.EmailEncodingKey = 'UTF-8';
        ECUser.ProfileId = saProfile.Id;
        ECUser.LanguageLocaleKey = 'en_US';
        ECUser.IsActive = true;
        insert ECUser;

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

        TestDataFactory.createFunctionalGroupWithCategory(
            'Admission Services - Undergraduate',
            'Test Category',
            'Test Subcategory'
        );
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Functional Group'
                AND Active__c = TRUE
                AND Name = 'Admission Services - Undergraduate'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            Email_Address__c = 'service@test.test',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            priority__c = 99
        );
        insert car;

        Case_Assignment_Rule__c carDefault = new Case_Assignment_Rule__c(
            Email_Address__c = 'admissions@asu.edu',
            email_template_id__c = templateId,
            queue_id__c = String.valueOf(APIUser.Id).substring(0, 15),
            origin__c = 'Test Origin',
            CC_functional_group__c = fg.Id,
            CC_category__c = cat.Id,
            CC_sub_category__c = subCat.Id,
            Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach',
            priority__c = 999
        );
        insert carDefault;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign;
        Map<String, Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

        Campaign camp = new Campaign(
            Name = 'C Test',
            Type = 'Web',
            RecordTypeId = CampaignRecordTypeInfo.get('Other Source').getRecordTypeId(),
            IsActive = true
        );
        insert camp;

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : contactList) {
            contactIds.add(c.Id);
        }

        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

        List<Opportunity> oppList = createOpportunities(contactList);
        for (Opportunity o : oppList) {
            o.CloseDate = Date.today();
            o.OwnerId = TMUser.Id;
            o.Enrollment_Coach__c = ECUser.Id;
        }
        insert oppList;

        TMUser.IsActive = false;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            update TMUser;
        }

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
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
            system.assert(
                ca.OwnerId == ECUser.Id,
                'Case owner was not assigned to Enrollment Coach User as specified by Default CAR'
            );
        }
    }

    @isTest
    private static void financialAidChangeStateWithSufficientLinks() {
        setfinancialAidQueue();
        Contact testContact = createContact();
        Case caseUnderTest = createCase(financialAidQueue, testContact);
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
        setRegistrarQueue();
        Contact testContact = createContact();

        Test.startTest();
        Case caseUnderTest = createCase(registrarQueue, testContact);
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
        setRegistrarQueue();
        Contact testContact = createContact();
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
        setRegistrarQueue();
        Contact testContact = createContact();

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
        setRegistrarQueue();
        Contact testContact = createContact();
        Case caseUnderTest = createCase(registrarQueue, testContact);
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
        setRegistrarQueue();
        Contact testContact = createContact();
        Case caseUnderTest = createCase(registrarQueue, testContact);
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
        setfinancialAidQueue();
        User apiDrupalUser = [SELECT Id FROM User WHERE Name = 'API ASU DRUPAL'];

        Contact testContact = createContact();
        Case caseUnderTest = createCase(financialAidQueue, testContact);
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

    private static testMethod void testAssignRTAdOutreach() {
        TestDataFactory.createFunctionalGroupWithCategory('ASU Advisor Outreach', 'Test Category', 'Test Subcategory');
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'ASU Advisor Outreach'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
                Subject = 'Test Subject',
                CC_functional_group__c = fg.Id,
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
            system.assertEquals(
                ca.RecordTypeId,
                CaseRecordTypeInfo.get('(Admin Only) ASU Advisor Outreach').getRecordTypeId()
            );
        }
    }

    private static testMethod void testAssignRTCoachOutreach() {
        TestDataFactory.createFunctionalGroupWithCategory('ASU Coach Outreach', 'Test Category', 'Test Subcategory');
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'ASU Coach Outreach'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
                Subject = 'Test Subject',
                CC_functional_group__c = fg.Id,
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
            system.assertEquals(ca.RecordTypeId, CaseRecordTypeInfo.get('ASU Coach Outreach').getRecordTypeId());
        }
    }

    private static testMethod void testAssignRTAdService() {
        TestDataFactory.createFunctionalGroupWithCategory('Admission Services', 'Recruitment', 'Recruitment');
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Admission Services'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Recruitment' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Sub Category' AND Active__c = TRUE AND Name = 'Recruitment' AND Parent__c = :cat.Id
        ];

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
                Subject = 'Test Subject',
                CC_functional_group__c = fg.Id,
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
            system.assertEquals(ca.RecordTypeId, CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId());
        }
    }

    private static testMethod void testAssignRTService() {
        TestDataFactory.createFunctionalGroupWithCategory(
            'ASU Salesforce Support',
            'Test Category',
            'Test Subcategory'
        );
        Case_Classification__c fg = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'ASU Salesforce Support'
        ];
        Case_Classification__c cat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Category' AND Active__c = TRUE AND Name = 'Test Category' AND Parent__c = :fg.Id
        ];
        Case_Classification__c subCat = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Sub Category'
                AND Active__c = TRUE
                AND Name = 'Test Subcategory'
                AND Parent__c = :cat.Id
        ];

        List<Contact> contactList = createContacts(1);
        insert contactList;

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName();

        List<Case> caseList = new List<Case>();
        for (Contact c : contactList) {
            Case ca = new Case(
                ContactId = c.Id,
                RecordTypeId = CaseRecordTypeInfo.get('ASU Admission Services').getRecordTypeId(),
                Subject = 'Test Subject',
                CC_functional_group__c = fg.Id,
                CC_Category__c = cat.Id,
                CC_Sub_Category__c = subCat.Id,
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
            system.assertEquals(ca.RecordTypeId, CaseRecordTypeInfo.get('ASU Service').getRecordTypeId());
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
        Contact testContact = createContact();
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
