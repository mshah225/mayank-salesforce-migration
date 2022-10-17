public class AdvisorPortalTopLevelFilterController {
    public static String successPodRecordId;
    public static String successResourceRecordId;

    @AuraEnabled(cacheable=true)
    public static String viewAsOptions(Boolean gradOnly) {
        OrderedMapStringToString viewAsOptions = AdvisorCaseTransferService.getTransferToOptionsByUser(
            UserInfo.getUserId(),
            gradOnly
        );

        return JSON.serialize(viewAsOptions.getOrderedList());
    }
}