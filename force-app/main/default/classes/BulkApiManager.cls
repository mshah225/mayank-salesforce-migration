public class BulkApiManager {
    private String jobId;
    private String orgUrl;
    private String sessionKey;
    private String objectType;
    private String operationType;
    private final Integer NUMBER_OF_RETRIES = 10;
    private final Boolean DEBUG = false;
    private final String ENDPOINT = '/services/async/44.0/job/';

    public BulkApiManager(String objectType, String operationType) {
        orgUrl = URL.getOrgDomainUrl().toExternalForm();
        sessionKey = UserInfo.getSessionID();
        if (objectType == 'CONVERTED_LEAD') {
            this.objectType = 'lead';
        } else if (objectType == 'CAR') {
            this.objectType = 'case_assignment_rule__c';
        } else if (objectType == 'EDPLUS_CASE') {
            this.objectType = 'case';
        } else if (objectType == 'DELETED_SILVERPOP') {
            this.objectType = System.Label.SilverPopName;
        } else if (objectType == 'CONTACT_NO_PHONE') {
            this.objectType = 'contact';
        } else {
            this.objectType = objectType.toLowerCase().capitalize();
        }
        this.operationType = operationType;
        createJob();
    }

    private void createJob() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(orgUrl + ENDPOINT);
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', sessionKey);
        req.setHeader('Content-Type', 'application/xml; charset=UTF-8');
        String body =
            '<?xml version="1.0" encoding="UTF-8"?><jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload"><operation>' +
            operationType +
            '</operation><object>' +
            objectType +
            '</object><contentType>CSV</contentType></jobInfo>';
        req.setBody(body);
        HttpResponse res;
        try {
            Http http = new Http();
            res = http.send(req);
            if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                throw new ResponseException('Error With Response Code: ' + res.getStatusCode());
            } else {
                jobId = parseJobIdFromResponse(res);
            }
        } catch (Exception e) {
            ErrorLogger error = new ErrorLogger();
            error.setException(e);
            error.setClassName('BulkApiManager');
            error.setDetails('Response Body: ' + res.getBody() + ' Body: ' + body);
            error.log();
            throw e;
        }
    }

    public void sendBatch(String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(orgUrl + ENDPOINT + jobId + '/batch');
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', sessionKey);
        req.setHeader('Content-Type', 'text/csv');
        req.setBody(body);
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                throw new ResponseException('Error With Response Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            ErrorLogger error = new ErrorLogger();
            error.setException(e);
            error.setClassName('BulkApiManager');
            error.setDetails('Job Id: ' + jobId);
            error.log();
            throw e;
        }
    }

    public void closeJob() {
        Boolean jobClosed = false;
        try {
            for (Integer i = 0; i < NUMBER_OF_RETRIES && !jobClosed; i++) {
                jobClosed = tryToCloseJob();
            }
            if (!jobClosed) {
                throw new ResponseException('Error closed the job: ' + jobId);
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(jobId);
            ErrorLogger.log(e, vars, DEBUG);
        }
    }

    public Boolean tryToCloseJob() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(orgUrl + ENDPOINT + jobId);
        req.setMethod('POST');
        req.setHeader('X-SFDC-Session', sessionKey);
        req.setHeader('Content-Type', 'application/xml');
        String body = '<?xml version="1.0" encoding="UTF-8"?><jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload"><state>Closed</state></jobInfo>';
        req.setBody(body);
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                throw new ResponseException('Error With Response Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            return false;
        }

        return true;
    }

    private String parseJobIdFromResponse(HttpResponse response) {
        String responseBody = response.getBody();
        responseBody = responseBody.substring(responseBody.indexOf('<id>'), responseBody.indexOf('</id>'));
        responseBody = responseBody.replace('<id>', '');

        return responseBody;
    }

    private class ResponseException extends Exception {
    }
}
