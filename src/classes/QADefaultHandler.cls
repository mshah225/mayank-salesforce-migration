global class QADefaultHandler implements QuickAction.QuickActionDefaultsHandler {
    private static boolean debug = false;
    global QADefaultHandler() {
    }

    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        EmailMessage em; // Stores the temp EmailMessage object created by the quick action
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults;
        List<String> vars = new List<String>();

        // Check if the quick action is the standard Case Feed send email action
        for (Integer i = 0; i < defaults.size(); i++) {
            if (
                defaults.get(i) instanceof QuickAction.SendEmailQuickActionDefaults &&
                defaults.get(i).getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&
                ((defaults.get(i).getActionName().equals('Case.Email') &&
                defaults.get(i).getActionType().equals('Email')) ||
                (defaults.get(i).getActionName().equals('Case.New_Send_Email') &&
                defaults.get(i).getActionType().equals('SendEmail')))
            ) {
                sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults) defaults.get(i);
                break;
            }
        }

        if (sendEmailDefaults != null) {
            em = (EmailMessage) sendEmailDefaults.getTargetSObject();
            em.FromAddress = getEmailFromAddress(sendEmailDefaults.getContextId());
        }
    }

    global String getEmailFromAddress(Id contextId) {
        String result; // the email to use
        Case c;
        List<String> vars = new List<String>();
        try {
            c = [SELECT OwnerId, RecordTypeId, Most_Recent_Queue__c FROM Case WHERE Id = :contextId];

            if (c.RecordTypeId == IDHelper.getRTID('Case', 'ASU_Advisor_Outreach')) {
                if (Validator.validateId(c.ownerId, group.class)) {
                    result = [SELECT Primary_Email__c FROM Success_pod__c WHERE ownerId = :c.OwnerId LIMIT 1]
                    .Primary_Email__c;
                } else {
                    result = [
                        SELECT Primary_Email__c
                        FROM Success_Pod__c
                        WHERE Owner_Name__c = :c.Most_Recent_Queue__c
                        LIMIT 1
                    ]
                    .Primary_Email__c;
                }
            } else if (c.RecordTypeId == IDHelper.getRTID('Case', 'ASU_Coach_Outreach')) {
                result = [SELECT Recruiter_Email__c FROM User WHERE Id = :UserInfo.getUserId()].Recruiter_Email__c;
            }

            return result;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertIdToJSON('contextId', contextId));
            vars.add(ErrorLogger.convertSObjectToJSON('c', c));
            ErrorLogger.log(e, vars, debug);
            return result;
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
