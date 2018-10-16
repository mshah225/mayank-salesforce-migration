public class JiraViewAllIssuesController {
    
    @AuraEnabled
    public static List<JiraIssue> getIssuesForUser() {
        String asurite = [SELECT Alias FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Alias;
        String jiraResponse = JiraWebserviceCallout.getIssues(asurite);
        return createMapFromResponse(jiraResponse);
    }
    
    private static List<JiraIssue> createMapFromResponse(String jiraResponse) {
        List<JiraIssue> issuesForUser = new List<JiraIssue>();
        Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(jiraResponse);
        List<Object> jiraIssues = (List<Object>)deserializedResponse.get('issues');
        for(Object issue : jiraIssues) {
            Map<String, Object> issueData = (Map<String, Object>)issue;
            Map<String, Object> fieldData = (Map<String, Object>)issueData.get('fields');
            JiraIssue issueForUser = new JiraIssue((String)issueData.get('id'), (String)fieldData.get('summary'), (String)issueData.get('key'));
            issuesForUser.add(issueForUser);
        }
        return issuesForUser;
    }
    
    public class JiraIssue {
        @AuraEnabled public String issueId {set; get;}
        @AuraEnabled public String summary {set; get;}
        @AuraEnabled public String key {set; get;}
        
        public JiraIssue(String issueId, String summary, String key) {
            this.issueId = issueId;
            this.summary = summary;
            this.key = key;
        }
    }
}