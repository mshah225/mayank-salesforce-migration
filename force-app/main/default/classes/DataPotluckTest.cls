@isTest
public class DataPotluckTest {
    @isTest
    private static void testParseError503() {
        String errorMsg = DataPotluck.parseErrorMessage(
            '<html><body><h1>503 Service Unavailable</h1>No server is available to handle this request.</body></html>'
        );
        Assert.areEqual(null, errorMsg);
    }

    @isTest
    private static void testParseErrorNoPerms() {
        String errorMsg = DataPotluck.parseErrorMessage('{ "error": "unauthorized" }');
        Assert.areEqual('unauthorized', errorMsg);
    }

    @isTest
    private static void testParseErrorNone() {
        String errorMsgNull = DataPotluck.parseErrorMessage(null);
        String errorMsgEmpty = DataPotluck.parseErrorMessage('');

        Assert.areEqual(null, errorMsgNull);
        Assert.areEqual(null, errorMsgEmpty);
    }
}
