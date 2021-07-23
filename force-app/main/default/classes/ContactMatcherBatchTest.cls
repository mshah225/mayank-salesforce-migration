@isTest
public with sharing class ContactMatcherBatchTest {
    private static String attachmentFileName = 'TestAttachment';

    @TestSetup
    static void setup() {
        Contact con = new Contact(FirstName = 'ContactMatcherBatch', LastName = 'TestContact');

        Contact_Upload__c attParent = new Contact_Upload__c(
            Description__c = 'Test Contact_Upload__c',
            Status__c = 'New'
        );
        insert attParent;

        Contact csvContact1 = new Contact(
            FirstName = 'CSV_Contact_1',
            LastName = 'TestContact1',
            Email = 'CSV_Contact_1.TestContact1@test.test'
        );
        Contact csvContact2 = new Contact(
            FirstName = 'CSV_Contact_2',
            LastName = 'TestContact2',
            Email = 'CSV_Contact_2.TestContact2@test.test'
        );
        Contact csvContact3 = new Contact(
            FirstName = 'CSV_Contact_3',
            LastName = 'TestContact3',
            Email = 'CSV_Contact_3.TestContact3@test.test'
        );

        insert new List<Contact>{ csvContact1, csvContact2, csvContact3 };

        Blob fileContents = Blob.valueOf(
            'First Name,Last Name,Email Address\r' +
            csvContact1.FirstName +
            ',' +
            csvContact1.LastName +
            ',' +
            csvContact1.Email +
            '\r' +
            csvContact2.FirstName +
            ',' +
            csvContact2.LastName +
            ',' +
            csvContact2.Email +
            '\r' +
            csvContact3.FirstName +
            ',' +
            csvContact3.LastName +
            ',' +
            csvContact3.Email +
            '\r'
        );
        Attachment att = new Attachment(
            Name = attachmentFileName + '.csv',
            Body = fileContents,
            ParentId = attParent.Id
        );
        insert att;

        Subscription__c subscription = new Subscription__c(
            Name = 'Test Subscription',
            Subscription_Type__c = 'List',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert subscription;

        Subscriber__c subscriber1 = new Subscriber__c(Contact__c = csvContact1.Id, Subscription__c = subscription.Id);
        Subscriber__c subscriber2 = new Subscriber__c(Contact__c = csvContact2.Id, Subscription__c = subscription.Id);
        Subscriber__c subscriber3 = new Subscriber__c(Contact__c = csvContact3.Id, Subscription__c = subscription.Id);
        insert new List<Subscriber__c>{ subscriber1, subscriber2, subscriber3 };
    }

    @isTest
    private static void testCreatesNewAttachmentWithIds() {
        Attachment att = [SELECT Id FROM Attachment LIMIT 1];
        Subscription__c subscription = [SELECT Id FROM Subscription__c LIMIT 1];

        Test.startTest();
        ContactMatcherBatch batch = new ContactMatcherBatch(att.Id, subscription.Id);
        Database.executeBatch(batch, 500);
        Test.stopTest();

        Attachment newAtt = [
            SELECT Id, Body, Name
            FROM Attachment
            WHERE Name = :attachmentFileName + '(With Ids).csv'
            LIMIT 1
        ];

        // Separate into each row/column
        String newAttContents = newAtt.Body.toString();
        List<String> newAttLines = newAttContents.split('\r');
        List<String> fileHeaders = null;
        List<List<String>> fileRows = new List<List<String>>();
        for (String eachRow : newAttLines) {
            if (fileHeaders == null) {
                fileHeaders = eachRow.split(',');
            } else {
                fileRows.add(eachRow.split(','));
            }
        }
        // Which index has the contact Id's?
        Integer indexOfId = 0;
        for (Integer i = 0; i < fileHeaders.size(); i++) {
            if (fileHeaders[i].equals('Contact Id')) {
                indexOfId = i;
                break;
            }
        }
        // Verify that all rows had ID added in
        System.assertEquals(3, fileRows.size());
        for (List<String> separatedRows : fileRows) {
            System.assert(Validator.validateId(separatedRows[indexOfId], Contact.class));
        }
    }
}
