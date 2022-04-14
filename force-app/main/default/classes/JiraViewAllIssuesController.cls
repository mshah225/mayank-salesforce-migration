public class JiraViewAllIssuesController {
    @AuraEnabled
    public static List<JiraIssue> getIssuesForUser() {
        String asurite = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Alias;
        String jiraResponse = JiraCallout.getIssues(asurite);
        return createMapFromResponse(jiraResponse);
    }

    @AuraEnabled
    public static List<JiraIssue> getWatchedIssuesForUser() {
        String asurite = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Alias;
        String jiraResponse = JiraCallout.getWatchedIssues(asurite);
        return createMapFromResponse(jiraResponse);
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
        @AuraEnabled
        public String issueId { get; set; }
        @AuraEnabled
        public String summary { get; set; }
        @AuraEnabled
        public String key { get; set; }
        @AuraEnabled
        public String issueType { get; set; }
        @AuraEnabled
        public String status { get; set; }

        public JiraIssue(String issueId, String summary, String key, String issueType, String Status) {
            this.issueId = issueId;
            this.summary = summary;
            this.key = key;
            this.issueType = issueType;
            this.status = status;
        }
    }
}
