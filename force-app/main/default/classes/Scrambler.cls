public class Scrambler {
    public static String scrambleEmailOrUsername(String emailOrUsername) {
        if (String.isBlank(emailOrUsername)) {
            return '';
        }

        emailOrUsername += '.' + UserInfo.getUserName().substringAfterLast('.');
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
}
