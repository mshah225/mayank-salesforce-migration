global class QADefaultHandler implements QuickAction.QuickActionDefaultsHandler {
    private static boolean debug = false;
    global QADefaultHandler() {
    }

    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        EmailMessage em; // Stores the temp EmailMessage object created by the quick action
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults;
        List<String> vars = new List<String>();

        // Check if the quick action is the standard Case Feed send email action
        for (Integer x = 0; x < defaults.size(); x++) {
            if (
                defaults.get(x) instanceof QuickAction.SendEmailQuickActionDefaults &&
                defaults.get(x).getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&
                ((defaults.get(x).getActionName().equals('Case.Email') && 
                  defaults.get(x).getActionType().equals('Email')) || 
                 ((defaults.get(x).getActionName().equals('Case.New_Send_Email') && 
                   defaults.get(x).getActionType().equals('SendEmail'))))

            ) {
                sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults) defaults.get(x);
                break;
            }
        }

        if (sendEmailDefaults != null) {
            em = (EmailMessage) sendEmailDefaults.getTargetSObject();
            setEmailFromAndToAddress(sendEmailDefaults.getContextId(), em);
        }
    }

    global void setEmailFromAndToAddress(Id contextId, EmailMessage em) {
        String result;
        Case c;
        List<String> vars = new List<String>();
        try{
            c = [SELECT Contact.Email, OwnerId, RecordTypeId, Most_Recent_Queue__c
                FROM Case
                WHERE Id = :contextId];
            em.ToAddress = c.Contact.Email;
            if (c.RecordTypeId == IDHelper.getRTID('Case', 'ASU_Advisor_Outreach')) {
                List<Success_pod__c> primaryEmailFromPod;
                if (Validator.validateId(c.ownerId, group.class)) {
                    primaryEmailFromPod = [SELECT Primary_Email__c FROM Success_pod__c WHERE ownerId = :c.OwnerId LIMIT 1];
                } else {
                    primaryEmailFromPod = [SELECT Primary_Email__c FROM Success_Pod__c WHERE Owner_Name__c = :c.Most_Recent_Queue__c LIMIT 1];
                }
                if (!primaryEmailFromPod.isEmpty() && primaryEmailFromPod[0].Primary_Email__c != null) {
                    result = primaryEmailFromPod[0].Primary_Email__c;
                }
            } else if (c.RecordTypeId == IDHelper.getRTID('Case', 'ASU_Coach_Outreach')) {
                List<User> primaryEmailFromUser;
                primaryEmailFromUser = [SELECT Recruiter_Email__c FROM User WHERE Id = :UserInfo.getUserId()];
                if (!primaryEmailFromUser.isEmpty() && primaryEmailFromUser[0].Recruiter_Email__c != null) {
                    result = primaryEmailFromUser[0].Recruiter_Email__c;
                }
            }

            if (em.CcAddress == result || result == null) {
                em.CcAddress = null;
            }

            if (result != null) {
                em.FromAddress = result;
            }
        }
        catch(Exception e){
            vars.add(ErrorLogger.convertIdToJSON('contextId', contextId));
            vars.add(ErrorLogger.convertSObjectToJSON('c', c));
            ErrorLogger.log(e, vars, debug);
        }
    }


    global boolean isAdvisorCase(Case context) {
        if (context.RecordTypeId == IDHelper.getRTID('Case', 'ASU_Advisor_Outreach')) {
            return true;
        } else {
            return false;
        }
    }

    global boolean caseOwnedByGroup(Case context) {
        if (Validator.validateId(context.OwnerId, Group.class)) {
            return true;
        } else {
            return false;
        }
    }
}
