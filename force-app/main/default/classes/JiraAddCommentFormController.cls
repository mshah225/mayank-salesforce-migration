public class JiraAddCommentFormController {
    @AuraEnabled
    public static void submitForm(String ticketComment, String jiraKey, String status) {
        JiraCallout.addComment(jiraKey, ticketComment);
        JiraCallout.updateStatus(jiraKey, status);
    }
}
