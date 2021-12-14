@isTest
public with sharing class BulkApiManagerTest {
    /**
     * For these tests the relevant details we would want to check are impossible to directly observe.
     * But they are sent to an endpoint.  We utilize a MockCallout class to allow us to capture the
     * sent details, which we can then observe and verify are correct.
     */

    @isTest
    private static void testSuccessfulCreate() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        BulkApiManager apiManager = new BulkApiManager('EDPLUS_CASE', 'update');
        Test.stopTest();

        System.assert(mockCallout.reqBody.contains('<operation>update</operation><object>case</object>'));
    }

    @isTest
    private static void testFailedCreate() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        mockCallout.shouldSucceed = false;
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        try {
            BulkApiManager apiManager = new BulkApiManager('EDPLUS_CASE', 'update');
        } catch (BulkApiManager.ResponseException ex) {
            // Do nothing - already caught on lower level and created case
        }
        Test.stopTest();

        Case c = [SELECT Id, Subject, Description FROM Case];
        System.assert(c.Subject.contains('BulkApiManager.ResponseException'));
        System.assert(c.Description.contains('FAILURE_CODE_BAMT_01'));
    }

    @isTest
    private static void testSuccessfulSendBatch() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        try {
            BulkApiManager apiManager = new BulkApiManager('EDPLUS_CASE', 'update');
            apiManager.sendBatch('batchBody');
        } catch (BulkApiManager.ResponseException ex) {
            // Do nothing - already caught on lower level and created case
        }
        Test.stopTest();

        System.assertEquals('batchBody', mockCallout.reqBody);
    }

    @isTest
    private static void testFailedSendBatch() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        try {
            BulkApiManager apiManager = new BulkApiManager('EDPLUS_CASE', 'update');
            mockCallout.shouldSucceed = false;
            apiManager.sendBatch('batchBody');
        } catch (BulkApiManager.ResponseException ex) {
            // Do nothing - already caught on lower level and created case
        }
        Test.stopTest();

        Case c = [SELECT Id, Subject, Description FROM Case];
        System.assert(c.Subject.contains('BulkApiManager.ResponseException'));
        System.assert(c.Description.contains('Job Id'));
    }

    @isTest
    private static void testSuccessfulCloseJob() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        BulkApiManager apiManager = new BulkApiManager('EDPLUS_CASE', 'update');
        apiManager.closeJob();
        Test.stopTest();

        System.assert(mockCallout.reqBody.contains('<state>Closed</state>'));
    }

    @isTest
    private static void testFailedCloseJob() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        BulkApiManager apiManager = new BulkApiManager('EDPLUS_CASE', 'update');
        mockCallout.shouldSucceed = false;
        apiManager.closeJob();
        Test.stopTest();

        Case c = [SELECT Id, Subject, Description FROM Case];
        System.assert(c.Subject.contains('BulkApiManager.ResponseException'));
        System.assert(c.Description.contains('Error closed the job'));
    }

    @isTest
    private static void testTypes() {
        ObjectScramblerMockCallout mockCallout = new ObjectScramblerMockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        BulkApiManager apiManagerConvertedLead = new BulkApiManager('CONVERTED_LEAD', 'delete');
        BulkApiManager apiManagerCAR = new BulkApiManager('CAR', 'update');
        BulkApiManager apiManagerEdPlusCase = new BulkApiManager('EDPLUS_CASE', 'update');
        BulkApiManager apiManagerSilverpop = new BulkApiManager('DELETED_SILVERPOP', 'delete');
        BulkApiManager apiManagerContact1 = new BulkApiManager('CONTACT_NO_PHONE', 'update');
        BulkApiManager apiManagerUser = new BulkApiManager('User', 'update');
        BulkApiManager apiManagerContact2 = new BulkApiManager('Contact', 'update');
        Test.stopTest();

        System.assertEquals('lead', apiManagerConvertedLead.objectType);
        System.assertEquals('case_assignment_rule__c', apiManagerCAR.objectType);
        System.assertEquals('case', apiManagerEdPlusCase.objectType);
        System.assertEquals(System.Label.SilverPopName, apiManagerSilverpop.objectType);
        System.assertEquals('contact', apiManagerContact1.objectType);
        System.assertEquals('User', apiManagerUser.objectType);
        System.assertEquals('Contact', apiManagerContact2.objectType);
    }

    public class ObjectScramblerMockCallout implements HttpCalloutMock {
        public String reqBody = '';
        public Boolean shouldSucceed = true;

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            reqBody = req.getBody();

            if (shouldSucceed)
                res = createSuccessfulResponse(req);
            else
                res = createFailureResponse(req);

            return res;
        }

        public HTTPResponse createSuccessfulResponse(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('<id>003M0000012A8X5</id>');
            res.setStatusCode(200);
            return res;
        }

        public HTTPResponse createFailureResponse(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/plain');
            res.setBody('FAILURE_CODE_BAMT_01');
            res.setStatusCode(500);
            return res;
        }
    }
}
