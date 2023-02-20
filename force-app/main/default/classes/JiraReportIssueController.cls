public class JiraReportIssueController {
    @AuraEnabled
    public static String createBugReport(String title, String description, String watchers) {
        String jiraKey = JiraCallout.createTicket(title, description, 'Bug', ''); // create
        JiraCallout.updateStatus(jiraKey, 'Ready For Work'); // set status
        JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        return jiraKey;
    }

    @AuraEnabled
    public static String createNewDevelopmentRequest(String title, String description, String watchers) {
        String jiraKey = JiraCallout.createTicket(title, description, 'Task', ''); // create
        JiraCallout.updateStatus(jiraKey, 'New Development Request'); // set status
        JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        return jiraKey;
    }

    @AuraEnabled
    public static String createDataImport(String title, String description, String watchers) {
        String jiraKey = JiraCallout.createTicket(title, description, 'Task', 'DATA IMPORT'); // create
        JiraCallout.updateStatus(jiraKey, 'Open'); // set status
        JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        return jiraKey;
    }
}