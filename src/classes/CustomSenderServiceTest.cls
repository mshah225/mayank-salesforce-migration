@isTest
public class CustomSenderServiceTest {
    @isTest
    public static void getContactSenderListTest() {
        List<Contact> conList = new List<Contact>();
        List<Id> ids = new List<Id>();
        Id contRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName()
            .get('External Mastered')
            .getRecordTypeId();
        //Creating Contact record
        Contact cont = new Contact();
        cont.RecordTypeId = contRecType;
        cont.EMPLID__c = '12345';
        cont.LastName = 'Test SMS';
        conList.add(cont);
        Database.insert(conList);
        //Adding contact record in the id list which will be passed to Invocable Method
        for (contact c : conList) {
            ids.add(c.Id);
        }
        //Creating active group
        Student_Group__c testGroup = new Student_Group__c();
        testGroup.SG_PeopleSoft_Code__c = 'NONPROD';
        testGroup.SG_Contact__c = cont.id;
        testGroup.SG_Status__c = true;
        Database.insert(testGroup);
        //Creating Success Coach and Supervisor
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User successCoach = createUser(
            ProfileId,
            'successCoach',
            'successCoach3242746bcfguy69@abc.com',
            'us1z',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'successCoach@abc.com',
            true
        );

        User superVisor = createUser(
            ProfileId,
            'superVisor',
            'superVisor2746bcfguy69@abc.com',
            'us2z',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'superVisor@abc.com',
            true
        );

        User testAdmin = createUser(
            ProfileId,
            'testAdmin1',
            'testAdminbyu373242746bcfguy69@abc.com',
            'q1m90',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'testAdminInvalid@abc.com',
            true
        );

        List<User> userList = new List<User>();
        userList.add(successCoach);
        userList.add(superVisor);
        userList.add(testAdmin);
        Database.insert(userList);

        //Creating Sender Id
        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c();
        sender.smagicinteract__Label__c = 'Test Sender Id';
        sender.smagicinteract__senderId__c = 'TestSenderId';
        sender.SenderIdUnit__c = 'FYS';
        Database.insert(sender);
        //Creating Sender Profile Map Record
        smagicinteract__SenderId_Profile_Map__c senderProfileMap = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap.smagicinteract__User__c = successCoach.Id;
        senderProfileMap.smagicinteract__SenderId_Lookup__c = sender.Id;
        Database.insert(senderProfileMap);
        //Creating Success Coach Mapping Record
        Success_Coach_Mapping__c testRec = new Success_Coach_Mapping__c();
        testRec.Success_Coach__c = successCoach.id;
        testRec.Supervisor__c = superVisor.id;
        testRec.PeopleSoft_Student_Group_Code__c = 'NONPROD';
        Database.insert(testRec);

        System.runAs(testAdmin) {
            //Preparing to call 'CustomSenderService' Class
            Callable callable = (Callable) Type.forName('', 'CustomSenderService').newInstance();
            Map<String, Object> parameterMap = new Map<String, Object>();
            parameterMap.put('requestContext', 'requestContext');
            parameterMap.put('givenCriteria', 'DefaultCriteria');
            parameterMap.put('ids', ids);
            System.debug('@@@@@ Calling CustomSenderService');
            Test.startTest();
            Object obj = callable.call('getSenderInfo', parameterMap);
            Test.stopTest();
            List<smagicinteract__SMS_SenderId__c> senderIdList = (List<smagicinteract__SMS_SenderId__c>) obj;
            System.assertEquals(true, senderIdList.size() > 0);
            for (smagicinteract__SMS_SenderId__c senderId : senderIdList) {
                System.assertEquals(true, 'TestSenderId'.equalsIgnoreCase(senderId.smagicinteract__senderId__c));
            }
        }
    }

    @isTest
    public static void getContactSenderList2Test() {
        List<Contact> conList = new List<Contact>();
        List<Id> ids = new List<Id>();
        Id contRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName()
            .get('External Mastered')
            .getRecordTypeId();
        //Creating Contact record
        Contact cont = new Contact();
        cont.RecordTypeId = contRecType;
        cont.EMPLID__c = '12345';
        cont.LastName = 'Test SMS';
        conList.add(cont);
        Database.insert(conList);
        //Adding contact record in the id list which will be passed to Invocable Method
        for (contact c : conList) {
            ids.add(c.Id);
        }
        //Creating active group
        Student_Group__c testGroup = new Student_Group__c();
        testGroup.SG_PeopleSoft_Code__c = 'NONPROD';
        testGroup.SG_Contact__c = cont.id;
        testGroup.SG_Status__c = true;
        Database.insert(testGroup);
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        //Creating Success Coach and Supervisor
        User successCoach = createUser(
            ProfileId,
            'successCoach',
            'successCoach3242746bcfguy69@abc.com',
            'us1z',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'successCoach@abc.com',
            true
        );

        User superVisor = createUser(
            ProfileId,
            'superVisor',
            'superVisor2746bcfguy69@abc.com',
            'us2z',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'superVisor@abc.com',
            true
        );

        User testAdmin = createUser(
            ProfileId,
            'testAdmin1',
            'testAdminbyu373242746bcfguy69@abc.com',
            'q1m90',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'testAdminInvalid@abc.com',
            true
        );

        List<User> userList = new List<User>();
        userList.add(successCoach);
        userList.add(superVisor);
        userList.add(testAdmin);

        Database.insert(userList);
        //Creating Sender Id
        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c();
        sender.smagicinteract__Label__c = 'Test Sender Id';
        sender.smagicinteract__senderId__c = 'TestSenderId';
        sender.SenderIdUnit__c = 'FYS';
        Database.insert(sender);
        //Creating Sender Profile Map Record
        smagicinteract__SenderId_Profile_Map__c senderProfileMap = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap.smagicinteract__User__c = successCoach.Id;
        senderProfileMap.smagicinteract__SenderId_Lookup__c = sender.Id;
        Database.insert(senderProfileMap);
        //Creating Success Coach Mapping Record
        Success_Coach_Mapping__c testRec = new Success_Coach_Mapping__c();
        testRec.Success_Coach__c = successCoach.id;
        testRec.Supervisor__c = superVisor.id;
        testRec.PeopleSoft_Student_Group_Code__c = 'NONPROD';
        Database.insert(testRec);

        //Creating Sender Id for testAdmin
        smagicinteract__SMS_SenderId__c senderId2 = new smagicinteract__SMS_SenderId__c();
        senderId2.smagicinteract__Label__c = 'Test Admin Id';
        senderId2.smagicinteract__senderId__c = 'AdminSenderId';
        senderId2.SenderIdUnit__c = 'FYS';
        Database.insert(senderId2);
        //Creating Sender Profile Map Record
        smagicinteract__SenderId_Profile_Map__c senderProfileMap2 = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap2.smagicinteract__User__c = testAdmin.Id;
        senderProfileMap2.smagicinteract__SenderId_Lookup__c = senderId2.Id;
        Database.insert(senderProfileMap2);
        System.runAs(testAdmin) {
            //Preparing to call 'CustomSenderService' Class
            Callable callable = (Callable) Type.forName('', 'CustomSenderService').newInstance();
            Map<String, Object> parameterMap = new Map<String, Object>();
            parameterMap.put('requestContext', 'requestContext');
            parameterMap.put('givenCriteria', 'DefaultCriteria');
            parameterMap.put('ids', ids);
            System.debug('@@@@@ Calling CustomSenderService');
            Test.startTest();
            Object obj = callable.call('getSenderInfo', parameterMap);
            Test.stopTest();
            List<smagicinteract__SMS_SenderId__c> senderIdList = (List<smagicinteract__SMS_SenderId__c>) obj;
            System.assertEquals(true, senderIdList.size() > 0);
            for (smagicinteract__SMS_SenderId__c senderId : senderIdList) {
                System.assertEquals(true, 'AdminSenderId'.equalsIgnoreCase(senderId.smagicinteract__senderId__c));
            }
        }
    }

    @isTest
    public static void getSenderIdListTestPositive() {
        List<smagicinteract__Conversation__C> convList = new List<smagicinteract__Conversation__c>();
        List<Id> ids = new List<Id>();

        Id contRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName()
            .get('External Mastered')
            .getRecordTypeId();

        Contact cont = new Contact();
        cont.RecordTypeId = contRecType;
        cont.EMPLID__c = '12345';
        cont.LastName = 'Test SMS';
        Database.insert(cont);

        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c();
        sender.smagicinteract__Label__c = 'Test Sender Id';
        sender.smagicinteract__senderId__c = 'TestMessage';
        sender.SenderIdUnit__c = 'FYS';
        Database.insert(sender);

        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'abcd123';
        conv.smagicinteract__Sender__c = sender.Id;
        conv.smagicinteract__Contact__c = cont.Id;
        convList.add(conv);
        Database.insert(convList);

        for (smagicinteract__Conversation__c c : convList) {
            ids.add(c.Id);
        }

        Callable callable = (Callable) Type.forName('', 'CustomSenderService').newInstance();
        Map<String, Object> parameterMap = new Map<String, Object>();
        parameterMap.put('requestContext', 'requestContext');
        parameterMap.put('givenCriteria', 'DefaultCriteria');
        parameterMap.put('ids', ids);
        Object obj = callable.call('getSenderInfo', parameterMap);
        List<smagicinteract__SMS_SenderId__c> senderIdList = (List<smagicinteract__SMS_SenderId__c>) obj;
        System.assertEquals(true, senderIdList != null);
        System.assertEquals(true, senderIdList.size() > 0);
        for (smagicinteract__SMS_SenderId__c senderId : senderIdList) {
            System.assertEquals(true, 'TestMessage'.equalsIgnoreCase(senderId.smagicinteract__senderId__c));
        }
    }

    @isTest
    public static void getSenderIdListTestNegative() {
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User usr1 = createUser(
            ProfileId,
            'last21',
            'usr1cb78gbyu373240006bcfguy69@abc.com',
            'usr21',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'usr21@abc.com',
            true
        );
        insert usr1;

        smagicinteract__SMS_SenderId__c sender1 = new smagicinteract__SMS_SenderId__c();
        sender1.smagicinteract__Label__c = 'Test Sender Id New';
        sender1.smagicinteract__senderId__c = 'TestMessage12345';
        sender1.SenderIdUnit__c = 'FYS';
        Database.insert(sender1);

        smagicinteract__SenderId_Profile_Map__c senderProfileMap1 = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap1.smagicinteract__User__c = usr1.Id;
        senderProfileMap1.smagicinteract__SenderId_Lookup__c = sender1.Id;
        Database.insert(senderProfileMap1);

        User usr = createUser(
            ProfileId,
            'last2',
            'usr1cb78gbyu373242746bcfguy69@abc.com',
            'usr2',
            'America/Los_Angeles',
            'UTF-8',
            'en_US',
            'en_US',
            'usr2@abc.com',
            true
        );
        insert usr;

        List<smagicinteract__smsMagic__c> messageList = new List<smagicinteract__smsMagic__c>();
        List<Id> ids = new List<Id>();
        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c();
        sender.smagicinteract__Label__c = 'Test Sender Id';
        sender.smagicinteract__senderId__c = 'TestMessage';
        sender.SenderIdUnit__c = 'FYS';
        Database.insert(sender);

        smagicinteract__SenderId_Profile_Map__c senderProfileMap = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap.smagicinteract__User__c = usr.Id;
        senderProfileMap.smagicinteract__SenderId_Lookup__c = sender.Id;
        Database.insert(senderProfileMap);

        smagicinteract__smsMagic__c message = new smagicinteract__smsMagic__c(
            smagicinteract__Direction__c = 'IN',
            smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey(),
            smagicinteract__SenderId__c = 'Test',
            smagicinteract__SMSText__c = 'Test123',
            smagicinteract__Source__c = '9000',
            smagicinteract__PhoneNumber__c = '9192939495',
            smagicinteract__Unformatted_Phone_Number__c = '19192939495'
        );

        messageList.add(message);
        Database.insert(messageList);

        for (smagicinteract__smsMagic__c m : messageList) {
            ids.add(m.Id);
        }

        System.runAs(usr) {
            Callable callable = (Callable) Type.forName('', 'CustomSenderService').newInstance();
            Map<String, Object> parameterMap = new Map<String, Object>();
            parameterMap.put('requestContext', 'requestContext');
            parameterMap.put('givenCriteria', 'DefaultCriteria');
            parameterMap.put('ids', ids);
            Object obj = callable.call('getSenderInfo', parameterMap);
            List<smagicinteract__SMS_SenderId__c> senderIdList = (List<smagicinteract__SMS_SenderId__c>) obj;
            System.debug('@@-- senderIdList : ' + senderIdList);
            System.assertEquals(true, senderIdList.size() > 0);
            for (smagicinteract__SMS_SenderId__c senderId : senderIdList) {
                System.debug('@@senderId : ' + senderId);
                System.assertEquals(true, 'TestMessage'.equalsIgnoreCase(senderId.smagicinteract__senderId__c));
            }
        }

    }
    private static user createUser(
        Id profileId,
        String lastName,
        String userName,
        String alias,
        String timezoneKey,
        String emailEncoding,
        String langLocalKey,
        String localeKey,
        String email,
        Boolean isActive
    ) {
        User newuser = new user();
        newuser.ProfileId = profileId;
        newuser.LastName = lastName;
        newuser.Username = userName;
        newuser.Alias = alias;
        newuser.TimeZoneSidKey = timezoneKey;
        newuser.EmailEncodingKey = emailEncoding;
        newuser.LanguageLocaleKey = langLocalKey;
        newuser.LocaleSidKey = localeKey;
        newuser.Email = email;
        newuser.IsActive = isActive;
        return newuser;
    }
}
