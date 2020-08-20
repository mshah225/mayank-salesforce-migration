public class ASUBrandMenuController {
    public String links { get; set; }
    public List<Link> menuLinks { get; set; }

    public ASUBrandMenuController() {
    }
    public ASUBrandMenuController(ApexPages.StandardController controller) {
    }
    public ASUBrandMenuController(AKBController controller) {
    }
    public ASUBrandMenuController(MyASUHelpFAQController controller) {
    }
    public ASUBrandMenuController(UnsubscribeController controller) {
    }
    public ASUBrandMenuController(ViewCaseController controller) {
    }
    public ASUBrandMenuController(ViewAllCasesController controller) {
    }

    public PageReference init() {
        Cookie linksCookie;
        String linksJSON = '';
        String asuriteIdParm = '';
        String timeParm = '';
        String signatureParm = '';

        System.debug('params: ' + ApexPages.currentPage().getParameters());

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

            menuLinks = new List<Link>();
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
                    menuLinks.add(thisLink);
                }
            }
        }

        if (menuLinks == null) {
            menuLinks.add(new Link(name = '', url = '/myasu'));
            menuLinks.add(new Link(name = 'Finances', url = '/myasu/student/finances'));
            menuLinks.add(new Link(name = 'Campus Services', url = '/myasu/student/campusservices'));
            menuLinks.add(new Link(name = 'Profile', url = '/myasu/student/profile'));
            menuLinks.add(new Link(name = 'Help', url = '/'));
        }

        System.debug('asuriteId: ' + asuriteIdParm);
        System.debug('time: ' + timeParm);
        System.debug('signature: ' + signatureParm);
        System.debug('menuLinks: ' + menuLinks);

        return null;
    }
}
