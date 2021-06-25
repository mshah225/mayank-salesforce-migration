public class FYSConversationUpdateHandler {
    public void checkForErrors(Database.SaveResult[] lsr) {
        List<smagicinteract__Error_Log__c> errorLogs = new List<smagicinteract__Error_Log__c>();
        for (Database.SaveResult sr : lsr) {
            if (!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];
                smagicinteract__Error_Log__c errorLogObj = new smagicinteract__Error_Log__c();
                errorLogObj.smagicinteract__Class_Name__c = 'FYSConversationUpdateHandler';
                errorLogObj.smagicinteract__Error_Message__c = err.getMessage();
                errorLogObj.smagicinteract__Error_Status_Code__c = String.valueOf(err.getStatusCode());
                errorLogObj.smagicinteract__Error_Type__c = 'Fatal';
                errorLogObj.smagicinteract__Object__c = 'smagicinteract__Conversation__c';
                errorLogObj.smagicinteract__Fields__c = String.valueOf(err.getFields());
                errorLogObj.smagicinteract__Line_number__c = 58;
                errorLogObj.smagicinteract__User__c = UserInfo.getUserId();
                errorLogs.add(errorLogObj);
            }
        }
        if (!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }
}
