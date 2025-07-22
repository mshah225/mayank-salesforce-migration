@isTest
public with sharing class CsvReaderTest {
    @isTest
    private static void testSuccessfulReadCSV() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\r');

        // Read it
        List<List<String>> result = CsvReader.readCsvFile(Blob.valueOf(fileContents));

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testHandlingDQuotes() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(10, 5);

        // replace final item on first line with dquoted contents,
        // final 2 items on second line with dquoted contents,
        // final 3 items on third lines ...
        for (Integer i = 0; i < fileContentsLines.size(); i++) {
            for (Integer j = i; j >= 0; j--) {
                fileContentsLines.get(i).remove(0);
                fileContentsLines.get(i).add('",' + randomWord(4) + '"');
            }
        }

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\r');

        // Read it
        List<List<String>> result = CsvReader.readCsvFile(Blob.valueOf(fileContents));

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, new List<String>{ '"' });
    }

    @isTest
    private static void testEmbeddedCharacters() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = new List<List<String>>();
        for (Integer i = 0; i < 20; i++) {
            fileContentsLines.add(new List<String>());
            for (Integer j = 0; j < 50; j++) {
                String word = '"' + randomWord(5) + '",\n\n' + randomWord(5);
                fileContentsLines.get(fileContentsLines.size() - 1).add(word);
            }
        }

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            List<String> escapedLineValues = new List<String>();
            for (String cell : fileLine)
                escapedLineValues.add('"' + cell.replace('"', '""') + '"');
            intraLineJoins.add(String.join(escapedLineValues, ','));
        }
        String fileContents = String.join(intraLineJoins, '\n');

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ',', '\n').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testCsvValues() {
        String value = randomWord(7);
        String delim = ',';
        Boolean enclosed = false;

        CsvReader.CsvValue csvVal = new CsvReader.CsvValue(value, enclosed, delim);
        CsvReader.CsvValue csvVal2 = new CsvReader.CsvValue(value, enclosed, delim);

        Assert.isTrue(csvVal.equals(csvVal2), 'Assert two CSVValues are equal');
        csvVal.assertEquals(csvVal2);
    }

    @isTest
    private static void testWindowsStyle() {
        // Windows-style CSVs use \r\n to delim lines

        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\n\r');

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ',', '\n\r').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testPOSIXStyle() {
        // POSIX-style CSVs use \n to delim lines

        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\n');

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ',', '\n').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testOldMacsStyle() {
        // Old (pre OS X) Mac-style CSVs use \r to delim lines

        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\r');

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ',', '\r').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testInvalidStyle() {
        // No one should use \r\n, but let's still handle that malformed format

        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\r\n');

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ',', '\r\n').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testMixedStyle() {
        // No one should use \r\n, but let's still handle that malformed format

        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = '';
        Integer modulus = 0;

        // alternating line endings
        for (String row : intraLineJoins) {
            if (Math.mod(modulus++, 4) == 0) {
                fileContents += row + '\n';
            } else if (Math.mod(modulus++, 4) == 1) {
                fileContents += row + '\r';
            } else if (Math.mod(modulus++, 4) == 2) {
                fileContents += row + '\n\r';
            } else {
                fileContents += row + '\r\n';
            }
        }

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ',', '\r\n|\n\r|\r|\n').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testSemicolonDelim() {
        // POSIX-style CSVs use \n to delim lines

        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ';'));
        }
        String fileContents = String.join(intraLineJoins, '\n');

        // Read it
        List<List<String>> result = new CsvReader(Blob.valueOf(fileContents), ';', '\n').getLines();

        // Check read it correctly
        assertCsvListsEquals(fileContentsLines, result, null);
    }

    @isTest
    private static void testMissingDelimiters() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);
        fileContentsLines.get(20).set(10, '"stuff outside dquotes" problem');

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\n');

        // Try to read it
        CsvReader csvReader = new CsvReader(Blob.valueOf(fileContents), ',', '\n');

        Boolean threwProperException = false;
        try {
            List<List<String>> result = csvReader.getLines();
        } catch (CsvReader.MissingDelimiterException ex) {
            threwProperException = true;
        }

        Assert.isTrue(threwProperException, 'Should have thrown a MissingDelimiterException, but it did not');
    }

    @isTest
    private static void testUnpairedDQuote() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);

        // add an unpaired dquote in middle of file
        fileContentsLines.get(20).set(10, '"unpairedquote');

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            List<String> escapedLineValues = new List<String>();
            for (String cell : fileLine)
                escapedLineValues.add(cell);
            intraLineJoins.add(String.join(escapedLineValues, ','));
        }
        String fileContents = String.join(intraLineJoins, '\r');

        // Try to read it
        CsvReader csvReader = new CsvReader(Blob.valueOf(fileContents), ',', '\n');

        Boolean threwProperException = false;
        try {
            List<List<String>> result = csvReader.getLines();
        } catch (CsvReader.UnpairedDQuoteException ex) {
            threwProperException = true;
        }

        Assert.isTrue(threwProperException, 'Should have thrown a UnpairedDQuoteException, but it did not');
    }

    @isTest
    private static void testInvalidColumnCount() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = generateRandomFile(40, 30);
        List<List<String>> fileContentsLines2 = generateRandomFile(10, 10);
        fileContentsLines.addAll(fileContentsLines2);

        // Build file
        List<String> intraLineJoins = new List<String>();
        for (List<String> fileLine : fileContentsLines) {
            intraLineJoins.add(String.join(fileLine, ','));
        }
        String fileContents = String.join(intraLineJoins, '\n');

        // Try to read it
        CsvReader csvReader = new CsvReader(Blob.valueOf(fileContents), ',', '\n');

        Boolean threwProperException = false;
        try {
            List<List<String>> result = csvReader.getLines();
        } catch (CsvReader.InconsistentColumnCountException ex) {
            threwProperException = true;
        }

        Assert.isTrue(threwProperException, 'Should have thrown a InconsistentColumnCountException, but it did not');
    }

    private static void assertCsvListsEquals(
        List<List<String>> expected,
        List<List<String>> actual,
        List<String> ignoreChars
    ) {
        Integer expectedRowCount = expected.size();
        Integer actualRowCount = actual.size();

        Assert.areEqual(
            expectedRowCount,
            actualRowCount,
            'Expected ' + expectedRowCount + ' rows, but there are ' + actualRowCount + ' rows.'
        );

        for (Integer i = 0; i < expected.size(); i++) {
            Integer expectedColCount = expected.get(i).size();
            Integer actualColCount = actual.get(i).size();

            Assert.areEqual(
                expectedColCount,
                actualColCount,
                'Line ' +
                    i +
                    ' should have ' +
                    expectedColCount +
                    ' columns, but there are ' +
                    actualColCount +
                    ' columns'
            );

            for (Integer j = 0; j < expected.get(i).size(); j++) {
                String expectedWord = expected.get(i).get(j);
                String actualWord = actual.get(i).get(j);

                // If there are any characters to ignore when comparing (such as dquotes), then filter those out before comparing
                if (ignoreChars != null) {
                    for (Integer k = 0; k < ignoreChars.size(); k++) {
                        expectedWord = expectedWord.replace(ignoreChars.get(k), '');
                        actualWord = actualWord.replace(ignoreChars.get(k), '');
                    }
                }

                Assert.areEqual(
                    expectedWord,
                    actualWord,
                    'Expected row=' + +i + ' col=' + j + ' to be ' + expectedWord + ' but it was ' + actual
                );
            }
        }
    }

    private static List<List<String>> generateRandomFile(Integer rows, Integer columns) {
        List<List<String>> fileContentsLines = new List<List<String>>();
        for (Integer i = 0; i < rows; i++) {
            fileContentsLines.add(new List<String>());
        }

        for (Integer i = 0; i < fileContentsLines.size(); i++) {
            for (Integer j = 0; j < columns; j++) {
                fileContentsLines.get(i).add(randomWord(5));
            }
        }

        return fileContentsLines;
    }

    private static String randomWord(Integer length) {
        String s = '';
        for (Integer i = 0; i < length; i++) {
            s += randomLetter();
        }
        return s;
    }
    private static String randomLetter() {
        List<Integer> allChars = new List<Integer>();
        // All ASCII printable characters
        for (Integer i = 65; i <= 90; i++) {
            allChars.add(i);
        }
        for (Integer i = 97; i <= 122; i++) {
            allChars.add(i);
        }
        return String.fromCharArray(new List<Integer>{ allChars[(Integer) (Math.random() * allChars.size())] });
    }
}
