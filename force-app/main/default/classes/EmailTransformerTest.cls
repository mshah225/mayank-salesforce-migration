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
    // it makes an error logger case and returns the unmodified email
    @IsTest
    private static void emailTransformFailCustomMetadata() {
        EmailReplySuffix__mdt metadatum = [SELECT MasterLabel FROM EmailReplySuffix__mdt LIMIT 1];

        String emailAdress = 'asu.advising' + metadatum.MasterLabel; // unexpected formatted email with cleanup domain

        if (metadatum != null) {
            EmailTransformer emailServiceObject = new EmailTransformer();
            Test.startTest();
            String extractedEmail = emailServiceObject.cleanEmailAddress(emailAdress);
            Test.stopTest();

            Case errorLoggerCase = [SELECT Id, Subject FROM Case WHERE Subject LIKE '%Apex Exception%' LIMIT 1];

            System.assertEquals(emailAdress, extractedEmail);
            System.assert(
                errorLoggerCase.Subject.contains(new EmailTransformer.EmailTransformerException().getTypeName()),
                'Created error logger case of incorrect type'
            );
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
