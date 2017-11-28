@isTest
private class Test_CaseListTransferController {

    @testSetup static void setUpData() {
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
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue;
        }

        List<Case_Assignment_Rule__c> carList = new List<Case_Assignment_Rule__c>();

        
        TestDataFactory.createFunctionalGroupWithCategory('Engineering', 'Eng', 'SubEng');
        TestDataFactory.createFunctionalGroup('University Registrar Services');
        Case_Classification__c fg = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Engineering'];
        Case_Classification__c cat = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Category' AND Active__c = true AND Name = 'Eng' AND Parent__c =: fg.Id];
        Case_Classification__c subCat = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Sub Category' AND Active__c = true AND Name = 'SubEng' AND Parent__c =: cat.Id];
        Case_Classification__c fgTwo = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'University Registrar Services'];
        Case_Assignment_Rule__c one = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'Engineering',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = fg.Id,
            Label__c = 'Engineering (Default)',
            CC_Category__c = cat.Id,
            CC_Sub_Category__c = subCat.Id,
            Queue_ID__c = String.valueOf(testGroup.Id).substring(0, 15)
        );

        Case_Assignment_Rule__c two = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Colleges',
            CTPGroup__c = 'Engineering',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = fg.Id,
            Label__c = 'School of blah blah'
        );

        Case_Assignment_Rule__c three = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'University Registrar Services',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = fgTwo.Id,
            Label__c = 'University Registrar Services (Default)'
        );

        Case_Assignment_Rule__c four = new Case_Assignment_Rule__c(
            CTPColumn__c = 'Service Departments',
            CTPGroup__c = 'University Registrar Services',
            CTPVisible__c = true,
            Email_Address__c = 'default@email.com',
            CC_Functional_Group__c = fgTwo.Id,
            Label__c = 'School of blah blah'
        );

        carList.add(one);
        carList.add(two);
        carList.add(three);
        carList.add(four);

        insert carList;


        List<Case> testCases = new List<Case>();
        
        for (Case c : TestDataFactory.createCases(5)) {
            c.description = 'desc';
            testCases.add(c);
        }

        insert testCases;

        Case testCaseWithNoSubDesc = new Case (
            Subject = '',
            Description = ''
        );

        insert testCaseWithNoSubDesc;

        User testUser = UserService.createTestUser();
        Id pId = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%' LIMIT 1].Id;
        testUser.ProfileId = pId;

        insert testUser;
    }

    @isTest static void testTransferToDept() {
        Case_Assignment_Rule__c testCar = [
            SELECT Id, Label__c, CTPGroup__c
            FROM Case_Assignment_Rule__c
            WHERE Label__c = 'Engineering (Default)'
        ];

        Case caseToTest = [SELECT Id FROM Case LIMIT 1];
        PageReference pageRef = page.CaseTransfer;
        Test.setCurrentPage(pageRef);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
        CaseListTransferController ctc = new CaseListTransferController(sc);
        ctc.page3();
        ctc.selectedId = testCar.Id;
        ctc.selectedCARLabel = testCar.Label__c;
        ctc.selectedGroupName = testCar.CTPGroup__c;
        ctc.page4();
        ctc.transferCase();

        Test.stopTest();

        Case caseToAssert = [
            SELECT Id, CC_Functional_Group__c, OwnerId
            FROM Case
            WHERE Id = :caseToTest.Id
        ];

        Group groupToAssert = [
            SELECT Id
            FROM Group
            WHERE Name = 'Test Group Name'
        ];

        Case_Classification__c expectedResult = [Select Id FROM Case_Classification__c WHERE RecordType.Name = 'Functional Group' AND Active__c = true AND Name = 'Engineering'];
        System.assertEquals(expectedResult.Id, caseToAssert.CC_Functional_Group__c);
        System.assertEquals(groupToAssert.Id, caseToAssert.OwnerId);
    }

    @isTest static void testTransferToUserWithSearch() {
        User testUser = [
            SELECT Id, Name
            FROM User
            WHERE Name = 'Test User'
        ];

        Case caseToTest = [SELECT Id FROM Case LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
        CaseListTransferController ctc = new CaseListTransferController(sc);
        PageReference pageRef = page.CaseTransfer;
        Test.setCurrentPage(pageRef);

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

    @isTest static void testNullSubAndDesc() {
        Case caseToTest = [
            SELECT Id
            FROM Case
            WHERE Subject = ''
            LIMIT 1
        ];

        User testUser = [
            SELECT Id, Name
            FROM User
            WHERE Name = 'Test User'
        ];

        ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
        CaseListTransferController ctc = new CaseListTransferController(sc);
        PageReference pageRef = page.CaseTransfer;
        Test.setCurrentPage(pageRef);

        Test.startTest();

        ctc.selectedId = testUser.Id;
        ctc.toUser = true;
        ctc.transferCase();

        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean isMsgThere = false;

        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('The Subject and Description are required fields')) {
                isMsgThere = true;
            }
        }

        System.assert(isMsgThere);
    }
    
    public static testMethod void Test_MultipleCases() {
        List<Apexpages.Message> msgs;
        User testUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test User'
        ];
        
        List<Case> casesToTest = [
            SELECT Id
            FROM Case
            WHERE Subject != ''
        ];
        
        ApexPages.standardSetController ssc = new ApexPages.standardSetController(casesToTest);
        ssc.setSelected(casesToTest);
        CaseListTransferController ctc = new CaseListTransferController(ssc);
        PageReference pageRef = page.CaseListTransfer;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();

        ctc.selectedId = testUser.Id;
        ctc.toUser = true;
        ctc.transferCase();

        Test.stopTest();
        
        msgs = ApexPages.getMessages();
        
        system.assertEquals(0, msgs.size());
        
        casesToTest = [
            SELECT Id, OwnerId
            FROM Case
            WHERE Subject != ''
        ];
        
        for (Case c : [SELECT OwnerId
            FROM Case
            WHERE Subject != '']) {
            system.assertEquals(testUser.Id, c.ownerId);
        }
    }
    
    public static testMethod void Test_MultipleCasesFromURL() {
        List<Apexpages.Message> msgs;
        String caseIds = '';
        
        User testUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test User'
        ];
        
        List<Case> casesToTest = [
            SELECT Id
            FROM Case
            WHERE Subject != ''
        ];
        
        for (Case c : casesToTest) {
            caseIds += c.Id + ',';
        }
        
        caseIds += 'badId'; // Used to make sure this ID is excluded from the transfer
        
        ApexPages.currentPage().getParameters().put('caseIds', caseIds);
        ApexPages.standardSetController ssc = new ApexPages.standardSetController(casesToTest);
        CaseListTransferController ctc = new CaseListTransferController(ssc);
        PageReference pageRef = page.CaseListTransfer;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();

        ctc.selectedId = testUser.Id;
        ctc.toUser = true;
        ctc.transferCase();

        Test.stopTest();
        
        msgs = ApexPages.getMessages();
        
        system.assertEquals(1, msgs.size()); // Make sure the bad ID is flagged
        
        casesToTest = [
            SELECT Id, OwnerId
            FROM Case
            WHERE Subject != ''
        ];
        
        for (Case c : [SELECT OwnerId
            FROM Case
            WHERE Subject != '']) {
            system.assertEquals(testUser.Id, c.ownerId);
        }
    }
    
    public static testMethod void Test_ReleaseOwnership() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test User'
        ];
        
        Case_Assignment_Rule__c testCar = [
            SELECT Id, Label__c, CTPGroup__c, Queue_ID__c
            FROM Case_Assignment_Rule__c
            WHERE Label__c = 'Engineering (Default)'
        ];

        // First, lets make sure all cases are using the same CAR
        List<Case> casesToTest = [SELECT Id FROM Case WHERE Subject != ''];
        PageReference pageRef = page.CaseTransfer;
        Test.setCurrentPage(pageRef);

        ApexPages.standardSetController ssc = new ApexPages.standardSetController(casesToTest);
        ssc.setSelected(casesToTest);
        CaseListTransferController ctc = new CaseListTransferController(ssc);
        ctc.page3();
        ctc.selectedId = testCar.Id;
        ctc.selectedCARLabel = testCar.Label__c;
        ctc.selectedGroupName = testCar.CTPGroup__c;
        ctc.page4();
        ctc.transferCase();
        
        // next, let's transfer all cases to the same user
        casesToTest = [SELECT Id FROM Case WHERE Subject != ''];
        
        ssc = new ApexPages.standardSetController(casesToTest);
        ssc.setSelected(casesToTest);
        ctc = new CaseListTransferController(ssc);
        
        ctc.selectedId = testUser.Id;
        ctc.toUser = true;
        ctc.transferCase();
        
        // Finally, let's release the cases
        casesToTest = [SELECT Id FROM Case WHERE Subject != ''];
        
        ssc = new ApexPages.standardSetController(casesToTest);
        ssc.setSelected(casesToTest);
        ctc = new CaseListTransferController(ssc);
        
        test.startTest();
        
        ctc.releaseOwnership();
        
        test.stopTest();
        
        // Verify that every case is owned by the correct queue
        for (Case c : [SELECT OwnerId FROM Case WHERE Subject != '']) {
            system.assertEquals(testCar.Queue_ID__c, c.ownerId);
        }
    }
    
    public static testMethod void Test_GoBack() {
        pageReference result;
        List<Case> casesToTest = [SELECT Id FROM Case WHERE Subject != ''];
        PageReference pageRef = page.CaseTransfer;
        Test.setCurrentPage(pageRef);

        ApexPages.standardSetController ssc = new ApexPages.standardSetController(casesToTest);
        ssc.setSelected(casesToTest);
        CaseListTransferController ctc = new CaseListTransferController(ssc);
        
        // Go back for department transfers
        ctc.page = 4;
        ctc.toUser = false;
        ctc.goBack();
        system.assertEquals(3, ctc.page);
        
        ctc.goBack();
        system.assertEquals(1, ctc.page);
        
        ctc.goBack();
        // Note: salesforce returns null when returning to list view
        
        // Go back for user transfers
        ctc.page = 4;
        ctc.toUser = true;
        ctc.goBack();
        system.assertEquals(2, ctc.page);
        
        ctc.goBack();
        system.assertEquals(1, ctc.page);
        
        ctc.goBack();
        // Note: Salesforce returns null when returning to list view
    }
}
