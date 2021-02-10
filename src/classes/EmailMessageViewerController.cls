public with sharing class EmailMessageViewerController {
    public String emailId;
    public String emailBody { get; set; }

    public EmailMessageViewerController() {
        emailId = ApexPages.currentPage().getParameters().get('id'); //'02s21000000EeEF'
        init();
    }

    public void init() {
        List<EmailMessage> msg = [SELECT ActivityId, Subject, HtmlBody FROM EmailMessage WHERE Id = :emailId];
        if (msg.size() > 0) {
            emailBody = msg[0].HtmlBody;
        }
    }
}
