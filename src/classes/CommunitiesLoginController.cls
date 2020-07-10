/**
 * An apex page controller that exposes the site login functionality
 */
public with sharing class CommunitiesLoginController {
    // Code we will invoke on page load.
    public PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');

        if (Site.getName() == 'Family_Portal') {
            String newStartUrl = '/FamilyPortal/FamilyPortalStep1';
            if (startUrl.contains('?')) {
                startUrl = newStartUrl + '?' + startUrl.split('\\?')[1];
            } else {
                startUrl = newStartUrl;
            }
        }

        return Network.forwardToAuthPage(startUrl);
    }
}