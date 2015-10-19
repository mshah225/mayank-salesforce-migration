public without sharing class SCLaunchController
{
    public List<Link> linkList { get; set; }
    public String links { get; set; }
    public String masqScopeIdCookie { get; set; }

    public SCLaunchController() { }
    public SCLaunchController(ServiceCenter controller) { }

    public PageReference init()
    {
        Cookie linksCookie;
        String linksJSON = '';
        String asuriteIdParm = '';
        String navbarParm = '';
        String timeParm = '';
        String signatureParm = '';

        System.debug('parms: ' + ApexPages.currentPage().getParameters());

        if (ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null)
        {
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');
        }

        if (ApexPages.currentPage().getParameters().get('asuriteId') != null)
        {
            asuriteIdParm = ApexPages.currentPage().getParameters().get('asuriteId');
        }

        if (ApexPages.currentPage().getParameters().get('time') != null)
        {
            timeParm = ApexPages.currentPage().getParameters().get('time');
        }

        if (ApexPages.currentPage().getParameters().get('signature') != null)
        {
            signatureParm = ApexPages.currentPage().getParameters().get('signature');
        }

        if (ApexPages.currentPage().getParameters().get('navbar') != null)
        {
            links = ApexPages.currentPage().getParameters().get('navbar');
            System.debug('links: ' + links);
            links = links.replace('{"navbarLinks":','');
            links = links.substring(0, (links.length()-1));

            //Write the cookie
            if (links != null && links != '')
            {
                linksCookie = new Cookie('navbarlinks', links, null, -1, false);
                ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
            }
        }
        else
        {
            linksCookie = ApexPages.currentPage().getCookies().get('navbarlinks');
        }

        if (linksCookie != null)
        {
            linksJSON = linksCookie.getValue();
            System.debug('Cookie value: ' + linksJSON);
            // Clean up any HTML encoding for quotes
            linksJSON = linksJSON.replaceAll('&quot;', '"');
            linksJSON = linksJSON.replaceAll('&#34;', '"');
            System.debug(linksJSON);
            //linkList = (List<Link>) JSON.deserialize(linksJSON, List<Link>.class);

            linkList = new List<Link>();
            JSONParser parser = JSON.createParser(linksJSON);
            while (parser.nextToken() != null)
            {
                //if current token is a field name
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
                {
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

        System.debug('asuriteId: ' + asuriteIdParm);
        System.debug('navbar: ' + navbarParm);
        System.debug('time: ' + timeParm);
        System.debug('signature: ' + signatureParm);

        return null;
    }

    public class Link
    {
        public String name { set; get { return name; } }
        public String url { set; get { return url; } }
    }
}
