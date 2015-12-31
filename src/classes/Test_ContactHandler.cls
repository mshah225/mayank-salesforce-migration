@isTest
public with sharing class Test_ContactHandler 
{
    private static final Integer TRIGGERLOAD = 200;

	@isTest static void testSFMasteredContactCreation()
	{
        Id SFMasteredContactRTId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Contact'
                AND Name = 'SF Mastered'
        ].Id;

        Id SFMasteredContactAccountRTId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Account'
                AND Name = 'SF Mastered Contact'
        ].Id;

		// Set up the Contacts
        Set<Id> sfMasteredIds = new Set<Id>();
        List<Contact> sfMasteredContacts = ContactService.createTestContacts(TRIGGERLOAD, false);

        Test.startTest();
        insert sfMasteredContacts;
        Test.stopTest();

        sfMasteredContacts = [
                SELECT Id, RecordTypeId
                FROM Contact
                LIMIT :TRIGGERLOAD
        ];

		for (Contact testContact : sfMasteredContacts)
		{
			System.assertEquals(SFMasteredContactRTId, testContact.RecordTypeId);
            sfMasteredIds.add(testContact.Id);
		}

		List<Account> sfMasteredAccounts = new List<Account>([
                SELECT Id, RecordTypeId
                FROM Account
                WHERE Contact__c IN :sfMasteredIds
        ]);

		for (Account testAccount : sfMasteredAccounts)
		{
			System.assertEquals(SFMasteredContactAccountRTId, testAccount.RecordTypeId);
		}

        // This is not really necessary, but bumps up test coverage for the TriggerFactory class
        delete sfMasteredContacts;
	}

    @isTest static void testSFMasteredContactUpdate()
    {
        Id SFMasteredContactRTId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Contact'
                AND Name = 'SF Mastered'
        ].Id;

        Id SFMasteredContactAccountRTId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Account'
                AND Name = 'SF Mastered Contact'
        ].Id;

        // Set up the Contacts
        Set<Id> sfMasteredIds = new Set<Id>();
        List<Contact> sfMasteredContacts = ContactService.createTestContacts(TRIGGERLOAD, false);

        insert sfMasteredContacts;

        for (Contact testContact : sfMasteredContacts)
        {
            testContact.FirstName = 'Updated';
        }

        Test.startTest();
        update sfMasteredContacts;
        Test.stopTest();

        sfMasteredContacts = [
                SELECT Id, RecordTypeId
                FROM Contact
                LIMIT :TRIGGERLOAD
        ];

        for (Contact testContact : sfMasteredContacts)
        {
            System.assertEquals(SFMasteredContactRTId, testContact.RecordTypeId);
            sfMasteredIds.add(testContact.Id);
        }

        List<Account> sfMasteredAccounts = new List<Account>([
                SELECT Id, RecordTypeId
                FROM Account
                WHERE Contact__c IN :sfMasteredIds
        ]);

        for (Account testAccount : sfMasteredAccounts)
        {
            System.assertEquals(SFMasteredContactAccountRTId, testAccount.RecordTypeId);
        }
    }

	@isTest static void testExtMasteredContactCreation()
	{
        Id ExtMasteredContactId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Contact'
                AND Name = 'External Mastered'
        ].Id;

        Id ExtMasteredContactAccountId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Account'
                AND Name = 'External Mastered Contact'
        ].Id;

        // Set up the Contacts
        Set<Id> extMasteredIds= new Set<Id>();
        List<Contact> extMasteredContacts = ContactService.createTestContacts(TRIGGERLOAD, true);

        Test.startTest();
        insert extMasteredContacts;
        Test.stopTest();

        extMasteredContacts = [
                SELECT Id, RecordTypeId
                FROM Contact
                LIMIT :TRIGGERLOAD
        ];

        for (Contact testContact : extMasteredContacts)
        {
            System.assertEquals(ExtMasteredContactId, testContact.RecordTypeId);
            extMasteredIds.add(testContact.Id);
        }

        List<Account> extMasteredAccounts = new List<Account>([
                SELECT Id, RecordTypeId
                FROM Account
                WHERE Contact__c IN :extMasteredIds
        ]);

        for (Account testAccount : extMasteredAccounts)
        {
            System.assertEquals(ExtMasteredContactAccountId, testAccount.RecordTypeId);
        }
	}

    @isTest static void testExtMasteredContactUpdate()
    {
        Id ExtMasteredContactId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Contact'
                AND Name = 'External Mastered'
        ].Id;

        Id ExtMasteredContactAccountId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Account'
                AND Name = 'External Mastered Contact'
        ].Id;

        // Set up the Contacts
        Set<Id> extMasteredIds = new Set<Id>();
        List<Contact> extMasteredContacts = ContactService.createTestContacts(TRIGGERLOAD, true);

        insert extMasteredContacts;

        for (Contact testContact : extMasteredContacts)
        {
            testContact.FirstName = 'Updated';
        }

        Test.startTest();
        update extMasteredContacts;
        Test.stopTest();

        extMasteredContacts = [
                SELECT Id, RecordTypeId
                FROM Contact
                LIMIT :TRIGGERLOAD
        ];

        for (Contact testContact : extMasteredContacts)
        {
            System.assertEquals(ExtMasteredContactId, testContact.RecordTypeId);
            extMasteredIds.add(testContact.Id);
        }

        List<Account> extMasteredAccounts = new List<Account>([
                SELECT Id, RecordTypeId
                FROM Account
                WHERE Contact__c IN :extMasteredIds
        ]);

        for (Account testAccount : extMasteredAccounts)
        {
            System.assertEquals(ExtMasteredContactAccountId, testAccount.RecordTypeId);
        }
    }

    @isTest static void testScanbizContacts()
    {
        Id scanbizCampaignMemberRTId = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'CampaignMember'
                AND Name = 'Corporate Relations Member'
        ].Id;

        Campaign scanbizCampaign = CampaignService.createTestCampaign('Engineering – GOEE', scanbizCampaignMemberRTId);
        insert scanbizCampaign;

        Account scanbizAccount = AccountService.createTestSFMasteredAccount();
        insert scanbizAccount;

        Contact scanbizContact = ContactService.createTestContact();
        scanbizContact.scanbizcards__ScanBizCards__c = true;
        scanbizContact.AccountId = scanbizAccount.Id;

        Test.startTest();
        insert scanbizContact;
        Test.stopTest();

        Relationship__c scanbizRelationship = [
                SELECT Account__c, Contact__c, Relationship_Type__c
                FROM Relationship__c
                LIMIT 1
        ];

        scanbizContact = [
                SELECT Scanbiz_Account__c, Corporate_Relations_Contact_Owner__c
                FROM Contact
                WHERE Id = :scanbizContact.Id
        ];

        CampaignMember scanbizCampaignMember = [
                SELECT Id, CampaignId
                FROM CampaignMember
                WHERE ContactId = :scanbizContact.Id
        ];

        System.assertEquals(scanbizAccount.Id, scanbizRelationship.Account__c);
        System.assertEquals(scanbizContact.Id, scanbizRelationship.Contact__c);
        System.assertEquals('Employee', scanbizRelationship.Relationship_Type__c);
        System.assertEquals(scanbizAccount.Id, scanbizContact.Scanbiz_Account__c);
        System.assertEquals(UserInfo.getUserId(), scanbizContact.Corporate_Relations_Contact_Owner__c);
        System.assertEquals(scanbizCampaign.Id, scanbizCampaignMember.CampaignId);
    }
}