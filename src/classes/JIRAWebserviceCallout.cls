global class JIRAWebserviceCallout {
    static final Boolean DEBUG = false;
    static final String USERNAME = ApiUser__c.getValues('Jira').Username__c;
    static final String PASSWORD = ApiUser__c.getValues('Jira').Password__c;
    static final String JIRA_URL = ApiUser__c.getValues('Jira').Url__c;
    
    WebService static String createNewIssue(String summary, String description, String addUsers, String type) {
        List<String> errorLoggerVars = new List<String>();
        String jiraKey;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        
        String endpoint = JIRA_URL + '/rest/api/3/issue';
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        String  jsonstr='{"fields":'+
            '{   "project":     {      "id": "17074"      }, '+
            '"summary": "' + summary + '",  '+
            '"description": { "type": "doc","version": 1,"content": [{"type": "paragraph","content": [{  "type": "text", "text": "'+ description +'" }  ]  } ] },'+
            ' "issuetype": {  "name": "' + type + '"     }'+
            '   }}';
        req.setBody(jsonstr);
        try {
            res = http.send(req);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            jiraKey = (String) m.get('key');
            if (type.equals('Bug')) {
                updateStatus(jiraKey, 'Ready For Work');
            } else {
                updateStatus(jiraKey, 'New Development Request');
            }
            addWatchers(jiraKey,addUsers);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(jsonstr);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        
        return jiraKey;
    }
    
    WebService static void addWatchers(String jiraKey, String watchers) {
        List<String> errorLoggerVars = new List<String>();   
        HttpResponse res = new HttpResponse();
        Http http = new Http();
		HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        
        //Construct Endpoint
        String endpoint = JIRA_URL + '/rest/api/3/issue/' + jiraKey + '/watchers';
        
        //Set Method and Endpoint and Body
        
        String[] watchersToAdd = watchers.split(',');
        try {
            //Send endpoint to JIRA
            for (Integer i = 0 ; i < watchersToAdd.size(); i++) {
                req.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type','application/json');
                req.setMethod('POST');
                req.setEndpoint(endpoint);
                req.setBody(watchersToAdd[i]);
                res = http.send(req);
            }
        } catch(System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(JSON.serialize(watchersToAdd));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }
    
    WebService static void addComment(String jiraKey, String comment) {
        List<String> errorLoggerVars = new List<String>();    
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String endpoint = JIRA_URL + '/rest/api/2/issue/' + jiraKey;  
        String jsonComment = '{"update": { "comment": [ { "add": { "body": "' + comment + '" }}]}}';
        
        try {
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            req.setMethod('PUT');
            req.setEndpoint(endpoint);
            req.setBody(jsonComment);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(jsonComment);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }
    
    WebService static void updateStatus(String jiraKey, String status) {
        List<String> errorLoggerVars = new List<String>();    
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String endpoint = JIRA_URL + '/rest/api/2/issue/' + jiraKey + '/transitions';
        String jsonStatus = '{"transition": {"id": "' + getStatusKey(status) + '"}}';
        
        try {
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            req.setBody(jsonStatus);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(jsonStatus);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }
    
    WebService static String getIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;
        
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        //Construct Authorization and Content header
        Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        
        //Construct Endpoint
        String endpoint = JIRA_URL +'/rest/api/2/search?jql=assignee%3D' + asurite + '%26status!%3DDone%26status!%3DCanceled%26Status!%3DClosed%26Status!%3DMigrated&fields=id,summary';
        //Set Method and Endpoint and Body
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        try {
            //Send endpoint to JIRA
            res = http.send(req);
            responseBody = res.getBody();
        } catch(System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(endpoint);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        return responseBody;
    }
    
    private static String getStatusKey(String statusName) {
        String statusKey;
        System.debug(statusName);
        switch on statusName {
            when 'Open' {
                statusKey = '11';
            }	
            when 'Ready For QA Testing' {
                statusKey = '401';
            }
            when '2nd Technical Review' {
                statusKey = '121';
            }
            when 'New Development Request' {
                statusKey = '161';
                System.debug(statusKey);
            }
            when 'New' {
                statusKey = '3';
            }
            when 'Working' {
                statusKey = '4';
            }
            when 'Closed' {
                statusKey = '2';
            }
            when 'Escalated' {
                statusKey = '5';
            }
            when 'Ready For Work' {
                statusKey = '351';
            }
            when else {
                statusKey = '11';
            }
        }
        return statusKey;
    }
}