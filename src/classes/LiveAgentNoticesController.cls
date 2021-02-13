public class LiveAgentNoticesController {
    public List<List<String>> noticeList { get; set; }
    private String buttonPressed { get; set; }

    public LiveAgentNoticesController() {
        getButtonIdFromURL();
        getNotices();
    }

    private void getButtonIdFromURL() {
        String buttonParam = ApexPages.currentPage().getURL();
        Integer indexOf = buttonParam.indexOf('button_id');
        buttonParam = buttonParam.substring(indexOf + 12, indexOf + 27);
        buttonPressed = [SELECT DeveloperName FROM LiveChatButton WHERE Id = :buttonParam LIMIT 1].DeveloperName;
    }

    private void getNotices() {
        noticeList = new List<List<String>>();
        DateTime currentTime = System.now();
        List<LiveAgent_Custom_Message__c> customMessages = [
            SELECT Custom_Message__c
            FROM LiveAgent_Custom_Message__c
            WHERE
                Start_Date_Time__c <= :currentTime
                AND End_Date_Time__c > :currentTime
                AND LiveAgent_Button__c = :buttonPressed
        ];
        for (LiveAgent_Custom_Message__c message : customMessages) {
            String messageToDisplay = message.Custom_Message__c;
            noticeList.add(messageToDisplay.split('\n'));
        }
    }
}
