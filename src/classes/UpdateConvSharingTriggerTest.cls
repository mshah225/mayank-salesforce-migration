@isTest
public class UpdateConvSharingTriggerTest {
    @isTest
    public static void updateSharingTest() {
        //Test for change in Success Coach
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

        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'Conversation 1';
        conv.smagicinteract__Contact__c = c.Id;
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
    public static void testErrorLogging() {
        Database.SaveResult[] lsr = Database.insert(
            new List<smagicinteract__Conversation__c>{ new smagicinteract__Conversation__c() },
            false
        );
        UpdateConvSharingTriggerHandler uc = new UpdateConvSharingTriggerHandler();
        uc.checkForErrors(lsr);

        List<smagicinteract__Error_Log__c> errorLogList = [SELECT Id FROM smagicinteract__Error_Log__c];
        //System.assertEquals(1, errorLogList.size());
    }
}
