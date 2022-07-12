@isTest
public class CaseScramblerTest {
    @TestSetup
    private static void setup() {
        Case c = new Case(Subject = 'Test Subject', Description = 'Case Desc');
        insert c;
    }

    @isTest
    private static void testScrambleFields() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        CaseScrambler scrambler = new CaseScrambler(testCase);

        Case scrambledCase = (Case) scrambler.scrambleFields();

        System.assertEquals(testCase.Id, scrambledCase.Id);
    }

    @isTest
    private static void testToCsvString() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String expectedString = testCase.Id + ',true\n';

        CaseScrambler scrambler = new CaseScrambler(testCase);

        String csvString = scrambler.toCsvString();

        System.assertEquals(expectedString, csvString);
    }
}
