@isTest
private class ContactUploadDetailServiceTest {
    private static Map<Integer, String> columnPosToHeaderMap;
    private static ContactUploadDetailService detailService;
    private static Subscription__c subForDetails;
    private static List<String> contactValues;

    private static void setup() {
        ContactUploadFactory.DefaultContactUpload contactUploadCreator = new ContactUploadFactory.DefaultContactUpload();
        Contact_Upload__c contactUpload = (Contact_Upload__c) contactUploadCreator.create(1)[0];
        insert contactUpload;

        columnPosToHeaderMap = new Map<Integer, String>();
        columnPosToHeaderMap.put(0, 'ASURITE');
        columnPosToHeaderMap.put(1, 'First Name');
        columnPosToHeaderMap.put(2, 'Last Name');
        columnPosToHeaderMap.put(3, 'Email Address');
        columnPosToHeaderMap.put(4, 'EMPLID');

        SubscriptionFactory.ParentSubscription subscriptionCreator = new SubscriptionFactory.ParentSubscription();
        subForDetails = (Subscription__c) subscriptionCreator.create(1)[0];
        insert subForDetails;

        detailService = new ContactUploadDetailService(contactUpload.Id, columnPosToHeaderMap);
        detailService.setSubscriptionId(subForDetails.Id);
        detailService.setSubscriberStatus('Subscribed');

        contactValues = new List<String>{ 'tester', 'Test', 'Person', 'test@test.com', '1234567890' };
    }

    @isTest
    private static void contactCreationFromListOfStrings() {
        setup();
        Contact_Upload_Detail__c cudBeingCreated = detailService.createAndValidateRow(contactValues);
        System.assertEquals('Success', cudBeingCreated.Status__c);
        System.assertEquals('tester', cudBeingCreated.ASURITE__c);
        System.assertEquals('Test', cudBeingCreated.First_Name__c);
        System.assertEquals('Person', cudBeingCreated.Last_Name__c);
        System.assertEquals('test@test.com', cudBeingCreated.Email__c);
        System.assertEquals('Subscribed', cudBeingCreated.Subscriber_Status__c);
    }

    @isTest
    private static void createSubscriberForDetail() {
        setup();
        Contact createdContact = createAndInsertNewTestContact();

        Contact_Upload_Detail__c cudBeingCreated = detailService.createAndValidateRow(contactValues);
        cudBeingCreated.Contact__c = createdContact.Id;
        List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>();
        cudList.add(cudBeingCreated);
        detailService.createSubscriberStatusMap(cudList);
        Subscriber__c subCreated = detailService.createSubscriberForUploadDetail(cudBeingCreated);
        System.assertEquals(createdContact.Id, subCreated.Contact__c);
    }

    @isTest
    private static void findContactWithEMPLID() {
        setup();
        Contact createdContact = createAndInsertNewTestContact();

        Test.startTest();
        Contact_Upload_Detail__c cudBeingCreated = detailService.createAndValidateRow(contactValues);
        ContactUploadSearcher searcher = new ContactUploadSearcher(
            new List<Contact_Upload_Detail__c>{ cudBeingCreated }
        );
        searcher.searchAndCreateContacts();
        Test.stopTest();

        System.assertEquals(createdContact.Id, cudBeingCreated.Contact__c);
    }

    @isTest
    private static void createSubscriberForUploadDetailSubscribedStatus() {
        setup();
        Contact createdContact = createAndInsertNewTestContact();

        Contact_Upload_Detail__c cudBeingCreated = detailService.createAndValidateRow(contactValues);
        cudBeingCreated.Contact__c = createdContact.Id;
        cudBeingCreated.Subscriber_Status__c = 'Subscribed';
        List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>();
        cudList.add(cudBeingCreated);
        detailService.createSubscriberStatusMap(cudList);
        Subscriber__c subCreated = detailService.createSubscriberForUploadDetail(cudBeingCreated);
        System.assertEquals(subCreated.Subscriber_Status__c, 'Subscribed');
    }

    @isTest
    private static void createSubscriberForUploadDetailUnsubscribedStatus() {
        setup();
        Contact createdContact = createAndInsertNewTestContact();

        Contact_Upload_Detail__c cudBeingCreated = detailService.createAndValidateRow(contactValues);
        cudBeingCreated.Contact__c = createdContact.Id;
        cudBeingCreated.Subscriber_Status__c = 'Unsubscribed';

        List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>();
        cudList.add(cudBeingCreated);
        detailService.createSubscriberStatusMap(cudList);
        Subscriber__c subCreated = detailService.createSubscriberForUploadDetail(cudBeingCreated);
        System.assertEquals(subCreated.Subscriber_Status__c, 'Unsubscribed');
    }

    @isTest
    private static void tryForcingUnsubbedSubscriberToBeSubbed() {
        setup();
        Contact createdContact = createAndInsertNewTestContact();

        Contact_Upload_Detail__c cudBeingCreated = detailService.createAndValidateRow(contactValues);
        cudBeingCreated.Contact__c = createdContact.Id;
        cudBeingCreated.Subscriber_Status__c = 'Unsubscribed';
        List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>();
        cudList.add(cudBeingCreated);
        detailService.createSubscriberStatusMap(cudList);
        Subscriber__c subCreated = detailService.createSubscriberForUploadDetail(cudBeingCreated);
        insert subCreated;
        System.assertEquals(subCreated.Subscriber_Status__c, 'Unsubscribed');

        Contact_Upload_Detail__c cudBeingUpdated = detailService.createAndValidateRow(contactValues);
        cudBeingUpdated.Contact__c = createdContact.Id;
        cudBeingUpdated.Subscriber_Status__c = 'Subscribed';

        List<Contact_Upload_Detail__c> cudListUpdated = new List<Contact_Upload_Detail__c>();
        cudListUpdated.add(cudBeingUpdated);
        detailService.createSubscriberStatusMap(cudListUpdated);
        Subscriber__c subUpdated = detailService.createSubscriberForUploadDetail(cudBeingUpdated);
        System.assertEquals(subUpdated.Subscriber_Status__c, 'Unsubscribed');
        System.assert(
            cudListUpdated[0]
                .Processing_Notes__c.contains('Subscriber Status cannot be updated from Unsubscribed To Subscribed')
        );
    }

    private static Contact createAndInsertNewTestContact() {
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        Contact createdContact = (Contact) contactCreator.create(1)[0];
        createdContact.EMPLID__c = '1234567890';
        insert createdcontact;
        return createdContact;
    }
}
