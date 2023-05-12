@isTest
private class HTTPRestService_RocketChatTest {
    @isTest
    static void testCallout() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new RocketChatCalloutMock());
        string res;
        res = HTTPRestService_RocketChat.GETRestCallout('/getMessages');
    }
}
