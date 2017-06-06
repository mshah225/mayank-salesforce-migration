global class EmailAlertArticlesController implements Schedulable {

    global void execute(SchedulableContext sc) {
        Integer intAddDays=10;
        String stagnantQuery='SELECT Id,ArticleNumber, Title, PublishStatus,Functional_Group__c, ValidationStatus,Article_Expiration_Date__c ' + 
            'FROM FAQ__kav ' + 
            'WHERE PublishStatus=\'Draft\' ' +
                'AND Language=\'en_US\' ' + 
                'AND (ValidationStatus=\'Draft\' OR ValidationStatus=\'Format Review\' OR ValidationStatus=\'Content Review\') ' + 
                'AND LastModifiedDate<LAST_N_DAYS:'+ intAddDays;
                
        SendEmail(stagnantQuery, true, false);
        
        String expiredQuery= 'SELECT Id,ArticleNumber,Title,PublishStatus, Functional_Group__c, ValidationStatus, Article_Expiration_Date__c ' +
            'FROM FAQ__kav ' +
            'WHERE PublishStatus=\'Online\' ' +
                'AND Language=\'en_US\' ' + 
                'AND (Article_Expiration_Date__c< '+ String.valueOf(System.Today()) + ' OR Article_Expiration_Date__c= ' + String.valueOf(System.Today().addDays(-30)) + ')';
        
        SendEmail(expiredQuery, false, true);
    }
    
    
    public Set<Id> returnUserIds(String strFuncGroup, List<Group> lstGrp) {
        List<Group> retGroup = new List<Group>();
        Set<Id> retUserId = new Set<Id>();
        for(Group objGrp: lstGrp) {
            if(objGrp.Name.contains(strFuncGroup)) {
                retUserId.addAll(getUserIdsFromQueue(objGrp.Id));
            }
        }
        return retUserId;
    }
    
    /*
    A method to get the Users from the queue. If the queue contains a group then users of the group are added.
    */
    
    public Set<Id> getUserIdsFromQueue(Id queueId) {
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

    
    /*
    Method to send an email based on the article query. 
    If the email is for stagnant articles then a dummy update to the article is done so that it fires again 10 days .
    For expired articles no such dummy updates is needed.
    */
    
    public void SendEmail(String articleQuery, Boolean boolStagnant, Boolean boolExpiry) {
        String subject;
        String htmlBody;
        String plainBody;
        Set<String> setStrQueryFuncGroup = new Set<String>();
        Set<String> setExcludeFuncGroup = new Set<String>();
        Set<String> setStrFuncGroup = new Set<String>();
        Map<String,List<FAQ__kav>> mapFuncGrouptoArticles = new Map<String,List<FAQ__kav>>(); 
        List<FAQ__kav> lstForMap = new List<FAQ__kav>();
        List<FAQ__kav> lstArticleUpdate = new List<FAQ__kav>();
        List<Id> lstEmailUserId;
        List<Messaging.SingleEmailMessage> lstMassEmailMsg = new List<Messaging.SingleEmailMessage>();
        Map<String, Set<Id>> mapFuncGroupsToUsers = new Map<String,Set<Id>>();
        List<Group> lstGrp;
        
        for(Knowledge_Functional_Group__c objKnowFuncGroup: [SELECT Name,Functional_Group_Name__c FROM Knowledge_Functional_Group__c]) {
            setExcludeFuncGroup.add(objKnowFuncGroup.Functional_Group_Name__c);
        }        
        
        for(FAQ__kav objFaqKav: Database.query(articleQuery)) {
            if(objFaqKav.Functional_Group__c!=null && objFaqKav.Functional_Group__c!='' && !setExcludeFuncGroup.contains(objFaqKav.Functional_Group__c)) {
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
        
        lstGrp = [
            SELECT Id,Name
            FROM Group 
            WHERE Type='Queue' 
                AND Name LIKE :setStrQueryFuncGroup
        ];
        
        for(String strFuncGroup: setStrFuncGroup) {
            mapFuncGroupsToUsers.put(strFuncGroup, returnUserIds(strFuncGroup, lstGrp));
        }
        
        EmailTemplate et=[SELECT Id,Subject,htmlValue,Body FROM EmailTemplate WHERE Name = 'Knowledge Article Expired' LIMIT 1];
       
        Messaging.SingleEmailMessage mail;
        
        for(String strFuncGroup: setStrFuncGroup) {
            if(mapFuncGroupsToUsers.containsKey(strFuncGroup) && mapFuncGroupToArticles.containsKey(strFuncGroup)) {
                lstEmailUserId=new List<Id>();
                lstEmailUserId.addAll(mapFuncGroupsToUsers.get(strFuncGroup));
                for(FAQ__kav objFaqKav: mapFuncGroupToArticles.get(strFuncGroup)) {
                    lstArticleUpdate.add(objFaqKav);
                    subject = et.subject;
                    htmlBody = et.htmlValue;
                    htmlBody=htmlBody.replace('{!FAQ__kav.Title}',objFaqKav.Title);
                    htmlBody=htmlBody.replace('{!FAQ__kav.ArticleNumber}',objFaqKav.ArticleNumber);
                    htmlBody=htmlBody.replace('{!FAQ__kav.Link}', System.URL.getSalesforceBaseURL().toExternalForm() + '/' + objFaqKav.Id);
                    mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(lstEmailUserId);
                    mail.setTemplateId(et.Id);     
                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlBody);
                    lstMassEmailMsg.add(mail);
                }
            }
        }
        
        if(boolStagnant && lstArticleUpdate!=null && lstArticleUpdate.size()>0) 
            update lstArticleUpdate;
        
        if(lstMassEmailMsg!=null && lstMassEmailMsg.size()>0)
            Messaging.sendEmail(lstMassEmailMsg);
        
        
    }
    
    
}