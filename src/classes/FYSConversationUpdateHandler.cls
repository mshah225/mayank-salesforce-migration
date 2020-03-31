public class FYSConversationUpdateHandler {
    public void execute(List<smagicinteract__Conversation_Sender_Map__c> senders) {
        
        Map<Id, Set<smagicinteract__conversation__c>> contactConversationMap = getContactConversationMap(senders);
        
        if (contactConversationMap != null && !contactConversationMap.isEmpty()) {
            Map<String, Set<Id>> codeContactMap = getCodeContactMapping(contactConversationMap);
            System.debug('@@--codeContactMap : '+ codeContactMap);
            Map<Id, smagicinteract__conversation__c> convsMap = new Map<Id, smagicinteract__conversation__c>();
            Map<String, Success_Coach_Mapping__c> codeMapping = new Map<String, Success_Coach_Mapping__c>();
            if (codeContactMap != null & !codeContactMap.isEmpty()) {
                for (Success_Coach_Mapping__c mapping : [select PeopleSoft_Student_Group_Code__c, Success_Coach__c, Success_Coach_Queue_Name__c,
                                                         Supervisor__c, Supervisor_Queue_Name__c
                                                         from Success_Coach_Mapping__c 
                                                         where PeopleSoft_Student_Group_Code__c in :codeContactMap.keyset()
                                                         and Success_Coach__c != null and Supervisor__c != null 
                                                         and Success_Coach_Queue_Name__c != null and Supervisor_Queue_Name__c != null order by lastmodifieddate desc])
                {
                    System.debug('@@-- mapping : '+ mapping);
                    String code = mapping.PeopleSoft_Student_Group_Code__c;
                    Set<Id> contactIds = codeContactMap.get(code.toLowerCase());
                    System.debug('@@-- contactIds : '+ contactIds);
                    if(contactIds != null && contactIds.size() > 0) {
						for (Id contactId : contactIds) {
                            Set<smagicinteract__conversation__c> conversations = contactConversationMap.get(contactId);
                            for (smagicinteract__conversation__c conversation : conversations) {
                                    if(!convsMap.containsKey(conversation.id)) {
                                       convsMap.put(conversation.id, new smagicinteract__conversation__c(id = conversation.id,
                                                                                                      PeopleSoft_Code__c = code,
                                                                                                      Success_Coach__c = mapping.Success_Coach__c,
                                                                                                      Supervisor__c = mapping.Supervisor__c,
                                                                                                      Success_Coach_Mapping__c = mapping.Id)); 
                                    }
                                }
                            }                        
                    }
                }
            }
            System.debug('@@-- convsMap : '+ convsMap);
            if (convsMap != null && !convsMap.values().isEmpty()) {
                Database.SaveResult[] lsr = database.update(convsMap.values(), false);
            }
        }
    }
    
    public void checkForErrors(Database.SaveResult[] lsr) {
        List<smagicinteract__Error_Log__c> errorLogs = new List<smagicinteract__Error_Log__c>();
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];
                smagicinteract__Error_Log__c errorLogObj = new smagicinteract__Error_Log__c();
                errorLogObj.smagicinteract__Class_Name__c = 'FYSConversationUpdateHandler';
                errorLogObj.smagicinteract__Error_Message__c = err.getMessage();                  
                errorLogObj.smagicinteract__Error_Status_Code__c = String.valueOf(err.getStatusCode());
                errorLogObj.smagicinteract__Error_Type__c = 'Fatal';
                errorLogObj.smagicinteract__Object__c = 'smagicinteract__Conversation__c';
                errorLogObj.smagicinteract__Fields__c = String.valueOf(err.getFields());
                errorLogObj.smagicinteract__Line_number__c = 58;
                errorLogObj.smagicinteract__User__c = UserInfo.getUserId();
                errorLogs.add(errorLogObj);
            }
        }
        if (!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }
    
    private Map<Id, Set<smagicinteract__conversation__c>> getContactConversationMap(List<smagicinteract__Conversation_Sender_Map__c> senders) {
        Map<Id, Set<smagicinteract__conversation__c>> contactConversationMap = new Map<Id, Set<smagicinteract__conversation__c>>();
        for (smagicinteract__Conversation_Sender_Map__c senderMap : [select id, smagicinteract__conversation__r.id,
                                                                     smagicinteract__conversation__r.smagicinteract__Contact__c 
                                                                     from smagicinteract__Conversation_Sender_Map__c 
                                                                     where smagicinteract__conversation__r.PeopleSoft_Code__c = null
                                                                     and smagicinteract__conversation__r.Success_Coach__c = null
                                                                     and smagicinteract__conversation__r.Supervisor__c = null
                                                                     and smagicinteract__SMS_SenderId__r.IsEnterpriseUser__c = true
                                                                     and id in :senders]) 
        {
            smagicinteract__conversation__c c = senderMap.smagicinteract__conversation__r;
            if (contactConversationMap.containsKey(c.smagicinteract__Contact__c)) {
                contactConversationMap.get(c.smagicinteract__Contact__c).add(c);
            } else {
                contactConversationMap.put(c.smagicinteract__Contact__c, new Set<smagicinteract__conversation__c>{c});
            }
        }
        System.debug('@@-- contactConversationMap : '+ contactConversationMap);
        return contactConversationMap;
    }
    
    private Map<String, Set<ID>> getCodeContactMapping(Map<Id, Set<smagicinteract__conversation__c>> contactConversationMap) {
        Map<String, Set<Id>> codeContactMap = new Map<String, Set<Id>>();
        if (contactConversationMap != null && !contactConversationMap.isEmpty()) {
            for (Student_Group__c studentGroup : [select id, SG_Contact__c, SG_PeopleSoft_Code__c 
                                                  from Student_Group__c 
                                                  where SG_Status__c = true 
                                                  and SG_Contact__c in :contactConversationMap.keySet() 
                                                  and SG_PeopleSoft_Code__c != null]) 
            {
                String code = studentGroup.SG_PeopleSoft_Code__c.toLowerCase();
                Set<Id> contactIds = codeContactMap.get(code);
                if (contactIds == null) {
                    contactIds = new Set<Id>();
                }
                contactIds.add(studentGroup.SG_Contact__c);
                codeContactMap.put(code, contactIds);
            }
        }
        System.debug('@@-- codeContactMap : '+ codeContactMap);
        return codeContactMap;
    }
}