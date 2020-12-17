/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-08
 *
 * Controller logic for AdvisorPortalMassEmailModalController.cmp
 */
public class AdvisorPortalMassEmailModalController {
    private static final Id ADVISOR_PORTAL_EMAIL_RTID = IDHelper.getRecordTypeId('Portal_Email__c', 'Advisor');

    @AuraEnabled
    public static user fetchUser() {
        User userDetail = [SELECT Name FROM User WHERE id = :userInfo.getUserId()];
        return userDetail;
    }

    @AuraEnabled
    public static void createPortalEmails(Map<Id, Case[]> contactIdToCasesMap, String subject, String body) {
        if (contactIdToCasesMap.keySet().isEmpty()) {
            return;
        }

        List<Portal_Email__c> portalEmailsToInsert = new List<Portal_Email__c>();
        Map<Id, Id> contactIdToSuccessStudentId = new Map<Id, Id>();

        // Get success students for all contact emails (not needed case emails)
        for (Success_Student__c ss : [
            SELECT Id, Student__c
            FROM Success_Student__c
            WHERE Student__c IN :contactIdToCasesMap.keySet() AND Is_Active__c = TRUE
        ]) {
            contactIdToSuccessStudentId.put(ss.Student__c, ss.Id);
        }

        for (String contactId : contactIdToCasesMap.keySet()) {
            Case newestCase = null;
            Map<Id, Portal_Email__c> portalEmailMap = new Map<Id, Portal_Email__c>();
            Portal_Email__c contactEmail = new Portal_Email__c(
                Status__c = 'New',
                Contact__c = contactId,
                Success_Student__c = contactIdToSuccessStudentId.get(contactId),
                Subject__c = subject,
                Additional_Message_Text__c = body,
                RecordTypeId = ADVISOR_PORTAL_EMAIL_RTID,
                Email_Template_Name__c = 'Advisor Ad-hoc template'
            );

            if (contactIdToCasesMap.get(contactId).size() > 0) {
                // Handle emails for contacts w/ cases
                for (Case portalCase : contactIdToCasesMap.get(contactId)) {
                    if (newestCase == null) {
                        newestCase = portalCase;
                    } else if (newestCase.CreatedDate < portalCase.CreatedDate) {
                        newestCase = portalCase;
                    }

                    portalEmailMap.put(
                        portalCase.Id,
                        new Portal_Email__c(
                            Status__c = 'Duplicate',
                            Case__c = portalCase.Id,
                            Contact__c = portalCase.ContactId,
                            Subject__c = subject,
                            Additional_Message_Text__c = body,
                            RecordTypeId = ADVISOR_PORTAL_EMAIL_RTID,
                            Email_Template_Name__c = 'Advisor Ad-hoc template'
                        )
                    );
                }

                // Newest case should have email with status 'New'
                if (newestCase != null && portalEmailMap.containsKey(newestCase.Id)) {
                    portalEmailMap.get(newestCase.Id).Status__c = 'New';
                }

                portalEmailsToInsert.addAll(portalEmailMap.values());
            } else {
                // Handle emails for contacts w/o cases
                portalEmailsToInsert.add(contactEmail);
            }
        }

        insert portalEmailsToInsert;
    }
}
