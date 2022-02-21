@isTest
public class ContactUploadBatchTest {
    private static List<Contact_Upload_Detail__c> contactUploadDetailToInsertList = new List<Contact_Upload_Detail__c>();
    private static List<Subscription__c> createdSubscriptionsList = new List<Subscription__c>();

    private static void setup() {
        Subscription__c createdSubscriptions = new Subscription__c(
            Name = 'Test Subscription',
            Subscription_Type__c = 'List',
            Subscriber_Private_in_Salesforce__c = false
        );
        createdSubscriptionsList.add(createdSubscriptions);
        insert createdSubscriptionsList;

        Contact contactToInsert = new contact();
        contactToInsert.firstName = 'Test';
        contactToInsert.lastName = 'Test';
        contactToInsert.EMPLID__C = '1000000000';
        insert contactToInsert;

        Contact_Upload__c contactUploadToInsert = new Contact_Upload__c();
        insert contactUploadToInsert;

        Contact_Upload_Detail__c contactUploadDetailToInsert = new Contact_Upload_Detail__c(
            Contact_Upload__c = contactUploadToInsert.Id,
            First_Name__c = 'Alice',
            Last_Name__c = 'Test',
            Email__c = 'atest@example.com',
            Subscription__c = 'a28000000000000'
        );

        contactUploadDetailToInsertList.add(contactUploadDetailToInsert);
    }

    @isTest
    public static void modifyDuplicateEmplIds() {
        setup();
        ContactUploadBatch batch = new ContactUploadBatch(null, createdSubscriptionsList[0].Id, 'Subscribed');

        ContactUploadSearcher searcher = new ContactUploadSearcher(contactUploadDetailToInsertList);
        searcher.searchAndCreateContacts();
        System.assertEquals(1, contactUploadDetailToInsertList.size());

        Integer countOfPreexistingContacts = 0;
        for (Contact_Upload_Detail__c contactDetails : contactUploadDetailToInsertList) {
            if (contactDetails.Contact__c != null) {
                countOfPreexistingContacts++;
            }
        }
        System.assertEquals(1, countOfPreexistingContacts);
    }

    @isTest
    public static void contactUploadDetailTest() {
        Contact con = new contact();
        con.firstName = 'Test';
        con.lastName = 'Test';
        insert con;

        Contact_Upload__c conUpload = new Contact_Upload__c(
            Description__c = 'Test Contact_Upload__c',
            Status__c = 'New'
        );
        insert conUpload;

        Contact_Upload_Detail__c conUploadDetail = new Contact_Upload_Detail__c(
            Subscriber_Status__c = 'Subscribed',
            EMPLID__c = '123456',
            Status__c = 'Error',
            Contact_Upload__c = conUpload.Id
        );
        insert conUploadDetail;

        Attachment attach = new attachment();
        Blob resultBody = blob.valueOf('Test attachment');
        attach.name = 'Test Name';
        attach.body = resultBody;
        attach.parentId = con.Id;
        insert attach;

        Subscription__c subscription = new Subscription__c(
            Name = 'Test Subscription',
            Subscription_Type__c = 'Business Unit',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert subscription;

        Subscriber__c subscriber = new Subscriber__c(
            Subscription__c = subscription.Id,
            Contact__c = con.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        insert subscriber;

        ContactUploadBatch batch = new ContactUploadBatch(attach.Id, subscriber.Id, subscriber.Subscriber_Status__c);

        Test.startTest();
        Boolean res = batch.noErroredRecords();
        Test.stopTest();

        System.assertEquals(true, res);
    }
}
