@isTest
public with sharing class CsvReaderTest {
    @isTest
    private static void testSuccessfulReadCSV() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = new List<List<String>>();
        for (Integer i = 0; i < 40; i++) {
            fileContentsLines.add(new List<String>());
        }
        Integer wordsPerLine = 30;
        for (Integer i = 0; i < fileContentsLines.size(); i++) {
            for (Integer j = 0; j < wordsPerLine; j++) {
                fileContentsLines.get(i).add(randomWord(5));
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
        System.assertEquals(fileContentsLines.size(), result.size());
        for (Integer i = 0; i < fileContentsLines.size(); i++) {
            System.assertEquals(fileContentsLines.get(i).size(), result.get(i).size());
            for (Integer j = 0; j < fileContentsLines.get(i).size(); j++) {
                System.assertEquals(fileContentsLines.get(i).get(j), result.get(i).get(j));
            }
        }
    }

    @isTest
    private static void testHandlingDQuotes() {
        // Construct 2d array to build file from
        List<List<String>> fileContentsLines = new List<List<String>>();
        for (Integer i = 0; i < 10; i++) {
            fileContentsLines.add(new List<String>());
        }
        Integer wordsPerLine = 5;
        for (Integer i = 0; i < fileContentsLines.size(); i++) {
            for (Integer j = 0; j < Math.mod(i, wordsPerLine); j++) {
                fileContentsLines.get(i).add(randomWord(5));
            }
            fileContentsLines.get(i).add('",' + randomWord(4) + '"'); // comma in dquote
            for (Integer j = 0; j < wordsPerLine - (Math.mod(i, wordsPerLine) + 1); j++) {
                fileContentsLines.get(i).add(randomWord(5));
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
        System.assertEquals(fileContentsLines.size(), result.size());
        for (Integer i = 0; i < fileContentsLines.size(); i++) {
            System.assertEquals(fileContentsLines.get(i).size(), result.get(i).size());
            for (Integer j = 0; j < fileContentsLines.get(i).size(); j++) {
                System.assertEquals(fileContentsLines.get(i).get(j).replace('"', ''), result.get(i).get(j));
            }
        }
    }

    @isTest
    private static void testCsvValues() {
        String value = randomWord(7);
        String delim = ',';
        Boolean enclosed = false;

        CsvReader.CsvValue csvVal = new CsvReader.CsvValue(value, enclosed, delim);
        CsvReader.CsvValue csvVal2 = new CsvReader.CsvValue(value, enclosed, delim);

        System.assert(csvVal.equals(csvVal2), 'Assert two CSVValues are equal');
        csvVal.assertEquals(csvVal2);
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
