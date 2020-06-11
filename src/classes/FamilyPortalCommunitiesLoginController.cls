/**
 * An apex page controller that exposes the site login functionality
 */
public with sharing class CommunitiesLoginController {
    // Code we will invoke on page load.
    public PageReference forwardToAuthPage() {
        if (Site.getName() == 'Family_Portal') {
            String existingStartUrl = System.currentPageReference().getParameters().get('startURL');
            String startUrl = '/FamilyPortal/FamilyPortalStep1';
            if (existingStartUrl.contains('?')) {
                startUrl += '?' + existingStartUrl.split('\\?')[1];
            }
        }
        return Network.forwardToAuthPage(startUrl);
    }
}