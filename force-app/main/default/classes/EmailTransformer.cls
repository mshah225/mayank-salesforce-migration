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

    public String trimReplyFromSuffix(String emailToClean) {
        String cleanedEmail = emailToClean;
        for (EmailReplySuffix__mdt suffixToCheckFor : emailSuffixes) {
            if (cleanedEmail.contains(suffixToCheckFor.MasterLabel)) {
                cleanedEmail = removeSuffixFromEmail(cleanedEmail, suffixToCheckFor.MasterLabel);
                cleanedEmail = findAndReplaceSecondToLastPeriod(cleanedEmail);
            }
        }

        return cleanedEmail.toLowerCase();
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
