public class NavLinks {
    
    public Navlinks(Object controller) {}
    public List<Link> linkList { get; set; }

    private Cookie createCookieFromURL() {
        Cookie cookieFromURL;
        String links;
        String nullPath = null;
        Integer sessionCookie = -1;
        Boolean insecureCookie = false;
        links = ApexPages.currentPage().getParameters().get('navbar');
        cookieFromURL = new Cookie('navbarlinks',links,nullPath,sessionCookie,insecureCookie);
        return cookieFromURL;
    }
    
    private Cookie getCurrentPageCookie(String cookieName) {
        Cookie currentPageCookie = ApexPages.currentPage().getCookies().get(cookieName);
        return currentPageCookie;
    }
    
    private String getCookieValue(Cookie linksCookie) {
        String cookieValue;
        if (linksCookie != null) {
            cookieValue = linksCookie.getValue();
        }
        return cookieValue;
    }
    
    private String cleanUpHtmlEncoding(String value) {
        if (!String.isEmpty(value)) {
            value.replaceAll('&quot;','"');
            value.replaceAll('&#34;','"');
        }
        return value;
    }
    
    private void parseCookieJSONAndPopulateLinks(Cookie linksCookie) {
        String linksJSON;
        Map<String, Object> jsonCookieValue;
        Map<String, Object> linkNameAndURL;
        List<Object> linkObjectsFromJSON = new List<Object>();
        
        linksJSON = getCookieValue(linksCookie);
        // Clean up any HTML encoding for quotes
        linksJSON = cleanUpHtmlEncoding(linksJSON);
        
        try {
            jsonCookieValue = (Map<String, Object>) JSON.deserializeUntyped(linksJSON);
            linkObjectsFromJSON = (List<Object>) jsonCookieValue.get('navbarLinks');
            linkList = new List<Link>();
        } catch (NullPointerException ex) {
            List<String> errorVars = new List<String>();
            errorVars.add(ErrorLogger.convertStringToJSON('Cookie Value', linksJSON));
            errorVars.add(ErrorLogger.convertStringToJSON('Null Pointer Exception Message', ex.getMessage()));
            ErrorLogger.log(ex, errorVars, false);    
        } catch (JSONException ex) {
            List<String> errorVars = new List<String>();
            errorVars.add(ErrorLogger.convertStringToJSON('Cookie Value', linksJSON));
            errorVars.add(ErrorLogger.convertStringToJSON('JSON Exception Message', ex.getMessage()));
            ErrorLogger.log(ex, errorVars, false);    
        } catch (TypeException ex) {
            List<String> errorVars = new List<String>();
            errorVars.add(ErrorLogger.convertStringToJSON('Cookie Value', linksJSON));
            errorVars.add(ErrorLogger.convertStringToJSON('Type Exception Message', ex.getMessage()));
            ErrorLogger.log(ex, errorVars, false);    
        }
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
    
    public PageReference init() {
        Cookie linksCookie;
        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            linksCookie = createCookieFromURL();
            ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
        } else {
            linksCookie = getCurrentPageCookie('navbarlinks');
        }
        parseCookieJSONAndPopulateLinks(linksCookie);
        return null;
    }
}