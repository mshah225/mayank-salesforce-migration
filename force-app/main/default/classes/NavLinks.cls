public class NavLinks {
    public NavLinks() {
    }
    public NavLinks(FamilyPortalController controller) {
    }
    public NavLinks(ServiceCenter controller) {
    }
    public NavLinks(viewCaseController controller) {
    }
    public NavLinks(AKBController controller) {
    }
    public NavLinks(ViewAllCasesController controller) {
    }
    public NavLinks(ApexPages.StandardController controller) {
    }
    public NavLinks(UnsubscribeController controller) {
    }

    public String links { get; set; }
    public List<Link> linkList { get; set; }

    public PageReference init() {
        Cookie linksCookie;
        String linksJSON = '';
        String asuriteIdParm = '';
        String timeParm = '';
        String signatureParm = '';

        System.debug('parms: ' + ApexPages.currentPage().getParameters());

        if (ApexPages.currentPage().getParameters().get('asuriteId') != null) {
            asuriteIdParm = ApexPages.currentPage().getParameters().get('asuriteId');
        }

        if (ApexPages.currentPage().getParameters().get('time') != null) {
            timeParm = ApexPages.currentPage().getParameters().get('time');
        }

        if (ApexPages.currentPage().getParameters().get('signature') != null) {
            signatureParm = ApexPages.currentPage().getParameters().get('signature');
        }

        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            links = ApexPages.currentPage().getParameters().get('navbar');
            System.debug('links: ' + links);
            links = links.replace('{"navbarLinks":', '');
            links = links.substring(0, (links.length() - 1));

            // Write the cookie
            if (links != null && links != '') {
                linksCookie = new Cookie('navbarlinks', links, null, -1, false);
                ApexPages.currentPage().setCookies(new List<Cookie>{ linksCookie });
            }
        } else {
            linksCookie = ApexPages.currentPage().getCookies().get('navbarlinks');
        }

        if (linksCookie != null) {
            linksJSON = linksCookie.getValue();
            System.debug('Cookie value: ' + linksJSON);
            // Clean up any HTML encoding for quotes
            linksJSON = linksJSON.replaceAll('&quot;', '"');
            linksJSON = linksJSON.replaceAll('&#34;', '"');
            System.debug(linksJSON);

            linkList = new List<Link>();
            JSONParser parser = JSON.createParser(linksJSON);
            while (parser.nextToken() != null) {
                // If current token is a field name
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    Link thisLink = new Link();
                    String fieldName = parser.getText();
                    thisLink.name = fieldName;
                    System.debug('merf thisLinks name: ' + thisLink.name);
                    // Move to token after the field name
                    parser.nextToken();
                    thisLink.url = parser.getText();
                    linkList.add(thisLink);
                }
            }
        }

        System.debug('asuriteId: ' + asuriteIdParm);
        System.debug('time: ' + timeParm);
        System.debug('signature: ' + signatureParm);
        System.debug('linkList: ' + linkList);

        return null;
    }
}
