public class LeadDeleter implements ObjectScramble {
    Lead leadToDelete;

    public LeadDeleter(Lead leadToDelete) {
        this.leadToDelete = leadToDelete;
    }

    public sObject scrambleFields() {
        return leadToDelete;
    }

    public String toCsvString() {
        String formattedString = leadToDelete.Id;

        formattedString += '\n';

        return formattedString;
    }
}
