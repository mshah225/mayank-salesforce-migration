@isTest
public class StringAddressHelperTest {
    @TestSetup
    private static void setup() {
        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Address Formatter',
            Email = 'test.address.formatter@test.test'
        );
        insert c;
    }

    @isTest
    private static void testStandardAddress() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        c.MailingStreet = '1234 Newbury Blvd';
        c.MailingCity = 'Avon Birch';
        c.MailingState = 'Michigan';
        c.MailingPostalCode = '88401';
        c.MailingCountry = 'United States';
        update c;

        c = [SELECT MailingAddress FROM Contact WHERE Id = :c.Id];

        Assert.areEqual(
            '1234 Newbury Blvd Avon Birch, Michigan (MI) 88401 United States (US) {, }',
            new StringAddressHelper(
                    '%STREET% %CITY%, %STATE% (%STATECODE%) %POSTAL% %COUNTRY% (%COUNTRYCODE%) {%LATITUDE%, %LONGITUDE%}'
                )
                .format(c.MailingAddress)
        );
    }

    @isTest
    private static void testEmptyParenthesesAddress() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        c.MailingStreet = '1234 Newbury Blvd';
        c.MailingCity = 'Avon Birch';
        c.MailingState = 'Michigan';
        c.MailingCountry = 'United States';
        update c;

        c = [SELECT MailingAddress FROM Contact WHERE Id = :c.Id];

        Assert.areEqual(
            '1234 Newbury Blvd Avon Birch, Michigan',
            new StringAddressHelper('%STREET% %CITY%, %STATE% (%POSTAL%)', true).format(c.MailingAddress)
        );
    }

    @isTest
    private static void testMultipleEmptyParenthesesAddress() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        c.MailingStreet = '1234 Newbury Blvd';
        c.MailingCity = 'Avon Birch';
        c.MailingState = 'Michigan';
        c.MailingCountry = 'United States';
        update c;

        c = [SELECT MailingAddress FROM Contact WHERE Id = :c.Id];

        Assert.areEqual(
            '1234 Newbury Blvd Avon Birch, Michigan',
            new StringAddressHelper('%STREET% %CITY%, %STATE% ( (%POSTAL%), [%POSTAL%] )', true).format(c.MailingAddress)
        );
    }

    @isTest
    private static void testError() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        c.MailingStreet = '1234 Newbury Blvd';
        c.MailingCity = 'Avon Birch';
        c.MailingState = 'Michigan';
        c.MailingCountry = 'United States';
        update c;

        c = [SELECT MailingAddress FROM Contact WHERE Id = :c.Id];

        Exception thrownError;
        String addr;
        try {
            addr = new StringAddressHelper('Address is %UNKNOWN%', true).format(c.MailingAddress);
        } catch (Exception ex) {
            thrownError = ex;
        }

        Assert.isInstanceOfType(
            thrownError,
            StringAddressHelper.StringAddressHelperException.class,
            'Expected to throw an exception of type StringAddressHelper.StringAddressHelperException, but actually threw ' +
            thrownError?.getTypeName()
        );
        Assert.isTrue(
            thrownError?.getMessage()?.contains('Invalid contents in format string, issue at index 11'),
            'Expected error to contain "Invalid contents in format string, issue at index 11", but it said: "' +
                thrownError?.getMessage() +
                '"'
        );
    }
}
