@isTest
public class DynamicSoqlBuilderTest {
    @TestSetup
    static void setup() {
        insert new List<Contact>{
            new Contact(
                FirstName = 'Morgan',
                LastName = 'Yu',
                Email = 'morgan.yu@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(2005, 5, 5)
            ),
            new Contact(
                FirstName = 'Alex',
                LastName = 'Yu',
                Email = 'alex.yu@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(2001, 12, 17)
            ),
            new Contact(
                FirstName = 'Abigail',
                LastName = 'Foy',
                Email = 'abigail.foy@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(2002, 1, 13)
            ),
            new Contact(
                FirstName = 'Emma',
                LastName = 'Beatty',
                Email = 'emma.beatty@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(2003, 7, 7)
            ),
            new Contact(
                FirstName = 'Elias',
                LastName = 'Black',
                Email = 'elias.black@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(2000, 3, 28)
            ),
            new Contact(
                FirstName = 'Zachary',
                LastName = 'West',
                Email = 'zachary.west@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(2002, 1, 13)
            ),
            new Contact(
                FirstName = 'Danielle',
                LastName = 'Sho',
                Email = 'danielle.sho@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(2004, 8, 4)
            ),
            new Contact(
                FirstName = 'Ryan',
                LastName = 'O\'Brien',
                Email = 'robrien@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(1992, 12, 17)
            )
        };
    }

    /**
     * Simple return one field
     */
    @isTest
    private static void simpleQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest simpleQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Return multiple fields
     */
    @isTest
    private static void multipleFieldsQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest multipleFieldsQuery');
        List<Contact> expectedContacts = [SELECT Id, FirstName, LastName, Email FROM Contact];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.FirstName)
            .returnField(Schema.SObjectType.Contact.fields.LastName)
            .returnField(Schema.SObjectType.Contact.fields.Email)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Return lookup record's fields
     */
    @isTest
    private static void lookupFieldsQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest lookupFieldsQuery');

        List<Case> testCases = new List<Case>();
        for (Contact c : [SELECT Id FROM Contact])
            testCases.add(new Case(Subject = 'Subject', ContactId = c.Id));
        insert testCases;

        List<Case> expectedCases = [
            SELECT Id, Contact.Name
            FROM Case
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField('Contact.Name')
            .query();

        Assert.isTrue(
            !expectedCases.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Return child records
     */
    @isTest
    private static void childRecordsQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest multipleFieldsQuery');

        List<Case> testCases = new List<Case>();
        for (Contact c : [SELECT Id FROM Contact])
            testCases.add(new Case(Subject = 'Subject', ContactId = c.Id));
        insert testCases;

        List<Contact> expectedContacts = [SELECT Id, (SELECT Id FROM Cases) FROM Contact];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(new DynamicSoqlBuilder(Schema.SObjectType.Case).returnField(Schema.SObjectType.Case.fields.Id))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Test for EQUALS restrictions
     */
    @isTest
    private static void whereEqualsStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName = 'Yu'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(Schema.SObjectType.Contact.fields.LastName, 'Yu')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsBooleanQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsBooleanQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE DoNotCall = TRUE];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(Schema.SObjectType.Contact.fields.DoNotCall, true)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];
        List<Contact> expectedContacts = new List<Contact>{ allContacts[0] };

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictEqual(
                Schema.SObjectType.Contact.fields.Self_Service_PIN__c,
                expectedContacts[0].Self_Service_PIN__c
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past') };
        ObjectService.wait(2000);
        insert new List<Case>{ new Case(Subject = 'Future') };

        List<Case> allCases = [
            SELECT Id, CreatedDate
            FROM Case
        ];
        List<Case> expectedCases = new List<Case>{ allCases[0] };
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField(Schema.SObjectType.Case.fields.CreatedDate)
            .restrictEqual(Schema.SObjectType.Case.fields.CreatedDate, expectedCases[0].CreatedDate)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsDateQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate = :Date.newInstance(2003, 7, 7)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(Schema.SObjectType.Contact.fields.Birthdate, Date.newInstance(2003, 7, 7))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsBindQuery');
        String lastName = 'Yu';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName = :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(Schema.SObjectType.Contact.fields.LastName, new DynamicSoqlBuilderRestriction.Bind('lname'))
            .bind('lname', lastName)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsKeywordQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsKeywordQuery');

        // Update to have birthdates near today so we can use TODAY in filter
        Date past = Date.today().addDays(-3);
        Date today = Date.today();
        Date future = Date.today().addDays(3);
        List<Contact> contacts = new List<Contact>([SELECT Id, Birthdate FROM Contact]);
        for (Integer i = 0; i < contacts.size(); i++) {
            if (Math.mod(i, 3) == 0)
                contacts[i].Birthdate = past;
            else if (Math.mod(i, 3) == 1)
                contacts[i].Birthdate = today;
            else
                contacts[i].Birthdate = future;
        }
        update contacts;

        // And check correct response
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate = TODAY];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(
                Schema.SObjectType.Contact.fields.Birthdate,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Test for NOT EQUALS restrictions
     */
    @isTest
    private static void whereNotEqualsStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName != 'Yu'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotEqual(Schema.SObjectType.Contact.fields.LastName, 'Yu')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotEqualsBooleanQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsBooleanQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE DoNotCall != TRUE];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotEqual(Schema.SObjectType.Contact.fields.DoNotCall, true)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotEqualsDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];
        List<Contact> expectedContacts = new List<Contact>();
        for (Integer i = 1; i < allContacts.size(); i++)
            expectedContacts.add(allContacts[i]);

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictNotEqual(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, allContacts[0].Self_Service_PIN__c)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotEqualsDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past') };
        ObjectService.wait(2000);
        insert new List<Case>{ new Case(Subject = 'Future') };

        List<Case> allCases = [
            SELECT Id, CreatedDate
            FROM Case
            ORDER BY CreatedDate ASC
        ];
        List<Case> expectedCases = new List<Case>{ allCases[0] };
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField(Schema.SObjectType.Case.fields.CreatedDate)
            .restrictNotEqual(Schema.SObjectType.Case.fields.CreatedDate, allCases[1].CreatedDate)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotEqualsDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsDateQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate != :Date.newInstance(2003, 7, 7)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotEqual(Schema.SObjectType.Contact.fields.Birthdate, Date.newInstance(2003, 7, 7))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotEqualsBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsBindQuery');
        String lastName = 'Yu';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName != :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotEqual(
                Schema.SObjectType.Contact.fields.LastName,
                new DynamicSoqlBuilderRestriction.Bind('lname')
            )
            .bind('lname', lastName)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotEqualsKeywordQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotEqualsKeywordQuery');

        // Update to have birthdates near today so we can use TODAY in filter
        Date past = Date.today().addDays(-3);
        Date today = Date.today();
        Date future = Date.today().addDays(3);
        List<Contact> contacts = new List<Contact>([SELECT Id, Birthdate FROM Contact]);
        for (Integer i = 0; i < contacts.size(); i++) {
            if (Math.mod(i, 3) == 0)
                contacts[i].Birthdate = past;
            else if (Math.mod(i, 3) == 1)
                contacts[i].Birthdate = today;
            else
                contacts[i].Birthdate = future;
        }
        update contacts;

        // And check correct response
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate != TODAY];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotEqual(
                Schema.SObjectType.Contact.fields.Birthdate,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Test for LESS THAN OR EQUAL restrictions
     */
    @isTest
    private static void whereLessThanOrEqualsStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanOrEqualsStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName <= 'Foy'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThanOrEqual(Schema.SObjectType.Contact.fields.LastName, 'Foy')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanOrEqualsDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanOrEqualsDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];

        Decimal maxPin, minPin, midPin;
        for (Contact c : allContacts) {
            if (maxPin == null || c.Self_Service_PIN__c > maxPin)
                maxPin = c.Self_Service_PIN__c;
            if (minPin == null || c.Self_Service_PIN__c < minPin)
                minPin = c.Self_Service_PIN__c;
        }
        for (Contact c : allContacts)
            if (c.Self_Service_PIN__c > minPin && c.Self_Service_PIN__c < maxPin) {
                midPin = c.Self_Service_PIN__c;
                break;
            }

        List<Contact> expectedContacts = [
            SELECT Id, Self_Service_PIN__c
            FROM Contact
            WHERE Self_Service_PIN__c <= :midPin
        ];

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictLessThanOrEqual(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, midPin)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanOrEqualsDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanOrEqualsDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past'), new Case(Subject = 'Past') };
        ObjectService.wait(2000);
        Datetime midDt = Datetime.now();
        ObjectService.wait(2000);
        insert new List<Case>{ new Case(Subject = 'Future'), new Case(Subject = 'Future') };

        List<Case> expectedCases = [
            SELECT Id, CreatedDate
            FROM Case
            WHERE CreatedDate <= :midDt
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField(Schema.SObjectType.Case.fields.CreatedDate)
            .restrictLessThanOrEqual(Schema.SObjectType.Case.fields.CreatedDate, midDt)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanOrEqualsDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanOrEqualsDateQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate <= :Date.newInstance(2002, 1, 13)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThanOrEqual(Schema.SObjectType.Contact.fields.Birthdate, Date.newInstance(2002, 1, 13))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanOrEqualsBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanOrEqualsBindQuery');
        String lastName = 'Foy';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName <= :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThanOrEqual(
                Schema.SObjectType.Contact.fields.LastName,
                new DynamicSoqlBuilderRestriction.Bind('lname')
            )
            .bind('lname', lastName)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanOrEqualsKeywordQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanOrEqualsKeywordQuery');

        // Update to have birthdates near today so we can use TODAY in filter
        Date past = Date.today().addDays(-3);
        Date today = Date.today();
        Date future = Date.today().addDays(3);
        List<Contact> contacts = new List<Contact>([SELECT Id, Birthdate FROM Contact]);
        for (Integer i = 0; i < contacts.size(); i++) {
            if (Math.mod(i, 3) == 0)
                contacts[i].Birthdate = past;
            else if (Math.mod(i, 3) == 1)
                contacts[i].Birthdate = today;
            else
                contacts[i].Birthdate = future;
        }
        update contacts;

        // And check correct response
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate <= TODAY];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThanOrEqual(
                Schema.SObjectType.Contact.fields.Birthdate,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Test for GREATER THAN OR EQUAL restrictions
     */
    @isTest
    private static void whereGreaterThanOrEqualsStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanOrEqualsStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName >= 'Foy'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThanOrEqual(Schema.SObjectType.Contact.fields.LastName, 'Foy')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanOrEqualsDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanOrEqualsDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];

        Decimal maxPin, minPin, midPin;
        for (Contact c : allContacts) {
            if (maxPin == null || c.Self_Service_PIN__c > maxPin)
                maxPin = c.Self_Service_PIN__c;
            if (minPin == null || c.Self_Service_PIN__c < minPin)
                minPin = c.Self_Service_PIN__c;
        }
        for (Contact c : allContacts)
            if (c.Self_Service_PIN__c > minPin && c.Self_Service_PIN__c < maxPin) {
                midPin = c.Self_Service_PIN__c;
                break;
            }

        List<Contact> expectedContacts = [
            SELECT Id, Self_Service_PIN__c
            FROM Contact
            WHERE Self_Service_PIN__c >= :midPin
        ];

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictGreaterThanOrEqual(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, midPin)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanOrEqualsDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanOrEqualsDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past'), new Case(Subject = 'Past') };
        ObjectService.wait(2000);
        Datetime midDt = Datetime.now();
        ObjectService.wait(2000);
        insert new List<Case>{ new Case(Subject = 'Future'), new Case(Subject = 'Future') };

        List<Case> expectedCases = [
            SELECT Id, CreatedDate
            FROM Case
            WHERE CreatedDate >= :midDt
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField(Schema.SObjectType.Case.fields.CreatedDate)
            .restrictGreaterThanOrEqual(Schema.SObjectType.Case.fields.CreatedDate, midDt)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanOrEqualsDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanOrEqualsDateQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate >= :Date.newInstance(2002, 1, 13)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThanOrEqual(Schema.SObjectType.Contact.fields.Birthdate, Date.newInstance(2002, 1, 13))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanOrEqualsBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanOrEqualsBindQuery');
        String lastName = 'Foy';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName >= :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThanOrEqual(
                Schema.SObjectType.Contact.fields.LastName,
                new DynamicSoqlBuilderRestriction.Bind('lname')
            )
            .bind('lname', lastName)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanOrEqualsKeywordQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanOrEqualsKeywordQuery');

        // Update to have birthdates near today so we can use TODAY in filter
        Date past = Date.today().addDays(-3);
        Date today = Date.today();
        Date future = Date.today().addDays(3);
        List<Contact> contacts = new List<Contact>([SELECT Id, Birthdate FROM Contact]);
        for (Integer i = 0; i < contacts.size(); i++) {
            if (Math.mod(i, 3) == 0)
                contacts[i].Birthdate = past;
            else if (Math.mod(i, 3) == 1)
                contacts[i].Birthdate = today;
            else
                contacts[i].Birthdate = future;
        }
        update contacts;

        // And check correct response
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate >= TODAY];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThanOrEqual(
                Schema.SObjectType.Contact.fields.Birthdate,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Test for LESS THAN restrictions
     */
    @isTest
    private static void whereLessThanStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName < 'Foy'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThan(Schema.SObjectType.Contact.fields.LastName, 'Foy')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];

        Decimal maxPin, minPin, midPin;
        for (Contact c : allContacts) {
            if (maxPin == null || c.Self_Service_PIN__c > maxPin)
                maxPin = c.Self_Service_PIN__c;
            if (minPin == null || c.Self_Service_PIN__c < minPin)
                minPin = c.Self_Service_PIN__c;
        }
        for (Contact c : allContacts)
            if (c.Self_Service_PIN__c > minPin && c.Self_Service_PIN__c < maxPin) {
                midPin = c.Self_Service_PIN__c;
                break;
            }

        List<Contact> expectedContacts = [
            SELECT Id, Self_Service_PIN__c
            FROM Contact
            WHERE Self_Service_PIN__c < :midPin
        ];

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictLessThan(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, midPin)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past'), new Case(Subject = 'Past') };
        ObjectService.wait(2000);
        Datetime midDt = Datetime.now();
        ObjectService.wait(2000);
        insert new List<Case>{ new Case(Subject = 'Future'), new Case(Subject = 'Future') };

        List<Case> expectedCases = [
            SELECT Id, CreatedDate
            FROM Case
            WHERE CreatedDate < :midDt
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField(Schema.SObjectType.Case.fields.CreatedDate)
            .restrictLessThan(Schema.SObjectType.Case.fields.CreatedDate, midDt)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanDateQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate < :Date.newInstance(2002, 1, 13)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThan(Schema.SObjectType.Contact.fields.Birthdate, Date.newInstance(2002, 1, 13))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanBindQuery');
        String lastName = 'Foy';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName < :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThan(
                Schema.SObjectType.Contact.fields.LastName,
                new DynamicSoqlBuilderRestriction.Bind('lname')
            )
            .bind('lname', lastName)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereLessThanKeywordQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLessThanKeywordQuery');

        // Update to have birthdates near today so we can use TODAY in filter
        Date past = Date.today().addDays(-3);
        Date today = Date.today();
        Date future = Date.today().addDays(3);
        List<Contact> contacts = new List<Contact>([SELECT Id, Birthdate FROM Contact]);
        for (Integer i = 0; i < contacts.size(); i++) {
            if (Math.mod(i, 3) == 0)
                contacts[i].Birthdate = past;
            else if (Math.mod(i, 3) == 1)
                contacts[i].Birthdate = today;
            else
                contacts[i].Birthdate = future;
        }
        update contacts;

        // And check correct response
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate < TODAY];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLessThan(
                Schema.SObjectType.Contact.fields.Birthdate,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Test for GREATER THAN restrictions
     */
    @isTest
    private static void whereGreaterThanStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName > 'Foy'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThan(Schema.SObjectType.Contact.fields.LastName, 'Foy')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];

        Decimal maxPin, minPin, midPin;
        for (Contact c : allContacts) {
            if (maxPin == null || c.Self_Service_PIN__c > maxPin)
                maxPin = c.Self_Service_PIN__c;
            if (minPin == null || c.Self_Service_PIN__c < minPin)
                minPin = c.Self_Service_PIN__c;
        }
        for (Contact c : allContacts)
            if (c.Self_Service_PIN__c > minPin && c.Self_Service_PIN__c < maxPin) {
                midPin = c.Self_Service_PIN__c;
                break;
            }

        List<Contact> expectedContacts = [
            SELECT Id, Self_Service_PIN__c
            FROM Contact
            WHERE Self_Service_PIN__c > :midPin
        ];

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictGreaterThan(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, midPin)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past'), new Case(Subject = 'Past') };
        ObjectService.wait(2000);
        Datetime midDt = Datetime.now();
        ObjectService.wait(2000);
        insert new List<Case>{ new Case(Subject = 'Future'), new Case(Subject = 'Future') };

        List<Case> expectedCases = [
            SELECT Id, CreatedDate
            FROM Case
            WHERE CreatedDate > :midDt
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .returnField(Schema.SObjectType.Case.fields.CreatedDate)
            .restrictGreaterThan(Schema.SObjectType.Case.fields.CreatedDate, midDt)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanDateQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate > :Date.newInstance(2002, 1, 13)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThan(Schema.SObjectType.Contact.fields.Birthdate, Date.newInstance(2002, 1, 13))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanBindQuery');
        String lastName = 'Foy';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName > :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThan(
                Schema.SObjectType.Contact.fields.LastName,
                new DynamicSoqlBuilderRestriction.Bind('lname')
            )
            .bind('lname', lastName)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereGreaterThanKeywordQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereGreaterThanKeywordQuery');

        // Update to have birthdates near today so we can use TODAY in filter
        Date past = Date.today().addDays(-3);
        Date today = Date.today();
        Date future = Date.today().addDays(3);
        List<Contact> contacts = new List<Contact>([SELECT Id, Birthdate FROM Contact]);
        for (Integer i = 0; i < contacts.size(); i++) {
            if (Math.mod(i, 3) == 0)
                contacts[i].Birthdate = past;
            else if (Math.mod(i, 3) == 1)
                contacts[i].Birthdate = today;
            else
                contacts[i].Birthdate = future;
        }
        update contacts;

        // And check correct response
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate > TODAY];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictGreaterThan(
                Schema.SObjectType.Contact.fields.Birthdate,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for LIKE restrictions
     */
    @isTest
    private static void whereLikeStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLikeQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'E%'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictLike(Schema.SObjectType.Contact.fields.FirstName, 'E%')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for IN restrictions
     */
    @isTest
    private static void whereInStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName IN ('Yu', 'Sho')];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictIn(Schema.SObjectType.Contact.fields.LastName, new List<String>{ 'Yu', 'Sho' })
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereInEmptyQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInEmptyQuery');
        List<String> lastNames = new List<String>();
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName IN :lastNames];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictIn(Schema.SObjectType.Contact.fields.LastName, lastNames)
            .query();

        Assert.isTrue(expectedContacts.isEmpty(), 'Should have no records.');
        Assert.areEqual(expectedContacts.size(), returnedContacts.size());
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereInDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];

        List<Decimal> selfServicePins = new List<Decimal>();
        for (Integer i = 0; i < allContacts.size(); i++)
            if (Math.mod(i, 2) == 0)
                selfServicePins.add(allContacts[0].Self_Service_PIN__c);

        List<Contact> expectedContacts = [
            SELECT Id, Self_Service_PIN__c
            FROM Contact
            WHERE Self_Service_PIN__c IN :selfServicePins
        ];

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .returnField(Schema.SObjectType.Contact.fields.Self_Service_PIN__c)
            .restrictIn(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, selfServicePins)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereInDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past') };
        ObjectService.wait(1200);
        insert new List<Case>{ new Case(Subject = 'Future') };
        ObjectService.wait(1200);
        insert new List<Case>{ new Case(Subject = 'Far Future') };

        List<Case> allCases = [
            SELECT Id, CreatedDate
            FROM Case
            ORDER BY CreatedDate ASC
        ];

        List<Datetime> createdDates = new List<Datetime>();
        for (Integer i = 0; i < allCases.size(); i++)
            if (Math.mod(i, 2) == 0)
                createdDates.add(allCases[0].CreatedDate);

        List<Case> expectedCases = [
            SELECT Id
            FROM Case
            WHERE CreatedDate IN :createdDates
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .restrictIn(Schema.SObjectType.Case.fields.CreatedDate, createdDates)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereInDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInDateQuery');

        List<Date> birthdates = new List<Date>{ Date.newInstance(2002, 1, 13), Date.newInstance(2005, 5, 5) };

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate IN :birthdates];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictIn(Schema.SObjectType.Contact.fields.Birthdate, birthdates)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereInBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInBindQuery');
        List<String> lastNames = new List<String>{ 'Yu', 'Sho' };

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName IN :lastNames];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictIn(Schema.SObjectType.Contact.fields.LastName, new DynamicSoqlBuilderRestriction.Bind('lname'))
            .bind('lname', lastNames)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereInSubQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInBindQuery');
        List<String> lastNames = new List<String>{ 'Yu', 'Sho' };

        List<Case> testCases = new List<Case>();
        for (Contact c : [SELECT Id FROM Contact])
            testCases.add(new Case(Subject = 'Subject', ContactId = c.Id));
        insert testCases;

        List<Case> expectedCases = [
            SELECT Id
            FROM Case
            WHERE ContactId IN (SELECT Id FROM Contact WHERE LastName IN :lastNames)
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .restrictIn(
                Schema.SObjectType.Case.fields.ContactId,
                new DynamicSoqlBuilder(Schema.SObjectType.Contact)
                    .returnField(Schema.SObjectType.Contact.fields.Id)
                    .restrictIn(Schema.SObjectType.Contact.fields.LastName, lastNames)
            )
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for NOT IN restrictions
     */
    @isTest
    private static void whereNotInStringQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInStringQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName NOT IN ('Yu', 'Sho')];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotIn(Schema.SObjectType.Contact.fields.LastName, new List<String>{ 'Yu', 'Sho' })
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInEmptyQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInEmptyQuery');
        List<String> lastNames = new List<String>();
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName NOT IN :lastNames];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotIn(Schema.SObjectType.Contact.fields.LastName, lastNames)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        Assert.areEqual(expectedContacts.size(), returnedContacts.size());
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInDecimalQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInDecimalQuery');
        List<Contact> allContacts = [SELECT Id, Self_Service_PIN__c FROM Contact];

        List<Decimal> selfServicePins = new List<Decimal>();
        for (Integer i = 0; i < allContacts.size(); i++)
            if (Math.mod(i, 2) == 0)
                selfServicePins.add(allContacts[0].Self_Service_PIN__c);

        List<Contact> expectedContacts = [
            SELECT Id
            FROM Contact
            WHERE Self_Service_PIN__c NOT IN :selfServicePins
        ];

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotIn(Schema.SObjectType.Contact.fields.Self_Service_PIN__c, selfServicePins)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInDatetimeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInDatetimeQuery');

        // Make cases with CreatedDate both before and after queriable timestamp
        insert new List<Case>{ new Case(Subject = 'Past') };
        ObjectService.wait(1200);
        insert new List<Case>{ new Case(Subject = 'Future') };
        ObjectService.wait(1200);
        insert new List<Case>{ new Case(Subject = 'Far Future') };

        List<Case> allCases = [
            SELECT Id, CreatedDate
            FROM Case
            ORDER BY CreatedDate ASC
        ];

        List<Datetime> createdDates = new List<Datetime>();
        for (Integer i = 0; i < allCases.size(); i++)
            if (Math.mod(i, 2) == 0)
                createdDates.add(allCases[0].CreatedDate);

        List<Case> expectedCases = [
            SELECT Id
            FROM Case
            WHERE CreatedDate NOT IN :createdDates
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .restrictNotIn(Schema.SObjectType.Case.fields.CreatedDate, createdDates)
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInDateQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInDateQuery');

        List<Date> birthdates = new List<Date>{ Date.newInstance(2002, 1, 13), Date.newInstance(2005, 5, 5) };

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate NOT IN :birthdates];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotIn(Schema.SObjectType.Contact.fields.Birthdate, birthdates)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInBindQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInBindQuery');
        List<String> lastNames = new List<String>{ 'Yu', 'Sho' };

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName NOT IN :lastNames];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotIn(Schema.SObjectType.Contact.fields.LastName, new DynamicSoqlBuilderRestriction.Bind('lname'))
            .bind('lname', lastNames)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName NOT IN ('Yu', 'Sho')];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictNotIn(Schema.SObjectType.Contact.fields.LastName, new List<String>{ 'Yu', 'Sho' })
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInSubQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInSubQuery');
        List<String> lastNames = new List<String>{ 'Yu', 'Sho' };

        List<Case> testCases = new List<Case>();
        for (Contact c : [SELECT Id FROM Contact])
            testCases.add(new Case(Subject = 'Subject', ContactId = c.Id));
        insert testCases;

        List<Case> expectedCases = [
            SELECT Id
            FROM Case
            WHERE ContactId NOT IN (SELECT Id FROM Contact WHERE LastName IN :lastNames)
        ];
        List<Case> returnedCases = (List<Case>) new DynamicSoqlBuilder(Schema.SObjectType.Case)
            .returnField(Schema.SObjectType.Case.fields.Id)
            .restrictNotIn(
                Schema.SObjectType.Case.fields.ContactId,
                new DynamicSoqlBuilder(Schema.SObjectType.Contact)
                    .returnField(Schema.SObjectType.Contact.fields.Id)
                    .restrictIn(Schema.SObjectType.Contact.fields.LastName, lastNames)
            )
            .query();

        Assert.isTrue(!expectedCases.isEmpty(), 'If expectedCases is empty - then we have nothing to verify against.');
        assertSame(expectedCases, returnedCases);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests applying multiple restrictions (thus AND)
     */
    @isTest
    private static void whereAndQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereAndQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE FirstName = 'Morgan' AND LastName = 'Yu'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(Schema.SObjectType.Contact.fields.FirstName, 'Morgan')
            .restrictEqual(Schema.SObjectType.Contact.fields.LastName, 'Yu')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests applying a custom OR restrictions
     */
    @isTest
    private static void whereOrQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereOrQuery');
        List<Contact> expectedContacts = [
            SELECT Id
            FROM Contact
            WHERE FirstName = 'Morgan' OR Email = 'zachary.west@asu.test'
        ];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrict(
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.EqualRestriction('FirstName', 'Morgan'),
                        new DynamicSoqlBuilderRestriction.EqualRestriction('Email', 'zachary.west@asu.test')
                    }
                )
            )
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for applying a limit to the query
     */
    @isTest
    private static void limitQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest limitQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact LIMIT 2];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .setLimit(2)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for applying an offset to the query
     */
    @isTest
    private static void offsetQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest offsetQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact LIMIT 2 OFFSET 2];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .setLimit(2)
            .setOffset(2)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for applying an order to the query
     */
    @isTest
    private static void orderByQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest orderByQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact ORDER BY FirstName ASC];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .setOrder('FirstName ASC')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Tests for searching when the string has quotes
     */
    @isTest
    private static void whereStringContainsQuotes() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereStringContainsQuotes');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName = 'O\'Brien'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder(Schema.SObjectType.Contact)
            .returnField(Schema.SObjectType.Contact.fields.Id)
            .restrictEqual(Schema.SObjectType.Contact.fields.LastName, 'O\'Brien')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Assert that the records in both lists are the same - every record that exists in one exists in the other,
     * and each pair of records have the same set of fields (and those fields have the same value)
     *
     * Records must include the Id field since this is used to map expected vs returned
     */
    private static void assertSame(List<SObject> expectedRecords, List<SObject> returnedRecords) {
        Assert.areEqual(
            expectedRecords.size(),
            returnedRecords.size(),
            'Expected ' + expectedRecords.size() + ' records, but returned ' + returnedRecords.size() + ' records.'
        );

        Map<Id, SObject> returnedRecordsMap = new Map<Id, SObject>();
        for (SObject con : returnedRecords)
            returnedRecordsMap.put(con.Id, con);

        for (SObject expectedRecord : expectedRecords) {
            // Exists in map
            Assert.isTrue(
                returnedRecordsMap.containsKey(expectedRecord.Id),
                'Expected Record(Id=' + expectedRecord.Id + ') to be returned, but it was not.'
            );

            // Compare all fields
            SObject returnedRecord = returnedRecordsMap.get(expectedRecord.Id);

            Map<String, Object> expectedMp = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(expectedRecord)
            );
            Map<String, Object> returnedMp = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(returnedRecord)
            );
            Assert.areEqual(
                expectedMp.size(),
                returnedMp.size(),
                'Expected Record to have ' +
                    expectedMp.size() +
                    ' fields, but it had ' +
                    returnedMp.size() +
                    ' fields returned.'
            );

            for (String field : expectedMp.keySet()) {
                // exists in map
                Assert.isTrue(
                    returnedMp.containsKey(field),
                    'Expected field ' + field + ' to be returned, but it was not.'
                );
                // correct value for field
                Assert.areEqual(
                    expectedMp.get(field),
                    returnedMp.get(field),
                    'Expected field ' +
                        field +
                        ' to equal ' +
                        expectedMp.get(field) +
                        ', but it was ' +
                        returnedMp.get(field)
                );
            }
        }
    }
}
