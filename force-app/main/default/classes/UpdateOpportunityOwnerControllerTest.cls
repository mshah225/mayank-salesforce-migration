@isTest
private class UpdateOpportunityOwnerControllerTest {
    private static final String testUserAlias = 'testUsr';
    private static final String testUserAlias2 = 'testUsr2';

    @TestSetup
    private static void setup() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Contacts for all the opportunities
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            testContacts.add(
                new Contact(
                    FirstName = 'Test-' + i,
                    LastName = 'Contact',
                    Email = 'test' + i + '@test.com',
                    EmplId__c = '123456' + i
                )
            );
        }
        insert testContacts;

        // Two test users
        Id standardUserProfileId = RecordIdHelper.getProfileId('Standard User');
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'usernameopptest@test.test',
            Email = 'test@nomail.com',
            Alias = testUserAlias,
            CommunityNickname = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = standardUserProfileId
        );
        User testUser2 = new User(
            FirstName = 'Test2',
            LastName = 'User',
            Username = 'username2opptest@test.test',
            Email = 'test2@nomail.com',
            Alias = testUserAlias2,
            CommunityNickname = testUserAlias2,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = standardUserProfileId
        );
        insert new List<User>{ testUser, testUser2 };

        // Create the opportunities
        Id undergradOpportunity = RecordIdHelper.getRecordTypeId('Opportunity', 'Undergraduate_Prospect');
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < testContacts.size(); i++) {
            opps.add(
                new Opportunity(
                    AccountId = testAccount.Id,
                    Contact__c = testContacts[i].Id,
                    RecordTypeId = undergradOpportunity,
                    StageName = 'Prospect',
                    Name = 'TestOpp ' + i,
                    OwnerId = (Math.mod(i, 2) == 0 ? testUser.Id : testUser2.Id),
                    CloseDate = System.today()
                )
            );
        }
        insert opps;
    }

    @isTest
    static void testOwnerUpdate() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2];

        Integer numberOfCasesOwnedByTestUser = 0, numberOfCasesOwnedByTestUser2 = 0, numberOfCasesInController;

        // Count how many opportunities owned by each user
        List<Opportunity> testOpportunities = [SELECT Id, OwnerId FROM Opportunity];
        for (Opportunity opp : testOpportunities) {
            if (opp.OwnerId == testUser.Id)
                numberOfCasesOwnedByTestUser++;
            else if (opp.OwnerId == testUser2.Id)
                numberOfCasesOwnedByTestUser2++;
        }

        Test.startTest();
        testOpportunities = [SELECT Id FROM Opportunity WHERE OwnerId = :testUser.Id];
        ApexPages.StandardSetController stdSetCtl = new ApexPages.StandardSetController(testOpportunities);
        stdSetCtl.setSelected(testOpportunities);
        UpdateOpportunityOwnerController controller = new UpdateOpportunityOwnerController(stdSetCtl);

        numberOfCasesInController = controller.getNumberOfOpportunities();

        controller.setNewOwner(testUser2.Id);
        controller.confirmOwner();
        controller.submitUpdate();
        controller.cancel();
        Test.stopTest();

        testOpportunities = [SELECT Id FROM Opportunity WHERE OwnerId = :testUser2.Id];

        System.assertEquals(numberOfCasesOwnedByTestUser, numberOfCasesInController);
        System.assertEquals(numberOfCasesOwnedByTestUser + numberOfCasesOwnedByTestUser2, testOpportunities.size());
    }

    @isTest
    static void testZeroOpportunities() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUserAlias2];

        Integer numberOfCasesInController;

        Test.startTest();
        List<Opportunity> testOpportunities = new List<Opportunity>();
        ApexPages.StandardSetController stdSetCtl = new ApexPages.StandardSetController(testOpportunities);
        UpdateOpportunityOwnerController controller = new UpdateOpportunityOwnerController(stdSetCtl);
        numberOfCasesInController = controller.getNumberOfOpportunities();
        controller.confirmOwner();
        Test.stopTest();

        System.assertEquals(0, numberOfCasesInController);
        System.assertEquals(1, ApexPages.getMessages().size());
        for (ApexPages.Message message : ApexPages.getMessages()) {
            Boolean properMessage = false;
            if (
                message.getSeverity() == ApexPages.Severity.ERROR &&
                message.getSummary().contains('No opportunities selected in the list view')
            ) {
                properMessage = true;
            }
            System.assert(properMessage, 'Found a message that was unexpected.');
        }
    }

    @isTest
    static void testCheckPage() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        Integer pageNumberInController;
        Pagereference actualPageRef;

        Test.startTest();
        List<Opportunity> testOpportunities = new List<Opportunity>();
        ApexPages.StandardSetController stdSetCtl = new ApexPages.StandardSetController(testOpportunities);
        UpdateOpportunityOwnerController controller = new UpdateOpportunityOwnerController(stdSetCtl);
        actualPageRef = controller.page1();
        pageNumberInController = controller.getPage();
        Test.stopTest();

        System.assertEquals(1, pageNumberInController);
        System.assertEquals(null, actualPageRef.getUrl());
    }
}