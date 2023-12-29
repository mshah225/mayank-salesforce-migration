/**
 * An apex page controller that exposes the site login functionality
 */
public with sharing class CommunitiesLoginController {
    public PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Network.forwardToAuthPage(startUrl);
    }
}