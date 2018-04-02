public class NavLinks {
    public NavLinks() {}
    public NavLinks(ServiceCenter controller) { }
    public NavLinks(viewCaseController controller){}
    public NavLinks(AKBController controller) { }
    public NavLinks(ViewAllCasesController controller) { }
    public NavLinks(ApexPages.StandardController controller) { }
    public NavLinks(UnsubscribeController controller) { }

    public String links { get; set; }
    public List<Link> linkList { get; set; }

    private Cookie createCookieFromURL() {
        Cookie cookieFromURL;
        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            links = ApexPages.currentPage().getParameters().get('navbar');
            links = links.replace('{"navbarLinks":','');
            if (links != null && links != '') {
                links = links.substring(0, (links.length()-1));
                cookieFromURL = new Cookie('navbarlinks',links,null,-1,false);
                return cookieFromURL;
            }
        }
        return null;
    }
    
    private Cookie getCurrentPageCookie(String cookieName) {
        Cookie currentPageCookie = ApexPages.currentPage().getCookies().get(cookieName);
        return currentPageCookie;
    }
    
    private void parseCookieJSONAndPopulateLinks(Cookie linksCookie) {
        String linksJSON = '';
        if (linksCookie != null) {
            linksJSON = linksCookie.getValue();
        
            // Clean up any HTML encoding for quotes
            linksJSON = linksJSON.replaceAll('&quot;', '"');
            linksJSON = linksJSON.replaceAll('&#34;', '"');
            
            linkList = new List<Link>();
            JSONParser parser = JSON.createParser(linksJSON);
            while (parser.nextToken() != null) {
                // If current token is a field name
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    Link thisLink = new Link();
                    String fieldName = parser.getText();
                    thisLink.name = fieldName;
                    // Move to token after the field name
                    parser.nextToken();
                    thisLink.url = parser.getText();
                    linkList.add(thisLink);
                }
            }
        }
    }
    
    public PageReference init() {
        Cookie linksCookie;
        //String linksJSON = '';
        linksCookie = createCookieFromURL();
        if (linksCookie != null) {
            ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
        } else {
            linksCookie = getCurrentPageCookie('navbarlinks');
        }
        parseCookieJSONAndPopulateLinks(linksCookie);
        return null;
    }
}