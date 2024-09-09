public class AdvisorPortalFilterSavingService {
    @AuraEnabled(cacheable=true)
    public static AdvisorPortalFilter getDefaultFilter() {
        AdvisorPortalFilter filter = null;
        List<Success_Resource__c> activeResources = [
            SELECT Default_Filter__c
            FROM Success_Resource__c
            WHERE Resource__c = :UserInfo.getUserId() AND IsActive__c = TRUE
        ];

        if (!activeResources.isEmpty()) {
            String json = activeResources[0].Default_Filter__c;

            if (String.isNotBlank(json)) {
                try {
                    filter = AdvisorPortalFilter.deserialize(json);
                    // and upgrade, since saved filter may be an older version of the filter object
                    filter.upgradeToMostRecentVersion();
                } catch (Exception ex) {
                    throw new AdvisorPortalFilterCannotGetDefaultCorruptedException(
                        'This user has a filter - but it\'s format is corrupted'
                    );
                }
            }
        }

        // If they don't have a saved filter, we should just apply some default values depending on the user's roles/access
        if (filter == null) {
            filter = new AdvisorPortalFilter();
        }

        // Default values
        if (String.isBlank(filter.caseTypeState))
            filter.caseTypeState = 'ProactiveCasesState';
        if (String.isBlank(filter.career))
            filter.career = 'UGRD';

        if (ProfileHelper.currentUserHasProfile('System Administrator')) {
            // Sys admin - leave it alone
        } else if (
            PermissionSetHelper.currentUserHasPermissionSet('Role_Academic_Advisor_Portal_Service_Users') &&
            PermissionSetHelper.currentUserHasPermissionSet('Role_Graduate_Academic_Advisor_Portal_Service_Users')
        ) {
            // Have both perms - leave it alone
        } else if (
            !PermissionSetHelper.currentUserHasPermissionSet('Role_Academic_Advisor_Portal_Service_Users') &&
            PermissionSetHelper.currentUserHasPermissionSet('Role_Graduate_Academic_Advisor_Portal_Service_Users')
        ) {
            // Only can access GRD - force it to GRD
            filter.career = 'GRD';
        } else if (
            !PermissionSetHelper.currentUserHasPermissionSet('Role_Graduate_Academic_Advisor_Portal_Service_Users') &&
            PermissionSetHelper.currentUserHasPermissionSet('Role_Academic_Advisor_Portal_Service_Users')
        ) {
            // Only can access UGRD - force it to UGRD
            filter.career = 'UGRD';
        } else {
            throw new AdvisorPortalFilterCannotGetDefaultPermissionsException(
                'The current user, userid=' +
                    UserInfo.getUserId() +
                    ' does not have the Role_Academic_Advisor_Portal_Service_Users or Role_Graduate_Academic_Advisor_Portal_Service_Users permission set. The advisor portal will not work properly without one of these permission sets.'
            );
        }

        return filter;
    }

    @AuraEnabled
    public static void setDefaultFilter(String json) {
        if (json.length() > Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength()) {
            throw new AdvisorPortalFilterCannotSaveDefaultException(
                'Filter too large. Filter is ' +
                    json.length() +
                    ' bytes long, but it must be, at most ' +
                    Schema.SObjectType.Success_Resource__c.fields.Default_Filter__c.getLength() +
                    'bytes. Try selecting fewer filters.'
            );
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
            throw new AdvisorPortalFilterCannotSaveDefaultException(
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
            throw new AdvisorPortalFilterCannotSaveDefaultException(
                'This user doesn\'t have a success resource and can\'t use the save filters feature'
            );
    }

    public class AdvisorPortalFilterCannotSaveDefaultException extends Exception {
    }
    public class AdvisorPortalFilterCannotGetDefaultPermissionsException extends Exception {
    }
    public class AdvisorPortalFilterCannotGetDefaultCorruptedException extends Exception {
    }
}
