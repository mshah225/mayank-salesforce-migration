global class JIRAWebserviceCallout {
    private static final Boolean DEBUG = false;
    private static final String USERNAME = ApiUser__c.getValues('Jira').Username__c;
    private static final String PASSWORD = ApiUser__c.getValues('Jira').Password__c;
    private static final String JIRA_URL = ApiUser__c.getValues('Jira').Url__c;
    
    WebService static String createNewIssue(String summary, String description, String addUsers, String type) {
        List<String> errorLoggerVars = new List<String>();
        String jiraKey;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        String endPoint = JIRA_URL + '/rest/api/3/issue';
        
        String body = '{"fields":' +
            '{   "project":     {      "id": "17074"      }, ' +
            '"summary": "' + summary + '",  ' +
            '"description": { "type": "doc","version": 1,"content": [{"type": "paragraph","content": [{  "type": "text", "text": "' + description + '" }  ]  } ] },'+
            ' "issuetype": {  "name": "' + type + '"     }'+
            '   }}';
        
        setHeader(req);
        setEndpoint(req, endpoint, 'POST');
        setBody(req, body);
        
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
            errorLoggerVars.add(body);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        
        return jiraKey;
    }
    
    WebService static void addWatchers(String jiraKey, String watchers) {
        List<String> errorLoggerVars = new List<String>();   
        HttpResponse res = new HttpResponse();
        Http http = new Http();
		HttpRequest req = new HttpRequest();
        
        String endpoint = JIRA_URL + '/rest/api/2/issue/' + jiraKey + '/watchers';
        
        String[] watchersToAdd = watchers.split(',');
        try {
            //Send endpoint to JIRA
            for (Integer i = 0 ; i < watchersToAdd.size(); i++) {
                setHeader(req);
                setEndPoint(req, endPoint, 'POST');
                setBody(req, '"' + watchersToAdd[i] + '"');
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
        String endPoint = JIRA_URL + '/rest/api/2/issue/' + jiraKey;  
        String body = '{"update": { "comment": [ { "add": { "body": "' + comment + '" }}]}}';
        
        try {
        	setHeader(req);
            setEndpoint(req, endPoint, 'PUT');
            setBody(req, body);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(body);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }
    
    WebService static void updateStatus(String jiraKey, String status) {
        List<String> errorLoggerVars = new List<String>();    
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = JIRA_URL + '/rest/api/2/issue/' + jiraKey + '/transitions';
        String body = '{"transition": {"id": "' + getStatusKey(status) + '"}}';
        
        try {
            setHeader(req);
            setEndpoint(req, endPoint, 'POST');
            setBody(req, body);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(body);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }
    
    WebService static String getIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        String endPoint = JIRA_URL +'/rest/api/2/search?jql=assignee%3D' + asurite + '%26status!%3DDone%26status!%3DCanceled%26Status!%3DClosed%26Status!%3DMigrated%20order%20by%20updated%20DESC&fields=id,summary,issuetype';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);
            responseBody = res.getBody();
        } catch(System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(endPoint);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        return responseBody;
    }
    
    WebService static String getWatchedIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        String endPoint = JIRA_URL +'/rest/api/2/search?jql=watcher%3D' + asurite + '%26status!%3DDone%26status!%3DCanceled%26Status!%3DClosed%26Status!%3DMigrated%20order%20by%20updated%20DESC&fields=id,summary,issuetype';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);
            responseBody = res.getBody();
        } catch(System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(endPoint);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        return responseBody;
    }
    
    private static void setHeader(HttpRequest req) {
        Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
    }
    
    private static void setEndPoint(HttpRequest req, String endPoint, String method) {
        req.setMethod(method);
        req.setEndpoint(endPoint);
    }
    
    private static void setBody(HttpRequest req, String body) {
        req.setBody(body);
    }
    
    private static String getStatusKey(String statusName) {
        String statusKey;
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