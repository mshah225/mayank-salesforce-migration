public without sharing class LiveAgentPostSurveyController {
    public String postChatSurveyLink { get; set; }
    public String agentOfflineMessage { get; set; }
    public String contactName { get; set; }
    public String nonAuthCallerId { get; set; }

    public LiveAgentPostSurveyController() {
        setPostChatSurveyLink();
        setNonAuthCallerId();
        setAgentOfflineMessage();
        getContact();
    }

    private void setPostChatSurveyLink() {
        List<Live_Agent_Setting__mdt> settings = [
            SELECT Value__c
            FROM Live_Agent_Setting__mdt
            WHERE DeveloperName = 'Post_Chat_Survey_Link'
            LIMIT 1
        ];

        postChatSurveyLink = settings.isEmpty() ? '' : settings[0].Value__c;
    }

    // ContactId for non-auth
    private void setNonAuthCallerId() {
        List<Live_Agent_Setting__mdt> callerIdSetting = [
            SELECT Value__c
            FROM Live_Agent_Setting__mdt
            WHERE DeveloperName = 'Non_Authenticated_CallerId'
            LIMIT 1
        ];

        nonAuthCallerId = callerIdSetting[0].Value__c;
    }

    private void setAgentOfflineMessage() {
        List<LiveAgent_Custom_Message__c> offlineMessages = [
            SELECT Custom_Message__c
            FROM LiveAgent_Custom_Message__c
            WHERE LiveAgent_Button__c = 'Agent Offline'
            ORDER BY CreatedDate DESC
        ];
        agentOfflineMessage = offlineMessages.isEmpty()
            ? 'We apologize for the inconvenience. We are having trouble connecting you with a representative. Please call 1-855-278-5080 to speak to a representative immediately.'
            : offlineMessages[0].Custom_Message__c;
    }

    private void getContact() {
        // Default contact name
        contactName = 'Visitor';

        // Params
        String parameterList = ApexPages.currentPage().getParameters().get('attachedRecords');
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(parameterList);

        // Search
        String contactId = (String) m.get('ContactId');
        String caseId = (String) m.get('CaseId');

        // If no contactId in the params, try getting it from the case
        if (contactId == null) {
            Case chatCase = [SELECT ContactId FROM Case WHERE Id = :caseId LIMIT 1];
            contactId = chatCase.ContactId;
        }

        // If we have a contactId, and its not our non-auth contact
        if (contactId != null && !contactId.equals(nonAuthCallerId)) {
            Contact chatter = [SELECT FirstName FROM Contact WHERE Id = :contactId LIMIT 1];
            // If we have a contact, use their first name
            if (chatter.Id != null) {
                contactName = chatter.FirstName;
            }
        }
    }
}
