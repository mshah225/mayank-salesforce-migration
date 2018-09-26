public class LiveAgentUtils {
    private static final Integer LEFT_URL_OFFSET = 12;
    private static final Integer RIGHT_URL_OFFSET = 27;
    
    public static void getButtonIdFromURL() {
        String buttonParam = ApexPages.currentPage().getURL();
        Integer indexOfButtonId = buttonParam.indexOf('button_id');
        buttonParam = buttonParam.substring(indexOfButtonId + LEFT_URL_OFFSET, indexOfButtonId + RIGHT_URL_OFFSET);
        return [SELECT DeveloperName FROM LiveChatButton WHERE Id =: buttonParam LIMIT 1].DeveloperName;
    }
    
}