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

    public PageReference init() {
        Cookie linksCookie;
        String linksJSON = '';
    
        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            links = ApexPages.currentPage().getParameters().get('navbar');
            links = links.replace('{"navbarLinks":','');
            if (links != null && links != '') {
                links = links.substring(0, (links.length()-1));
                // Write the cookie
                linksCookie = new Cookie('navbarlinks',links,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
            }
        } else {
            linksCookie = ApexPages.currentPage().getCookies().get('navbarlinks');
        }

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
        return null;
    }
}