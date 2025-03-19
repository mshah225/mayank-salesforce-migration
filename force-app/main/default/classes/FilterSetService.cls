public inherited sharing class FilterSetService {
    public static void checkOwnerBeforeRename(List<Filter_Set__c> newList, Map<Id, Filter_Set__c> oldMap) {
        System.debug('checkOwnerBeforeRename');
        for (Filter_Set__c filterSet : newList) {
            Filter_Set__c oldFilterSet = oldMap.get(filterSet.Id);

            if (RecordHelper.hasNewOrChangedField(filterSet, oldFilterSet, Filter_Set__c.Name)) {
                // Only allowed to rename if you own it or are a system admin
                if (
                    filterSet.Owner__c != UserInfo.getUserId() &&
                    !ProfileHelper.currentUserHasProfile('System Administrator')
                ) {
                    filterSet.addError('You do not own this filter set and are not allowed to rename it');
                }
            }
        }
    }
}