@isTest
private class ViewCaseControllerTest {
    private static final String testUserAliasBase = 'testUsr';
    @testSetup
    static void setupTestData() {
        List<Contact> testContacts = new List<Contact>();
        Integer emplId = 1200000000;
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact-' + i,
                    Email = 'test.contact.' + i + '@test.test',
                    EmplId__c = '' + (emplId++)
                )
            );
        }
        testContacts[3].Affiliation_Alumni__c = 'Current';
        insert testContacts;
        // Get AccountIds for each contact
        Map<Id, Contact> testContactIdToAccountIdMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact]);
        for (Contact con : testContacts) {
            con.AccountId = testContactIdToAccountIdMap.get(con.Id).AccountId;
        }
        
         List<Case> testCases = new List<Case>();
        testCases.add(
            new Case(
                Subject = 'Open Test Case',
                Description = 'Auto generated test case',
                ContactId = testContacts[0].Id
            )
        );
        for (Integer i = 0; i < 10; i++) {
            testCases.add(
                new Case(
                    Subject = 'Test Case ' + i,
                    Description = 'Auto generated test case',
                    ContactId = testContacts[0].Id,
                    Status = 'Closed: Resolved'
                )
            );
        }
        insert testCases;
        
         Account acc = new Account(Name = 'Test HS 1', Institution_Type__c = 'HS');
        Insert acc;
        
        Term__c termA = new Term__c(
            Name = 'Fall 2025',
            Session_A_C_Start_Date__c = System.today().addDays(30),
            Year__c = '2025'
        );
        insert termA;
        
        Term__c termB = new Term__c(
            Name = 'B Session',
            Session_B_Start_Date__c = System.today().addDays(60),
            Year__c = '2024'
        );
        insert termB;
        
       /* Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Enrolled',
            CloseDate = System.today().addMonths(1),
            Career__c = 'Undergraduate',
            Admitted_Session__c = 'A/C',
            Term__c = termA.Id,
            Contact__c = contact.Id,
            AccountId = acc.Id
        );
      //  insert opp;*/
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Closed',
            Origin = 'Web',
            // Created_By_Name__c = 'Test User',
            ClosedDate = System.today().addDays(-20)
        );
        insert testCase;
        
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('This is test content'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        Test.startTest();
        Email_To_Case_Configuration__c config = new Email_To_Case_Configuration__c(
            Name = 'Default Org Wide Email Address',
            Value__c = 'default@example.com'
        );
        insert config;
        Test.stopTest();
        
         List<User> testUsers = new List<User>();
        Id asuCommunityProfileId = RecordIdHelper.getProfileId('ASU Community');
        for (Integer i = 0; i < testContacts.size(); i++) {
            Contact testCon = testContacts[i];
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User-' + i,
                Username = 'test.user.' + i + '@test.test',
                Email = 'test.user.' + i + '@test.test',
                Alias = testUserAliasBase + i,
                CommunityNickname = testUserAliasBase + i,
                TimeZoneSidKey = 'America/Phoenix',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = asuCommunityProfileId,
                LanguageLocaleKey = 'en_US',
                ContactId = testCon.Id
            );
            testUsers.add(testUser);
        }
        insert testUsers;
    }
    
    @isTest
    private static void fetchCaseDetailsWithoutMyASUHelpViewAsService() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        Case checkCase;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            checkCase = vcc.getCaseDetails();
            
            vcc.viewingAs = true;
            vcc.retrieveCaseDetails();
        }
        Test.stopTest();
        
        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }
    
    @isTest
    private static void fetchCaseDetailsWithMyASUHelpViewAsService() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        Case checkCase;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            vcc.viewingAs = true;
            checkCase = vcc.getCaseDetails();
        }
        Test.stopTest();
        
        System.assertEquals(checkCase.Id, caseOnTestUser.Id);
    }
    
    @isTest
    private static void fetchChatMessages() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [
            SELECT Id, OwnerId
            FROM Case
            WHERE ContactId = :testUser.ContactId AND Subject = 'Open Test Case'
            LIMIT 1
        ];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        List<ChatMessage> fetchedChatMessages;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            fetchedChatMessages = vcc.getChatMessages();
        }
        Test.stopTest();
        
       // System.assertEquals(fetchedChatMessages.size(), 1);
    }
    
    @isTest
    private static void correctNumberOfChatMessages() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [
            SELECT Id, OwnerId
            FROM Case
            WHERE ContactId = :testUser.ContactId AND Subject = 'Open Test Case'
            LIMIT 1
        ];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        List<ChatMessage> fetchedChatMessages;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            fetchedChatMessages = vcc.getChatMessages();
        }
        Test.stopTest();
        
        List<bomgar__Event__c> bomgarForAssert = [
            SELECT
            bomgar__DestinationValue__c,
            bomgar__EventDateTime__c,
            bomgar__EventType__c,
            bomgar__PerformedByType__c,
            bomgar__PerformedByValue__c,
            bomgar__Text__c,
            Id,
            Name,
            OwnerId
            FROM bomgar__Event__c
            WHERE
            bomgar__BomgarSession__r.bomgar__relatedcase__c = :caseOnTestUser.Id
            AND (bomgar__PerformedByType__c = 'representative'
                 OR bomgar__PerformedByType__c = 'customer')
            AND bomgar__DestinationValue__c = 'everyone'
            ORDER BY bomgar__EventDateTime__c ASC
        ];
        List<Chat_Message__c> chatMessages = [SELECT Body__c FROM Chat_Message__c];
        System.assertEquals(bomgarForAssert.size() + chatMessages.size(), fetchedChatMessages.size());
    }
    
   /* @isTest
    private static void testRestCalloutSuccess() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        ViewCaseController vcc;
        
        Test.setMock(HttpCalloutMock.class, new EmailMessageCalloutMock());
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.replyCaseFile.Title = 'Test Name';
            vcc.replyCaseFile.VersionData = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';
            
            vcc.submitReply();
        }
        Test.stopTest();
        
        System.assert(String.isEmpty(vcc.caseReply));
        Boolean successMessageFound = false;
        for (CustomAlert alert : vcc.alertHandler.alerts) {
            if (alert.message.contains('Your response was submitted successfully')) {
                successMessageFound = true;
            }
        }
        System.assert(successMessageFound);
    }
    
    @isTest
    private static void testRestCalloutFailure() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        ViewCaseController vcc;
        
        EmailMessageCalloutMock calloutMock = new EmailMessageCalloutMock();
        calloutMock.shouldSucceed = false;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        System.runAs(testUser) {
            vcc = new ViewCaseController();
            vcc.replyCaseFile.Title = 'Test Name';
            vcc.replyCaseFile.VersionData = Blob.valueOf('Test Attachment Body');
            vcc.caseReply = 'Test Message';
            
            vcc.submitReply();
        }
        Test.stopTest();
        
        System.assert(String.isEmpty(vcc.caseReply));
        Boolean failureMessageFound = false;
        for (CustomAlert alert : vcc.alertHandler.alerts) {
            if (alert.message.contains('Your response was not submitted successfully')) {
                failureMessageFound = true;
            }
        }
        System.assert(failureMessageFound);
    } */
    
    @isTest
    private static void testCorrectReplyToEmail() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        caseOnTestUser.Initial_Request_Sent_To_Addresses__c = 'testEmail@test.com';
        update caseOnTestUser;
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        String jsonEmail;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            jsonEmail = vcc.createJsonEmail();
        }
        Test.stopTest();
        
        System.assert(jsonEmail.contains('testEmail@test.com'));
    }
    
    @isTest
    private static void testNoIntendedReplyToEmail() {
        User testUser = [
            SELECT Id, ContactId, FirstName, LastName, EMPLID__c, ASURite_Id__c
            FROM User
            WHERE Alias = :testUserAliasBase + '0'
        ];
        Case caseOnTestUser = [SELECT Id, OwnerId FROM Case WHERE ContactId = :testUser.ContactId LIMIT 1];
        
        PageReference viewCase = Page.viewcase;
        viewCase.getParameters().put('id', caseOnTestUser.Id);
        Test.setCurrentPage(viewCase);
        
        String jsonEmail;
        
        Test.startTest();
        System.runAs(testUser) {
            ViewCaseController vcc = new ViewCaseController();
            jsonEmail = vcc.createJsonEmail();
        }
        Test.stopTest();
        //System.assert(jsonEmail.contains('noEmail@test.com'));
    }
}