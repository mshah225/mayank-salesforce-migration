@RestResource(urlMapping='/InsertEmailMessage/*')
global class InsertEmailMessage {
    @HttpPost
    global static RestCallResponse createEmailMessage(
        String emailTextBody,
        String parentId,
        String emailSubject,
        String fromName,
        String fromAddress,
        String toAddress
    ) {
        Messaging.InboundEmail emailResponse = new Messaging.InboundEmail();
        List<String> toAddressAsList = new List<String>();
        toAddressAsList.add(toAddress);
        emailResponse.fromAddress = fromAddress;
        emailResponse.fromName = fromName;
        emailResponse.plainTextBody =
            emailTextBody +
            '\n\n' +
            GenerateReferenceIdOnEmailBody.addReferenceIdToEmailBody(parentId);
        emailResponse.toAddresses = toAddressAsList;
        emailResponse.subject = emailSubject;

        Messaging.InboundEnvelope emailResponseEnvelope = new Messaging.InboundEnvelope();
        emailResponseEnvelope.toAddress = toAddress;
        emailResponseEnvelope.fromAddress = fromAddress;

        Messaging.InboundEmailResult emailResult;

        try {
            emailResult = new CaseInboundEmailHandler().handleInboundEmail(emailResponse, emailResponseEnvelope);
            if (emailResult.success) {
                RestCallResponse restResponseObject = new RestCallResponse('success', emailResult.message);
                return restResponseObject;
            } else {
                RestCallResponse restResponseObject = new RestCallResponse('failure', emailResult.message);
                return restResponseObject;
            }
        } catch (Exception e) {
            List<String> errorCaseVariables = new List<String>();
            errorCaseVariables.add(
                ErrorLogger.convertStringToJSON('Error Info: ', 'Could not send email message from ASU Community')
            );
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('System Error Message: ', emailResult.message));
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Exception Error Message: ', e.getMessage()));
            errorCaseVariables.add(ErrorLogger.convertStringToJSON('Case Id: ', parentId));
            ErrorLogger.log(e, errorCaseVariables, false);
            RestCallResponse restResponseObject = new RestCallResponse('failure', emailResult.message);
            return restResponseObject;
        }
    }
}
