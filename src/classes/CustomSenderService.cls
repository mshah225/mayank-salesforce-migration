global with sharing class CustomSenderService implements Callable {
    // Dispatch actual methods
    global Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'getSenderInfo' {
                return this.getSenderIds((String) args.get('givenCriteria'), (List<String>) args.get('ids'));
            }
            when else {
                throw new SenderServiceMalformedCallException('Method not implemented');
            }
        }
    }

    List<smagicinteract__SMS_SenderId__c> getSenderIds(String givenCriteria, List<String> ids) {
        Boolean flag = true;
        Set<Id> convIds = new Set<Id>();
        List<smagicinteract__SMS_SenderId__c> senderIds = new List<smagicinteract__SMS_SenderId__c>();
        System.debug('@@@@@ Ids passed : ' + ids);
        if (ids == null || ids.isEmpty()) {
            return getDefaultSenderIds();
        }

        if (ids.size() == 1) {
            Id recordId = ids[0];
            if (recordId.getSobjectType() == contact.SObjectType) {
                senderIds = getDefaultSenderIds();
                if (senderIds.isEmpty()) {
                    senderIds = getContactSenderIds(ids[0]);
                }
                return senderIds;
            }
        }
        for (Id record : ids) {
            if (record != null && smagicinteract__Conversation__c.sObjectType == record.getsobjecttype()) {
                System.debug('@@@@@ Adding RecordId in the list : ' + record);
                convIds.add(record);
            }
        }
        System.debug('@@@@@ convIds : ' + convIds);

        if (convIds != null && convIds.size() > 0) {
            for (smagicinteract__Conversation__c conv : [
                SELECT
                    Id,
                    smagicinteract__Sender__r.Id,
                    smagicinteract__Sender__r.smagicinteract__senderId__c,
                    smagicinteract__Sender__r.smagicinteract__Label__c,
                    smagicinteract__Sender__r.smagicinteract__Description__c,
                    smagicinteract__Sender__r.SenderIdUnit__c,
                    smagicinteract__Sender__r.smagicinteract__Used_For__c,
                    smagicinteract__Sender__r.smagicinteract__Email_Notification_Template__c,
                    smagicinteract__Sender__r.smagicinteract__Notification_Recipient__c
                FROM smagicinteract__Conversation__c
                WHERE Id IN :convIds
            ]) {
                System.debug(
                    '@@@@@ conv : ' +
                    conv.smagicinteract__Sender__r.Id +
                    ', ' +
                    conv.smagicinteract__Sender__r.SenderIdUnit__c
                );
                if (
                    conv.smagicinteract__Sender__r.Id != null &&
                    'FYS'.equalsIgnoreCase(conv.smagicinteract__Sender__r.SenderIdUnit__c)
                ) {
                    senderIds.add(conv.smagicinteract__Sender__r);
                    flag = false;
                }
            }
        }
        if (flag) {
            senderIds = getDefaultSenderIds();
        }
        System.debug('@@@@@ final Sender Ids : ' + senderIds);
        return senderIds;
    }

    private List<smagicinteract__SMS_SenderId__c> getContactSenderIds(Id contactId) {
        List<smagicinteract__SMS_SenderId__c> ContactSenderIds = new List<smagicinteract__SMS_SenderId__c>();
        List<Student_Group__c> activeGroups = [
            SELECT id, SG_PeopleSoft_Code__c
            FROM Student_Group__c
            WHERE SG_Contact__c = :contactId AND SG_Status__c = TRUE
        ];
        if (activeGroups.size() == 0) {
            return ContactSenderIds;
        }
        List<String> codeList = new List<String>();
        for (Student_Group__c code : activeGroups) {
            codeList.add(code.SG_PeopleSoft_Code__c);
        }
        List<Success_Coach_Mapping__c> coachAndSupervisorList = [
            SELECT id, Success_Coach__c, Supervisor__c
            FROM Success_Coach_Mapping__c
            WHERE PeopleSoft_Student_Group_Code__c IN :codeList
        ];
        if (coachAndSupervisorList.size() == 0) {
            return ContactSenderIds;
        }
        Set<Id> userIds = new Set<Id>();
        for (Success_Coach_Mapping__c rec : coachAndSupervisorList) {
            if (rec.Success_Coach__c != null) {
                userIds.add(rec.Success_Coach__c);
            }
            if (rec.Supervisor__c != null) {
                userIds.add(rec.Supervisor__c);
            }
        }
        if (userIds.size() > 0) {
            for (smagicinteract__SenderId_Profile_Map__c senderIdMap : [
                SELECT
                    id,
                    smagicinteract__User__c,
                    smagicinteract__SenderId_Lookup__r.smagicinteract__senderId__c,
                    smagicinteract__SenderId_Lookup__r.smagicinteract__Label__c,
                    smagicinteract__SenderId_Lookup__r.smagicinteract__Description__c,
                    smagicinteract__SenderId_Lookup__r.SenderIdUnit__c,
                    smagicinteract__SenderId_Lookup__r.smagicinteract__Used_For__c,
                    smagicinteract__SenderId_Lookup__r.smagicinteract__Email_Notification_Template__c,
                    smagicinteract__SenderId_Lookup__r.smagicinteract__Notification_Recipient__c,
                    smagicinteract__SenderId_Lookup__r.IsEnterpriseUser__c
                FROM smagicinteract__SenderId_Profile_Map__c
                WHERE smagicinteract__User__c IN :userIds
            ]) {
                if (String.isNotBlank(senderIdMap.smagicinteract__SenderId_Lookup__r.smagicinteract__senderId__c)) {
                    ContactSenderIds.add(senderIdMap.smagicinteract__SenderId_Lookup__r);
                }
            }
        }
        return ContactSenderIds;
    }
    private List<smagicinteract__SMS_SenderId__c> getDefaultSenderIds() {
        List<smagicinteract__SMS_SenderId__c> senderIds = new List<smagicinteract__SMS_SenderId__c>();
        for (smagicinteract__SenderId_Profile_Map__c senderProfileMap : [
            SELECT
                id,
                smagicinteract__SenderId_Lookup__r.Id,
                smagicinteract__SenderId_Lookup__r.smagicinteract__senderId__c,
                smagicinteract__SenderId_Lookup__r.smagicinteract__Label__c,
                smagicinteract__SenderId_Lookup__r.smagicinteract__Description__c,
                smagicinteract__SenderId_Lookup__r.SenderIdUnit__c,
                smagicinteract__SenderId_Lookup__r.smagicinteract__Used_For__c,
                smagicinteract__SenderId_Lookup__r.smagicinteract__Email_Notification_Template__c,
                smagicinteract__SenderId_Lookup__r.smagicinteract__Notification_Recipient__c
            FROM smagicinteract__SenderId_Profile_Map__c
            WHERE
                smagicinteract__User__c = :UserInfo.getUserId()
                OR smagicinteract__Profile_Id__c = :UserInfo.getProfileId()
            ORDER BY smagicinteract__User__c ASC NULLS LAST
        ]) {
            if (String.isNotBlank(senderProfileMap.smagicinteract__SenderId_Lookup__r.smagicinteract__senderId__c)) {
                senderIds.add(senderProfileMap.smagicinteract__SenderId_Lookup__r);
                break;
            }
        }
        System.debug('@@--defaultSenderIds : ' + senderIds);
        return senderIds;
    }

    public class SenderServiceMalformedCallException extends Exception {
    }
}
