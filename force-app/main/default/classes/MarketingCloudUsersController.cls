public with sharing class MarketingCloudUsersController {
    public final static String CUSTOM_SETTING_BY_NAME = 'users';

    @AuraEnabled(cacheable=true)
    public static List<MarketingCloudUsersCallout.MarketingCloudUser> getUsersFromMarketingCloud() {
        MarketingCloudUsersCallout calloutToMarkingCloudForUsers = new MarketingCloudUsersCallout(
            CUSTOM_SETTING_BY_NAME
        );
        List<MarketingCloudUsersCallout.MarketingCloudUser> users = calloutToMarkingCloudForUsers.getUsers();

        return users;
    }
}
