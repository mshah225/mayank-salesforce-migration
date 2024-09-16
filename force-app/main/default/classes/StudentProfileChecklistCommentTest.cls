@isTest
public class StudentProfileChecklistCommentTest {
    @isTest
    private static void testParseError503() {
        String errorMsg = StudentProfileChecklistComment.parseErrorMessage(
            '<html><body><h1>503 Service Unavailable</h1>No server is available to handle this request.</body></html>'
        );
        Assert.areEqual('503 Error, API is not running', errorMsg);
    }

    @isTest
    private static void testParseErrorNoPerms() {
        String errorMsg = StudentProfileChecklistComment.parseErrorMessage('{ "error": "Invalid Client" }');
        Assert.areEqual('Invalid Client', errorMsg);
    }

    @isTest
    private static void testParseErrorNone() {
        String errorMsgNull = StudentProfileChecklistComment.parseErrorMessage(null);
        String errorMsgEmpty = StudentProfileChecklistComment.parseErrorMessage('');

        Assert.areEqual(null, errorMsgNull);
        Assert.areEqual(null, errorMsgEmpty);
    }
}
