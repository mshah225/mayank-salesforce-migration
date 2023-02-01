global class JiraCallout {
    private static final Boolean DEBUG = false;

    /**
     * Create a new ticket with summary as the title
     *
     * @param summary The title for the new ticket
     * @param description The body for the new ticket
     * @param type The type for the new ticket
     *
     * @return A string that is the JIRA key for the create ticket
     */
    public static String createTicket(String summary, String description, String type) {
        List<String> errorLoggerVars = new List<String>();
        String jiraKey;
        String alias = [SELECT alias FROM User WHERE Id = :UserInfo.getUserId()].alias;
        String email = alias + '@asu.edu';
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String body = '';
        String bodyWithoutReporter = '';
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue';

        // Create with reporter specified
        JSONObject jsObj = new JSONObject();
        jsObj.put('fields.project.id', '17074');
        jsObj.put('fields.summary', summary.replaceAll('[\\n\\r]+', ' '));
        jsObj.put('fields.description', description);
        jsObj.put('fields.issuetype.name', type);
        jsObj.put('fields.reporter.id', getJiraAccountId(email));

        // Create without reporter specified (used in fallback)
        JSONObject jsObjNoReporter = new JSONObject();
        jsObjNoReporter.put('fields.project.id', '17074');
        jsObjNoReporter.put('fields.summary', summary.replaceAll('[\\n\\r]+', ' '));
        jsObjNoReporter.put('fields.description', description);
        jsObjNoReporter.put('fields.issuetype.name', type);

        body = jsObj.serialize();
        bodyWithoutReporter = jsObjNoReporter.serialize();

        setHeader(req);
        setEndpoint(req, endpoint, 'POST');
        setBody(req, body);

        try {
            res = http.send(req);

            // Try without reporter if failed
            if (res.getStatusCode() == 400) {
                setBody(req, bodyWithoutReporter);
                res = http.send(req);
            }

            // If response was a success (a 200-type response is success) extra jira key
            if (200 <= res.getStatusCode() && res.getStatusCode() < 300) {
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                jiraKey = (String) m.get('key');
            } else {
                // If there was an error response, then report that back to the end-user
                String errorBody = '';
                try {
                    errorBody = res.getBody() != null ? res.getBody() : '';
                } catch (Exception e) {
                }
                throw new JiraCalloutException('Error With Response Code: ' + res.getStatusCode() + '\n' + errorBody);
            }
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('body', body));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
            throw e;
        }

        return jiraKey;
    }

    /**
     * Add each user specified as watchers on the ticket
     *
     * @param jiraKey JIRA Key
     * @param watchers Comma separated list of watchers to add to the ticket
     */
    public static void addWatchers(String jiraKey, String watchers) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        String endpoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey + '/watchers';

        List<String> watchersToAdd = new List<String>();
        if (String.isNotEmpty(watchers)) {
            watchersToAdd = watchers.replaceAll('\\s+', '').split(',');
        }

        try {
            //Send endpoint to JIRA
            for (Integer i = 0; i < watchersToAdd.size(); i++) {
                setHeader(req);
                setEndPoint(req, endPoint, 'POST');
                setBody(req, '"' + getJiraAccountId(watchersToAdd[i] + '@asu.edu') + '"');
                res = http.send(req);
            }
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('watchersToAdd', JSON.serialize(watchersToAdd)));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }

    /**
     * Add a comment to the ticket
     *
     * @param jiraKey JIRA Key
     * @param comment Comment to add
     */
    public static void addComment(String jiraKey, String comment) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey;

        JSONObject jsObj = new JSONObject();
        jsObj.put('update.comment[0].add.body', comment);
        String body = jsObj.serialize();

        try {
            setHeader(req);
            setEndpoint(req, endPoint, 'PUT');
            setBody(req, body);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('body', body));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }

    /**
     * Change the ticket to the specified status
     *
     * @param jiraKey JIRA Key
     * @param status Status to convert to
     */
    public static void updateStatus(String jiraKey, String status) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey + '/transitions';

        JSONObject jsObj = new JSONObject();
        jsObj.put('transition.id', getStatusKey(status));

        String body = jsObj.serialize();

        try {
            setHeader(req);
            setEndpoint(req, endPoint, 'POST');
            setBody(req, body);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('body', body));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
    }

    /**
     * Add component to the jira ticket
     *
     * @param jiraKey JIRA Key
     * @param status Status to convert to
     */
    public static void addComponent(String jiraKey, String componentName) {
        List<String> errorLoggerVars = new List<String>();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:Jira_Base_URL/rest/api/2/issue/' + jiraKey + '';

        JSONObject jsObj = new JSONObject();
        jsObj.put('update.components[0].add.name', componentName);

        String body = jsObj.serialize();

        try {
            setHeader(req);
            setEndpoint(req, endPoint, 'PUT');
            setBody(req, body);
            res = http.send(req);
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('body', body));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
            throw e;
        }
    }

    /**
     * Get all issues that this user is assigned
     *
     * @param asurite ASURite for user
     *
     * @return A string which is the response from JIRA about which tickets this user is assigned
     */
    public static String getIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;
        String accountId = getJiraAccountId(asurite + '@asu.edu');

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        String endPoint =
            'callout:Jira_Base_URL/rest/api/2/search?jql=assignee%3D' +
            accountId +
            '%26status!%3DDone%26status!%3DCanceled%26Status!%3DClosed%26Status!%3D%22Close%20Issue%22%20order%20by%20updated%20DESC&fields=id,summary,issuetype,status';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);
            responseBody = res.getBody();
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('endPoint', endPoint));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }
        return responseBody;
    }

    /**
     * Get all issues that this user is watching
     *
     * @param asurite ASURite for user
     *
     * @return A string which is the response from JIRA about which tickets this user is watching
     */
    public static String getWatchedIssues(String asurite) {
        List<String> errorLoggerVars = new List<String>();
        String responseBody;
        String accountId = getJiraAccountId(asurite + '@asu.edu');

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        String endPoint =
            'callout:Jira_Base_URL/rest/api/2/search?jql=watcher%20%3D%20' +
            accountId +
            '%20AND%20(assignee%20%3D%20NULL%20OR%20assignee%20!%3D%20' +
            accountId +
            ')%26status%21%3DDone%26status%21%3DCanceled%26Status%21%3DClosed%26Status%21%3D%22Close%20Issue%22%20order%20by%20updated%20DESC&fields=id,summary,issuetype,status';

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);
            responseBody = res.getBody();
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('endPoint', endPoint));
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

    private static String getJiraAccountId(String email) {
        List<String> errorLoggerVars = new List<String>();
        String accountId;

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        String endPoint = 'callout:Jira_Base_URL/rest/api/3/user/search?query=' + email;

        try {
            setHeader(req);
            setEndPoint(req, endPoint, 'GET');
            res = http.send(req);

            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'accountId')) {
                    parser.nextToken();
                    accountId = parser.getText();
                    break;
                }
            }
        } catch (System.CalloutException e) {
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('res.toString()', res.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('req.toString()', req.toString()));
            errorLoggerVars.add(ErrorLogger.convertStringToJSON('endPoint', endPoint));
            ErrorLogger.log(e, errorLoggerVars, DEBUG);
        }

        return accountId;
    }

    public class JiraCalloutException extends Exception {
    }
}