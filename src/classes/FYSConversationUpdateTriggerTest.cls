@isTest
public class FYSConversationUpdateTriggerTest {

    @isTest
    public static void testExecute() {
		
        smagicinteract__SMS_SenderId__c smsSender = new smagicinteract__SMS_SenderId__c();
        smsSender.IsEnterpriseUser__c = true;
        smsSender.smagicinteract__senderId__c = '12345';
        smsSender.smagicinteract__Used_For__c = 'Both';
        Database.insert(smsSender);
        
        RecordType recordTypeForContact = [select Id, Name 
                                           from RecordType 
                                           where sobjecttype = 'Contact' 
                                           and Name = 'External Mastered'
                                           Limit 1];
        Contact c = new Contact();
        c.RecordTypeId = recordTypeForContact.Id;
        c.EMPLID__c = '12345';
        c.LastName = 'Test SMS';
        Database.insert(c);
        
        smagicinteract__Conversation__c conv = new smagicinteract__Conversation__c();
        conv.Name = 'Conv 1';
        conv.smagicinteract__Contact__c = c.Id;
        Database.insert(conv);
        
        Student_Group__c  studentGrp = new Student_Group__c ();
        studentGrp.SG_Contact__c = c.Id;
        studentGrp.SG_Status__c = true;
        studentGrp.SG_PeopleSoft_Code__c = 'R100';
        Database.insert(studentGrp);
        
        Success_Coach_Mapping__c mapping = new Success_Coach_Mapping__c ();
        mapping.Success_Coach__c = UserInfo.getUserId();
        mapping.PeopleSoft_Student_Group_Code__c = 'R100';
        mapping.Supervisor__c = UserInfo.getUserId();
        Database.insert(mapping);
        
        smagicinteract__Conversation_Sender_Map__c convSender = new smagicinteract__Conversation_Sender_Map__c();
        convSender.smagicinteract__Conversation__c = conv.Id;
        convSender.smagicinteract__SMS_SenderId__c = smsSender.Id;
        Database.insert(convSender);
        
        smagicinteract__Conversation__C updatedConv = [select Id, Success_Coach__c, Supervisor__c from smagicinteract__Conversation__C where Id = :conv.Id];
        System.assertEquals(false, updatedConv.Success_Coach__c == null);
        System.assertEquals(false, updatedConv.Supervisor__c == null);           
    }
    
    @isTest
    public static void testErrorLogging() {
        Database.SaveResult[] lsr = Database.insert(new List<smagicinteract__Conversation__c>{new smagicinteract__Conversation__c(smagicinteract__Inbound_Number__c ='123456789123456789123456789')}, false);
        FYSConversationUpdateHandler uc = new FYSConversationUpdateHandler();
        uc.checkForErrors(lsr);
        
        List<smagicinteract__Error_Log__c> errorLogList = [select Id from smagicinteract__Error_Log__c];
        System.assertEquals(1, errorLogList.size());
        
        
    }
}
