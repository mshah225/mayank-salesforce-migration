public class JiraViewAllIssuesController {
    
    @AuraEnabled
    public static List<JiraIssue> getIssuesForUser() {
        String asurite = [SELECT Alias FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Alias;
        List<JiraIssue> issuesForUser = new List<JiraIssue>();
        String jiraResponse = JiraWebserviceCallout.getIssues(asurite);
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
    @AuraEnabled
    public static void submitQAForm(String devTestingResults, String qaTestPlan, String qaTesters, String dataLoads, String qaConfigurations, String jiraKey) {
        String comment = 'DEV Testing Results and Summary: \\n' + devTestingResults + '\\n'
            				   + 'QA Test Plan: \\n' + qaTestPlan + '\\n'
            				   + 'QA Tester(s): \\n' + qaTesters + '\\n'
            				   + 'Data Loads : \\n' + dataLoads + '\\n'
            				   + 'QA Configuration Items: \\n' + qaConfigurations;
        JIRAWebserviceCallout.addComment(jiraKey, comment); 
        JIRAWebserviceCallout.updateStatus(jiraKey, 'Ready For QA Testing');
    }
    
    @AuraEnabled
    public static void submitSecondTechForm(String jiraKey, String testingResults, String migratingFiles, String summary) {
        String comment = 'How did your testing in the QA Full Sandbox go? \\n' + testingResults + '\\n'
            				   + 'List of items to migrate: \\n' + migratingFiles + '\\n'
            				   + 'Please provide a short description of your change for our users: \\n' + summary;
        JIRAWebserviceCallout.addComment(jiraKey, comment); 
        JIRAWebserviceCallout.updateStatus(jiraKey, '2nd Technical Review'); 
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