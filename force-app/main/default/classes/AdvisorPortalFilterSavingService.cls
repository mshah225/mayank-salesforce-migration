public inherited sharing class AdvisorPortalFilterSavingService {
    @AuraEnabled(cacheable=true)
    public static String getDefaultFilter() {
        String json = null;
        List<Success_Resource__c> activeResources = [
            SELECT Default_Filter__c
            FROM Success_Resource__c
            WHERE Resource__c = :UserInfo.getUserId() AND IsActive__c = TRUE
        ];

        if (!activeResources.isEmpty())
            json = activeResources[0].Default_Filter__c;
        else
            throw new AdvisorPortalFilterSavingException(
                'This user doesn\'t have a success resource and can\'t use the save filters feature'
            );

        return json == null ? '{}' : json;
    }

    @AuraEnabled
    public static void setDefaultFilter(String json) {
        if (json.length() > Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength()) {
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
        else
            throw new AdvisorPortalFilterSavingException(
                'This user doesn\'t have a success resource and can\'t use the save filters feature'
            );
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
        else
            throw new AdvisorPortalFilterSavingException(
                'This user doesn\'t have a success resource and can\'t use the save filters feature'
            );
    }

    public class AdvisorPortalFilterSavingException extends Exception {
    }
}