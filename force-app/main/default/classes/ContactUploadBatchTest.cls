@isTest
public class ContactUploadBatchTest {
    private static List<Contact_Upload_Detail__c> contactUploadDetailToInsert;
    private static List<Subscription__c> createdSubscriptions;

    private static void setup() {
        SubscriptionFactory.DefaultSubscription subscriptionCreator = new SubscriptionFactory.DefaultSubscription();
        createdSubscriptions = subscriptionCreator.create(1);
        insert createdSubscriptions;
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        List<Contact> contactToInsert = contactCreator.create(1);
        contactToInsert[0].EMPLID__C = '1000000000';
        insert contactToInsert;

        ContactUploadFactory.DefaultContactUpload contactUploadCreator = new ContactUploadFactory.DefaultContactUpload();
        List<Contact_Upload__c> contactUploadToInsert = contactUploadCreator.create(1);
        insert contactUploadToInsert;

        ContactUploadDetailFactory.DefaultContactUploadDetail contactUpLoadDetailCreator = new ContactUploadDetailFactory.DefaultContactUploadDetail(
            contactUploadToInsert[0]
        );
        contactUploadDetailToInsert = contactUpLoadDetailCreator.create(10);
    }

    @isTest
    public static void modifyDuplicateEmplIds() {
        setup();
        ContactUploadBatch batch = new ContactUploadBatch(null, createdSubscriptions[0].Id, 'Subscribed');

        ContactUploadSearcher searcher = new ContactUploadSearcher(contactUploadDetailToInsert);
        searcher.searchAndCreateContacts();
        System.assertEquals(10, contactUploadDetailToInsert.size());

        Integer countOfPreexistingContacts = 0;
        for (Contact_Upload_Detail__c contactDetails : contactUploadDetailToInsert) {
            if (contactDetails.Contact__c != null) {
                countOfPreexistingContacts++;
            }
        }
        System.assertEquals(1, countOfPreexistingContacts);
    }
}
