public class ContactScrambler implements ObjectScramble {
    Contact contactToScramble;

    public ContactScrambler(Contact contactToScramble) {
        this.contactToScramble = contactToScramble;
    }

    public sObject scrambleFields() {
        scrambleEmails();
        scrambleDates();
        removeSilverpopId();

        return contactToScramble;
    }

    public String toCsvString() {
        String formattedString = contactToScramble.Id;
        formattedString += ',';
        if (contactToScramble.Birthdate != null) {
            formattedString += contactToScramble.Birthdate;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.email)) {
            formattedString += contactToScramble.email;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.Corporate_Relations_Email__c)) {
            formattedString += contactToScramble.Corporate_Relations_Email__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.EPO_Email__c)) {
            formattedString += contactToScramble.EPO_Email__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.ASU_Email__c)) {
            formattedString += contactToScramble.ASU_Email__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.Last_Case_Email_Used__c)) {
            formattedString += contactToScramble.Last_Case_Email_Used__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.Lead_Email__c)) {
            formattedString += contactToScramble.Lead_Email__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.Lead_Secondary_Email__c)) {
            formattedString += contactToScramble.Lead_Secondary_Email__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.me3hs_User_ID__c)) {
            formattedString += contactToScramble.me3hs_User_ID__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.Parent_Email__c)) {
            formattedString += contactToScramble.Parent_Email__c;
        }
        formattedString += ',';
        if (!String.isEmpty(contactToScramble.Personal_Email__c)) {
            formattedString += contactToScramble.Personal_Email__c;
        }

        formattedString += ',#N/A';

        formattedString += '\n';

        return formattedString;
    }

    private void scrambleEmails() {
        contactToScramble.email = Scrambler.scrambleEmailOrUsername(contactToScramble.email);
        contactToScramble.Corporate_Relations_Email__c = Scrambler.scrambleEmailOrUsername(
            contactToScramble.Corporate_Relations_Email__c
        );
        contactToScramble.EPO_Email__c = Scrambler.scrambleEmailOrUsername(contactToScramble.EPO_Email__c);
        contactToScramble.ASU_Email__c = Scrambler.scrambleEmailOrUsername(contactToScramble.ASU_Email__c);
        contactToScramble.Last_Case_Email_Used__c = Scrambler.scrambleEmailOrUsername(
            contactToScramble.Last_Case_Email_Used__c
        );
        contactToScramble.Lead_Email__c = Scrambler.scrambleEmailOrUsername(contactToScramble.Lead_Email__c);
        contactToScramble.Lead_Secondary_Email__c = Scrambler.scrambleEmailOrUsername(
            contactToScramble.Lead_Secondary_Email__c
        );
        contactToScramble.me3hs_User_ID__c = Scrambler.scrambleEmailOrUsername(contactToScramble.me3hs_User_ID__c);
        contactToScramble.Parent_Email__c = Scrambler.scrambleEmailOrUsername(contactToScramble.Parent_Email__c);
        contactToScramble.Personal_Email__c = Scrambler.scrambleEmailOrUsername(contactToScramble.Personal_Email__c);
    }

    private void scrambleDates() {
        contactToScramble.Birthdate = Scrambler.scrambleDate(contactToScramble.Birthdate);
    }

    private void removeSilverpopId() {
        contactToScramble.silverpop__Silverpop_RecipientID__c = null;
    }
}
