@IsTest
private class DuoAuthUserTest {
    /**
     * Tests a Duo Authentication request using a mock user Id
     */
    @IsTest
    static void successWithUserId() {
        StaticResourceCalloutMock authMock = new StaticResourceCalloutMock();
        authMock.setStaticResource('DuoAuth');
        authMock.setStatusCode(200);
        authMock.setHeader('Content-Type', 'application/json');

        DuoRequest authApi = new DuoAuthUserId(
            'USERID1111',
            new DuoPushFactor('MOCKDEVICE1111')
                .setType('Login')
                .setDisplayUsername('Super Gary')
                .setPushInfo(new Map<String, String>{ 'mock_info' => 'Mock Info', 'more_info' => '1234' })
        );
        Test.setMock(HttpCalloutMock.class, authMock);
        Test.startTest();
        DuoResponse response = new DuoAPI().send(authApi);
        Test.stopTest();

        System.assert(response.getResult() instanceof DuoAuth.Success);

        DuoAuth.Success result = (DuoAuth.Success) response.getResult();
        System.assertEquals('allow', result.result);
        System.assertEquals('allow', result.status);
        System.assertEquals('Success. Logging you in...', result.status_msg);
    }

    /**
     * Tests a Duo Authentication request using a mock username
     */
    @IsTest
    static void successWithUsername() {
        StaticResourceCalloutMock authMock = new StaticResourceCalloutMock();
        authMock.setStaticResource('DuoError');
        authMock.setStatusCode(401);
        authMock.setHeader('Content-Type', 'application/json');

        DuoRequest authApi = new DuoAuthUsername('super.gary@example.com', new DuoPushFactor('MOCKDEVICE1111'))
            .setIPAddress('127.0.0.1');
        Test.setMock(HttpCalloutMock.class, authMock);
        Test.startTest();
        DuoResponse response = new DuoAPI().send(authApi);
        Test.stopTest();

        System.assert(response.getResult() instanceof DuoAPI.Error);
    }
}
