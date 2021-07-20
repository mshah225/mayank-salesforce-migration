public class ContactPhoneAdder implements ObjectScramble {
    Contact contactToScramble;

    public ContactPhoneAdder(Contact contactToScramble) {
        this.contactToScramble = contactToScramble;
    }

    public sObject scrambleFields() {
        addPhoneNumber();

        return contactToScramble;
    }

    public String toCsvString() {
        String formattedString = contactToScramble.Id;
        formattedString += ',';
        formattedString += contactToScramble.HomePhone;

        formattedString += '\n';

        return formattedString;
    }


    private void addPhoneNumber() {
        contactToScramble.HomePhone = contactToScramble.Phone;
        contactToScramble.HomePhone = contactToScramble.HomePhone.replaceAll(',', '/');
    }
}
