@isTest
global class JiraHttpMockCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint().contains('watchers')) {
            return addWatchers();
        } else if (req.getMethod().equals('PUT')) {
            return addComment();
        } else if (req.getEndpoint().contains('api/2/issue')) {
            return createNewIssueResponse();
        } else if (req.getEndpoint().contains('transitions')) {
            return updateStatus();
        } else if (req.getEndpoint().contains('/rest/api/2/search?jql=')) {
            return getIssues();
        } else if (req.getEndpoint().contains('/rest/api/2/jql/pdcleaner')) {
            return getId();
        }
        return null;
    }

    private HTTPResponse createNewIssueResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"key":"TEST"}');
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse addWatchers() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"key":"TEST"}');
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse addComment() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"key":"TEST"}');
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse updateStatus() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"key":"TEST"}');
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getIssues() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{ "expand": "schema,names", "startAt": 0, "maxResults": 50, "total": 5, "issues": [ { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "297241", "self": "https://asudev.jira.com/rest/api/2/issue/297241", "key": "UTOTRN-96", "fields": { "summary": "Learning History - Justin Sanchez", "issuetype" : { "name" : "Task" }, "status" : { "name" : "Ready for Work" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "394979", "self": "https://asudev.jira.com/rest/api/2/issue/394979", "key": "SFE-17360", "fields": { "summary": "Create singular component for Submit Bug / Submit NDR", "issuetype" : { "name" : "Task" }, "status" : { "name" : "Ready for Work" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "394161", "self": "https://asudev.jira.com/rest/api/2/issue/394161", "key": "SFE-17267", "fields": { "summary": "10/12 Dev Deployment", "issuetype" : { "name" : "Bug" }, "status" : { "name" : "In Testing" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "392543", "self": "https://asudev.jira.com/rest/api/2/issue/392543", "key": "SFE-17021", "fields": { "summary": "Create Community and Page Layout", "issuetype" : { "name" : "Bug" }, "status" : { "name" : "In Testing" } } }, { "expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields", "id": "392524", "self": "https://asudev.jira.com/rest/api/2/issue/392524", "key": "SFE-17014", "fields": { "summary": "Lightning Community for Jira Forms", "issuetype" : { "name" : "Epic" }, "status" : { "name" : "In Progress" } } } ] }'
        );
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse getId() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{"queryStrings":["assignee = 557058:472c64c9-2567-4213-839b-86bf21558300"],"queriesWithUnknownUsers":[]}'
        );
        res.setStatusCode(200);
        return res;
    }
}
