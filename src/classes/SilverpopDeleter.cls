public class SilverpopDeleter implements ObjectScramble {
    sObject silverpopToDelete;

    public SilverpopDeleter(sObject silverpopToDelete) {
        this.silverpopToDelete = silverpopToDelete;
    }

    public sObject scrambleFields() {
        return silverpopToDelete;
    }

    public String toCsvString() {
        String formattedString = silverpopToDelete.Id;

        formattedString += '\n';

        return formattedString;
    }
}
