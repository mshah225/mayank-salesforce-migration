@isTest
public class EmailTransformerTest {
    // Tests that emails are cleaned up as expected - assuming they are in the correct format
    @IsTest
    private static void emailTransformMatchCustomMetadata() {
        List<EmailReplySuffix__mdt> metadata = [SELECT MasterLabel FROM EmailReplySuffix__mdt];
        String originalEmail = 'test.test@asu.edu'; // clean version of the email

        for (EmailReplySuffix__mdt metadatum : metadata) {
            EmailTransformer emailServiceObject = new EmailTransformer();
            String emailThatShouldBeCleaned = 'test.test@reply.asu.edu';
            String extractedEmail = emailServiceObject.cleanEmailAddress(emailThatShouldBeCleaned); // should return the cleaned email
            System.assertEquals(originalEmail, extractedEmail);
        }
    }

    // Tests that emails are not cleaned up if they don't match the metadata
    @IsTest
    private static void emailTransformFailMatch() {
        String emailAdress = 'test.test@asu.edu'; // no cleanup domain - should be untouched

        EmailTransformer emailServiceObject = new EmailTransformer();
        String extractedEmail = emailServiceObject.cleanEmailAddress(emailAdress);
        System.assertEquals(emailAdress, extractedEmail);
    }
}
