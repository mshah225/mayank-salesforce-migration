public class SandboxRefreshService {
    public static String orgType;

    public static String setOrgTypeFromUrl(String url) {
        if (!String.isEmpty(orgType)) {
            return orgType;
        }
        if (url.containsIgnoreCase('DEV')) {
            orgType = '.dev';
        } else if (url.containsIgnoreCase('UAT')) {
            orgType = '.uat';
        } else if (url.containsIgnoreCase('QA')) {
            orgType = '.qa';
        }
        return orgType;
    }

    public static Sobject scrambleEmailField(Sobject objectToModify, List<String> fieldList) {
        for (String field : fieldList) {
            String originalEmail = (String) objectToModify.get(field);
            String scrambledEmail = getScrambledEmailFrom(originalEmail);
            objectToModify.put(field, scrambledEmail);
        }
        return objectToModify;
    }

    private static String getScrambledEmailFrom(String originalEmail) {
        String scrambledEmail;
        if (!String.isEmpty(originalEmail) && originalEmail.right(4) != orgType) {
            scrambledEmail = originalEmail + orgType;
            if (scrambledEmail.length() > 80) {
                scrambledEmail = scrambledEmail.right(80);
            }
        }
        return scrambledEmail;
    }

    public static Date scrambleBirthday(Date originalBirthday) {
        Integer intRandom = Math.round(Math.random() * 1000);
        intRandom = Math.mod(intRandom, 60) - 30;
        return originalBirthday.addDays(intRandom);
    }

    public static Sobject removeSilverPopId(Sobject objectToRemoveField) {
        objectToRemoveField.put('silverpop__Silverpop_RecipientID__c', '');
        return objectToRemoveField;
    }
}
