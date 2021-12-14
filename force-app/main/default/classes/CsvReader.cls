public class CsvReader {
    public static final String COMMA = String.fromCharArray(new List<Integer>{ 44 });
    public static final String CARRIAGE_RETURN = '\r';
    public static final String DQUOTE = '\"';
    public static final String LINE_FEED = '\n';
    public static final String CARRIAGE_RETURN_LINE_FEED = CARRIAGE_RETURN + LINE_FEED;
    public static final String LINE_FEED_CARRIAGE_RETURN = LINE_FEED + CARRIAGE_RETURN;
    public static final String DOUBLE_DQUOTE = DQUOTE + DQUOTE;

    public static List<List<String>> readCsvFile(Blob file) {
        return readCsvFile(file.toString());
    }

    public static List<List<String>> readCsvFile(String fileString) {
        if (!fileString.endsWith(CARRIAGE_RETURN)) {
            fileString = fileString + CARRIAGE_RETURN;
        }

        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CsvValue csvValue = new CsvValue();

        Boolean endOfData = false;
        while (!endOfData) {
            csvValue = readValue(fileString);

            rowValues.add(csvValue.value);

            if (csvValue.delimiter == CARRIAGE_RETURN) {
                if (rowValues.size() > 1 || (rowValues.size() == 1 && !String.isBlank(rowValues[0]))) {
                    fileValues.add(rowValues);

                    if (fileValues.size() > 0) {
                        System.assertEquals(fileValues.get(0).size(), rowValues.size());
                    }
                }
                rowValues = new List<String>();
            }

            if (csvValue.biteSize() == fileString.length()) {
                endOfData = true;
            } else {
                fileString = fileString.substring(csvValue.biteSize());
            }
        }
        return fileValues;
    }

    public static CsvValue readValue(String data) {
        System.assert(data.endsWith(CARRIAGE_RETURN));

        CsvValue csvValue = new CsvValue();

        if (data.startsWith(DQUOTE)) {
            csvValue.enclosed = true;

            Integer startingSearchIndex = 1;
            Integer dquoteIndex = -1;
            Integer doubleDquoteIndex = -1;

            Boolean closerFound = false;

            while (!closerFound) {
                dquoteIndex = data.indexOf(DQUOTE, startingSearchIndex);

                doubleDquoteIndex = data.indexOf(DOUBLE_DQUOTE, startingSearchIndex);

                System.assert(dquoteIndex != -1);

                if (dquoteIndex == doubleDquoteIndex) {
                    startingSearchIndex = doubleDquoteIndex + DOUBLE_DQUOTE.length();
                } else {
                    closerFound = true;
                }
            }

            csvValue.value = data.substring(DQUOTE.length(), dquoteIndex).replaceAll(DOUBLE_DQUOTE, DQUOTE);

            Integer commaIndex = data.indexOf(COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(CARRIAGE_RETURN, dquoteIndex);

            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = COMMA;
            } else {
                csvValue.delimiter = CARRIAGE_RETURN;
            }
        } else {
            csvValue.enclosed = false;

            Integer commaIndex = data.indexOf(COMMA);
            Integer crlfIndex = data.indexOf(CARRIAGE_RETURN);

            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = COMMA;
            } else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = CARRIAGE_RETURN;
            }
        }

        return csvValue;
    }

    @TestVisible
    private class CsvValue {
        public String value;
        public Boolean enclosed;
        public String delimiter;

        public CsvValue() {
            this(null, null, null);
        }

        public CsvValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }

        public Integer biteSize() {
            Integer biteSize = value.replaceAll(DQUOTE, DOUBLE_DQUOTE).length() + delimiter.length();

            if (enclosed) {
                biteSize += DQUOTE.length() * 2;
            }

            return biteSize;
        }

        public Boolean equals(CsvValue compCsvValue) {
            return this.value.equals(compCsvValue.value) &&
                this.enclosed == compCsvValue.enclosed &&
                this.delimiter == compCsvValue.delimiter;
        }

        public void assertEquals(CsvValue compCsvValue) {
            System.assertEquals(value, compCsvValue.value);
            System.assertEquals(enclosed, compCsvValue.enclosed);
            System.assertEquals(delimiter, compCsvValue.delimiter);
        }
    }
}
