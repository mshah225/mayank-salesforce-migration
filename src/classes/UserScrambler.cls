public class UserScrambler implements ObjectScramble {
    User userToScramble;

    public UserScrambler(User userToScramble) {
        this.userToScramble = userToScramble;
    }

    public sObject scrambleFields() {
        userToScramble.isActive = false;

        return userToScramble;
    }

    public String toCsvString() {
        String formattedString = userToScramble.Id;

        formattedString += ',false';

        formattedString += '\n';

        return formattedString;
    }
}
