@RestResource(urlMapping = '/InsertEmailMessage/*')
global class InsertEmailMessage {

    @HttpPost
    global static RestCallResponse createEmailMessage(
            String emailTextBody, 
            String  parentId, 
            String emailSubject, 
            Boolean isIncoming, 
            String fromName, 
            String fromAddress, 
            String toAddress, 
            String status) {
        EmailMessage emailResponse = new EmailMessage();
        emailResponse.TextBody = emailTextBody;
        emailResponse.Incoming = isIncoming;
        emailResponse.ParentId = parentId;
        emailResponse.Subject = emailSubject;
        emailResponse.FromName = fromName;
        emailResponse.FromAddress = fromAddress;
        emailResponse.ToAddress = toAddress;
        emailResponse.Status = status;
        try {
            insert emailResponse;
            RestCallResponse restResponseObject = new RestCallResponse('success', emailResponse.Id);
            return restResponseObject;
        } catch (Exception e) {
            List<String> errorCaseVariables = new List<String>();
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Error Info: ', e.getMessage()));
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Case Id: ', parentId));
            ErrorLogger.log(e, errorCaseVariables, false);
            RestCallResponse restResponseObject = new RestCallResponse('failure', e.getMessage());
            return restResponseObject;        
        } 
    }
}