public class CaseScrambler implements ObjectScramble {
    Case caseToScramble;

    public CaseScrambler(Case caseToScramble) {
        this.caseToScramble = caseToScramble;
    }

    public sObject scrambleFields() {
        return caseToScramble;
    }

    public String toCsvString() {
        String formattedString = caseToScramble.Id;

        formattedString += ',true';

        formattedString += '\n';

        return formattedString;
    }
}
