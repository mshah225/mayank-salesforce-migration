public class ASUBrandHeaderController {
    public String links { get; set; }
    public List<Link> menuLinks { get; set; }
    public Boolean isLoggedInUser;

    public ASUBrandHeaderController() {
        setUserStatus();
    }
    public ASUBrandHeaderController(ApexPages.StandardController controller) {
        setUserStatus();
    }
    public ASUBrandHeaderController(AKBController controller) {
        setUserStatus();
    }
    public ASUBrandHeaderController(MyASUHelpController controller) {
        setUserStatus();
    }
    public ASUBrandHeaderController(UnsubscribeController controller) {
        setUserStatus();
    }
    public ASUBrandHeaderController(ViewCaseController controller) {
        setUserStatus();
    }
    public ASUBrandHeaderController(ViewAllCasesController controller) {
        setUserStatus();
    }

    private void setUserStatus() {
        isLoggedInUser = false;

        if (UserInfo.getUserId() != null && !UserInfo.getLastName().containsIgnoreCase('site guest user')) {
            isLoggedInUser = true;
        }
    }

    public Boolean getIsLoggedInUser() {
        return isLoggedInUser;
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
            menuLinks = new List<Link>();

            Link link1 = new Link();
            link1.name = 'Home';
            link1.url = '/myasu';

            Link link2 = new Link();
            link2.name = 'Finances';
            link2.url = '/myasu/student/finances';

            Link link3 = new Link();
            link3.name = 'Campus Services';
            link3.url = '/myasu/student/campusservices';

            Link link4 = new Link();
            link4.name = 'Profile';
            link4.url = '/myasu/student/profile';

            Link link5 = new Link();
            link5.name = 'Help';
            link5.url = '/';

            menuLinks.add(link1);
            menuLinks.add(link2);
            menuLinks.add(link3);
            menuLinks.add(link4);
            menuLinks.add(link5);
        }

        System.debug('asuriteId: ' + asuriteIdParm);
        System.debug('time: ' + timeParm);
        System.debug('signature: ' + signatureParm);
        System.debug('menuLinks: ' + menuLinks);

        return null;
    }
}
