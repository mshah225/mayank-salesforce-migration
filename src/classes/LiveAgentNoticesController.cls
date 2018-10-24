public class LiveAgentNoticesController {
    public List<List<String>> noticeList {set; get;}
    private String buttonPressed {set; get;}
    private static final Integer LEFT_URL_OFFSET = 12;
    private static final Integer RIGHT_URL_OFFSET = 27;
    
    public LiveAgentNoticesController() {
        buttonPressed = LiveAgentUtils.getButtonIdFromURL();
        getNotices();
    }
    
    private void getNotices() {
        noticeList = new List<List<String>>();
        DateTime currentTime = System.now();
        List<LiveAgent_Custom_Message__c> customMessages = [SELECT Custom_Message__c 
                                                            FROM LiveAgent_Custom_Message__c 
                                                            WHERE Start_Date_Time__c <=: currentTime 
                                                            AND End_Date_Time__c >: currentTime 
                                                            AND LiveAgent_Button__c =: buttonPressed];
        for (LiveAgent_Custom_Message__c message : customMessages) {
            String messageToDisplay = message.Custom_Message__c;
            noticeList.add(messageToDisplay.split('\n'));
        }
    }
}