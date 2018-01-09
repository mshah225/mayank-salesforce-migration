/**
 * CSVReader contains static methods used for reading a CSV file and returning
 * the contained values in a nested List of Strings.
 *
 */
public class CsvReader {

	/**
     * Comma String as defined by IETF RFC 4180.
     */
    public static final String COMMA =
            String.fromCharArray(new List<Integer> { 44 });

    /**
     * Carriage return String as defined by Salesforce documentation.
     *
     * Force.com IDE Library >
     * Apex Developer's Guide >
     * Language Constructs >
     * Data Types >
     * Primitive Data Types
     */
    public static final String CR = '\r';

    /**
     * Double-quote String as defined by Salesforce documentation.
     *
     * Force.com IDE Library >
     * Apex Developer's Guide >
     * Language Constructs >
     * Data Types >
     * Primitive Data Types
     */
    public static final String DQUOTE = '\"';

    /**
     * Line feed String as defined by Salesforce documentation.
     *
     * Force.com IDE Library >
     * Apex Developer's Guide >
     * Language Constructs >
     * Data Types >
     * Primitive Data Types
     */
    public static final String LF = '\n';

    /**
     * Carriage return String followed by a line feed String.
     */
    public static final String CRLF = CR + LF;

    /**
     * Line feed String followed by a carriage return String.
     */
    public static final String LFCR = LF + CR;

    /**
     * Escaped double-quotes per IETF RFC 4180.
     */
    public static final String DQUOTEDQUOTE = DQUOTE + DQUOTE;

    /**
     * Returns a List containing Lists of Strings that represents
     * the values contained in an IETF RFC 4180-compliant CSV file.
     *
     * Each element in the outer list represents a row in the CSV file.
     * Each element in the inner list is the value in the field specified
     * by the row-column combination.
     *
     * @param  file the CSV file to read
     * @return      the List<List<String>> containing values read from the
     *              CSV file
     */
    public static List<List<String>> readCsvFile(Blob file) {
        String fileString = file.toString();

        if (!fileString.endsWith(CR)) {
            fileString = fileString + CR;
        }

        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CsvValue csvValue = new CsvValue();

        Boolean eod = false;  // Whether end of CSV data is reached
        while (!eod) {
            //System.debug(fileString);

            csvValue = readValue(fileString);

            rowValues.add(csvValue.value);

            if (csvValue.delimiter == CR) {
                fileValues.add(rowValues);

                System.debug(rowValues);

                if (fileValues.size() > 0) {
                    System.assertEquals(fileValues.get(0).size(), rowValues.size());
                }

                rowValues = new List<String>();
            }

            if (csvValue.biteSize() == fileString.length()) {
                eod = true;
            } else {
                fileString = fileString.substring(csvValue.biteSize());
            }
        }
        return fileValues;
    }

    /**
     * Returns the first String value read from a String representation of
     * data contained in an IETF RFC 4180-compliant CSV file.
     *
     * The data is assumed to be terminated with a CRLF.
     *
     * @param  data the textual CSV data in one long string
     * @return      the first CSV value read from <code>data</code>.
     *              null is returned if no value is discerned.
     */
    public static CsvValue readValue(String data) {
        System.assert(data.endsWith(CR));

        CsvValue csvValue = new CsvValue();

        if (data.startsWith(DQUOTE)) {
          csvValue.enclosed = true;

            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE

            Boolean closerFound = false;

            while (!closerFound) {
                dquoteIndex = data.indexOf(DQUOTE, searchIndex);

                dquotesIndex = data.indexOf(DQUOTEDQUOTE, searchIndex);

                System.assert(dquoteIndex != -1);

                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex + DQUOTEDQUOTE.length();
                } else {
                    closerFound = true;
                }
            }

            csvValue.value = data.substring(
                DQUOTE.length(), dquoteIndex)
                .replaceAll(DQUOTEDQUOTE, DQUOTE);

            Integer commaIndex = data.indexOf(COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(CR, dquoteIndex);

            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = COMMA;
            } else {
                csvValue.delimiter = CR;
            }
        } else {
            csvValue.enclosed = false;

            Integer commaIndex = data.indexOf(COMMA);
            Integer crlfIndex = data.indexOf(CR);

            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = COMMA;
            } else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = CR;
            }
        }

        System.debug('Returning: ' + csvValue);

        return csvValue;
    }

    /**
     * CSVValue is a class structure containing information about a CSV
     * value that was read from a CSV file, including such information as
     * whether the value was encapsulated in double-quotes.
     */
    private class CsvValue {
        /**
         * The field value that was read from the CSV file.
         */
        public String value;

        /**
         * Whether the value was surrounded by double-quotes.
         */
        public Boolean enclosed;

        /**
         * The comma or CRLF delimiter that identified the end of the CSV value.
         */
        public String delimiter;

        /**
         * Default constructor, setting all members to null.
         */
        public CsvValue() {
            this(null, null, null);
        }

        /**
         * Constructor.
         *
         * @param value     the field value
         * @param enclosed  whether the value was surrounded by double-quotes
         * @param delimiter the delimiter that identified the end
         *                  of the CSV value
         */
        public CsvValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }

        /**
         * Returns the number of characters to remove from the data
         * String which produced the CSVValue in order to reach the next
         * value in the data String.
         */
        public Integer biteSize() {
            Integer biteSize = value
                .replaceAll(DQUOTE, DQUOTEDQUOTE).length()
                + delimiter.length();

            if (enclosed) {
                biteSize += DQUOTE.length() * 2;
            }

            System.debug('biteSize: ' + biteSize);

            return biteSize;
        }

        /**
         * Returns whether a CSVValue has the same <code>value</code> and
         * <code>enclosed</code> as another CSVValue.
         */
        public Boolean equals(CsvValue compCsvValue) {
            return this.value.equals(compCsvValue.value)
                && this.enclosed == compCsvValue.enclosed
                && this.delimiter == compCsvValue.delimiter;
        }

        /**
         * Asserts that two <code>CSVValue</code> instances have the same
         * <code>value</code> and <code>enclosed</code>.
         */
        public void assertEquals(CsvValue compCsvValue) {
            System.assertEquals(value, compCsvValue.value);
            System.assertEquals(enclosed, compCsvValue.enclosed);
            System.assertEquals(delimiter, compCsvValue.delimiter);
        }
    }

    /**
     * Test some use cases for reading IETF RFC 4180-compliant CSV values.
     */
	 /*
    public static testMethod void readCSVValueTest() {
        String data = null;  // Placeholder for data to use in testing.

        System.debug(data = CRLF);
        new CSVValue('', false, CRLF)
                .assertEquals(readCSVValue(data));

        System.debug(data = '""' + CRLF);
        new CSVValue('', true, CRLF)
                .assertEquals(readCSVValue(data));

        System.debug(data = '"",asdf' + CRLF);
        new CSVValue('', true, COMMA)
                .assertEquals(readCSVValue(data));

        System.debug(data = ',asdf' + CRLF);
        new CSVValue('', false, COMMA)
                .assertEquals(readCSVValue(data));

        System.debug(data = '"' + CRLF + '",blah' + CRLF);
        new CSVValue(CRLF, true, COMMA)
                .assertEquals(readCSVValue(data));

        System.debug(data = '"""marty""","""chang"""' + CRLF);
        new CSVValue('"marty"', true, COMMA)
                .assertEquals(readCSVValue(data));

        System.debug(data = '"com""pli""cate' + CRLF + 'd"'
                + CRLF);
        new CSVValue('com"pli"cate' + CRLF + 'd', true, CRLF)
                .assertEquals(readCSVValue(data));

        System.debug(data = 'asdf' + CRLF);
        new CSVValue('asdf', false, CRLF)
                .assertEquals(readCSVValue(data));
    }
	*/

    /**
     * Tests one case of parsing a CSV file that contains the following data:
     *
     * abc,"def","g""h""i"
     * "j
     * kl","m
     * n""o""",
     */
	 /*
    public static testMethod void readCSVFile() {
      String data = 'abc,"def","g""h""i"' + CRLF + '"j' + CRLF
             + 'kl","m' + CRLF + 'n""o""",';

      List<List<String>> fileValues =
             readCSVFile(Blob.valueOf(data));
    }
	*/
}
