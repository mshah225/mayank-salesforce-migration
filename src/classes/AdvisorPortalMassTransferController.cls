/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-12
 *
 * Controller logic for AdvisorPortalMassTransfer.cmp
 */
public class AdvisorPortalMassTransferController {
    @AuraEnabled
    public static void transferCases(List<Case> portalCases, String ownerId) {
        if (portalCases.isEmpty())
            return;

        for (Case portalCase : portalCases) {
            portalCase.OwnerId = ownerId;
        }

        update portalCases;
    }

    @AuraEnabled
    public static Boolean checkIfAllowedToUse() {
        List<Success_Resource__c> resourceForCurrentUser = [
            SELECT Role__c
            FROM Success_Resource__c
            WHERE
                Resource__c = :UserInfo.getUserId()
                AND (Role__c = 'Department Manager'
                OR Role__c = 'College Manager')
                AND IsActive__c = TRUE
        ];

        return resourceForCurrentUser.size() > 0;
    }
}
