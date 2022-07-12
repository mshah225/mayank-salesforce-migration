public class Scrambler {
    public static String carefullyScrambleEmailOrUsername(String emailOrUsername) {
        if (String.isBlank(emailOrUsername)) {
            return '';
        } else if (emailOrUsername.substringAfterLast('.').equals(getSandboxDomain())) {
            return emailOrUsername;
        } else {
            return scrambleEmailOrUsername(emailOrUsername);
        }
    }

    public static String scrambleEmailOrUsername(String emailOrUsername) {
        if (String.isBlank(emailOrUsername)) {
            return '';
        }

        emailOrUsername += '.' + getSandboxDomain();
        emailOrUsername = '"' + emailOrUsername.replace('"', '\'') + '"';
        return emailOrUsername;
    }

    public static Date scrambleDate(Date dateToScramble) {
        if (dateToScramble == null) {
            return null;
        }

        Integer randomOffset = 0;
        while (randomOffset == 0) {
            randomOffset = (Integer) (Math.random() * 30 - 15);
        }

        dateToScramble = dateToScramble.addDays(randomOffset);

        return dateToScramble;
    }

    public static String getSandboxDomain() {
        return UserInfo.getUserName().substringAfterLast('.');
    }
}
