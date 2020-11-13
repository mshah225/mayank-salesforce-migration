@RestResource(urlMapping='/EmailService/*')
global class EmailAPIService {
    static Map<String, String> configMap = new Map<String, String>();

    @HttpPost
    global static void sendAutoReply(Id emailCaseId, Id emailContactId, Id carId) {
        loadConfigurationSettings();

        // Get ReplyTo from CAR
        List<Case_Assignment_Rule__c> assignmentRule = new List<Case_Assignment_Rule__c>();
        assignmentRule = [
            SELECT Email_Address__c, Reply_To_Email_Address__c, Customer_Notice_Email_From_Name__c, Email_Template_ID__c
            FROM Case_Assignment_Rule__c
            WHERE Id = :carId
        ];

        String replyToAddress = assignmentRule[0].Reply_To_Email_Address__c;
        String emailFromName = assignmentRule[0].Customer_Notice_Email_From_Name__c;
        Id emailTemplateId = assignmentRule[0].Email_Template_ID__c;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(emailContactId);
        mail.setTemplateId(emailTemplateId);

        if (emailCaseId != null) {
            mail.setWhatId(emailCaseId);
        }

        OrgWideEmailAddress oweaToUse = new OrgWideEmailAddress();
        OrgWideEmailAddress defaultOwea = getDefaultOrgWideEmailAddress();
        Boolean noOweaFound = false;

        // Find the appropriate OrgWideEmailAddress for this reply
        try {
            oweaToUse = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :replyToAddress];
            mail.setOrgWideEmailAddressId(oweaToUse.Id);
        } catch (Exception e) {
            // Use context user's information if there is no default OrgWideEmailAddress configured
            if (defaultOwea == null) {
                mail.setSenderDisplayName(emailFromName);
            } else {
                mail.setOrgWideEmailAddressId(defaultOwea.Id);
            }
        }

        //Send the email
        try {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        } catch (Exception e) {
            //Most likely SINGLE_EMAIL_LIMIT_EXCEEDED; catching so the transaction will continue
        }
    }

    /**
     * Get the Org Wide Email Address
     */
    global static OrgWideEmailAddress getDefaultOrgWideEmailAddress() {
        OrgWideEmailAddress oweaLookup;
        String orgWideEmailAddress = getConfigurationSetting('Default Org Wide Email Address');

        if (orgWideEmailAddress != null && orgWideEmailAddress != '') {
            List<OrgWideEmailAddress> oweaList = [
                SELECT Id, DisplayName, Address
                FROM OrgWideEmailAddress
                WHERE Address = :orgWideEmailAddress
            ];
            if (oweaList.size() > 0) {
                oweaLookup = oweaList[0];
            }
        }

        return oweaLookup;
    }

    /**
     * Get config settings
     */
    global static String getConfigurationSetting(String settingName) {
        if (configMap.containsKey(settingName)) {
            return configMap.get(settingName);
        }

        return '';
    }
    /**
     * Load config settings
     */
    global static void loadConfigurationSettings() {
        Email_To_Case_Configuration__c[] configList = [SELECT Name, Value__c FROM Email_To_Case_Configuration__c];
        if (configList.size() > 0) {
            for (Email_To_Case_Configuration__c c : configList) {
                configMap.put(c.Name, c.Value__c);
            }
        }
    }
}
