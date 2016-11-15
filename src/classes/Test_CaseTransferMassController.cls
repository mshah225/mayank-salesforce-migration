@isTest
private class Test_CaseTransferMassController {
	
    @testSetup static void setUpData()
    {
        Group testGroup = new Group(
            Name = 'Test Group Name',
            Type = 'Queue'
        );

        insert testGroup;

        QueueSobject testQueue = new QueueSobject(
            QueueId = testGroup.Id,
            SobjectType = 'Case'
        );

        // To avoid MIXED DML ERROR, you need to insert this non-setup object
        // as the system user. In this case, just the admin running the test.
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert testQueue;
        }

        List<Case_Assignment_Rule__c> carList = new List<Case_Assignment_Rule__c>();

        Case_Assignment_Rule__c one = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'Engineering',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            Functional_Group__c = 'Engineering',
            Label__c = 'Engineering (Default)',
            Category__c = 'Eng',
            Sub_Category__c = 'SubEng',
            Queue_ID__c = String.valueOf(testGroup.Id).substring(0, 15)
        );

        Case_Assignment_Rule__c two = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'Engineering',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            Functional_Group__c = 'Engineering',
            Label__c = 'School of blah blah'
        );

        Case_Assignment_Rule__c three = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'University Registrar Services',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            Functional_Group__c = 'University Registrar Services',
            Label__c = 'University Registrar Services (Default)'
        );

        Case_Assignment_Rule__c four = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'University Registrar Services',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            Functional_Group__c = 'University Registrar Services',
            Label__c = 'School of blah blah'
        );

        carList.add(one);
        carList.add(two);
        carList.add(three);
        carList.add(four);

        insert carList;

        Case testCase = new Case(
            Subject = 'subject',
            Description = 'desc'
        );

        insert testCase;

        User testUser = UserService.createTestUser();
        Id pId = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%' LIMIT 1].Id;
        testUser.ProfileId = pId;

        insert testUser;
    }

    @isTest static void testTransferToDept()
    {
        Case_Assignment_Rule__c testCar = [
            SELECT Id, Label__c, CTPGroup__c
            FROM Case_Assignment_Rule__c
            WHERE Label__c = 'Engineering (Default)'
        ];

        Case caseToTest = [SELECT Id FROM Case LIMIT 1];
        List<Case> casesToTest = [SELECT Id FROM Case];
        List<string> ids = new List<string>();
        for(Case ca: casesToTest)
        {
            ids.add(ca.Id);
        }
        PageReference pageRef = page.CaseTransferMass;
        pageRef.getParameters().put('ids',string.valueOf(ids));
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

        Case caseToAssert = [
            SELECT Id, Functional_Group__c, OwnerId
            FROM Case
            WHERE Id = :caseToTest.Id
        ];

        Group groupToAssert = [
            SELECT Id
            FROM Group
            WHERE Name = 'Test Group Name'
        ];

        System.assertEquals('Engineering', caseToAssert.Functional_Group__c);
        System.assertEquals(groupToAssert.Id, caseToAssert.OwnerId);
    }

    @isTest static void testTransferToUserWithSearch()
    {
        User testUser = [
            SELECT Id, Name
            FROM User
            WHERE Name = 'Test User'
        ];

        Case caseToTest = [SELECT Id FROM Case LIMIT 1];
        List<Case> casesToTest = [SELECT Id FROM Case];
        List<string> ids = new List<string>();
        for(Case ca: casesToTest)
        {
            ids.add(ca.Id);
        }
        PageReference pageRef = page.CaseTransferMass;
        pageRef.getParameters().put('ids',string.valueOf(ids));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
        CaseTransferMassController ctc = new CaseTransferMassController(sc);

        Id [] fixedSearchResults= new Id[1];
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

        Case caseToAssert = [
            SELECT Id, OwnerId
            FROM Case
            WHERE Id = :caseToTest.Id
        ];

        System.assertEquals(testUser.Id, caseToAssert.OwnerId);
    }
}