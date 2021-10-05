public class Scrambler {
    public static String scrambleEmailOrUsername(String emailOrUsername) {
        String sandboxDomain = UserInfo.getUserName().substringAfterLast('.');

        if (String.isBlank(emailOrUsername)) {
            return '';
        }

        if (emailOrUsername.substringAfterLast('.') == sandboxDomain) {
            // No changes needed
        } else {
            emailOrUsername += '.' + sandboxDomain;
        }
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
