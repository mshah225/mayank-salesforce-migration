global class EmailAlertArticlesController implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        SendEmail();
    }
    
    
    public Set<Id> returnUserIds(String strFuncGroup, List<Group> lstGrp) {
        List<Group> retGroup = new List<Group>();
        Set<Id> retUserId = new Set<Id>();
        for(Group objGrp: lstGrp){
            if(objGrp.Name.contains(strFuncGroup)){
                retUserId.addAll(getUserIdsFromQueue(objGrp.Id));
                //retGroup.add(objGrp);
            }
        }
        return retUserId;
    }
    
    public static Set<Id> getUserIdsFromQueue(Id queueId) {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
    
        String userType = Schema.SObjectType.User.getKeyPrefix();

        String groupType = Schema.SObjectType.Group.getKeyPrefix();
     
        // Loop through all group members in a group
        for (GroupMember m : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :queueId]) {

            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType)) {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType)) {
                // Call this function again but pass in the group found within this group
                result.addAll(getUserIdsFromQueue(m.UserOrGroupId));
            }
        }
        return result; 
    }

    
    public void SendEmail() {
        List<FAQ__kav> lstArticles = [
            SELECT Id,ArticleNumber, PublishStatus,Functional_Group__c
            FROM FAQ__kav 
            WHERE PublishStatus='Draft' 
                AND Language='en_US' 
                AND (LastModifiedDate>:(System.Today()-10) 
                AND LastModifiedDate<=:System.Today()-11) 
        ];
        
        Set<String> setStrQueryFuncGroup = new Set<String>();
        
        Set<String> setStrFuncGroup = new Set<String>();
        
        Map<String,List<FAQ__kav>> mapFuncGrouptoArticles = new Map<String,List<FAQ__kav>>(); 
        
        List<FAQ__kav> lstForMap = new List<FAQ__kav>();
        
        for(FAQ__kav objFaqKav: lstArticles) {
            if(objFaqKav.Functional_Group__c!=null && objFaqKav.Functional_Group__c!='') {
                setStrQueryFuncGroup.add('%' + objFaqKav.Functional_Group__c + '%');
                setStrFuncGroup.add(objFaqKav.Functional_Group__c);
                lstForMap = new List<FAQ__kav>();
                
                if(mapFuncGrouptoArticles.containsKey(objFaqKav.Functional_Group__c)) {
                    lstForMap=mapFuncGrouptoArticles.get(objFaqKav.Functional_Group__c);
                }
                
                lstForMap.add(objFaqKav);
                mapFuncGrouptoArticles.put(objFaqKav.Functional_Group__c, lstForMap);
            }
        }
        List<Group> lstGrp = [
            SELECT Id,Name
            FROM Group 
            WHERE Type='Queue' 
                AND Name LIKE :setStrQueryFuncGroup
        ];
        Map<String, Set<Id>> mapFuncGroupsToUsers = new Map<String,Set<Id>>();
        
        for(String strFuncGroup: setStrFuncGroup) {
            mapFuncGroupsToUsers.put(strFuncGroup, returnUserIds(strFuncGroup, lstGrp));
        }
        
        EmailTemplate et=[Select id from EmailTemplate where name = 'EmailTemplatename' limit 1];
        
        List<Id> lstEmailUserId;
        List<Messaging.MassEmailMessage> lstMassEmailMsg = new List<Messaging.MassEmailMessage>();
        Messaging.MassEmailMessage mail;
        
        for(String strFuncGroup: setStrFuncGroup) {
            if(mapFuncGroupsToUsers.containsKey(strFuncGroup) && mapFuncGroupToArticles.containsKey(strFuncGroup)) {
                lstEmailUserId=new List<Id>();
                lstEmailUserId.addAll(mapFuncGroupsToUsers.get(strFuncGroup));
                for(FAQ__kav objFaqKav: mapFuncGroupToArticles.get(strFuncGroup)) {
                    mail = new Messaging.MassEmailMessage();
                    mail.setTargetObjectIds(lstEmailUserId);
                    //mail.setSenderDisplayName('System Admin');
                    mail.setTemplateId(et.Id);            
                    //mail.setWhatId(objFaqKav.Id);
                    lstMassEmailMsg.add(mail);
                }
            }
        }
        
        //List<GroupMember> lstGroupMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN: lstGrp];
        
        
        /*
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!Contact.FirstName}', c.FirstName);

        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!Contact.FirstName}', c.FirstName);
        htmlBody = htmlBody.replace('{!myCustomString}', myCustomString);

        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Contact.FirstName}', c.FirstName);
        plainBody = plainBody.replace('{!myCustomString}', myCustomString);
        */
        
        //Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
        
        Messaging.sendEmail(lstMassEmailMsg);
    }

}