/**
 * There are two ways of interacting with the CsvReader class
 * either using the public static functions (readCsvFile) or by creating an instances of the class
 * and calling getLines.  Generally you should do the second, as it is more verstile, however, the
 * static functions remain for backwards compatibility.
 */

public class CsvReader {
    public static final String COMMA = String.fromCharArray(new List<Integer>{ 44 });
    public static final String CARRIAGE_RETURN = '\r';
    public static final String DQUOTE = '"';
    public static final String LINE_FEED = '\n';
    public static final String CARRIAGE_RETURN_LINE_FEED = CARRIAGE_RETURN + LINE_FEED;
    public static final String LINE_FEED_CARRIAGE_RETURN = LINE_FEED + CARRIAGE_RETURN;
    public static final String DOUBLE_DQUOTE = DQUOTE + DQUOTE;

    public static List<List<String>> readCsvFile(Blob file) {
        return readCsvFile(file.toString());
    }

    public static List<List<String>> readCsvFile(String fileString) {
        CsvReader csvReader = new CsvReader(fileString, COMMA, CARRIAGE_RETURN);
        return csvReader.getLines();
    }

    private String fileString;
    private String delim;
    private String newlineDelim;
    Integer pos = 0;
    Integer columnCount = -1;

    /**
     * CSVReader is a class designed to help parse CSV files. It consumes a string of CSV data and outputs a 2D array representing the cells
     * of the CSV file. Malformed CSV files can cause Exceptions to be thrown or can silently fail - which errors are checked and thrown are
     * listed in the docs for getLines
     *
     * After creating the CSVReader, you will want to call getLines to get a 2D array, representing the cells of the CSV file.
     *
     * Assumptions and Accomodations:
     *   1. CSV files MAY enclose any cell value in dquotes (").
     *   4. Cell values MAY include embedded newlines.
     *   2. CSV files MUST enclose any cell values that include embedded dquotes, commas, or linefeeds/carriage returns.
     *   3. Enclosed dquotes ARE represented using a double dquote ("").
     *   5. The developer MUST know the cell delimiter in use (usually a comma (,)).
     *      Although you can define this with a regex, being overly broad will likely
     *      cause data loss. E.g. if you specify semicolon and comma as a delim when the
     *      CSV is only using comma as the delim, any semicolons in the CSV won't be properly
     *      enclosed and claiming it is a delimiter will cause issues.
     *   6. The developer SHOULD know the row delimiter in use (usually \n or \n\r).
     *      However, since this varies by system, and lifefeed/carriage return are rarely seen
     *      outside of being control characters, you can usually safely use "\r\n|\n\r|\r|\n"
     *      in order to handle the most common line ends.
     *   7. When using Regex to define the delimiters order matters, "\r\n|\r" is different
     *      from "\r|\r\n" for this parser - using the second will cause a newline to sneak
     *      into a cell value rather than just acting as a control character.
     *
     * @param fileString    The contents of the CSV file as a single giant string
     * @param delim         The value delimiter, usually a comma
     * @param newlineDelim  The newline delimiter, depends on system producing the CSV file
     */
    public CsvReader(String fileString, String delim, String newlineDelim) {
        init(fileString, delim, newlineDelim);
    }
    public CsvReader(Blob file, String delim, String newlineDelim) {
        init(file.toString(), delim, newlineDelim);
    }

    private void init(String fileString, String delim, String newlineDelim) {
        this.fileString = fileString;
        this.delim = delim;
        this.newlineDelim = newlineDelim;
    }

    /**
     * Main interface with this class
     * Call this to convert the fileString specified in the constructor into a 2D array of cells
     *
     * @throws InconsistentColumnCountException If rows have differing numbers of columns
     * @throws UnpairedDQuoteException If enclosed cell values have no closing dquote
     * @throws MissingDelimiterException If missing delimiters after each cell value
     */
    public List<List<String>> getLines() {
        List<List<String>> allCellsOfCsv = new List<List<String>>();
        List<String> csvRow = new List<String>();

        while (hasNextValue()) {
            CsvValue csvValue = nextValue();

            // Add cell value to current row
            csvRow.add(csvValue.value);

            // If this CsvValue is delimitated by a newline, then insert row and move onto next row
            if (csvValue.endOfRow) {
                allCellsOfCsv.add(csvRow);

                if (columnCount == -1) {
                    // record number of columns in first row
                    columnCount = csvRow.size();
                } else {
                    // and compare all subsequent rows
                    if (csvRow.size() != columnCount) {
                        throw new InconsistentColumnCountException(
                            'Malformed CSV File: Expects each row to have ' +
                                columnCount +
                                ' columns, but row ' +
                                (allCellsOfCsv.size() + 1) +
                                ' has ' +
                                csvRow.size() +
                                ' columns.'
                        );
                    }
                }

                csvRow = new List<String>();
            }
        }

        return allCellsOfCsv;
    }

    /**
     * Are we at the end of the file or are there more value to read?
     */
    private Boolean hasNextValue() {
        return pos < fileString.length();
    }

    /**
     * Get the next value from the CSV file, in the form of a CsvValue object
     * Or returns null if there are no more values (if at end of file)
     *
     * You can check the delimiter of the returned CsvValue to determine
     * if this value was at the end of a line or not.
     *
     * @return A CsvValue representing the next cell in the CSV file
     *
     * @throws UnpairedDQuoteException If enclosed cell values have no closing dquote
     */
    private CsvValue nextValue() {
        CsvValue csvValue = new CsvValue();

        if (!hasNextValue()) {
            return null;
        }

        if (fileString.charAt(pos) == DQUOTE.charAt(0)) {
            csvValue.enclosed = true;

            Integer startingSearchIndex = pos + DQUOTE.length();
            Integer dquoteIndex = -1;
            Integer doubleDquoteIndex = -1;
            Boolean closerFound = false;

            // Look for closing quote
            while (!closerFound) {
                dquoteIndex = fileString.indexOf(DQUOTE, startingSearchIndex);
                doubleDquoteIndex = fileString.indexOf(DOUBLE_DQUOTE, startingSearchIndex); // CSV's use "" to escape quotes in enclosed values

                if (dquoteIndex == -1) {
                    Integer fileLength = fileString.length();
                    String escapedNextFewChars = fileString.substring(
                        pos,
                        pos + 50 < fileLength ? pos + 50 : fileLength
                    );
                    escapedNextFewChars = escapeSpecialCharacters(escapedNextFewChars);

                    throw new UnpairedDQuoteException(
                        'Malformed CSV File: Enclosed CSV value does not have a matching closing double quote ("). Starting dquote at position ' +
                            pos +
                            '. Next few characters `' +
                            escapedNextFewChars +
                            '`'
                    );
                }

                if (dquoteIndex == doubleDquoteIndex) {
                    // If match, then this is an escaped dquote, not the closer
                    startingSearchIndex = doubleDquoteIndex + DOUBLE_DQUOTE.length();
                } else {
                    closerFound = true;
                }
            }

            // Record value
            csvValue.value = fileString.substring(pos + DQUOTE.length(), dquoteIndex).replaceAll(DOUBLE_DQUOTE, DQUOTE);

            // Update position to after most recently read CsvValue
            pos = dquoteIndex + DQUOTE.length();
        } else {
            csvValue.enclosed = false;

            Integer lengthOfToken = 0;
            Boolean nextDelimFound = false;

            // Look for next delim to determine value length
            while (!nextDelimFound) {
                // stop because of comma
                if (charIsComma(pos + lengthOfToken))
                    break;
                // stop because of newline
                if (charIsNewline(pos + lengthOfToken))
                    break;
                // stop because of end of file
                if (pos + lengthOfToken == fileString.length())
                    break;
                // increment length
                lengthOfToken += 1;
            }

            // Record value
            csvValue.value = fileString.substring(pos, pos + lengthOfToken);

            // Update position to after most recently read CsvValue
            pos = pos + lengthOfToken;
        }

        // What delim is after it?
        String nextDelim = nextDelimiter();

        // Record the delimiter
        csvValue.delimiter = nextDelim;
        csvValue.endOfRow = nextDelim == null || charIsNewline(pos);

        // Move on past delimiter
        pos = pos + (nextDelim == null ? 0 : nextDelim.length());

        return csvValue;
    }

    /**
     * What is the next delim in the file string?
     * This assumes, that the next character (the char at pos) is that delim
     *
     * @return String of the next delim in the file (at pos), or NULL if at the end of the file
     *
     * @throws MissingDelimiterException If the next character is not a valid delim
     */
    private String nextDelimiter() {
        Pattern commaPattern = Pattern.compile('(' + delim + ')[\\W|\\w]*');
        Matcher commaMatcher = commaPattern.matcher(fileString.substring(pos));

        Pattern newlinePattern = Pattern.compile('(' + newlineDelim + ')[\\W|\\w]*');
        Matcher newlineMatcher = newlinePattern.matcher(fileString.substring(pos));

        if (commaMatcher.matches()) {
            return commaMatcher.group(1);
        } else if (newlineMatcher.matches()) {
            return newlineMatcher.group(1);
        } else if (pos == fileString.length()) {
            return null;
        } else {
            String escapedDelim = escapeSpecialCharacters(delim);
            String escapedNewlineDelim = escapeSpecialCharacters(newlineDelim);

            Integer fileLength = fileString.length();
            String escapedNextFewChars = fileString.substring(pos, pos + 50 < fileLength ? pos + 50 : fileLength);
            escapedNextFewChars = escapeSpecialCharacters(escapedNextFewChars);

            throw new MissingDelimiterException(
                'Malformed CSV File: Next character in CSV file was expected to be a delim, but it was not a delim. Newline delimiters are: [' +
                    escapedNewlineDelim +
                    '], cell delimiters are [' +
                    escapedDelim +
                    '], and the next few characters are `' +
                    escapedNextFewChars +
                    '`'
            );
        }
    }

    /**
     * Checks if the character at offset is a comma
     @return True if it is, false otherwise
     */
    private Boolean charIsComma(Integer offset) {
        Pattern commaPattern = Pattern.compile('(' + delim + ')[\\W|\\w]*');
        Matcher commaMatcher = commaPattern.matcher(fileString.substring(offset));
        return commaMatcher.matches();
    }
    /**
     * Checks if the character at offset is a newline
     @return True if it is, false otherwise
     */
    private Boolean charIsNewline(Integer offset) {
        Pattern newlinePattern = Pattern.compile('(' + newlineDelim + ')[\\W|\\w]*');
        Matcher newlineMatcher = newlinePattern.matcher(fileString.substring(offset));
        return newlineMatcher.matches();
    }

    private static String escapeSpecialCharacters(String s) {
        return s.replace('\\', '\\\\').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t');
    }

    @TestVisible
    private class CsvValue {
        public String value;
        public Boolean enclosed;
        public String delimiter;
        public Boolean endOfRow = false;

        public CsvValue() {
            this(null, null, null);
        }

        public CsvValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }

        public Boolean equals(CsvValue compCsvValue) {
            return this.value.equals(compCsvValue.value) &&
                this.enclosed == compCsvValue.enclosed &&
                this.delimiter == compCsvValue.delimiter &&
                this.endOfRow == compCsvValue.endOfRow;
        }

        public void assertEquals(CsvValue compCsvValue) {
            System.assertEquals(value, compCsvValue.value);
            System.assertEquals(enclosed, compCsvValue.enclosed);
            System.assertEquals(delimiter, compCsvValue.delimiter);
            System.assertEquals(endOfRow, compCsvValue.endOfRow);
        }
    }

    public class UnpairedDQuoteException extends Exception {
    }
    public class MissingDelimiterException extends Exception {
    }
    public class InconsistentColumnCountException extends Exception {
    }
}
