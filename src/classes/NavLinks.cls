public class NavLinks {
    public NavLinks() {}
    public Navlinks(Object controller) {}
    public List<Link> linkList { get; set; }
    
    private static Cookie linksCookie;
    
    public PageReference init() {
        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            linksCookie = createCookieFromURL();
            ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
        } else if (ApexPages.currentPage().getCookies().get('navbarlinks') != null) {
            linksCookie = getNavBarCookie();
        } else {
            return null;
        }
        
        parseCookieJsonAndPopulateLinks();
        return null;
    }
    
    private Cookie createCookieFromURL() {
        Cookie cookieFromURL;
        String nullPath = null;
        Integer sessionCookieTimeount = -1;
        Boolean isInsecureCookie = false;
        String links = ApexPages.currentPage().getParameters().get('navbar');
        cookieFromURL = new Cookie('navbarlinks', links, nullPath, sessionCookieTimeount, isInsecureCookie);
        return cookieFromURL;
    }
    
    private Cookie getNavBarCookie() {
        Cookie currentPageCookie = ApexPages.currentPage().getCookies().get('navbarlinks');
        return currentPageCookie;
    }
    
    private void parseCookieJsonAndPopulateLinks() {
        List<Object> linkObjectsFromParsedJson = new List<Object>();
        String linksJson;
        if (linksCookie == null) {
            linkList = new List<Link>();
            return;
        }
        
        linksJson = linksCookie.getValue();
        linksJson = cleanUpHtmlEncoding(linksJson);
        try {
            linkObjectsFromParsedJson = parseCookieJson(linksJson);
            linkList = new List<Link>();
        } catch (Exception ex) {
            List<String> errorVars = new List<String>();
            errorVars.add(ErrorLogger.convertStringToJson('JSON Value', linksJson));
            errorVars.add(ErrorLogger.convertStringToJson('Exception Message', ex.getMessage()));
            ErrorLogger.log(ex, errorVars, false);    
        }
        populateLinks(linkObjectsFromParsedJson);
    }
    
    private String cleanUpHtmlEncoding(String value) {
        if (!String.isEmpty(value)) {
            value.replaceAll('&quot;','"');
            value.replaceAll('&#34;','"');
        }
        return value;
    }
    
    private List<Object> parseCookieJson(String linksJson) {
        Map<String, Object> jsonCookieValue;
        List<Object> linkObjectsFromJson = new List<Object>();
        jsonCookieValue = (Map<String, Object>) Json.deserializeUntyped(linksJson);
        linkObjectsFromJson = (List<Object>) jsonCookieValue.get('navbarLinks');
        return linkObjectsFromJson;
    }
    
    public void populateLinks(List<Object> linkObjectsFromJson) {
        Map<String, Object> linkNameAndURL;
        for (Object linkObj: linkObjectsFromJson) {
            linkNameAndURL = (Map<String, Object>) linkObj;
            for (String linkName: linkNameAndURL.keySet()) {
                Link thisLink = new Link();
                thisLink.name = linkName;
                thisLink.url = (String) linkNameAndURL.get(linkName);
                linkList.add(thisLink);
            }
        }
    }
}
