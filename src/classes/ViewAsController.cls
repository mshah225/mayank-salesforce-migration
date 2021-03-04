public with sharing class ViewAsController {
    private transient Map<String, Cookie> cookieMap; // Stores the web page cookies
    private transient Cookie viewAsCookie; // Stores the cookie containing the vieweing user id

    /*
     * Cannot define getter of transient property
     *
     * <p>
     * Gets the pages current cookies
     * </p>
     */
    private Map<String, Cookie> getCookieMap() {
        cookieMap = ApexPages.currentPage().getCookies();

        return cookieMap;
    }

    /*
     * Keeps track of the view as id(user selected in view as component).
     *
     * <p>
     * Setter creates a cookie to store user id. Cookie
     * expires after each session.
     * </p>
     */
    public String viewAsId {
        get;
        set {
            viewAsId = value;
            viewAsCookie = new Cookie('viewAsId', viewAsId, null, -1, false); // setting max age to -1 creates a session cookie
            getCookieMap().put('viewAsId', viewAsCookie);
            ApexPages.currentPage().setCookies(cookieMap.values());
        }
    }

    /*
     * Contains list owner ids selected by user in viewas component search box
     */
    public String viewAsIdListString { get; set; }

    /*
     * Initialize component with current user's Id
     */
    public ViewAsController() {
        if (getCookieMap() != null) {
            if (cookieMap.containsKey('viewAsId')) {
                viewAsId = cookieMap.get('viewAsId').getValue();
            }
        }

        if (viewAsId == null || viewAsId == '') {
            viewAsId = UserInfo.getUserId();
        }
    }
}
