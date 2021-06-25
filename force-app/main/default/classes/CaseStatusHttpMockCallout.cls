@isTest
global class CaseStatusHttpMockCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{"controllerValues":{},"defaultValue":{"attributes":null,"label":"New","validFor":[],"value":"New"},"eTag":"81b2bd525fa23db2ebbff22c603e708e","url":"/services/data/v43.0/ui-api/object-info/Case/picklist-values/012d0000000x2VTAAY/Status","values":[{"attributes":null,"label":"Testing","validFor":[],"value":"Testing"}]}'
        );
        res.setStatusCode(200);
        return res;
    }
}
