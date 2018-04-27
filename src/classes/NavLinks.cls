public class NavLinks {
    
    public NavLinks() {}
    public Navlinks(Object controller) {}
    public List<Link> linkList { get; set; }
    private static Cookie linksCookie;
     public PageReference init() {
        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            linksCookie = createCookieFromURL();
            ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
        } else {
            linksCookie = getNavBarCookie();
        }
        parseCookieJSONAndPopulateLinks();
        return null;
    }
    
    private Cookie createCookieFromURL() {
        Cookie cookieFromURL;
        String links;
        String nullPath = null;
        Integer sessionCookie = -1;
        Boolean insecureCookie = false;
        links = ApexPages.currentPage().getParameters().get('navbar');
        cookieFromURL = new Cookie('navbarlinks', links, nullPath, sessionCookie, insecureCookie);
        return cookieFromURL;
    }
    
    private Cookie getNavBarCookie() {
        Cookie currentPageCookie = ApexPages.currentPage().getCookies().get('navbarlinks');
        return currentPageCookie;
    }
    
    private void parseCookieJSONAndPopulateLinks() {
        List<Object> linkObjectsFromParsedJSON = new List<Object>();
        String linksJSON;
        if (linksCookie != null) {
            linksJSON = linksCookie.getValue();
            linksJSON = cleanUpHtmlEncoding(linksJSON);
        }
        try {
            linkObjectsFromParsedJSON = parseCookieJSON(linksJSON);
            linkList = new List<Link>();
        } catch (Exception ex) {
            List<String> errorVars = new List<String>();
            errorVars.add(ErrorLogger.convertStringToJSON('Cookie Value', linksJSON));
            errorVars.add(ErrorLogger.convertStringToJSON('Null Pointer Exception Message', ex.getMessage()));
            ErrorLogger.log(ex, errorVars, false);    
        }
        populateLinks(linkObjectsFromParsedJSON);
    }
    
    private List<Object> parseCookieJSON(String linksJSON) {
        Map<String, Object> jsonCookieValue;
        List<Object> linkObjectsFromJSON = new List<Object>();
        jsonCookieValue = (Map<String, Object>) JSON.deserializeUntyped(linksJSON);
        linkObjectsFromJSON = (List<Object>) jsonCookieValue.get('navbarLinks');
        return linkObjectsFromJSON;
    }
    
    public void populateLinks(List<Object> linkObjectsFromJSON) {
        Map<String, Object> linkNameAndURL;
        for (Object linkObj: linkObjectsFromJSON) {
            linkNameAndURL = (Map<String, Object>) linkObj;
            for (String linkName: linkNameAndURL.keySet()) {
                Link thisLink = new Link();
                thisLink.name = linkName;
                thisLink.url = (String) linkNameAndURL.get(linkName);
                linkList.add(thisLink);
            }
        }
    }
    
    private String cleanUpHtmlEncoding(String value) {
        if (!String.isEmpty(value)) {
            value.replaceAll('&quot;','"');
            value.replaceAll('&#34;','"');
        }
        return value;
    }
    
    
    
   
}