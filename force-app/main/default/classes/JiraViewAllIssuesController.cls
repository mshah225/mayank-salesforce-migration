public class JiraViewAllIssuesController {
    @AuraEnabled
    public static List<JiraIssue> getIssuesForUser(String asurite) {
        String jiraResponse = JiraWebserviceCallout.getIssues(asurite);
        return createMapFromResponse(jiraResponse);
    }

    @AuraEnabled
    public static List<JiraIssue> getWatchedIssuesForUser(String asurite) {
        String jiraResponse = JiraWebserviceCallout.getWatchedIssues(asurite);
        return createMapFromResponse(jiraResponse);
    }

    @AuraEnabled(cacheable=true)
    public static String getIssuesForCurrentUser() {
        return JiraWebserviceCallout.getIssues(getJiraUserId());
    }
    @AuraEnabled(cacheable=true)
    public static String getWatchedIssuesForCurrentUser() {
        return JiraWebserviceCallout.getWatchedIssues(getJiraUserId());
    }

    public static String getJiraUserId() {
        User currentUser = [SELECT Id, Alias FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser.Alias;
    }

    private static List<JiraIssue> createMapFromResponse(String jiraResponse) {
        List<JiraIssue> issuesForUser = new List<JiraIssue>();
        Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(jiraResponse);
        List<Object> jiraIssues = (List<Object>) deserializedResponse.get('issues');
        for (Object issue : jiraIssues) {
            Map<String, Object> issueData = (Map<String, Object>) issue;
            Map<String, Object> fieldData = (Map<String, Object>) issueData.get('fields');
            Map<String, Object> typeData = (Map<String, Object>) fieldData.get('issuetype');
            Map<String, Object> statusData = (Map<String, Object>) fieldData.get('status');
            JiraIssue issueForUser = new JiraIssue(
                (String) issueData.get('id'),
                (String) fieldData.get('summary'),
                (String) issueData.get('key'),
                (String) typeData.get('name'),
                (String) statusData.get('name')
            );
            issuesForUser.add(issueForUser);
        }
        return issuesForUser;
    }

    public class JiraIssue {
        public String issueId;
        public String summary;
        public String key;
        public String issueType;
        public String status;
        public String url;

        public JiraIssue(String issueId, String summary, String key, String issueType, String Status) {
            this.issueId = issueId;
            this.summary = summary;
            this.key = key;
            this.issueType = issueType;
            this.status = status;
            this.url = 'https://asudev.jira.com/browse/' + this.key;
        }
    }
}
