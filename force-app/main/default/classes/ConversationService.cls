public with sharing class ConversationService {
    public void execute(List<smagicinteract__Conversation__c> senders) {
        Map<Id, Set<smagicinteract__conversation__c>> contactConversationMap = getContactConversationMap(senders);

        if (contactConversationMap != null && !contactConversationMap.isEmpty()) {
            Map<String, Set<Id>> codeContactMap = getCodeContactMapping(contactConversationMap);
            System.debug('@@--codeContactMap : ' + codeContactMap);
            Map<Id, smagicinteract__conversation__c> convsMap = new Map<Id, smagicinteract__conversation__c>();
            Map<String, Success_Coach_Mapping__c> codeMapping = new Map<String, Success_Coach_Mapping__c>();
            if (codeContactMap != null & !codeContactMap.isEmpty()) {
                for (Success_Coach_Mapping__c mapping : [
                    SELECT
                        PeopleSoft_Student_Group_Code__c,
                        Success_Coach__c,
                        Success_Coach_Queue_Name__c,
                        Supervisor__c,
                        Supervisor_Queue_Name__c
                    FROM Success_Coach_Mapping__c
                    WHERE
                        PeopleSoft_Student_Group_Code__c IN :codeContactMap.keyset()
                        AND Success_Coach__c != NULL
                        AND Supervisor__c != NULL
                        AND Success_Coach_Queue_Name__c != NULL
                        AND Supervisor_Queue_Name__c != NULL
                    ORDER BY lastmodifieddate DESC
                ]) {
                    System.debug('@@-- mapping : ' + mapping);
                    String code = mapping.PeopleSoft_Student_Group_Code__c;
                    Set<Id> contactIds = codeContactMap.get(code.toLowerCase());
                    System.debug('@@-- contactIds : ' + contactIds);
                    if (contactIds != null && contactIds.size() > 0) {
                        for (Id contactId : contactIds) {
                            Set<smagicinteract__conversation__c> conversations = contactConversationMap.get(contactId);
                            for (smagicinteract__conversation__c conversation : conversations) {
                                if (!convsMap.containsKey(conversation.id)) {
                                    convsMap.put(
                                        conversation.id,
                                        new smagicinteract__conversation__c(
                                            id = conversation.id,
                                            PeopleSoft_Code__c = code,
                                            Success_Coach__c = mapping.Success_Coach__c,
                                            Supervisor__c = mapping.Supervisor__c,
                                            Success_Coach_Mapping__c = mapping.Id
                                        )
                                    );
                                }
                            }
                        }
                    }
                }
            }
            System.debug('@@-- convsMap : ' + convsMap);
            if (convsMap != null && !convsMap.values().isEmpty()) {
                Database.SaveResult[] lsr = database.update(convsMap.values(), false);
            }
        }
    }

    private Map<Id, Set<smagicinteract__conversation__c>> getContactConversationMap(
        List<smagicinteract__Conversation__c> senders
    ) {
        Map<Id, Set<smagicinteract__conversation__c>> contactConversationMap = new Map<Id, Set<smagicinteract__conversation__c>>();
        for (smagicinteract__Conversation__c c : [
            SELECT id, smagicinteract__Contact__c
            FROM smagicinteract__Conversation__c
            WHERE
                PeopleSoft_Code__c = NULL
                AND Success_Coach__c = NULL
                AND Supervisor__c = NULL
                AND SenderIdUnit__c = 'FYS'
                AND id IN :senders
        ]) {
            if (contactConversationMap.containsKey(c.smagicinteract__Contact__c)) {
                contactConversationMap.get(c.smagicinteract__Contact__c).add(c);
            } else {
                contactConversationMap.put(c.smagicinteract__Contact__c, new Set<smagicinteract__conversation__c>{ c });
            }
        }
        System.debug('@@-- contactConversationMap : ' + contactConversationMap);
        return contactConversationMap;
    }

    private Map<String, Set<ID>> getCodeContactMapping(
        Map<Id, Set<smagicinteract__conversation__c>> contactConversationMap
    ) {
        Map<String, Set<Id>> codeContactMap = new Map<String, Set<Id>>();
        if (contactConversationMap != null && !contactConversationMap.isEmpty()) {
            for (Student_Group__c studentGroup : [
                SELECT id, SG_Contact__c, SG_PeopleSoft_Code__c
                FROM Student_Group__c
                WHERE
                    SG_Status__c = TRUE
                    AND SG_Contact__c IN :contactConversationMap.keySet()
                    AND SG_PeopleSoft_Code__c != NULL
            ]) {
                System.debug('@@-- studentGroup : ' + studentGroup);
                String code = studentGroup.SG_PeopleSoft_Code__c.toLowerCase();
                Set<Id> contactIds = codeContactMap.get(code);
                if (contactIds == null) {
                    contactIds = new Set<Id>();
                }
                contactIds.add(studentGroup.SG_Contact__c);
                codeContactMap.put(code, contactIds);
            }
        }
        System.debug('@@-- codeContactMap : ' + codeContactMap);
        return codeContactMap;
    }

    public void updateSharing(
        Map<Id, smagicinteract__Conversation__c> oldMap,
        Map<Id, smagicinteract__Conversation__c> newMap
    ) {
        Map<Id, Set<Id>> convUserIdMap = getConversationsWithModifiedCoachOrSupervisor(oldMap, newMap);

        if (convUserIdMap != null && convUserIdMap.keySet().size() > 0) {
            Map<Id, Set<Id>> existingConvShareMap = fetchExistingSharingRecords(convUserIdMap.keyset());

            List<smagicinteract__Conversation__Share> convShareListNew = getSharingRecordsToInsert(
                convUserIdMap,
                existingConvShareMap
            );
            if (convShareListNew != null && !convShareListNew.isEmpty()) {
                Database.SaveResult[] lsr = Database.insert(convShareListNew, false);
                checkForErrors(lsr);
            }
        }
    }

    private Map<Id, Set<Id>> getConversationsWithModifiedCoachOrSupervisor(
        Map<Id, smagicinteract__Conversation__c> oldMap,
        Map<Id, smagicinteract__Conversation__c> newMap
    ) {
        Map<Id, Set<Id>> convUserIdMap = new Map<Id, Set<Id>>();
        for (Id convId : newMap.keySet()) {
            smagicinteract__Conversation__c conv = newMap.get(convId);
            if (oldMap.get(convId).ownerId != conv.ownerId) {
                if (convUserIdMap.containsKey(convId)) {
                    convUserIdMap.get(convId).add(conv.Success_Coach__c);
                    convUserIdMap.get(convId).add(conv.Supervisor__c);
                } else {
                    Set<Id> tempSet = new Set<Id>{ conv.Success_Coach__c, conv.Supervisor__c };
                    convUserIdMap.put(convId, tempSet);
                }
            }
            if (oldMap.get(convId).Success_Coach__c != conv.Success_Coach__c) {
                if (convUserIdMap.containsKey(convId)) {
                    convUserIdMap.get(convId).add(conv.Success_Coach__c);
                } else {
                    Set<Id> tempSet = new Set<Id>{ conv.Success_Coach__c };
                    convUserIdMap.put(convId, tempSet);
                }
            }
            if (oldMap.get(convId).Supervisor__c != conv.Supervisor__c) {
                if (convUserIdMap.containsKey(convId)) {
                    convUserIdMap.get(convId).add(conv.Supervisor__c);
                } else {
                    Set<Id> tempSet = new Set<Id>{ conv.Supervisor__c };
                    convUserIdMap.put(convId, tempSet);
                }
            }
        }
        return convUserIdMap;
    }

    private Map<Id, Set<Id>> fetchExistingSharingRecords(Set<Id> conversationIds) {
        Map<Id, Set<Id>> existingConvShareMap = new Map<Id, Set<Id>>();
        for (smagicinteract__Conversation__Share convShare : [
            SELECT Id, RowCause, UserOrGroupId, ParentId
            FROM smagicinteract__Conversation__Share
            WHERE ParentId IN :conversationIds
        ]) {
            Set<Id> convShareSet = existingConvShareMap.get(convShare.ParentId);
            if (convShareSet == null) {
                convShareSet = new Set<Id>();
            }
            convShareSet.add(convShare.UserOrGroupId);
            existingConvShareMap.put(convShare.ParentId, convShareSet);
        }
        return existingConvShareMap;
    }

    private List<smagicinteract__Conversation__share> getSharingRecordsToInsert(
        Map<Id, Set<Id>> convUserIdMap,
        Map<Id, Set<Id>> existingConvShareMap
    ) {
        List<smagicinteract__Conversation__Share> convShareSetNew = new List<smagicinteract__Conversation__Share>();
        for (Id conversationId : convUserIdMap.keyset()) {
            Set<Id> userIds = convUserIdMap.get(conversationId);
            if (existingConvShareMap.containsKey(conversationId)) {
                Set<Id> convShareSet = existingConvShareMap.get(conversationId);
                for (Id userId : userIds) {
                    if (!convShareSet.contains(userId) && userId != null) {
                        convShareSetNew.add(createRecord(conversationId, userId));
                    }
                }
            } else {
                for (Id userId : userIds) {
                    if (userId != null) {
                        convShareSetNew.add(createRecord(conversationId, userId));
                    }
                }
            }
        }
        return convShareSetNew;
    }

    private smagicinteract__Conversation__share createRecord(Id conversationId, Id userId) {
        return new smagicinteract__Conversation__share(
            parentId = conversationId,
            UserOrGroupId = userId,
            AccessLevel = 'Edit',
            RowCause = Schema.smagicinteract__Conversation__share.RowCause.Programmatic_Sharing_For_FYS_Enterprise__c
        );
    }

    public void checkForErrors(Database.SaveResult[] lsr) {
        List<smagicinteract__Error_Log__c> errorLogs = new List<smagicinteract__Error_Log__c>();
        // Process the save results
        for (Database.SaveResult sr : lsr) {
            if (!sr.isSuccess()) {
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];

                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default
                // access level are not allowed.
                // These sharing records are not required and thus an insert exception is
                // acceptable.
                smagicinteract__Error_Log__c errorLogObj = new smagicinteract__Error_Log__c();
                errorLogObj.smagicinteract__Class_Name__c = 'ConversationService';
                errorLogObj.smagicinteract__Error_Message__c = err.getMessage();
                errorLogObj.smagicinteract__Error_Status_Code__c = String.valueOf(err.getStatusCode());
                errorLogObj.smagicinteract__Error_Type__c = 'Fatal';
                errorLogObj.smagicinteract__Object__c = 'smagicinteract__Conversation__share';
                errorLogObj.smagicinteract__Fields__c = String.valueOf(err.getFields());
                errorLogObj.smagicinteract__Line_number__c = 205;
                errorLogObj.smagicinteract__User__c = UserInfo.getUserId();

                errorLogs.add(errorLogObj);
            }
        }
        if (!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }
}