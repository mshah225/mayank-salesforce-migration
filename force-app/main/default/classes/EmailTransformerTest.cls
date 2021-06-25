@isTest
public class EmailTransformerTest {
    @IsTest
    private static void emailTransformMatchOriginalEmail() {
        EmailTransformer emailServiceObject = new EmailTransformer();
        String originalEmail = emailServiceObject.trimReplyFromSuffix('test.test.test.asu.edu@reply.asu.edu');
        System.assertEquals('test.test.test@asu.edu', originalEmail);
    }
}
