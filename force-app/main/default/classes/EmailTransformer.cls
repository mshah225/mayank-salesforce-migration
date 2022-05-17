public class EmailTransformer {
    public List<EmailReplySuffix__mdt> emailSuffixes {
        get {
            if (emailSuffixes == null) {
                emailSuffixes = [SELECT MasterLabel FROM EmailReplySuffix__mdt];
            }
            return emailSuffixes;
        }
        set;
    }

    public String cleanEmailAddress(String emailAddress) {
        String cleanEmailAddress = emailAddress;
        for (EmailReplySuffix__mdt suffixToCheckFor : emailSuffixes) {
            if (cleanEmailAddress.contains(suffixToCheckFor.MasterLabel)) {
                cleanEmailAddress = removeSuffixFromEmail(cleanEmailAddress, suffixToCheckFor.MasterLabel);
                cleanEmailAddress = findAndReplaceSecondToLastPeriod(cleanEmailAddress);
            }
        }

        return cleanEmailAddress.toLowerCase();
    }

    private String removeSuffixFromEmail(String emailWithSuffix, String suffixToRemove) {
        Integer positionOfSuffix = emailWithSuffix.indexOf(suffixToRemove);
        String emailWithoutSuffix = emailWithSuffix.subString(0, positionOfSuffix);
        return emailWithoutSuffix;
    }

    private String findAndReplaceSecondToLastPeriod(String emailToClean) {
        String reverseEmail = emailToClean.reverse();
        Integer posOfPeriod = reverseEmail.indexOf('.', reverseEmail.indexOf('.') + 1);
        reverseEmail = reverseEmail.subString(0, posOfPeriod) + '@' + reverseEmail.subString(posOfPeriod + 1);
        reverseEmail = reverseEmail.reverse();
        return reverseEmail;
    }
}
