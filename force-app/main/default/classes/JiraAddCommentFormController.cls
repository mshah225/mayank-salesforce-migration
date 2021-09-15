public class JiraAddCommentFormController {
    @AuraEnabled
    public static void submitForm(String ticketComment, String jiraKey, String status) {
        JIRAWebserviceCallout.addComment(jiraKey, ticketComment);
        JIRAWebserviceCallout.updateStatus(jiraKey, status);
    }
}
