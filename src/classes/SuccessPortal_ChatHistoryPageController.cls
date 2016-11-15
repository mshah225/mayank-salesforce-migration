public with sharing class SuccessPortal_ChatHistoryPageController
{
    public Boolean isStudentAssigned {get;set;}
    public List<ChatMessage> chatHistory {get;set;}    
    public string startDate {get;set;}
    public string endDate {get;set;}
    public Date todayDate = date.today();
    public boolean isTest {get;set;}
    
    //inbound params
    public string userId {get;set;} //user who opened the page
    public string userASURiteId {get;set;} 
    public string resourceUserId {get;set;}
    public string resourceASURiteId {get;set;}
    public string studentASURiteId {get;set;}
    
    public string coachResourceRecordTypeId {get;set;}
    public boolean isCoachUser;
    public boolean isCoachLead;
    public boolean isCoachManager;
    public boolean isCoachAdmin;
    public boolean isError {get;set;}
    public Date todaysDate {get;set;}
    
    public SuccessPortal_ChatHistoryPageController()
    {
        init();
    }
    
    public void init()
    {
        todaysDate = Date.Today();
        isError = false;
        userId = userinfo.getUserId();
        checkUserRole();
        
        if(ApexPages.currentPage().getParameters().containsKey('resourceASURiteId')){
            resourceASURiteId = ApexPages.currentPage().getParameters().get('resourceASURiteId');
        }
        if(ApexPages.currentPage().getParameters().containsKey('studentASURiteId')){
            studentASURiteId = ApexPages.currentPage().getParameters().get('studentASURiteId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('startDate') && !ApexPages.currentPage().getParameters().containsKey('startDateSrch')){
            startDate = ApexPages.currentPage().getParameters().get('startDate');
        }else if(ApexPages.currentPage().getParameters().containsKey('startDateSrch')){
            startDate = ApexPages.currentPage().getParameters().get('startDateSrch');
        }
        if(ApexPages.currentPage().getParameters().containsKey('endDateSrch')){
            endDate = ApexPages.currentPage().getParameters().get('endDateSrch');
        }else{
            endDate = getFormattedDate(todaysDate);
        }
        

        if(resourceASURiteId!=null && studentASURiteId != null && startDate!=null)
        {
            //now let's check to see if the requesting user is the same as the passed in user!
            if(userASURiteId==resourceASURiteId)
            {
                getResourceUserId();
                validateUserResourceMatch();
                isError = false;
                chatHistory = new List<ChatMessage>();
                getChatHistory();
            }
            else
            {
                //are they a manager or admin? if so, let them see the chat history
                if(isCoachManager||isCoachAdmin)
                {
                    isStudentAssigned = true;
                    isError = false;
                    chatHistory = new List<ChatMessage>();
                    getChatHistory();
                }
            }
        }
        else
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Missing parameters');
            ApexPages.addMessage(myMsg);
        }
    }

    //format the date to be consistent
    public String getFormattedDate(Date d){
        return DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYY-MM-dd');
    }

    //get the chat history
    public void getChatHistory(){
    
        chatHistory.clear();

        if(isStudentAssigned)
        {
            HTTPResponse res;
            string jsonContent;
            if(isTest!=null && isTest==true) {
                
                Test.setMock(HttpCalloutMock.class, new HTTPRestService_RocketChat_MockImpl()); 
                //jsonContent = '{"agentStates": [{"agentId": "2547405","agentStateId": "1","agentStateName": "LoggedOut","businessUnitId": "4595606","contactId": "","isActive": "True"}]}';
                jsonContent = '{ "statusCode": 200, "status": "success", "data": [ { "_id": "hREvzXjdbjXg6AbrM", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "test", "ts": "2016-07-22T23:20:27.113Z", "u": { "_id": "qCDzH5q3kSbkgjRjG", "username": "awinter6", "name": "Allan Wintersieck" }, "_updatedAt": "2016-07-22T23:20:27.114Z" }, { "_id": "K26HXGyZWrGLphFCp", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "test", "ts": "2016-07-22T23:41:31.043Z", "u": { "_id": "qCDzH5q3kSbkgjRjG", "username": "awinter6", "name": "Allan Wintersieck" }, "_updatedAt": "2016-07-22T23:41:31.044Z" }, { "_id": "rQPnbpnyok8jtXKFg", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "test", "ts": "2016-07-22T23:42:13.785Z", "u": { "_id": "qCDzH5q3kSbkgjRjG", "username": "awinter6", "name": "Allan Wintersieck" }, "_updatedAt": "2016-07-22T23:42:13.787Z" }, { "_id": "m6u9r5WjkGTAYyxmP", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "[ ](https://pitch.asuonline.asu.edu/direct/dbressan?msg=xBNw4cDutM7Dit9Zb) test", "ts": "2016-08-03T18:19:47.220Z", "u": { "_id": "qCDzH5q3kSbkgjRjG", "username": "awinter6", "name": "Allan Wintersieck" }, "urls": [ { "url": "https://pitch.asuonline.asu.edu/direct/dbressan?msg=xBNw4cDutM7Dit9Zb", "ignoreParse": true } ], "attachments": [ { "text": "www.google.com", "author_name": "dbressan", "author_icon": "/avatar/dbressan.jpg?_dc=0", "message_link": "https://pitch.asuonline.asu.edu/direct/dbressan?msg=xBNw4cDutM7Dit9Zb", "ts": "2016-07-26T21:45:36.663Z" } ], "_updatedAt": "2016-08-03T18:19:47.222Z" }, { "_id": "xYb6FreC5wkGwpnuw", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "[ ](https://pitch.asuonline.asu.edu/direct/dbressan?msg=xBNw4cDutM7Dit9Zb) ", "ts": "2016-08-03T18:20:52.388Z", "u": { "_id": "qCDzH5q3kSbkgjRjG", "username": "awinter6", "name": "Allan Wintersieck" }, "urls": [ { "url": "https://pitch.asuonline.asu.edu/direct/dbressan?msg=xBNw4cDutM7Dit9Zb", "ignoreParse": true } ], "attachments": [ { "text": "www.google.com", "author_name": "dbressan", "author_icon": "/avatar/dbressan.jpg?_dc=0", "message_link": "https://pitch.asuonline.asu.edu/direct/dbressan?msg=xBNw4cDutM7Dit9Zb", "ts": "2016-07-26T21:45:36.663Z" } ], "_updatedAt": "2016-08-03T18:20:52.391Z" }, { "_id": "M565rtnFpyzQA6NW5", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "", "file": { "_id": "sbrf746i9ftkKeo2K" }, "groupable": false, "attachments": [ { "title": "File Uploaded: sample.pdf", "title_link": "/file-upload/sbrf746i9ftkKeo2K/sample.pdf", "title_link_download": true } ], "ts": "2016-08-05T17:34:49.984Z", "u": { "_id": "uWQ4Q7qGPsvubyFoz", "username": "doalcant", "name": "David Alcantar" }, "_updatedAt": "2016-08-05T17:34:49.985Z" }, { "_id": "QdXkB9kWRjjNcCZ6g", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "test file", "ts": "2016-08-05T17:38:43.566Z", "u": { "_id": "uWQ4Q7qGPsvubyFoz", "username": "doalcant", "name": "David Alcantar" }, "_updatedAt": "2016-08-05T17:38:43.568Z" }, { "_id": "75rpQuuqkadGQvQnC", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "", "file": { "_id": "TB7fzXAQiisQsexnF" }, "groupable": false, "attachments": [ { "title": "File Uploaded: sample2.pdf", "title_link": "/file-upload/TB7fzXAQiisQsexnF/sample2.pdf", "title_link_download": true } ], "ts": "2016-08-05T17:39:13.011Z", "u": { "_id": "uWQ4Q7qGPsvubyFoz", "username": "doalcant", "name": "David Alcantar" }, "_updatedAt": "2016-08-05T17:39:13.012Z" }, { "_id": "Cb4EGDCyq5hWxgzAC", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "msg": "test", "ts": "2016-08-05T17:39:15.013Z", "u": { "_id": "uWQ4Q7qGPsvubyFoz", "username": "doalcant", "name": "David Alcantar" }, "_updatedAt": "2016-08-05T17:39:15.014Z" }, { "_id": "QPXzsLPGqHTEYLZtM", "t": "restricted-view", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "ts": "2016-08-04T18:45:51.172Z", "msg": "There are currently no open cases. Use /opencase to open one", "u": { "_id": "ASU-Assist", "username": "ASU-Assist", "name": "ASU Assist" }, "groupable": false, "private": true, "_updatedAt": "2016-08-04T18:45:52.272Z" }, { "_id": "DanT8hHwjAozFGKGP", "t": "restricted-view", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "ts": "2016-08-04T18:51:24.014Z", "msg": "Could not connect to SalesForce to log new case", "u": { "_id": "ASU-Assist", "username": "ASU-Assist", "name": "ASU Assist" }, "groupable": false, "private": true, "_updatedAt": "2016-08-04T18:51:24.165Z" }, { "_id": "55DbahuZicERDnC9t", "t": "restricted-view", "rid": "qCDzH5q3kSbkgjRjGuWQ4Q7qGPsvubyFoz", "ts": "2016-08-04T20:47:45.766Z", "msg": "Could not connect to SalesForce to log new case", "u": { "_id": "ASU-Assist", "username": "ASU-Assist", "name": "ASU Assist" }, "groupable": false, "private": true, "_updatedAt": "2016-08-04T20:47:45.944Z" } ] }';
            }
            else
            {
                jsonContent = HTTPRestService_RocketChat.GETRestCallout('getMessageInRange?From=' + resourceASURiteId + '&To=' + studentASURiteId + '&Start=' + startDate + 'T00:00:00.000Z&End=' + endDate + 'T23:59:59.999Z');
            } 
            JSONParser parser = JSON.createParser(jsonContent);
            
            if(parser != null)
            {    
                ChatMessage objChatMessage = new ChatMessage();
                Boolean found = false;
                System.JSONToken token;
                String text = '';

                   while((token = parser.nextToken()) != null) {
                    
                    if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                            text = parser.getText();
                            if (parser.nextToken() != JSONToken.VALUE_NULL) {
                                if (text == 'msg') {
                                    if(parser.getText() !=''){
                                        objChatMessage.setChatMessage(parser.getText());
                                        found=true;
                                    }
                                } else if (text == 'ts') {
                                    objChatMessage.setChatDate(parser.getDatetimeValue());
                                     found=true;
                                } else if (text == 'u') {
                                    //Starts reading user info
                                    while (parser.nextToken() != JSONToken.END_OBJECT) {
                                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                            text = parser.getText();
                                            if (parser.nextToken() != JSONToken.VALUE_NULL) {
                                                if (text == 'username') {
                                                    objChatMessage.setChatUsername(parser.getText());
                                                     found=true;
                                                } else if (text == 'name') {
                                                    objChatMessage.setChatName(parser.getText());
                                                     found=true;
                                                }
                                            }
                                        }
                                    }
                                } else if (text == 'urls') {
                                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                                        while (parser.nextToken() != JSONToken.END_OBJECT) {
                                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                                text = parser.getText();
                                                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                                                    if (text == 'url') {
                                                        objChatMessage.setChatMessage(parser.getText());
                                                        objChatMessage.setHasUrl(true);
                                                        found=true;
                                                    } 
                                                }
                                            }
                                        }
                                    }
                                } else if (text == 'attachments') {
                                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                                        while (parser.nextToken() != JSONToken.END_OBJECT) {
                                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                                text = parser.getText();
                                                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                                                    if (text == 'title_link') {
                                                       objChatMessage.setChatMessage('https://pitch.asuonline.asu.edu/' + parser.getText());
                                                       objChatMessage.setHasUrl(true);
                                                       found=true;
                                                    } else if (text == 'message_link'){
                                                        objChatMessage.setChatMessage(parser.getText());
                                                       objChatMessage.setHasUrl(true);
                                                       found=true;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                        
                       //end of if END OF OBJECT
                       }else{
                            if (found) {// Only append to list if we extracted info we wanted.
                                chatHistory.add(objChatMessage); 
                                objChatMessage = new ChatMessage();// allocate more memory to store the next object 
                                found = false;// reset
                            }           
                            // advance to next object
                            token = parser.nextToken();
                            if (token == JSONToken.END_ARRAY) {// we reached end of array of objects representing zipcodes
                                break;
                            }
                       } 
                    }
            }   
        }
    }
    
    //make sure the passed in resource is the coach for the passed in student
    public void validateUserResourceMatch(){
        isStudentAssigned = false;
        System.Debug('RESOURCEUSERID='+resourceUserId);
        System.Debug('STUDENTUSERID='+studentASURiteId);
        List<Success_Student__c> myStudents = new List<Success_Student__c>();
        myStudents = [SELECT Id, ASURiteID__c FROM Success_Student__c 
                        WHERE Success_Resource__r.Resource__c =: resourceUserId
                        AND ASURiteID__c =: studentASURiteId];
        //we have a match!
        if(myStudents.size()>0)
        {
            isStudentAssigned = true;
        }
    }
    
    private void getResourceUserId()
    {
        List<Success_Resource__c> resource = [SELECT Resource__c FROM Success_Resource__c 
                                            WHERE ASURiteID__c =: resourceASURiteId
                                            AND IsActive__c = true];
        if(resource.size()>0)
        {
            resourceUserId = resource[0].Resource__c;
        }
    }

    //check the role of the user who opened the page
    private void checkUserRole()
    {
        isCoachUser = false;
        isCoachLead = false;
        isCoachManager = false;
        isCoachAdmin = false;
        populateCoachResourceRecordTypeId();

        List<Success_Resource__c> resource = [SELECT Id, Role__c, ASURiteID__c, Success_POD__c, Success_POD__r.OwnerId, Committee_Code__c,RecordTypeId FROM Success_Resource__c 
                                            WHERE Resource__c =: userId
                                            AND IsActive__c = true 
                                            ORDER BY CreatedDate ASC];
        if(resource.size()>0)
        {
            userASURiteId = resource[0]. ASURiteID__c;
            if(resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'User')
            {
                isCoachUser = true;
            }
            else if (resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'Lead' )
            {
                isCoachLead = true;
            }
            else if (resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'Manager')
            {
                isCoachManager = true;
            }
            else if (resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'Admin')
            {
                isCoachAdmin = true;
            }
        }

    }
    
    //get the coach resource recordtype id
    public void populateCoachResourceRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_Resource__c'];
        if(rectype.size()>0)coachResourceRecordTypeId=rectype[0].Id;
    }

    //custom table
    public class ChatMessage{
        public string chatUsername {get;set;}
        public string chatName {get;set;}
        public string chatMessage {get;set;}
        public Datetime chatDate {get;set;}
        public Boolean hasUrl {get;set;}

        public ChatMessage(){
            chatUsername = '';
            chatName = '';
            chatMessage = '';
            chatDate = Date.Today();
            hasUrl = false;
        }

        public void setChatMessage(String value){
            chatMessage = value;
        }
        public void setChatUsername(String value){
            chatUsername = value;
        }
        public void setChatName(String value){
            chatName = value;
        }
        public void setChatDate(DateTime value){
            chatDate = value;
        }
        public void setHasUrl(Boolean value){
            hasUrl = value;
        }
    }

}