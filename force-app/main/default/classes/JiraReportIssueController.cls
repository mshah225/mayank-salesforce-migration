public class JiraReportIssueController {
    @AuraEnabled
    public static String callout(String title, String description, String watchers, String type) {
        String jiraKey;
        System.debug(type);
        if (type.contains('New')) {
            jiraKey = JiraCallout.createNewIssue(title, description, watchers, 'Task'); // create
            JiraCallout.updateStatus(jiraKey, 'New Development Request'); // set status
            if (watchers != null && watchers != '')
                JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        } else {
            jiraKey = JiraCallout.createNewIssue(title, description, watchers, 'Bug'); // create
            JiraCallout.updateStatus(jiraKey, 'Ready For Work'); // set status
            if (watchers != null && watchers != '')
                JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        }
        return jiraKey;
    }

    @AuraEnabled
    public static String createBugReport(String title, String description, String watchers) {
        String jiraKey = JiraCallout.createTicket(title, description, 'Bug'); // create
        JiraCallout.updateStatus(jiraKey, 'Ready For Work'); // set status
        JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        return jiraKey;
    }

    @AuraEnabled
    public static String createNewDevelopmentRequest(String title, String description, String watchers) {
        String jiraKey = JiraCallout.createTicket(title, description, 'Task'); // create
        JiraCallout.updateStatus(jiraKey, 'New Development Request'); // set status
        JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        return jiraKey;
    }

    @AuraEnabled
    public static String createDataImport(String title, String description, String watchers) {
        String jiraKey = JiraCallout.createTicket(title, description, 'Task'); // create
        JiraCallout.updateStatus(jiraKey, 'Open'); // set status
        JiraCallout.addComponent(jiraKey, 'DATA IMPORT'); // add component
        JiraCallout.addWatchers(jiraKey, watchers); // add watchers if needed
        return jiraKey;
    }
}