@isTest
private class ConversationDispatcherTest {
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

    /*@isTest
    private static void testMethod2() {
        ConversationDispatcher dispatcher = new ConversationDispatcher(null, null, null, null);
        dispatcher.beforeUpdate();
        dispatcher.beforeDelete();
        dispatcher.beforeInsert();
        dispatcher.afterInsert();
        dispatcher.afterDelete();
        dispatcher.afterUndelete();
    }*/
}
