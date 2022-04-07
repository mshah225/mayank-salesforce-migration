public with sharing class MarketingCloudUtilitiesController {
    public final static String CUSTOM_SETTING_BY_NAME = 'users';

    @AuraEnabled(cacheable=true)
    public static List<MarketingCloudUtilitiesWebService.MarketingCloudUser> getUsersFromMarketingCloud() {
        MarketingCloudUtilitiesWebService calloutToMarkingCloudForUsers = new MarketingCloudUtilitiesWebService(
            CUSTOM_SETTING_BY_NAME
        );
        List<MarketingCloudUtilitiesWebService.MarketingCloudUser> users = calloutToMarkingCloudForUsers.getUsers();

        return users;
    }
}
