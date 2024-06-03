@isTest
public class DynamicSoqlBuilderTest {
    @TestSetup
    static void setup() {
        List<Contact> testContacts = new List<Contact>();

        testContacts.add(
            new Contact(
                FirstName = 'Robert',
                LastName = 'Nordman',
                Email = 'rnordman@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(1999, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 14:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Priscilla',
                LastName = 'Nordman',
                Email = 'pnordman@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(1998, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 13:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Amanda',
                LastName = 'Nordman',
                Email = 'anordman@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(1997, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 12:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Robert',
                LastName = 'Comstock',
                Email = 'rcomstock@asu.test',
                DoNotCall = true,
                Birthdate = Date.newInstance(1996, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 11:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Roger',
                LastName = 'Davies',
                Email = 'rdavies@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(1995, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 10:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Justin',
                LastName = 'Sanchez',
                Email = 'jsanchez@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(1994, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 09:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Michael',
                LastName = 'Gilardi',
                Email = 'mgildari@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(1993, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 08:00:00')
            )
        );
        testContacts.add(
            new Contact(
                FirstName = 'Ryan',
                LastName = 'O\'Brien',
                Email = 'robrien@asu.test',
                DoNotCall = false,
                Birthdate = Date.newInstance(1992, 12, 17),
                Email_Change_Date__c = Datetime.valueOf('2023-10-12 07:00:00')
            )
        );

        insert testContacts;
    }

    @isTest
    private static void simpleQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest simpleQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact').returnField('Id').query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void multipleFieldsQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest multipleFieldsQuery');
        List<Contact> expectedContacts = [SELECT Id, FirstName, LastName, Email FROM Contact];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .returnField('FirstName')
            .returnField('LastName')
            .returnField('Email')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereEqualsQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereEqualsQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName = 'Nordman'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictEqual('LastName', 'Nordman')
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
        String lastName = 'Nordman';

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName = :lastName];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictEqual('LastName', new DynamicSoqlBuilderRestriction.Bind('lname'))
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
    private static void whereInQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereInQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName IN ('Nordman', 'Sanchez')];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictIn('LastName', new List<String>{ 'Nordman', 'Sanchez' })
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
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictIn('LastName', lastNames)
            .query();

        Assert.isTrue(expectedContacts.isEmpty(), 'Should have no records.');
        Assert.areEqual(expectedContacts.size(), returnedContacts.size());
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereNotInQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereNotInQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName NOT IN ('Nordman', 'Sanchez')];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictNotIn('LastName', new List<String>{ 'Nordman', 'Sanchez' })
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
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictNotIn('LastName', lastNames)
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
        List<String> lastNames = new List<String>{ 'Nordman', 'Sanchez' };

        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName IN :lastNames];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictIn('LastName', new DynamicSoqlBuilderRestriction.Bind('lname'))
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
    private static void whereLikeQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereLikeQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'Ro%'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictLike('FirstName', 'Ro%')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereAndQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereAndQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE FirstName = 'Robert' AND LastName = 'Nordman'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictEqual('FirstName', 'Robert')
            .restrictEqual('LastName', 'Nordman')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereOrQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereOrQuery');
        List<Contact> expectedContacts = [
            SELECT Id
            FROM Contact
            WHERE FirstName = 'Robert' OR Email = 'mgildari@asu.test'
        ];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrict(
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.EqualRestriction('FirstName', 'Robert'),
                        new DynamicSoqlBuilderRestriction.EqualRestriction('Email', 'mgildari@asu.test')
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

    @isTest
    private static void limitQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest limitQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact LIMIT 2];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .setLimit(2)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void offsetQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest offsetQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact LIMIT 2 OFFSET 2];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
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

    @isTest
    private static void orderByQuery() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest orderByQuery');
        List<Contact> expectedContacts = [SELECT Id FROM Contact ORDER BY FirstName ASC];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .setOrder('FirstName ASC')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereStringContainsQuotes() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereStringContainsQuotes');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE LastName = 'O\'Brien'];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictEqual('LastName', 'O\'Brien')
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereBoolean() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereBoolean');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE DoNotCall = TRUE];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictEqual('DoNotCall', true)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereDecimal() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereDecimal');
        List<Contact> expectedContacts = [SELECT Id, Self_Service_PIN__c FROM Contact WHERE DoNotCall = TRUE];

        List<Decimal> selfServicePins = new List<Decimal>();
        for (Contact con : expectedContacts) {
            selfServicePins.add(con.Self_Service_PIN__c);
        }

        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .returnField('Self_Service_PIN__c')
            .restrictIn('Self_Service_PIN__c', selfServicePins)
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereDate() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereDate');
        List<Contact> expectedContacts = [SELECT Id FROM Contact WHERE Birthdate < :Date.newInstance(1996, 12, 17)];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictLessThan('Birthdate', Date.newInstance(1996, 12, 17))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    @isTest
    private static void whereDatetime() {
        LogSuite.activateTestFlowSuite('DynamicSoqlBuilderTest whereDatetime');
        List<Contact> expectedContacts = [
            SELECT Id
            FROM Contact
            WHERE Email_Change_Date__c <= :Datetime.valueOf('2023-10-12 10:00:00')
        ];
        List<Contact> returnedContacts = (List<Contact>) new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .restrictLessThanOrEqual('Email_Change_Date__c', Datetime.valueOf('2023-10-12 10:00:00'))
            .query();

        Assert.isTrue(
            !expectedContacts.isEmpty(),
            'If expectedContacts is empty - then we have nothing to verify against.'
        );
        assertSame(expectedContacts, returnedContacts);
        LogSuite.deactivateTestFlowSuite();
    }

    /**
     * Assert that the contacts in both lists are the same - every Contact that exists in one exists in the other,
     * and both Contacts have the same set of fields
     */
    private static void assertSame(List<Contact> expectedContacts, List<Contact> returnedContacts) {
        Assert.areEqual(
            expectedContacts.size(),
            returnedContacts.size(),
            'Expected ' +
            expectedContacts.size() +
            ' contacts, but returned ' +
            returnedContacts.size() +
            ' contacts.'
        );

        Map<Id, Contact> returnedContactsSet = new Map<Id, Contact>();
        for (Contact con : returnedContacts)
            returnedContactsSet.put(con.Id, con);

        for (Contact expectedContact : expectedContacts) {
            // Exists in map
            Assert.isTrue(
                returnedContactsSet.containsKey(expectedContact.Id),
                'Expected Contact(Id=' +
                expectedContact.Id +
                ') to be returned, but it was not.'
            );

            // Compare all fields
            Contact returnedContact = returnedContactsSet.get(expectedContact.Id);

            Map<String, Object> expectedMp = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(expectedContact)
            );
            Map<String, Object> returnedMp = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(returnedContact)
            );
            Assert.areEqual(
                expectedMp.size(),
                returnedMp.size(),
                'Expected Contact to have ' +
                expectedMp.size() +
                ' fields, but it had ' +
                returnedMp.size() +
                ' fields returned.'
            );

            for (String field : expectedMp.keySet()) {
                // exists in map
                Assert.isTrue(
                    returnedMp.containsKey(field),
                    'Expected field ' +
                    field +
                    ' to be returned, but it was not.'
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
