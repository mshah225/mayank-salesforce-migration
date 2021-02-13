@isTest
private class Test_CaseTransferMassController {
    private static User testUser;
    static void setUpData() {
        Group testGroup = new Group(Name = 'Test Group Name', Type = 'Queue');

        insert testGroup;

        QueueSobject testQueue = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case');

        // To avoid MIXED DML ERROR, you need to insert this non-setup object
        // as the system user. In this case, just the admin running the test.
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue;
        }

        Case_Classification__c cc = new Case_Classification__c();
        cc.Name = 'Engineering';
        cc.Active__c = true;
        cc.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Functional Group')
            .getRecordTypeId();
        insert cc;

        Case_Classification__c ccURS = new Case_Classification__c();
        ccURS.Name = 'University Registrar Services';
        ccURS.Active__c = true;
        ccURS.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Functional Group')
            .getRecordTypeId();
        insert ccURS;

        Case_Classification__c cc1 = new Case_Classification__c();
        cc1.Name = 'Eng';
        cc1.Active__c = true;
        cc1.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Category')
            .getRecordTypeId();
        cc1.Parent__c = cc.Id;
        insert cc1;

        Case_Classification__c cc2 = new Case_Classification__c();
        cc2.Name = 'SubEng';
        cc2.Active__c = true;
        cc2.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Sub Category')
            .getRecordTypeId();
        cc2.Parent__c = cc1.Id;
        insert cc2;

        List<Case_Assignment_Rule__c> carList = new List<Case_Assignment_Rule__c>();

        Case_Assignment_Rule__c one = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'Engineering',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = cc.Id,
            Label__c = 'Engineering (Default)',
            CC_Category__c = cc1.Id,
            CC_Sub_Category__c = cc2.Id,
            Queue_ID__c = String.valueOf(testGroup.Id).substring(0, 15)
        );

        Case_Assignment_Rule__c two = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'Engineering',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = cc.Id,
            Label__c = 'School of blah blah'
        );

        Case_Assignment_Rule__c three = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'University Registrar Services',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = ccURS.Id,
            Label__c = 'University Registrar Services (Default)'
        );

        Case_Assignment_Rule__c four = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'University Registrar Services',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = ccURS.Id,
            Label__c = 'School of blah blah'
        );

        carList.add(one);
        carList.add(two);
        carList.add(three);
        carList.add(four);

        insert carList;

        Case testCase = new Case(Subject = 'subject', Description = 'desc');

        insert testCase;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        testUser = (User) userCreator.create(1)[0];
        Id pId = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%' LIMIT 1].Id;
        testUser.ProfileId = pId;

        insert testUser;
    }

    @isTest
    static void testTransferToDept() {
        setUpData();
        Case_Assignment_Rule__c testCar = [
            SELECT Id, Label__c, CTPGroup__c
            FROM Case_Assignment_Rule__c
            WHERE Label__c = 'Engineering (Default)'
        ];

        Case caseToTest = [SELECT Id FROM Case LIMIT 1];
        List<Case> casesToTest = [SELECT Id FROM Case];
        List<string> ids = new List<string>();
        for (Case ca : casesToTest) {
            ids.add(ca.Id);
        }
        PageReference pageRef = page.CaseTransferMass;
        pageRef.getParameters().put('ids', string.valueOf(ids));
        Test.setCurrentPage(pageRef);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
        CaseTransferMassController ctc = new CaseTransferMassController(sc);
        ctc.page3();
        ctc.selectedId = testCar.Id;
        ctc.selectedCARLabel = testCar.Label__c;
        ctc.selectedGroupName = testCar.CTPGroup__c;
        ctc.page4();
        ctc.transferCase();

        Test.stopTest();

        Case caseToAssert = [SELECT Id, CC_Functional_Group__r.Name, OwnerId FROM Case WHERE Id = :caseToTest.Id];

        Group groupToAssert = [SELECT Id FROM Group WHERE Name = 'Test Group Name'];

        System.assertEquals('Engineering', caseToAssert.CC_Functional_Group__r.Name);
        System.assertEquals(groupToAssert.Id, caseToAssert.OwnerId);
    }

    @isTest
    static void testTransferToUserWithSearch() {
        setUpData();
        Case caseToTest = [SELECT Id FROM Case LIMIT 1];
        List<Case> casesToTest = [SELECT Id FROM Case];
        List<string> ids = new List<string>();
        for (Case ca : casesToTest) {
            ids.add(ca.Id);
        }
        PageReference pageRef = page.CaseTransferMass;
        pageRef.getParameters().put('ids', string.valueOf(ids));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
        CaseTransferMassController ctc = new CaseTransferMassController(sc);

        Id[] fixedSearchResults = new List<Id>(1);
        fixedSearchResults[0] = testUser.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        ctc.page2();
        ctc.page1();
        ctc.page2();
        ctc.resetSearch();
        ctc.searchString = 'Test';
        ctc.searchUsers();
        ctc.selectedId = fixedSearchResults[0];
        ctc.page4();
        ctc.transferCase();

        Test.stopTest();

        Case caseToAssert = [SELECT Id, OwnerId FROM Case WHERE Id = :caseToTest.Id];

        System.assertEquals(testUser.Id, caseToAssert.OwnerId);
    }
}
