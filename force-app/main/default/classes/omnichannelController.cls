public class omnichannelController {
    public static String outOfOfficeMessage { get; set; }
    public static Boolean loggedInStatus { get; set; }

    @auraEnabled
    public static boolean updateOmniChannelInfo() {
        try {
            string userId = UserInfo.getUserId();

            User user = [SELECT omniChannel_loggedIn__c, Out_Of_Office_Message__c FROM user WHERE id = :userId];
            user.omniChannel_loggedIn__c = false;
            user.Out_Of_Office_Message__c = outOfOfficeMessage;

            Database.UpsertResult result = Database.upsert(user);
            return result.isSuccess();
        } catch (Exception e) {
            AuraHandledException auraExcep = new AuraHandledException(e.getMessage());
            auraExcep.setMessage(e.getMessage());
            throw auraExcep;
        }
    }
}
