/**
 * This is a helper formatter designed to either take a format string, and then format many address using that format
 * or to take in an address object and format it in a variety of ways
 *
 * The format string should be a string. It should contain primary puncutation marks and codes to indicate where each
 * component of the address should be placed
 *
 * The follow strings will be replace using values from the address obejct
 *
 *      %%                  A literal percent sign
 *      %STREET%            The street of the address
 *      %CITY%              The city of the address
 *      %STATE%             The state of the address
 *      %POSTAL%            The postal code of the address
 *      %COUNTRY%           The country of the address
 *      %STATECODE%         The statecode of the address
 *      %COUNTRYCODE%       The countrycode of the address
 *      %LATITUDE%          The latitude of the address
 *      %LONGITUDE%         The longitude of the address
 *
 * Uses the StringSanitizeHelper with whitespaceList = [' '],
 *                             punctuationList = [',', '.', '-']
 *                             puncutationPairs = {
 *                                  '(' => ')'
 *                                  '[' => ']'
 *                                  '{' => '}'
 *                                  '<' => '>'
 *                             }
 */
public class StringAddressHelper {
    // This is set when in format mode, and we will then allow the user to format multiple address in this format
    String format;

    // When constructing an address, attempt to remove unnecessary syntax symbols.
    // so if there is nothing inside parenthese, don't include them, if there is nothing before a comma, don't include it, etc.
    Boolean cleanup;

    public StringAddressHelper(String format) {
        init(format, null);
    }

    public StringAddressHelper(String format, Boolean cleanup) {
        init(format, cleanup);
    }

    private void init(String format, Boolean cleanup) {
        if (format == null)
            throw new IllegalArgumentException('Format cannot be null');

        this.format = format;
        this.cleanup = cleanup != null ? cleanup : false;

        validateFormat();
    }

    /**
     * Primary worker function

     * @param addr The address you want formatted into a string
     * @return That address formatted according to the format string
     *         or empty string if addr is null
     */
    public String format(System.Address addr) {
        if (addr == null)
            return '';

        String addrStr = '';

        // Build the address string based on the format
        for (Integer i = 0; i < format.length();) {
            String remainingStr = format.substring(i);

            if (remainingStr.startsWith('%%')) {
                addrStr += '%'; // replace with normal %
                i += 2; // move to after
            } else if (remainingStr.startsWith('%STREET%')) {
                addrStr += (addr.Street != null ? addr.Street : ''); // replace with street
                i += 8; // move to after
            } else if (remainingStr.startsWith('%CITY%')) {
                addrStr += (addr.City != null ? addr.City : ''); // replace with city
                i += 6; // move to after
            } else if (remainingStr.startsWith('%STATE%')) {
                addrStr += (addr.State != null ? addr.State : ''); // replace with state
                i += 7; // move to after
            } else if (remainingStr.startsWith('%POSTAL%')) {
                addrStr += (addr.PostalCode != null ? addr.PostalCode : ''); // replace with postal code
                i += 8; // move to after
            } else if (remainingStr.startsWith('%COUNTRY%')) {
                addrStr += (addr.Country != null ? addr.Country : ''); // replace with country
                i += 9; // move to after
            } else if (remainingStr.startsWith('%STATECODE%')) {
                addrStr += (addr.StateCode != null ? addr.StateCode : ''); // replace with statecode
                i += 11; // move to after
            } else if (remainingStr.startsWith('%COUNTRYCODE%')) {
                addrStr += (addr.CountryCode != null ? addr.CountryCode : ''); // replace with countrycode
                i += 13; // move to after
            } else if (remainingStr.startsWith('%LATITUDE%')) {
                addrStr += (addr.Latitude != null ? addr.Latitude.toString() : ''); // replace with latitude
                i += 10; // move to after
            } else if (remainingStr.startsWith('%LONGITUDE%')) {
                addrStr += (addr.Longitude != null ? addr.Longitude.toString() : ''); // replace with longitude
                i += 11; // move to after
            } else {
                addrStr += format.substring(i, i + 1); // Add character
                i += 1; // move to next
            }
        }

        // If cleanup is enabled, we want to strip empty sections of the formatted string
        if (cleanup) {
            StringSanitizeHelper StringSanitizeHelper = new StringSanitizeHelper();

            StringSanitizeHelper.setInnerPuncutationList(new List<String>{ ',', '.', '-' });
            StringSanitizeHelper.setPuncutationPairs(
                new Map<String, String>{ '(' => ')', '{' => '}', '[' => ']', '<' => '>' }
            );
            StringSanitizeHelper.setWhitespaceList(new List<String>{ ' ' });

            addrStr = StringSanitizeHelper.cleanup(addrStr);
        }

        return addrStr;
    }

    /**
     * Validates that the input string only contains valid characters
     */
    private void validateFormat() {
        for (Integer i = 0; i < format.length();) {
            String remainingStr = format.substring(i);

            if (remainingStr.startsWith('%%')) {
                i += 2; // move to after
            } else if (remainingStr.startsWith('%STREET%')) {
                i += 8; // move to after
            } else if (remainingStr.startsWith('%CITY%')) {
                i += 6; // move to after
            } else if (remainingStr.startsWith('%STATE%')) {
                i += 7; // move to after
            } else if (remainingStr.startsWith('%POSTAL%')) {
                i += 8; // move to after
            } else if (remainingStr.startsWith('%COUNTRY%')) {
                i += 9; // move to after
            } else if (remainingStr.startsWith('%STATECODE%')) {
                i += 11; // move to after
            } else if (remainingStr.startsWith('%COUNTRYCODE%')) {
                i += 13; // move to after
            } else if (remainingStr.startsWith('%LATITUDE%')) {
                i += 10; // move to after
            } else if (remainingStr.startsWith('%LONGITUDE%')) {
                i += 11; // move to after
            } else if (remainingStr.startsWith('%')) {
                throw new StringAddressHelperException(
                    'Invalid contents in format string, issue at index ' +
                        i +
                        ', could not parse "' +
                        remainingStr.substring(0, remainingStr.length() > 10 ? 10 : remainingStr.length()) +
                        '..."'
                );
            } else {
                i += 1; // move to next
            }
        }
    }

    public class StringAddressHelperException extends Exception {
    }
}
