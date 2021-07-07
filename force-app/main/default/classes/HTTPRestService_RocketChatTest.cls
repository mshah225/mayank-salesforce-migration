@isTest
private class HTTPRestService_RocketChatTest {
    @isTest
    static void testCallout() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new HTTPRestService_RocketChat_MockImpl());
        string res;
        res = HTTPRestService_RocketChat.GETRestCallout('/getMessages');
    }
}
