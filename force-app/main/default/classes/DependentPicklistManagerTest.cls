@isTest
public class DependentPicklistManagerTest {
    /* It is unknown how Salesforce has decided on the state subdivisions under the United States
     * It MOSTLY follows [ISO-3166-2](https://en.wikipedia.org/wiki/ISO_3166-2), but also includes
     * 3 codes for the US Armed Forces depending on where they are stationed (AA, AE, AP) and inexplicably
     * includes the Marshall Islands (MH)
     *
     * This will need to be updated if Salesforce ever changes this list (which seems possible given it
     * does not adhere to any published standard)
     */
    private static Map<String, String> stateCodeToStateMp = new Map<String, String>{
        'AL' => 'Alabama',
        'AK' => 'Alaska',
        'AS' => 'American Samoa',
        'AZ' => 'Arizona',
        'AR' => 'Arkansas',
        'AA' => 'Armed Forces Americas',
        'AE' => 'Armed Forces Europe',
        'AP' => 'Armed Forces Pacific',
        'CA' => 'California',
        'CO' => 'Colorado',
        'CT' => 'Connecticut',
        'DE' => 'Delaware',
        'DC' => 'District of Columbia',
        'FL' => 'Florida',
        'GA' => 'Georgia',
        'GU' => 'Guam',
        'HI' => 'Hawaii',
        'ID' => 'Idaho',
        'IL' => 'Illinois',
        'IN' => 'Indiana',
        'IA' => 'Iowa',
        'KS' => 'Kansas',
        'KY' => 'Kentucky',
        'LA' => 'Louisiana',
        'ME' => 'Maine',
        'MH' => 'Marshall Islands',
        'MD' => 'Maryland',
        'MA' => 'Massachusetts',
        'MI' => 'Michigan',
        'MN' => 'Minnesota',
        'MS' => 'Mississippi',
        'MO' => 'Missouri',
        'MT' => 'Montana',
        'NE' => 'Nebraska',
        'NV' => 'Nevada',
        'NH' => 'New Hampshire',
        'NJ' => 'New Jersey',
        'NM' => 'New Mexico',
        'NY' => 'New York',
        'NC' => 'North Carolina',
        'ND' => 'North Dakota',
        'MP' => 'Northern Mariana Islands',
        'OH' => 'Ohio',
        'OK' => 'Oklahoma',
        'OR' => 'Oregon',
        'PA' => 'Pennsylvania',
        'PR' => 'Puerto Rico',
        'RI' => 'Rhode Island',
        'SC' => 'South Carolina',
        'SD' => 'South Dakota',
        'TN' => 'Tennessee',
        'TX' => 'Texas',
        'UM' => 'United States Minor Outlying Islands',
        'VI' => 'US Virgin Islands',
        'UT' => 'Utah',
        'VT' => 'Vermont',
        'VA' => 'Virginia',
        'WA' => 'Washington',
        'WV' => 'West Virginia',
        'WI' => 'Wisconsin',
        'WY' => 'Wyoming'
    };

    @isTest
    private static void testGetValidDependentPicklistOptions() {
        DependentPicklistManager dependPicklistManager = new DependentPicklistManager(Account.BillingStateCode);

        List<Schema.PicklistEntry> options = dependPicklistManager.getOptions('US');

        Map<String, Schema.PicklistEntry> valueToOptMp = new Map<String, Schema.PicklistEntry>();
        for (Schema.PicklistEntry opt : options)
            valueToOptMp.put(opt.getValue(), opt);

        Set<String> stateCodes = stateCodeToStateMp.keySet();

        Assert.areEqual(stateCodes.size(), options.size());
        for (String stateCode : stateCodes) {
            Assert.isTrue(valueToOptMp.containsKey(stateCode));

            Schema.PicklistEntry pe = valueToOptMp.get(stateCode);

            Assert.areEqual(stateCode, pe.getValue());
            Assert.areEqual(stateCodeToStateMp.get(stateCode), pe.getLabel());
        }
    }

    @isTest
    private static void testCheckValidity() {
        DependentPicklistManager dependPicklistManager = new DependentPicklistManager(Account.BillingStateCode);

        Boolean isValid1 = dependPicklistManager.isValid('US', 'AZ');
        Boolean isValid2 = dependPicklistManager.isValid('CA', 'AZ');

        Assert.isTrue(isValid1, 'Expected AZ to be a valid option when controlling value is "US", but it was not');
        Assert.isFalse(isValid2, 'Expected AZ to NOT be a valid option when controlling value is "CA", but it WAS');
    }

    @isTest
    private static void testWrongControllingType1() {
        DependentPicklistManager dependPicklistManager = new DependentPicklistManager(Account.BillingStateCode);

        Exception thrownException = null;

        // Try and fail
        try {
            dependPicklistManager.getOptions(true);
        } catch (Exception ex) {
            thrownException = ex;
        }

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            IllegalArgumentException.class,
            'Expected to throw an exception of type IllegalArgumentException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.areEqual(
            'Tried to get dependent picklist options for Account.BillingStateCode using a controlling value="true", but this type is invalid for the controlling field',
            thrownException?.getMessage()
        );
    }

    @isTest
    private static void testWrongControllingType2() {
        DependentPicklistManager dependPicklistManager = new DependentPicklistManager(Account.BillingStateCode);

        Exception thrownException = null;

        // Try and fail
        try {
            dependPicklistManager.isValid(true, 'AZ');
        } catch (Exception ex) {
            thrownException = ex;
        }

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            IllegalArgumentException.class,
            'Expected to throw an exception of type IllegalArgumentException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.areEqual(
            'Tried to get check if "AZ" was a valid option for Account.BillingStateCode using a controlling value="true", but this type is invalid for the controlling field',
            thrownException?.getMessage()
        );
    }

    @isTest
    private static void testNotDependentPicklist() {
        Exception thrownException = null;

        // Try and fail
        try {
            DependentPicklistManager dependPicklistManager = new DependentPicklistManager(Account.Name);
        } catch (Exception ex) {
            thrownException = ex;
        }

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            IllegalArgumentException.class,
            'Expected to throw an exception of type IllegalArgumentException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.areEqual('Account.Name is not a dependent picklist', thrownException?.getMessage());
    }

    @isTest
    private static void testEmptyValues() {
        DependentPicklistManager dependPicklistManager = new DependentPicklistManager(Account.BillingStateCode);

        Boolean isValid1 = dependPicklistManager.isValid('US', '');
        Boolean isValid2 = dependPicklistManager.isValid('US', null);
        Boolean isValid3 = dependPicklistManager.isValid('', 'AZ');
        Boolean isValid4 = dependPicklistManager.isValid(null, 'AZ');

        Assert.isTrue(isValid1, 'Expected "" to be a valid option when controlling value is "US", but it was not');
        Assert.isTrue(isValid2, 'Expected NULL to be a valid option when controlling value is "US", but it was not');
        Assert.isFalse(isValid3, 'Expected AZ to NOT be a valid option when controlling value is "", but it WAS');
        Assert.isFalse(isValid4, 'Expected AZ to NOT be a valid option when controlling value is null, but it WAS');
    }
}