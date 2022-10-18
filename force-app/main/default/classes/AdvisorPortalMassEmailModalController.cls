/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-08
 *
 * Controller logic for AdvisorPortalMassEmailModalController.cmp
 */
public class AdvisorPortalMassEmailModalController {
    private static final Id ADVISOR_PORTAL_EMAIL_RTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Advisor');

    @AuraEnabled(cacheable=true)
    public static User fetchUser() {
        User userDetail = [SELECT Name FROM User WHERE id = :UserInfo.getUserId()];
        return userDetail;
    }

    @AuraEnabled
    public static void createPortalEmailsStr(List<String> contactWrappersJSONList, String subject, String body) {
        List<AdvisorPortalContact> contactWrappersList = new List<AdvisorPortalContact>();

        for (String contactWrapperJSON : contactWrappersJSONList) {
            contactWrappersList.add(
                (AdvisorPortalContact) JSON.deserialize(contactWrapperJSON, AdvisorPortalContact.class)
            );
        }

        // Get all case ids
        List<Id> allCaseIds = new List<Id>();
        for (AdvisorPortalContact contactWrapper : contactWrappersList) {
            for (AdvisorPortalCase caseWrapper : contactWrapper.cases) {
                allCaseIds.add(caseWrapper.portalCase.Id);
            }
        }

        // Get needed details
        List<Case> cases = new List<Case>(
            [SELECT Id, ContactId, OwnerId, Most_Recent_Queue__c, CreatedDate FROM Case WHERE Id IN :allCaseIds]
        );

        // Construct map
        Map<Id, Case[]> contactIdToCasesMap = new Map<Id, List<Case>>();
        for (Case c : cases) {
            if (!contactIdToCasesMap.containsKey(c.ContactId)) {
                contactIdToCasesMap.put(c.ContactId, new List<Case>());
            }
            contactIdToCasesMap.get(c.ContactId).add(c);
        }

        createPortalEmails(contactIdToCasesMap, subject, body);
    }

    public static void createPortalEmails(Map<Id, List<Case>> contactIdToCasesMap, String subject, String body) {
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

        Validator.setPrefix(Group.class);
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

                    Portal_Email__c pe = new Portal_Email__c(
                        Status__c = 'Duplicate',
                        Case__c = portalCase.Id,
                        Contact__c = portalCase.ContactId,
                        Subject__c = subject,
                        Additional_Message_Text__c = body,
                        RecordTypeId = ADVISOR_PORTAL_EMAIL_RTID,
                        Email_Template_Name__c = 'Advisor Ad-hoc template'
                    );

                    if (
                        !Validator.validateId(portalCase.OwnerId) &&
                        !Validator.validateId(portalCase.Most_Recent_Queue__c)
                    ) {
                        // Case had never been in a queue - so attach a success student so that can be used
                        // to resolve the email address to use
                        pe.Success_Student__c = contactIdToSuccessStudentId.get(contactId);
                    }

                    portalEmailMap.put(portalCase.Id, pe);
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
