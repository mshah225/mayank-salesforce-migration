@isTest
public class EmailTransformerTest {
    // Tests that emails are cleaned up as expected - assuming they are in the correct format
    @IsTest
    private static void emailTransformMatchCustomMetadata() {
        List<EmailReplySuffix__mdt> metadata = [SELECT MasterLabel FROM EmailReplySuffix__mdt];
        String originalEmail = 'test.test@asu.edu'; // clean version of the email

        for (EmailReplySuffix__mdt metadatum : metadata) {
            EmailTransformer emailServiceObject = new EmailTransformer();
            String emailThatShouldBeCleaned = originalEmail.replace('@', '.') + metadatum.MasterLabel; // email after messing with domain (looks like test.test.asu.edu@reply.asu.edu)
            String extractedEmail = emailServiceObject.cleanEmailAddress(emailThatShouldBeCleaned); // should return the cleaned email
            System.assertEquals(originalEmail, extractedEmail);
        }
    }

    // Tests that when an email's domain matches the custom metadata, and does not match the expected format,
    // this should just default to using the @asu.edu domain
    @IsTest
    private static void emailTransformFailCustomMetadata() {
        List<EmailReplySuffix__mdt> metadata = [SELECT MasterLabel FROM EmailReplySuffix__mdt];
        String originalEmail = 'asu.advising@asu.edu'; // clean version of the email

        for (EmailReplySuffix__mdt metadatum : metadata) {
            EmailTransformer emailServiceObject = new EmailTransformer();
            String emailThatShouldBeCleaned = originalEmail.replace('@asu.edu', metadatum.MasterLabel); // email after messing with domain (looks like asu.advising@reply.asu.edu)
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
