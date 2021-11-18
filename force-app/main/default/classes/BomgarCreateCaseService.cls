public with sharing class BomgarCreateCaseService {
    public static void processEvents(List<bomgar__BomgarWebEvent__c> events) {
        for (bomgar__BomgarWebEvent__c bgEvent : events) {
            if (
                'support_conference_member_added' == bgEvent.bomgar__EventType__c &&
                bgEvent.bomgar__ConferenceMemberType__c == 'representative' &&
                bgEvent.bomgar__ExternalKey__c != null &&
                bgEvent.bomgar__ExternalKey__c.startsWith('SFDC')
            ) {
                String caseId = BomgarCreateCaseUtil.createCase(bgEvent);
                try {
                    BomgarCreateCaseUtil.assignCase(bgEvent.bomgar__BomgarSessionID__c, caseId);
                } catch (Exception e) {
                    Bomgar.BomgarAPIAccess.RecordError(
                        'BomgarCreateCaseTrigger assignCase Failure lsid=[' +
                        bgEvent.bomgar__BomgarSessionID__c +
                        ']',
                        e
                    );
                }
            }
        }
    }
}
