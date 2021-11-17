@isTest
private class RelationshipTriggerTest {
    private static final integer qtyToTest;
    private static List<Relationship__c> relationships;
    private static List<Contact> parentContacts;
    private static Map<String, Relationships__c> settings;

    @testSetup
    static void testSetup() {
        List<Relationships__c> settingsToCreate = new List<Relationships__c>();
        List<Relationship__c> relsToCreate = new List<Relationship__c>();
        List<Contact> contactsToCreate = new List<Contact>();
        Relationship__c rel; // Temporary relationship object

        // Query only the contact_to_contact record type
        // Opted not to use reciprocal record types as it is unneeded
        Id rId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Relationship__c' AND DeveloperName = 'Contact_to_Contact'
        ]
        .Id;

        // Create custom settings for the relationship handler to query
        // These settings were pulled from setup to mimick a live environment
        settingsToCreate.add(new Relationships__c(Name = 'Parent/Guardian', Reciprocal__c = 'Child'));
        settingsToCreate.add(new Relationships__c(Name = 'Child', Reciprocal__c = 'Parent/Guardian'));

        insert settingsToCreate;

        contactsToCreate = TestDataFactory.createContacts(qtyToTest * 2);

        // Insert records that trigger async apex methods
        test.startTest();
        insert contactsToCreate;
        test.stopTest();

        // Link parents to children
        for (integer x = 0; x < qtyToTest; x++) {
            rel = new Relationship__c(
                Contact__c = contactsToCreate[x].Id,
                Related_Contact__c = contactsToCreate[x + qtyToTest].Id,
                Relationship_Type__c = 'Parent/Guardian',
                Active_Relationship__c = true,
                Relationship_Start_Date__c = Date.today(),
                RecordTypeId = rId,
                Relationship_Created_By__c = null,
                Sub_Type__c = null,
                Revoke_Status__c = false,
                Source__c = 'PS MyASU Guest Portal',
                Source_Date__c = Date.today()
            );

            relsToCreate.add(rel);
        }

        // Insert relationships
        insert relsToCreate;
    }

    /**
     * Initialize static variables (called once for each test method)
     */
    static {
        try {
            settings = Relationships__c.getAll();
            Set<Id> contactIds = new Set<Id>(); // Used to pull up contacts labled as parents

            qtyToTest = 2;
            relationships = [SELECT Contact__c FROM Relationship__c WHERE Relationship_Type__c = 'Parent/Guardian'];

            for (Relationship__c r : relationships) {
                contactIds.add(r.Contact__c);
            }

            // Get a list of every contact and every contact's reciprocal relationship
            // Ordered by name in decending order so that parents appear first in the list
            parentContacts = [
                SELECT
                    Id,
                    (
                        SELECT
                            Id,
                            Contact__c,
                            Related_Contact__c,
                            Relationship_Type__c,
                            Active_Relationship__c,
                            Relationship_Start_Date__c,
                            RecordTypeId
                        FROM Relationships__r
                        ORDER BY Name DESC
                    ),
                    (
                        SELECT
                            Id,
                            Contact__c,
                            Related_Contact__c,
                            Relationship_Type__c,
                            Active_Relationship__c,
                            Relationship_Start_Date__c,
                            RecordTypeId
                        FROM Reciprocal_Relationships__r
                        ORDER BY Name DESC
                    )
                FROM Contact
                WHERE Id IN :contactIds
            ];
        } catch (Exception e) {
        }
    }

    @isTest
    static void testReciprocalCreation() {
        Relationship__c parent;
        Relationship__c child;

        for (Contact c : parentContacts) {
            parent = (Relationship__c) c.getSObjects('Relationships__r')[0];
            child = (Relationship__c) c.getSObjects('Reciprocal_Relationships__r')[0];

            system.assert(parent.Contact__c == child.Related_Contact__c);
            system.assert(parent.Related_Contact__c == child.Contact__c);
            system.assert(child.Relationship_Type__c == settings.get(parent.Relationship_Type__c).Reciprocal__c);
            system.assert(parent.Active_Relationship__c == child.Active_Relationship__c);
            system.assert(parent.Relationship_Start_Date__c == child.Relationship_Start_Date__c);
            system.assert(parent.RecordTypeId == child.RecordTypeId);
        }

        system.assertEquals(qtyToTest, [SELECT Id FROM Relationship__c WHERE Relationship_Type__c = 'Child'].size());
    }

    @isTest
    static void testReciprocalUpdate() {
        List<Relationship__c> relsToUpdate = new List<Relationship__c>();
        List<Id> relsToVerify = new List<Id>();

        // Change parents to children
        for (Relationship__c r : [
            SELECT Reciprocal_Relationship__c, Relationship_Type__c
            FROM Relationship__c
            WHERE Relationship_Type__c = 'Parent/Guardian'
        ]) {
            r.Relationship_Type__c = 'Child';
            r.Revoke_Status__c = true;

            relsToVerify.add(r.Reciprocal_Relationship__c);
            relsToUpdate.add(r);
        }

        test.startTest();
        update relsToUpdate;
        test.stopTest();

        // Verify that children were updated to show that they are parents now
        for (Relationship__c r : [SELECT Relationship_Type__c FROM Relationship__c WHERE Id IN :relsToVerify]) {
            system.assertEquals('Parent/Guardian', r.Relationship_Type__c);
        }
    }

    @isTest
    static void testReciprocalDeletion() {
        test.startTest();
        delete relationships;
        test.stopTest();
    }

    @isTest
    static void testCreateRelationship() {
        Account testAccount = new Account(Name = 'Test Account', Website = 'www.example.com');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;

        String title = 'test title';

        Id recordId = IDHelper.getRecordTypeId('Relationship__c', 'Account_to_Contact');

        test.startTest();
        RelationshipService.createContactAccountRelationship(testContact.Id, testAccount.Id, recordId, title);
        test.stopTest();
    }
}
