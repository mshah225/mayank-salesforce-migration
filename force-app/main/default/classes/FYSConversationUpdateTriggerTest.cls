@isTest
public class FYSConversationUpdateTriggerTest {
    @isTest
    public static void testErrorLogging() {
        Database.SaveResult[] lsr = Database.insert(
            new List<smagicinteract__Conversation__c>{
                new smagicinteract__Conversation__c(smagicinteract__Inbound_Number__c = '123456789123456789123456789')
            },
            false
        );
        FYSConversationUpdateHandler uc = new FYSConversationUpdateHandler();
        uc.checkForErrors(lsr);

        List<smagicinteract__Error_Log__c> errorLogList = [SELECT Id FROM smagicinteract__Error_Log__c];
        System.assertEquals(1, errorLogList.size());
    }
}
