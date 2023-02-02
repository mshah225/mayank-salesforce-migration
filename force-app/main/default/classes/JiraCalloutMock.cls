@isTest
global class JiraCalloutMock implements HttpCalloutMock {
    private Boolean throwError = false;

    global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();

        if (throwError) {
            return createErrorResponse();
        } else if (isCreateIssueCall(req)) {
            return createNewIssueResponse(req);
        } else if (isUpdateStatusCall(req)) {
            return updateStatus(req);
        } else if (isAddCommentCall(req)) {
            return addComment(req);
        } else if (isAddComponentCall(req)) {
            return addComponent(req);
        } else if (isAddWatchersCall(req)) {
            return addWatchers(req);
        } else if (isGetIssuesCall(req)) {
            return getIssues(req);
        } else if (isGetAccountIdCall(req)) {
            return getJiraAccountId(req);
        }
        return null;
    }

    private HTTPResponse createErrorResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"errorMessages":["Unexpected Server Error"], "errors": {}}');
        res.setStatusCode(400);
        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful issue creations
     */
    private HTTPResponse createNewIssueResponse(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{ "id": "953486", "key": "SFE-49392", "self": "https://asudev.jira.com/rest/api/2/issue/953486", "transition": { "status": "200", "errorCollection": { "errorMessages": [], "errors": { } } } }'
        );
        res.setStatusCode(200);

        // If body is not JSON, then throw an error
        Object isProperlyJsonFormatted = JSON.deserializeUntyped(req.getBody());

        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful comment addition
     */
    private HTTPResponse addWatchers(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // If body is not JSON, then throw an error
        Object isProperlyJsonFormatted = JSON.deserializeUntyped(req.getBody());

        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful comment addition
     */
    private HTTPResponse addComment(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // If body is not JSON, then throw an error
        Object isProperlyJsonFormatted = JSON.deserializeUntyped(req.getBody());

        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful comment addition
     */
    private HTTPResponse addComponent(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // If body is not JSON, then throw an error
        Object isProperlyJsonFormatted = JSON.deserializeUntyped(req.getBody());

        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful status updates
     */
    private HTTPResponse updateStatus(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // If body is not JSON, then throw an error
        Object isProperlyJsonFormatted = JSON.deserializeUntyped(req.getBody());

        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful issue query
     */
    private HTTPResponse getIssues(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{ "expand": "schema,names", "startAt": 0, "maxResults": 50, "total": 5, "issues": [ { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "297241", "self": "https://asudev.jira.com/rest/api/2/issue/297241", "key": "UTOTRN-96", "fields": { "summary": "Learning History - Justin Sanchez", "issuetype" : { "name" : "Task" }, "status" : { "name" : "Ready for Work" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "394979", "self": "https://asudev.jira.com/rest/api/2/issue/394979", "key": "SFE-17360", "fields": { "summary": "Create singular component for Submit Bug / Submit NDR", "issuetype" : { "name" : "Task" }, "status" : { "name" : "Ready for Work" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "394161", "self": "https://asudev.jira.com/rest/api/2/issue/394161", "key": "SFE-17267", "fields": { "summary": "10/12 Dev Deployment", "issuetype" : { "name" : "Bug" }, "status" : { "name" : "In Testing" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "392543", "self": "https://asudev.jira.com/rest/api/2/issue/392543", "key": "SFE-17021", "fields": { "summary": "Create Community and Page Layout", "issuetype" : { "name" : "Bug" }, "status" : { "name" : "In Testing" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "392524", "self": "https://asudev.jira.com/rest/api/2/issue/392524", "key": "SFE-17014", "fields": { "summary": "Lightning Community for Jira Forms", "issuetype" : { "name" : "Epic" }, "status" : { "name" : "In Progress" } } } ] }'
        );
        res.setStatusCode(200);
        return res;
    }

    /**
     * Create a HTTPResponse that is formatted like how JIRA responds to successful accountId query
     */
    private HTTPResponse getJiraAccountId(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '[ { "self": "https://asudev.jira.com/rest/api/3/user?accountId=5dae0274a627f40c2f3c7702", "accountId": "5dae0274a627f40c2f3c7702", "accountType": "atlassian", "avatarUrls": { "48x48": "https://avatar-management--avatars.server-location.prod.public.atl-paas.net/initials/AA-3.png?size=48&s=48", "24x24": "https://avatar-management--avatars.server-location.prod.public.atl-paas.net/initials/AA-3.png?size=24&s=24", "16x16": "https://avatar-management--avatars.server-location.prod.public.atl-paas.net/initials/AA-3.png?size=16&s=16", "32x32": "https://avatar-management--avatars.server-location.prod.public.atl-paas.net/initials/AA-3.png?size=32&s=32" }, "displayName": "Robert Nordman", "active": true } ]'
        );
        res.setBody('{"accountId":"557058:472c64c9-2567-4213-839b-86bf21558300"}');
        res.setStatusCode(200);
        return res;
    }

    public void setThrowError(Boolean throwError) {
        this.throwError = throwError;
    }

    /**
     * Checks if this request is formatted like a create ticket request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a create ticket request
     */
    private Boolean isCreateIssueCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String method = req.getMethod();

        return path.equals('/rest/api/2/issue') && method.equals('POST');
    }

    /**
     * Checks if this request is formatted like a update status request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a update status request
     */
    private Boolean isUpdateStatusCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String method = req.getMethod();

        return path.startsWith('/rest/api/2/issue/') && path.endsWith('/transitions') && method.equals('POST');
    }

    /**
     * Checks if this request is formatted like a add comment request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a add comment request
     */
    private Boolean isAddCommentCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String method = req.getMethod();
        JSONObject jsObj = null;
        if (req.getBody() != null && req.getBody() != '') {
            jsObj = new JSONObject(req.getBody());
        }

        return path.startsWith('/rest/api/2/issue/') &&
            method.equals('PUT') &&
            jsObj != null &&
            jsObj.get('update.comment[0].add.body') != null;
    }

    /**
     * Checks if this request is formatted like a add comment request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a add comment request
     */
    private Boolean isAddComponentCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String method = req.getMethod();
        JSONObject jsObj = null;
        if (req.getBody() != null && req.getBody() != '') {
            jsObj = new JSONObject(req.getBody());
        }

        return path.startsWith('/rest/api/2/issue/') &&
            method.equals('PUT') &&
            jsObj != null &&
            jsObj.get('update.components[0].add.name') != null;
    }

    /**
     * Checks if this request is formatted like a add watchers request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a add watchers request
     */
    private Boolean isAddWatchersCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String method = req.getMethod();

        return path.startsWith('/rest/api/2/issue/') && path.endsWith('/watchers') && method.equals('POST');
    }

    /**
     * Checks if this request is formatted like a get issues request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a get issues request
     */
    private Boolean isGetIssuesCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String paramsStr = extractQueryParams(req.getEndpoint());
        String method = req.getMethod();

        return path.startsWith('/rest/api/2/search') && paramsStr.startsWith('?jql=') && method.equals('GET');
    }

    /**
     * Checks if this request is formatted like a query for userid request
     *
     * @param req The request we are curious about
     *
     * @return True if the request is formatted like a query for userid request
     */
    private Boolean isGetAccountIdCall(HTTPRequest req) {
        String path = extractPath(req.getEndpoint());
        String paramsStr = extractQueryParams(req.getEndpoint());
        String method = req.getMethod();

        return path.startsWith('/rest/api/3/user/search') && paramsStr.startsWith('?query=') && method.equals('GET');
    }

    /**
     * Get just the path component of this endpoint, i.e. strip out the domain
     * e.g. https://asu.edu/webapp4/sand/index.html returns /webapp4/sand/index.html#tallman?q=Hello%20World
     *
     * @param endpoint The endpoint (URL) we want the path from
     *
     * @return Everything after the domain - so everything after the first /-symbol (including that first /-symbol)
     */
    private static String extractPath(String endpoint) {
        // If the protocol is specified - remove it
        if (endpoint.contains('://'))
            endpoint = endpoint.substring(endpoint.indexOf('://') + 3);

        // if there is a / - then everything after it is what we want, otherwise no path
        endpoint = endpoint.contains('/') ? endpoint.substring(endpoint.indexOf('/')) : '';

        // If there is a hash locator, we don't want it
        endpoint = endpoint.contains('#') ? endpoint.substring(0, endpoint.indexOf('#')) : endpoint;

        // If there are query params, we don't want them
        endpoint = endpoint.contains('?') ? endpoint.substring(0, endpoint.indexOf('?')) : endpoint;

        return endpoint;
    }

    /**
     * Get just the query component of this endpoint, i.e. strip out the domain
     * e.g. https://asu.edu/webapp4/sand/index.html returns /webapp4/sand/index.html#tallman?q=Hello%20World
     *
     * @param endpoint The endpoint (URL) we want the path from
     *
     * @return Everything after the domain - so everything after the first /-symbol (including that first /-symbol)
     */
    private static String extractQueryParams(String endpoint) {
        // If the protocol is specified - remove it
        if (endpoint.contains('://'))
            endpoint = endpoint.substring(endpoint.indexOf('://') + 3);

        // If there are query params, we grab everything after them - or if not, then empty str
        endpoint = endpoint.contains('?') ? endpoint.substring(endpoint.indexOf('?')) : '';

        // If there is a hash locator, we don't want it
        endpoint = endpoint.contains('#') ? endpoint.substring(0, endpoint.indexOf('#')) : endpoint;

        return endpoint;
    }
}