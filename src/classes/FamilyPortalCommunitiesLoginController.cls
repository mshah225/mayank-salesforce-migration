/**
 * An apex page controller that exposes the site login functionality
 */
public with sharing class CommunitiesLoginController {
    // Code we will invoke on page load.
    public PageReference forwardToCustomAuthPage() {
        String startUrl = '/FamilyPortal/FamilyPortalStep1';
        if (Site.getName() == 'Family_Portal') {
            String existingStartUrl = System.currentPageReference().getParameters().get('startURL');
            if (existingStartUrl.contains('?')) {
                startUrl += '?' + existingStartUrl.split('\\?')[1];
            }
        }
        return Network.forwardToCustomAuthPage(startUrl);
    }
}