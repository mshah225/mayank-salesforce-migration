public with sharing class FilterSetController {
    /**
     * Allowed to share if there are ANY users you can share with.  This in practice limits sharing to managers.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean checkIfCanShare() {
        try {
            return !getShareOptions(null).isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get all the users a user is allowed to share with
     */
    @AuraEnabled(cacheable=true)
    public static List<LabelValue> getShareOptions(String mode) {
        try {
            Boolean gradMode = null;
            if (mode != null) {
                if (mode == 'GRAD')
                    gradMode = true;
                else if (mode == 'UGRAD')
                    gradMode = false;
            }

            AdvisorCaseTransferService.UserTransferOptionBuilder builder = new AdvisorCaseTransferService.UserTransferOptionBuilder(
                UserInfo.getUserId(),
                gradMode
            );
            return builder.getSubordinates();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}