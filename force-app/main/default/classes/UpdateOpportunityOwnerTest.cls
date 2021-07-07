/*
 * @author: aesanch2
 */
@isTest
private class UpdateOpportunityOwnerTest {
    private static List<Opportunity> testOpportunities;
    private static ApexPages.StandardSetController stdSetCtl;
    private static UpdateOpportunityOwnerController controller;
    private static User testUser;
    private static Account testAccount;
    private static Contact testContact;

    @isTest
    static void simpleOwnerUpdateTest() {
        createTestConfiguration();
        createOpportunities(10);

        testOpportunities = [SELECT name FROM Opportunity];
        stdSetCtl = new ApexPages.StandardSetController(testOpportunities);
        stdSetCtl.setSelected(testOpportunities);
        controller = new UpdateOpportunityOwnerController(stdSetCtl);

        Test.startTest();

        System.assertEquals(10, controller.getNumberOfOpportunities());

        controller.page1();
        System.assertEquals(1, controller.getPage());

        controller.setNewOwner(testUser.Id);
        controller.confirmOwner();
        controller.submitUpdate();

        System.assertEquals(testOpportunities[0].OwnerId, testUser.Id);

        controller.cancel();

        Test.stopTest();
    }

    private static void createTestConfiguration() {
        testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        ContactFactory.DefaultContact contactMaker = new ContactFactory.DefaultContact();
        List<Contact> contactsToInsert = contactMaker.create(10);
        testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        contactsToInsert.add(testContact);
        insert contactsToInsert;

        testUser = new User();
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Username = 'username@test.com';
        testUser.Email = 'test@nomail.com';
        testUser.Alias = 'testuser';
        testUser.CommunityNickname = 'testuserCom';
        testUser.TimeZoneSidKey = 'America/Phoenix';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = '00ed00000019z5nAAA';
        testuser.ContactId = testContact.Id;
        insert testUser;
    }

    private static void createOpportunities(Integer numOfOpps) {
        List<Opportunity> opps = new List<Opportunity>();
        List<Contact> createdContacts = [SELECT Id FROM Contact LIMIT :numOfOpps];
        Opportunity testOpp;

        for (Integer i = 0; i < numOfOpps; i++) {
            testOpp = new Opportunity();
            testOpp.AccountId = testAccount.Id;
            testOpp.Contact__c = createdContacts[i].Id;
            testOpp.RecordTypeId = '012d0000000x3xyAAA';
            testOpp.StageName = 'Prospect';
            testOpp.Name = 'TestOpp ' + i;
            testOpp.CloseDate = System.today();
            opps.add(testOpp);
        }

        insert opps;
        return;
    }
}
