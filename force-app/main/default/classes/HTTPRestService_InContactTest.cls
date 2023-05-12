@isTest
private class HTTPRestService_InContactTest {
    @isTest
    static void testCallout() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new InContactCalloutMock());

        HTTPResponse res = HTTPRestService_InContact.GETRestCallout(
            'https://api.incontact.com/InContactAuthorizationServer/Token'
        );

        // Verify response
        System.assertEquals(res.getBody(), '{"foo":"bar"}');
        System.assertEquals(200, res.getStatusCode());
    }
}
