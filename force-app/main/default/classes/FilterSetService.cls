public inherited sharing class FilterSetService {
    public static void checkOwnerBeforeRename(List<Filter_Set__c> newList, Map<Id, Filter_Set__c> oldMap) {
        for (Filter_Set__c filterSet : newList) {
            Filter_Set__c oldFilterSet = oldMap.get(filterSet.Id);

            if (RecordHelper.hasNewOrChangedField(filterSet, oldFilterSet, Filter_Set__c.Name)) {
                // Only allowed to rename if you own it or are a system admin
                if (
                    filterSet.OwnerId != UserInfo.getUserId() &&
                    !ProfileHelper.currentUserHasProfile('System Administrator')
                ) {
                    filterSet.addError('You do not own this filter set and are not allowed to rename it');
                }
            }
        }
    }

    public static void checkUniqueName(List<Filter_Set__c> newList) {
        Map<Id, Set<String>> userIdToNames = new Map<Id, Set<String>>();

        Set<Id> ownerIds = new Set<Id>();
        Set<Id> filterSetIds = new Set<Id>();
        for (Filter_Set__c fs : newList) {
            ownerIds.add(fs.OwnerId);
            filterSetIds.add(fs.Id);
        }

        // Get list of names per user
        for (Filter_Set__c fs : [
            SELECT Id, Name, OwnerId
            FROM Filter_Set__c
            WHERE OwnerId IN :ownerIds AND Id NOT IN :filterSetIds
        ]) {
            if (!userIdToNames.containsKey(fs.OwnerId))
                userIdToNames.put(fs.OwnerId, new Set<String>());
            userIdToNames.get(fs.OwnerId).add(fs.Name);
        }

        // Check for duplicates
        for (Filter_Set__c fs : newList) {
            Set<String> existingNames = userIdToNames.get(fs.OwnerId);
            if (existingNames != null && existingNames.contains(fs.Name))
                fs.addError('Filter Names must be unique. This name matches an existing filter set that you own.');
        }
    }

    public static void createFSUAForOwners(List<Filter_Set__c> newList) {
        List<Filter_Set_User_Association__c> fsuas = new List<Filter_Set_User_Association__c>();
        for (Filter_Set__c fs : newList)
            fsuas.add(new Filter_Set_User_Association__c(User__c = fs.OwnerId, Filter_Set__c = fs.Id));
        insert fsuas;
    }
}