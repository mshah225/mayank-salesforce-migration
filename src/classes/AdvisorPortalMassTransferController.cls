/**
* @author Mathew Ruff, Sierra-Cedar
* @date 2019-02-12
*
* Controller logic for AdvisorPortalMassTransfer.cmp
*/
public class AdvisorPortalMassTransferController {
    @AuraEnabled
    public static void transferCases(List<Case> portalCases, String ownerId) {
        if (portalCases.isEmpty()) return;

        for (Case portalCase : portalCases) {
            portalCase.OwnerId = ownerId;
        }

        update portalCases;
    }
}