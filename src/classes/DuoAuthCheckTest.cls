@IsTest
private class DuoAuthCheckTest {
    /**
     * Tests an Authorization header signature check against the Duo API
     *
     * This is a little difficult to test since Duo performs the check.
     * Instead we just mock the response with the assumption that the
     * DuoAuthorization class is generating the signatures correctly.
     */
    @IsTest
    static void checkSuccess() {
        StaticResourceCalloutMock checkMock = new StaticResourceCalloutMock();
        checkMock.setStaticResource('DuoCheck');
        checkMock.setStatusCode(200);
        checkMock.setHeader('Content-Type', 'application/json');

        DuoRequest checkApi = new DuoAuthCheck();
        Test.setMock(HttpCalloutMock.class, checkMock);
        Test.startTest();
        DuoResponse response = new DuoAPI().send(checkApi);
        Test.stopTest();

        DuoAuthCheck.Success result = (DuoAuthCheck.Success) response.getResult();
        System.assertEquals(100, result.timex);
    }

    /**
     * Tests a failed Authorization header signature check
     */
    @IsTest
    static void checkFail() {
        StaticResourceCalloutMock checkMock = new StaticResourceCalloutMock();
        checkMock.setStaticResource('DuoError');
        checkMock.setStatusCode(401);
        checkMock.setHeader('Content-Type', 'application/json');

        DuoRequest checkApi = new DuoAuthCheck();
        Test.setMock(HttpCalloutMock.class, checkMock);
        Test.startTest();
        DuoResponse response = new DuoAPI().send(checkApi);
        Test.stopTest();

        System.assert(response.getResult() instanceof DuoAPI.Error);
    }
}
