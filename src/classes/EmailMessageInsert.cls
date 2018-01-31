@RestResource(urlMapping = '/EmailMessageInsert/*')
global class EmailMessageInsert {
    @HttpPost
    global static String createEmailMessage(
        String emailTextBody, 
        String  parentId, 
        String emailSubject, 
        Boolean isIncoming, 
        String fromName, 
        String fromAddress, 
        String toAddress, 
        String status) {
            EmailMessage response = new EmailMessage();
            response.TextBody = emailTextBody;
            response.Incoming = isIncoming;
            response.ParentId = parentId;
            response.Subject = emailSubject;
            response.FromName = fromName;
            response.FromAddress = fromAddress;
            response.ToAddress = toAddress;
            response.Status = status;
            try {
                insert response;
                return 'success';
            } catch (Exception e) {
                List<String> errorCaseVariables = new List<String>();
                errorCaseVariables.add(ErrorLogger.convertStringToJSON('Case Id: ', parentId));
                errorCaseVariables.add(ErrorLogger.convertStringToJSON('User Name: ', fromName));
                errorCaseVariables.add(ErrorLogger.convertStringToJSON('Email Body: ', emailTextBody));
                ErrorLogger.log(e,errorCaseVariables,false);
                return 'failure';
            }
    } 
}