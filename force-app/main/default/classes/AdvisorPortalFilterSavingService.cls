public inherited sharing class AdvisorPortalFilterSavingService {
    @AuraEnabled(cacheable=true)
    public static String getDefaultFilter() {
        String json = [
            SELECT Default_Filter__c
            FROM Success_Resource__c
            WHERE Resource__c = :UserInfo.getUserId() AND IsActive__c = TRUE
            LIMIT 1
        ]
        .Default_Filter__c;
        return json;
    }

    @AuraEnabled
    public static void setDefaultFilter(String json) {
        if (json.length() > 2048) {
            throw new AdvisorPortalFilterSavingException('Filter too large. Try selecting fewer filters');
        }
        List<Success_Resource__c> activeResources = [
            SELECT Id, Default_Filter__c
            FROM Success_Resource__c
            WHERE Resource__c = :UserInfo.getUserId() AND IsActive__c = TRUE
        ];
        for (Success_Resource__c sr : activeResources) {
            sr.Default_Filter__c = json;
        }
        if (!activeResources.isEmpty())
            update activeResources;
    }

    @AuraEnabled
    public static void clearDefaultFilter() {
        List<Success_Resource__c> activeResources = [
            SELECT Id, Default_Filter__c
            FROM Success_Resource__c
            WHERE Resource__c = :UserInfo.getUserId() AND IsActive__c = TRUE
        ];
        for (Success_Resource__c sr : activeResources) {
            sr.Default_Filter__c = null;
        }
        if (!activeResources.isEmpty())
            update activeResources;
    }

    public class AdvisorPortalFilterSavingException extends Exception {
    }
}
