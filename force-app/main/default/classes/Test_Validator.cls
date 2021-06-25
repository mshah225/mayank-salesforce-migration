@isTest
public class Test_Validator {
    /**
     * Set up requried test data for the validator
     */
    @testSetup
    static void testSetup() {
        List<SOBject> recordsToCreate = new List<SObject>();
        recordsToCreate.add(TestDataFactory.createLead('validatorLead'));

        insert recordsToCreate;
    }

    /**
     * Tests the validators accuracy when validating email addresses
     */
    public static testMethod void Test_validateEmail() {
        String validEmail = 'test@asu.edu';
        String invalidEmail = 'YugiohIsForNerds';

        system.assert(Validator.validateEmail(validEmail));
        system.assert(!Validator.validateEmail(invalidEmail));
    }

    /**
     * Tests the validators accuracy when validating Ids
     */
    public static testMethod void Test_validateId() {
        string validId = string.valueOf([SELECT Id FROM Lead LIMIT 1].Id);
        string invalidId = 'ShammaLammaDingDong';

        system.assert(Validator.validateId(validId));
        system.assert(!Validator.validateId(invalidId));
    }

    /**
     * Test methods return false when passed null
     */
    public static testMethod void Test_nulls() {
        system.assert(!Validator.validateId(null));
        system.assert(!Validator.validateId(null, null));
        system.assert(!Validator.validateEmail(null));
    }

    /*
     * Tests the ValidateId overload that validates IDs and their key prefixes
     */
    public static testMethod void Test_ValidateIdWithPrefix() {
        string validId = string.valueOf([SELECT Id FROM Lead LIMIT 1].Id);
        string invalidId = 'Hippopotamus'; // You're a pleb if you need to use google to know if I spelld this correctly.
        system.assert(Validator.validateId(validId, lead.class));
        system.assert(!Validator.validateId(invalidId, lead.class));
    }

    /**
     * Tests the validators ability to validate EMPL Ids
     */
    public static testMethod void Test_ValidateEMPLId() {
        List<String> ids = new List<String>();

        ids.add('1203310168');
        ids.add('120331016');
        ids.add('120331016a');
        ids.add('asdfsdf1203310168adsfsdf');

        system.assert(Validator.validateEMPLId(ids[0]));
        system.assert(!Validator.validateEMPLId(ids[1]));
        system.assert(!Validator.validateEMPLId(ids[2]));
        system.assert(!Validator.validateEMPLId(ids[3]));
    }
}
