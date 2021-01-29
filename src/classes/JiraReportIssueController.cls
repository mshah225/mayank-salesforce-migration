public class JiraReportIssueController {
    @AuraEnabled
    public static String callout(String title, String description, String watchers, String type) {
        String jiraKey;
        System.debug(type);
        if (type.contains('New')) {
            jiraKey = JIRAWebserviceCallout.createNewIssue(title, description, watchers, 'Task');
        } else {
            jiraKey = JIRAWebserviceCallout.createNewIssue(title, description, watchers, 'Bug');
        }
        return jiraKey;
    }
}
