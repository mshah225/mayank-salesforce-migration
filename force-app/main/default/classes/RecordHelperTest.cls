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
}
