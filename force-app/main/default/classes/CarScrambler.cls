public class CarScrambler implements ObjectScramble {
    Case_Assignment_Rule__c carToScramble;

    public CarScrambler(Case_Assignment_Rule__c carToScramble) {
        this.carToScramble = carToScramble;
    }

    public sObject scrambleFields() {
        scrambleEmails();

        return carToScramble;
    }

    public String toCsvString() {
        String formattedString = carToScramble.Id;
        formattedString += ',';
        if (!String.isEmpty(carToScramble.Email_Address__c)) {
            formattedString += carToScramble.Email_Address__c;
        }
        formattedString += ',';
        if (!String.isEmpty(carToScramble.Reply_To_Email_Address__c)) {
            formattedString += carToScramble.Reply_To_Email_Address__c;
        }
        formattedString += '\n';

        return formattedString;
    }

    private void scrambleEmails() {
        carToScramble.Email_Address__c = Scrambler.carefullyScrambleEmailOrUsername(carToScramble.Email_Address__c);
        carToScramble.Reply_To_Email_Address__c = Scrambler.carefullyScrambleEmailOrUsername(
            carToScramble.Reply_To_Email_Address__c
        );
    }
}
