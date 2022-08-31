@isTest
private class ConversationTriggerTest {
    @isTest
    private static void testMethod1() {
        ConversationDispatcher dispatcher = new ConversationDispatcher(null, null, null, null);
        RecordType recordTypeForContact = [
            SELECT Id, Name
            FROM RecordType
            WHERE sobjecttype = 'Contact' AND Name = 'External Mastered'
            LIMIT 1
        ];
        Contact con = new Contact();
        con.RecordTypeId = recordTypeForContact.Id;
        con.EMPLID__c = '12345';
        con.LastName = 'Test SMS';
        Database.insert(con);

        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'Conversation 1';
        conv.smagicinteract__Contact__c = con.Id;
        Database.insert(conv);

        Profile p = [SELECT id FROM profile WHERE name = 'System Administrator'];
        User u1 = new User(
            Alias = 'test1',
            MobilePhone = '9960231818',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            lastname = 'test1',
            email = 'test2@test.com',
            username = 'test4@test.screenmagic.com'
        );
        Database.insert(u1);
        conv.Success_Coach__c = u1.Id;

        Test.startTest();
        Database.upsert(conv);
        Test.stopTest();

        List<smagicinteract__Conversation__Share> convShareList = [
            SELECT Id, RowCause, UserOrGroupId, ParentId
            FROM smagicinteract__Conversation__Share
            WHERE ParentId = :conv.Id
        ];
        system.assertEquals(2, convShareList.size());

        delete (conv);
        undelete (conv);
    }

    @isTest
    private static void updateSharingTest() {
        //Test for change in Success Coach
        RecordType recordTypeForContact = [
            SELECT Id, Name
            FROM RecordType
            WHERE sobjecttype = 'Contact' AND Name = 'External Mastered'
            LIMIT 1
        ];
        Contact con = new Contact();
        con.RecordTypeId = recordTypeForContact.Id;
        con.EMPLID__c = '12345';
        con.LastName = 'Test SMS';
        Database.insert(con);

        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'Conversation 1';
        conv.smagicinteract__Contact__c = con.Id;
        Database.insert(conv);

        Profile p = [SELECT id FROM profile WHERE name = 'System Administrator'];
        User u1 = new User(
            Alias = 'test1',
            MobilePhone = '9960231818',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            lastname = 'test1',
            email = 'test2@test.com',
            username = 'test4@test.screenmagic.com'
        );
        Database.insert(u1);

        conv.Success_Coach__c = u1.Id;
        Database.upsert(conv);

        List<smagicinteract__Conversation__Share> convShareList = [
            SELECT Id, RowCause, UserOrGroupId, ParentId
            FROM smagicinteract__Conversation__Share
            WHERE ParentId = :conv.Id
        ];

        system.assertEquals(2, convShareList.size());

        //Test for change in Supervisor
        Contact c1 = new Contact();
        c1.RecordTypeId = recordTypeForContact.Id;
        c1.EMPLID__c = '54321';
        c1.LastName = 'Test SMS New';
        Database.insert(c1);

        smagicinteract__Conversation__c conv1 = new smagicinteract__Conversation__c();
        conv1.Name = 'Conversation 2';
        conv1.smagicinteract__Contact__c = c1.Id;
        Database.insert(conv1);

        User u2 = new User(
            Alias = 'test2',
            MobilePhone = '9602318100',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            lastname = 'test2',
            email = 'test12@test.com',
            username = 'test124@test.screenmagic.com'
        );
        Database.insert(u2);

        conv1.Supervisor__c = u2.Id;
        Database.upsert(conv1);

        List<smagicinteract__Conversation__Share> convShareList1 = [
            SELECT Id, RowCause, UserOrGroupId, ParentId
            FROM smagicinteract__Conversation__Share
            WHERE ParentId = :conv1.Id
        ];

        system.assertEquals(2, convShareList1.size());
    }

    @isTest
    private static void testExecute() {
        smagicinteract__SMS_SenderId__c smsSender = new smagicinteract__SMS_SenderId__c();
        smsSender.SenderIdUnit__c = 'FYS';
        smsSender.smagicinteract__senderId__c = '12345';
        smsSender.smagicinteract__Used_For__c = 'Both';
        Database.insert(smsSender);

        RecordType recordTypeForContact = [
            SELECT Id, Name
            FROM RecordType
            WHERE sobjecttype = 'Contact' AND Name = 'External Mastered'
            LIMIT 1
        ];
        Contact c = new Contact();
        c.RecordTypeId = recordTypeForContact.Id;
        c.EMPLID__c = '12345';
        c.LastName = 'Test SMS';
        Database.insert(c);

        Student_Group__c studentGrp = new Student_Group__c();
        studentGrp.SG_Contact__c = c.Id;
        studentGrp.SG_Status__c = true;
        studentGrp.SG_PeopleSoft_Code__c = 'R100';
        Database.insert(studentGrp);

        Success_Coach_Mapping__c mapping = new Success_Coach_Mapping__c();
        mapping.Success_Coach__c = UserInfo.getUserId();
        mapping.PeopleSoft_Student_Group_Code__c = 'R100';
        mapping.Supervisor__c = UserInfo.getUserId();
        Database.insert(mapping);

        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'Conv 1';
        conv.smagicinteract__Contact__c = c.Id;
        conv.smagicinteract__Sender__c = smsSender.Id;
        Database.insert(conv);

        smagicinteract__Conversation__C updatedConv = [
            SELECT Id, Success_Coach__c, Supervisor__c
            FROM smagicinteract__Conversation__C
            WHERE Id = :conv.Id
        ];
        System.assertEquals(false, updatedConv.Success_Coach__c == null);
        System.assertEquals(false, updatedConv.Supervisor__c == null);
    }

    @isTest
    private static void testErrorLogging() {
        Database.SaveResult[] lsr = Database.insert(
            new List<smagicinteract__Conversation__c>{
                new smagicinteract__Conversation__c(smagicinteract__Inbound_Number__c = '123456789123456789123456789')
            },
            false
        );
        ConversationService uc = new ConversationService();
        uc.checkForErrors(lsr);

        List<smagicinteract__Error_Log__c> errorLogList = [SELECT Id FROM smagicinteract__Error_Log__c];
        System.assertEquals(1, errorLogList.size());
    }

    @isTest
    private static void testErrorLogger() {
        smagicinteract__Conversation__c conversation = new smagicinteract__Conversation__c();
        conversation.smagicinteract__Inbound_Number__c = '123456789123456789123456789';
        Database.SaveResult[] lsr = Database.insert(new List<smagicinteract__Conversation__c>{ conversation }, false);
        ConversationService service = new ConversationService();
        service.processDatabaseResults(lsr);

        conversation.smagicinteract__Inbound_Number__c = '123456789123456789123456780';
        Database.SaveResult[] lsr = Database.update(new List<smagicinteract__Conversation__c>{ conversation }, false);
        service.processDatabaseResults(lsr);

        Integer errorCaseCount = [SELECT COUNT() FROM Case];
        System.assertEquals(2, errorCaseCount);
    }
}