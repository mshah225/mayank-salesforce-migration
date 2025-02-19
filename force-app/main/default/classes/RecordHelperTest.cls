@isTest
public class RecordHelperTest {
    @isTest
    private static void testNoChanges() {
        // Tests that if no fields have changed, returns false
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');

        Assert.areEqual(
            false,
            RecordHelper.hasNewOrChangedFields(
                newContact,
                oldContact,
                new List<Schema.SObjectField>{ Contact.FirstName, Contact.LastName }
            )
        );
    }

    @isTest
    private static void testIrrelevantChanges() {
        // Tests that if only fields we aren't checking have changed, returns false
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'Old Bob', LastName = 'Newsmith');

        Assert.areEqual(
            false,
            RecordHelper.hasNewOrChangedFields(
                newContact,
                oldContact,
                new List<Schema.SObjectField>{ Contact.FirstName }
            )
        );
    }

    @isTest
    private static void testSingleChange() {
        // Tests that if one fields has changed, returns true
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'New Alice', LastName = 'Olden');

        Assert.areEqual(true, RecordHelper.hasNewOrChangedField(newContact, oldContact, Contact.FirstName));
    }

    @isTest
    private static void testMultipleChanges() {
        // Tests that if only mulitple fields have changed, returns true
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'New Alice', LastName = 'Newt');

        Assert.areEqual(
            true,
            RecordHelper.hasNewOrChangedFields(
                newContact,
                oldContact,
                new List<Schema.SObjectField>{ Contact.FirstName, Contact.LastName }
            )
        );
    }

    @isTest
    private static void testOneOfManyChanges() {
        // Tests that if only one of several field has changed, returns true
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'New Alice', LastName = 'Olden');

        Assert.areEqual(
            true,
            RecordHelper.hasNewOrChangedFields(
                newContact,
                oldContact,
                new List<Schema.SObjectField>{ Contact.FirstName, Contact.LastName }
            )
        );
    }

    @isTest
    private static void testNullOldChanges() {
        // Tests that if old record is null, returns true
        Contact oldContact = null;
        Contact newContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');

        Assert.areEqual(
            true,
            RecordHelper.hasNewOrChangedFields(
                newContact,
                oldContact,
                new List<Schema.SObjectField>{ Contact.FirstName }
            )
        );
    }

    @isTest
    private static void testSingleChangeString() {
        // Tests that if one fields has changed, returns true
        // Tests that this works when the parameter is a String rather than a Schema.SObjectField
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'New Alice', LastName = 'Olden');

        Assert.areEqual(true, RecordHelper.hasNewOrChangedField(newContact, oldContact, 'FirstName'));
    }

    @isTest
    private static void testOneOfManyChangesString() {
        // Tests that if only mulitple fields have changed, returns true
        // Tests that this works when the parameter is a List<String> rather than a List<Schema.SObjectField>
        Contact oldContact = new Contact(FirstName = 'Old Bob', LastName = 'Olden');
        Contact newContact = new Contact(FirstName = 'New Alice', LastName = 'Olden');

        Assert.areEqual(
            true,
            RecordHelper.hasNewOrChangedFields(newContact, oldContact, new List<String>{ 'FirstName', 'LastName' })
        );
    }

    @isTest
    private static void testGetValueRoot() {
        Contact record = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');

        Contact expected = record;
        Contact actual = (Contact) RecordHelper.getValue(record, '$');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueRootNull() {
        Contact record = null;

        Contact expected = record;
        Contact actual = (Contact) RecordHelper.getValue(record, '$');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueBasic() {
        Contact record = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');

        String expected = record.FirstName;
        String actual = (String) RecordHelper.getValue(record, '$.FirstName');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueLookups() {
        Contact con = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert con;
        Case record = new Case(Subject = 'Test case', ContactId = con.Id);
        insert record;
        record = [SELECT Id, Contact.FirstName FROM Case WHERE Id = :record.Id LIMIT 1];

        String expected = record.Contact.FirstName;
        String actual = (String) RecordHelper.getValue(record, '$.Contact.FirstName');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueLookupsNull() {
        Case record = new Case(Subject = 'Test case');
        insert record;
        record = [SELECT Id, Contact.FirstName FROM Case WHERE Id = :record.Id LIMIT 1];

        String expected = record.Contact.FirstName;
        String actual = (String) RecordHelper.getValue(record, '$.Contact.FirstName');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueDeepLookups() {
        Contact con = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert con;
        Case record = new Case(Subject = 'Test case', ContactId = con.Id);
        insert record;
        record = [SELECT Id, Contact.CreatedBy.Name FROM Case WHERE Id = :record.Id LIMIT 1];

        String expected = record.Contact.CreatedBy.Name;
        String actual = (String) RecordHelper.getValue(record, '$.Contact.CreatedBy.Name');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueDeepLookupsWithCache() {
        Contact con = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert con;
        Case record = new Case(Subject = 'Test case', ContactId = con.Id);
        insert record;
        record = [SELECT Id, Contact.CreatedBy.Name FROM Case WHERE Id = :record.Id LIMIT 1];

        RecordHelper.GetValueConfig config = new RecordHelper.GetValueConfig();
        config.cache = true;

        String expected = record.Contact.CreatedBy.Name;

        Integer start1 = Limits.getCpuTime();
        String actual1 = (String) RecordHelper.getValue(record, '$.Contact.CreatedBy.Name', config);
        Integer end1 = Limits.getCpuTime();

        Integer start2 = Limits.getCpuTime();
        String actual2 = (String) RecordHelper.getValue(record, '$.Contact.CreatedBy.Name', config);
        Integer end2 = Limits.getCpuTime();

        Assert.areEqual(expected, actual1);
        Assert.areEqual(expected, actual2);
        Assert.isTrue(
            (end2 - start2) < (end1 - start1),
            'Using cachine took ' +
                (end2 - start2) +
                'ms, without caching took ' +
                (end1 - start1) +
                'ms, caching should be faster but it wasn\'t'
        );
    }

    @isTest
    private static void testGetValueNoCache() {
        Contact record = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert record;

        RecordHelper.GetValueConfig config = new RecordHelper.GetValueConfig();
        config.cache = false;

        String expected1 = record.FirstName;
        String actual1 = (String) RecordHelper.getValue(record, '$.FirstName', config);

        record.FirstName = 'Waves';

        String expected2 = record.FirstName;
        String actual2 = (String) RecordHelper.getValue(record, '$.FirstName', config);

        Assert.areEqual(expected1, actual1);
        Assert.areEqual(expected2, actual2);
    }

    @isTest
    private static void testGetValueDeepLookupsNull() {
        Case record = new Case(Subject = 'Test case');
        insert record;
        record = [SELECT Id, Contact.CreatedBy.Name FROM Case WHERE Id = :record.Id LIMIT 1];

        String expected = record.Contact.CreatedBy.Name;
        String actual = (String) RecordHelper.getValue(record, '$.Contact.CreatedBy.Name');

        Assert.areEqual(expected, actual);
    }

    @isTest
    private static void testGetValueErrorFieldNotIncluded() {
        Exception thrownEx;
        Contact record = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert record;
        record = [SELECT Id, FirstName FROM Contact WHERE Id = :record.Id LIMIT 1];

        try {
            RecordHelper.getValue(record, '$.Email');
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            RecordHelper.RecordHelperFieldIncludedException.class,
            'Expected to throw an exception of type RecordHelper.RecordHelperFieldIncludedException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage().contains('is not set on the record'),
            'Expected to error message to contain "is not set on the record" but it said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testGetValueErrorLookupEndFieldNotIncluded() {
        Exception thrownEx;
        Contact con = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert con;
        Case record = new Case(Subject = 'Test case', ContactId = con.Id);
        insert record;
        record = [SELECT Id, Contact.FirstName FROM Case WHERE Id = :record.Id LIMIT 1];

        try {
            RecordHelper.getValue(record, '$.Contact.Email');
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            RecordHelper.RecordHelperFieldIncludedException.class,
            'Expected to throw an exception of type RecordHelper.RecordHelperFieldIncludedException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage().contains('is not set on the record'),
            'Expected to error message to contain "is not set on the record" but it said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testGetValueErrorLookupMidFieldNotIncluded() {
        Exception thrownEx;
        Contact con = new Contact(FirstName = 'Sky', LastName = 'Lane', Email = 'sky.lane@test.test');
        insert con;
        Case record = new Case(Subject = 'Test case', ContactId = con.Id);
        insert record;
        record = [SELECT Id, Subject FROM Case WHERE Id = :record.Id LIMIT 1];

        try {
            RecordHelper.getValue(record, '$.Contact.Email');
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            RecordHelper.RecordHelperFieldIncludedException.class,
            'Expected to throw an exception of type RecordHelper.RecordHelperFieldIncludedException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage().contains('is not set on the record'),
            'Expected to error message to contain "is not set on the record" but it said "' +
                thrownEx?.getMessage() +
                '"'
        );
    }
}
