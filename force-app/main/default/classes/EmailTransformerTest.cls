@isTest
public class EmailTransformerTest {
    @IsTest
    private static void emailTransformMatchCustomMetadata() {
        List<EmailReplySuffix__mdt> metadata = [SELECT MasterLabel FROM EmailReplySuffix__mdt];
        String originalEmail = 'test.test@asu.edu';

        for (EmailReplySuffix__mdt metadatum : metadata) {
            EmailTransformer emailServiceObject = new EmailTransformer();
            String extractedEmail = emailServiceObject.cleanEmailAddress(
                originalEmail.replace('@', '.') + metadatum.MasterLabel
            );
            System.assertEquals(originalEmail, extractedEmail);
        }
    }

    @IsTest
    private static void emailTransformFailCustomMetadata() {
        EmailReplySuffix__mdt metadatum = [SELECT MasterLabel FROM EmailReplySuffix__mdt LIMIT 1];

        String emailAdress = 'asu.advising' + metadatum.MasterLabel;

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

    @IsTest
    private static void emailTransformFailMatch() {
        String emailAdress = 'test.test@asu.edu';

        EmailTransformer emailServiceObject = new EmailTransformer();
        String extractedEmail = emailServiceObject.cleanEmailAddress(emailAdress);
        System.assertEquals(emailAdress, extractedEmail);
    }
}
