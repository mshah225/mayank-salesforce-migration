global class JIRAWebserviceCallout {
    private static final Boolean DEBUG = false;

    webService static String createNewIssue(String summary, String description, String addUsers, String type) {
        List<String> errorLoggerVars = new List<String>();
        String jiraKey;
        String alias = [SELECT alias FROM User WHERE Id = :UserInfo.getUserId()].alias;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String body = '';
        String bodyWithoutReporter = '';
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue';

        body =
            '{"fields":' +
            '{   "project":     {      "id": "17074"      }, ' +
            '"summary": "' +
            summary +
            '",  ' +
            '"description": "' +
            description +
            '",  ' +
            ' "issuetype": {  "name": "' +
            type +
            '"     }';
        bodyWithoutReporter = body + '   }}';

        body += ', "reporter": { "id": "' + getJIRAUserId(alias) + '"  }' + '   }}';

        setHeader(req);
        setEndpoint(req, endpoint, 'POST');
        setBody(req, body);

        try {
            res = http.send(req);
            if (res.getStatusCode() == 400) {
                setBody(req, bodyWithoutReporter);
                res = http.send(req);
            }
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            jiraKey = (String) m.get('key');
            if (type.equals('Bug')) {
                updateStatus(jiraKey, 'Ready For Work');
            } else {
                updateStatus(jiraKey, 'New Development Request');
            }
            if (addUsers != null) {
                addWatchers(jiraKey, addUsers);
            }
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(body);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }

        return jiraKey;
    }

    webService static void addWatchers(String jiraKey, String watchers) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        String endpoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey + '/watchers';

        String[] watchersToAdd = watchers.split(',');
        try {
            //Send endpoint to JIRA
            for (Integer i = 0; i < watchersToAdd.size(); i++) {
                setHeader(req);
                setEndPoint(req, endPoint, 'POST');
                setBody(req, '"' + getJIRAUserId(watchersToAdd[i]) + '"');
                res = http.send(req);
            }
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(JSON.serialize(watchersToAdd));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }

    webService static void addComment(String jiraKey, String comment) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey;
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

    webService static void updateStatus(String jiraKey, String status) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey + '/transitions';
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

    webService static String getIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        String endPoint =
            'callout:Jira_Base_URL/rest/api/2/search?jql=assignee%3D%27' +
            asurite +
            '%40asu.edu%27%26status!%3DDone%26status!%3DCanceled%26Status!%3DClosed%26Status!%3D%22Close%20Issue%22%20order%20by%20updated%20DESC&fields=id,summary,issuetype,status';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);
            responseBody = res.getBody();
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(endPoint);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        return responseBody;
    }

    webService static String getWatchedIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        String endPoint =
            'callout:Jira_Base_URL/rest/api/2/search?jql=watcher%20%3D%20%27' +
            asurite +
            '%40asu.edu%27%20AND%20(assignee%20%3D%20NULL%20OR%20assignee%20!%3D%20%27' +
            asurite +
            '%40asu.edu%27)%26status%21%3DDone%26status%21%3DCanceled%26Status%21%3DClosed%26Status%21%3D%22Close%20Issue%22%20order%20by%20updated%20DESC&fields=id,summary,issuetype,status';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);
            responseBody = res.getBody();
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(endPoint);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        return responseBody;
    }

    private static void setHeader(HttpRequest req) {
        req.setHeader('Content-Type', 'application/json');
    }

    private static void setEndPoint(HttpRequest req, String endPoint, String method) {
        req.setMethod(method);
        req.setEndpoint(endPoint);
    }

    private static void setBody(HttpRequest req, String body) {
        req.setBody(body);
    }

    @TestVisible
    private static String getStatusKey(String statusName) {
        String statusKey;
        switch on statusName {
            when 'Open' {
                statusKey = '131';
            }
            when 'In Testing' {
                statusKey = '81';
            }
            when 'Technical Review' {
                statusKey = '91';
            }
            when 'New Development Request' {
                statusKey = '11';
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
            when 'Done' {
                statusKey = '111';
            }
            when else {
                statusKey = '11';
            }
        }
        return statusKey;
    }

    private static String getJIRAUserId(String username) {
        List<String> errorLoggerVars = new List<String>();
        String userId;

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        username = username.replace('\n', '').replace('\r', '');

        String endPoint = 'callout:Jira_Base_URL/rest/api/2/jql/pdcleaner';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'POST');
            setBody(req, '{"queryStrings": ["assignee = ' + username + '"]}');
            res = http.send(req);

            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> queryStringList = (List<Object>) responseMap.get('queryStrings');
            userId = queryStringList[0].toString().split(' = ')[1];
        } catch (System.CalloutException e) {
            errorLoggerVars.add(res.toString());
            errorLoggerVars.add(req.toString());
            errorLoggerVars.add(endPoint);
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }

        return userId;
    }
}
