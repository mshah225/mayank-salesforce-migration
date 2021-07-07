public class LiveAgentUtils {
    private static final String SEARCH_TERM = 'button_id%3D';
    private static final Integer ID_LENGTH_OFFSET = 15;

    public static String getButtonIdFromURL() {
        String buttonParam = ApexPages.currentPage().getURL();
        Integer indexOfButtonId = buttonParam.indexOf(SEARCH_TERM);
        buttonParam = buttonParam.substring(
            SEARCH_TERM.length(),
            indexOfButtonId +
            SEARCH_TERM.length() +
            ID_LENGTH_OFFSET
        );
        return [SELECT DeveloperName FROM LiveChatButton WHERE Id = :buttonParam LIMIT 1].DeveloperName;
    }

    public static String getButtonIdFromURL(String buttonParam) {
        Integer indexOfButtonId = buttonParam.indexOf(SEARCH_TERM);
        buttonParam = buttonParam.substring(
            indexOfButtonId + SEARCH_TERM.length(),
            indexOfButtonId +
            SEARCH_TERM.length() +
            ID_LENGTH_OFFSET
        );
        System.debug(buttonParam);
        return [SELECT DeveloperName FROM LiveChatButton WHERE Id = :buttonParam LIMIT 1].DeveloperName;
    }
}
