@RestResource(urlMapping='/insertEmailMessage/*')
global class EmailMessageInsert {
    @HttpPost
    global static String createEmailMessage(String strTextBody, String  strParentId, String strSubject, Boolean boolIncoming, String strFromName, String strFromAddress, String strStatus){
        EmailMessage response = new EmailMessage();
        response.TextBody = strTextBody;
        response.Incoming = boolIncoming;
        response.ParentId = strParentId;
        response.Subject = strSubject;
        response.FromName = strFromName;
        response.FromAddress = strFromAddress;
        response.Status = strStatus;
        try{
            insert response;
            return 'success';
        }
        catch(Exception e){
            return 'failure';
            
        }
    } 
    
}