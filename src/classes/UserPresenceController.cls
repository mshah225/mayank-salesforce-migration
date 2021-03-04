public class UserPresenceController {
    @TestVisible
    public boolean ooo { get; set; }
    @TestVisible
    public String oooMessage { get; set; }

    public UserPresenceController() {
        User currentUser = [
            SELECT id, omniChannel_loggedIn__c, Out_Of_Office_Message__c
            FROM user
            WHERE id = :UserInfo.getUserId()
        ];
        ooo = currentUser.omniChannel_loggedIn__c;
        oooMessage = currentUser.Out_Of_Office_Message__c;
    }

    public PageReference saveOOOM() {
        User userRec = new User(id = UserInfo.getUserId());
        userRec.omniChannel_loggedIn__c = ooo != null ? ooo : false;
        userRec.Out_Of_Office_Message__c = String.isBlank(oooMessage) ? null : oooMessage;
        update userRec;

        String state = ooo && ooo != null ? 'Disabled' : 'Enabled';

        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.severity.INFO,
                'Out of Office configuration saved successfully.<br/>Out of office is ' +
                state +
                '.<br/>Out of office message is \'' +
                oooMessage +
                '\''
            )
        );
        return null;
    }
}
