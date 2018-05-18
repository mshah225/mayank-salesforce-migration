@isTest
private class ContactUploadDetailServiceTest {
    private static Map<Integer, String> columnPosToHeaderMap;
    private static ContactUploadDetailService detailService;
    private static Subscription__c subForDetails;
    
    private static void setup() {
        ContactUploadFactory.DefaultContactUpload contactUploadCreator = new ContactUploadFactory.DefaultContactUpload();
        Contact_Upload__c contactUpload = (Contact_Upload__c)contactUploadCreator.create(1)[0];
        insert contactUpload;
        
        columnPosToHeaderMap = new Map<Integer, String>();
        columnPosToHeaderMap.put(0, 'ASURITE');
        columnPosToHeaderMap.put(1, 'First Name');
        columnPosToHeaderMap.put(2, 'Last Name');
        columnPosToHeaderMap.put(3, 'Email Address');
        columnPosToHeaderMap.put(4, 'Subscription ID');
        columnPosToHeaderMap.put(5, 'EMPLID');
        
        detailService = new ContactUploadDetailService(contactUpload.Id, columnPosToHeaderMap);
        
        SubscriptionFactory.ParentSubscription subscriptionCreator = new SubscriptionFactory.ParentSubscription();
        subForDetails = (Subscription__c)subscriptionCreator.create(1)[0];
        insert subForDetails;
    }
    
    @isTest
    private static void contactCreationFromListOfStrings() {
        setup();
        List<String> contactValues = new list<String>{'tester', 'Test', 'Person', 'test@test.com', subForDetails.Id, ''};
        Contact_Upload_Detail__c cudBeingCreated = detailService.createContactFromRow(contactValues);
        System.assertEquals('Success', cudBeingCreated.Status__c);
        System.assertEquals('tester', cudBeingCreated.ASURITE__c);
        System.assertEquals('Test', cudBeingCreated.First_Name__c);
        System.assertEquals('Person', cudBeingCreated.Last_Name__c);
        System.assertEquals('test@test.com', cudBeingCreated.Email__c);
    }
    
    @isTest
    private static void createSubscriberForDetail() {
        setup();
        List<String> contactValues = new list<String>{'tester', 'Test', 'Person', 'test@test.com', subForDetails.Id, '1234567890'};
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        Contact createdContact = (Contact)contactCreator.create(1)[0];
        createdContact.EMPLID__c = '1234567890';
        insert createdcontact;
        Contact_Upload_Detail__c cudBeingCreated = detailService.createContactFromRow(contactValues);
        cudBeingCreated.Contact__c = createdContact.Id;
        
        Subscriber__c subCreated = detailService.createSubscriberForCUD(cudBeingCreated);
        System.assertEquals(createdContact.Id, subCreated.Contact__c);   
    }
    
    @isTest
    private static void addSubscriberToDetail() {
        setup();
        List<String> contactValues = new list<String>{'tester', 'Test', 'Person', 'test@test.com', subForDetails.Id, '1234567890'};
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        Contact createdContact = (Contact)contactCreator.create(1)[0];
        createdContact.EMPLID__c = '1234567890';
        insert createdcontact;
        Contact_Upload_Detail__c cudBeingCreated = detailService.createContactFromRow(contactValues);
        cudBeingCreated.Contact__c = createdContact.Id;
        
        Subscriber__c subCreated = detailService.createSubscriberForCUD(cudBeingCreated);
        insert subCreated;
        Map<String, Id> subKeyToSubIdMap = new Map<String, Id>();
        subKeyToSubIdMap.put(subCreated.Unique_Key__c, subCreated.Id);
        
        cudBeingCreated = detailService.addSubscriberToDetail(cudBeingCreated, subKeyToSubIdMap);
        
        System.assertEquals(subCreated.Id, cudBeingCreated.Subscriber__c);
    }
    
    @isTest
    private static void findContactWithEMPLID() {
        setup();
        List<String> contactValues = new list<String>{'tester', 'Test', 'Person', 'test@test.com', subForDetails.Id, '1234567890'};
        ContactFactory.DefaultContact contactCreator = new ContactFactory.DefaultContact();
        Contact createdContact = (Contact)contactCreator.create(1)[0];
        createdContact.EMPLID__c = '1234567890';
        insert createdcontact;
        Contact_Upload_Detail__c cudBeingCreated = detailService.createContactFromRow(contactValues);
        detailService.searchAndMatchContactWithEmplId(new List<Contact_Upload_Detail__c>{cudBeingCreated});
        System.assertEquals(createdContact.Id, cudBeingCreated.Contact__c);
    }
}