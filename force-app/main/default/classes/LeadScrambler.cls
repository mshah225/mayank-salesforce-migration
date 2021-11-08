public class LeadScrambler implements ObjectScramble {
    Lead leadToScramble;

    public LeadScrambler(Lead leadToScramble) {
        this.leadToScramble = leadToScramble;
    }

    public sObject scrambleFields() {
        scrambleEmails();
        scrambleBirthdate();
        removeSilverpopId();

        return leadToScramble;
    }

    public String toCsvString() {
        String formattedString = leadToScramble.Id;

        formattedString += ',';
        if (leadToScramble.Date_of_Birth__c != null) {
            formattedString += leadToScramble.Date_of_Birth__c;
        }

        formattedString += ',';
        if (leadToScramble.email != null) {
            formattedString += leadToScramble.email;
        }

        formattedString += ',';
        if (leadToScramble.email != null) {
            formattedString += leadToScramble.Recruiting_Email__c;
        }

        formattedString += ',';
        if (leadToScramble.email != null) {
            formattedString += leadToScramble.Secondary_Email__c;
        }

        formattedString += ',#N/A';

        formattedString += '\n';

        return formattedString;
    }

    private void scrambleEmails() {
        leadToScramble.email = Scrambler.carefullyScrambleEmailOrUsername(leadToScramble.email);
        leadToScramble.Recruiting_Email__c = Scrambler.carefullyScrambleEmailOrUsername(leadToScramble.Recruiting_Email__c);
        leadToScramble.Secondary_Email__c = Scrambler.carefullyScrambleEmailOrUsername(leadToScramble.Secondary_Email__c);
    }

    private void scrambleBirthdate() {
        leadToScramble.Date_of_Birth__c = Scrambler.scrambleDate(leadToScramble.Date_of_Birth__c);
    }

    private void removeSilverpopId() {
        leadToScramble.silverpop__Silverpop_RecipientID__c = null;
    }
}
