@isTest
public class CustomSenderServiceTest {

    @isTest
    public static void getSenderIdListTestPositive(){
        
        List<smagicinteract__Conversation__C> convList = new List<smagicinteract__Conversation__c>();
        List<Id> ids = new List<Id>();
        
        Id contRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Mastered').getRecordTypeId();
        
        Contact cont = new Contact();
        cont.RecordTypeId = contRecType;
        cont.EMPLID__c = '12345';
        cont.LastName = 'Test SMS';
        Database.insert(cont);
        
        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c();
        sender.smagicinteract__Label__c = 'Test Sender Id';
        sender.smagicinteract__senderId__c = 'TestMessage';
        sender.IsEnterpriseUser__c = true;
		Database.insert(sender);
		
        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'abcd123';
		conv.smagicinteract__Sender__c = sender.Id;
        conv.smagicinteract__Contact__c = cont.Id;
        convList.add(conv);
		Database.insert(convList);
		
        smagicinteract__Conversation_Sender_Map__c convMap = new smagicinteract__Conversation_Sender_Map__c();
        convMap.smagicinteract__Conversation__c = conv.Id;
        convMap.smagicinteract__SMS_SenderId__c = sender.Id;
        Database.insert(convMap);
        
        for(smagicinteract__Conversation__c c : convList) {
            ids.add(c.Id);
        }
        
		Callable callable = (Callable) Type.forName('','CustomSenderService').newInstance();
        Map<String,Object> parameterMap = new Map<String,Object>();
        parameterMap.put('requestContext','requestContext');
       	parameterMap.put('givenCriteria', 'DefaultCriteria');
        parameterMap.put('ids', ids);
        Object obj = callable.call('getSenderInfo',parameterMap);
        List<smagicinteract__SMS_SenderId__c> senderIdList = (List<smagicinteract__SMS_SenderId__c>) obj;        
        System.assertEquals(true, senderIdList != null);
        System.assertEquals(true, senderIdList.size() > 0);
        for(smagicinteract__SMS_SenderId__c senderId : senderIdList) {
			System.assertEquals(true, 'TestMessage'.equalsIgnoreCase(senderId.smagicinteract__senderId__c));          
        }
    }
    
    @isTest
    public static void getSenderIdListTestNegative(){
        
        User usr1 = new User();
        usr1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usr1.LastName = 'last21';
        usr1.Username = 'usr1cb78gbyu373240006bcfguy69@abc.com';
        usr1.Alias = 'usr21';
        usr1.TimeZoneSidKey = 'America/Los_Angeles';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.LanguageLocaleKey = 'en_US';
        usr1.LocaleSidKey = 'en_US';
        usr1.Email = 'usr21@abc.com';
        usr1.IsActive = true;
        insert usr1;
        
        smagicinteract__SMS_SenderId__c sender1 = new smagicinteract__SMS_SenderId__c();
        sender1.smagicinteract__Label__c = 'Test Sender Id New';
        sender1.smagicinteract__senderId__c = 'TestMessage12345';
        sender1.IsEnterpriseUser__c = true;
		Database.insert(sender1);
		
        smagicinteract__SenderId_Profile_Map__c senderProfileMap1 = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap1.smagicinteract__User__c = usr1.Id;
        senderProfileMap1.smagicinteract__SenderId_Lookup__c = sender1.Id;
        Database.insert(senderProfileMap1);
        
        
        
        User usr = new User();
        usr.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usr.LastName = 'last2';
        usr.Username = 'usr1cb78gbyu373242746bcfguy69@abc.com';
        usr.Alias = 'usr2';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';
        usr.Email = 'usr2@abc.com';
        usr.IsActive = true;
        insert usr;
        
        List<smagicinteract__smsMagic__c> messageList = new List<smagicinteract__smsMagic__c>();
        List<Id> ids = new List<Id>();
        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c();
        sender.smagicinteract__Label__c = 'Test Sender Id';
        sender.smagicinteract__senderId__c = 'TestMessage';
        sender.IsEnterpriseUser__c = true;
		Database.insert(sender);
		
        smagicinteract__SenderId_Profile_Map__c senderProfileMap = new smagicinteract__SenderId_Profile_Map__c();
        senderProfileMap.smagicinteract__User__c = usr.Id;
        senderProfileMap.smagicinteract__SenderId_Lookup__c = sender.Id;
        Database.insert(senderProfileMap);
        
        
        smagicinteract__smsMagic__c message = new smagicinteract__smsMagic__c( smagicinteract__Direction__c = 'IN',
                                                                               smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey(),
                                                                               smagicinteract__SenderId__c = 'Test',
                                                                               smagicinteract__SMSText__c = 'Test123',
                                                                               smagicinteract__Source__c = '9000',
                                                                               smagicinteract__PhoneNumber__c = '9192939495',
                                                                               smagicinteract__Unformatted_Phone_Number__c = '19192939495');
        
        messageList.add(message);
		Database.insert(messageList);

        for(smagicinteract__smsMagic__c m : messageList) {
            ids.add(m.Id);
        }
        
        System.runAs(usr) {
            Callable callable = (Callable) Type.forName('','CustomSenderService').newInstance();
            Map<String,Object> parameterMap = new Map<String,Object>();
            parameterMap.put('requestContext','requestContext');
            parameterMap.put('givenCriteria', 'DefaultCriteria');
            parameterMap.put('ids', ids);
            Object obj = callable.call('getSenderInfo',parameterMap);
            List<smagicinteract__SMS_SenderId__c> senderIdList = (List<smagicinteract__SMS_SenderId__c>) obj;
            System.debug('@@-- senderIdList : '+ senderIdList);        
            System.assertEquals(true, senderIdList.size() > 0);
            for(smagicinteract__SMS_SenderId__c senderId : senderIdList) {
                System.debug('@@senderId : '+ senderId);
                System.assertEquals(true, 'TestMessage'.equalsIgnoreCase(senderId.smagicinteract__senderId__c));          
            }
        }
        
    }   
}