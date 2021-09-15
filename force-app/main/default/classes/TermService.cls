/**
 * Created by aesanch2 on 9/28/15.
 */

public class TermService {
    public static Term__c createTestTerm() {
        Date today = Date.today();
        Integer year = today.year();

        Term__c testTerm = new Term__c();
        testTerm.Name = 'TestTerm';
        testTerm.Semester__c = 'Fall';
        testTerm.Year__c = String.valueOf(year);
        testTerm.Session_A_C_Start_Date__c = today;
        testterm.Session_B_Start_Date__c = today;

        return testTerm;
    }
}
