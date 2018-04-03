public class SandboxRefreshService {
    public static String orgType {set; get;}
    
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
    
    public static sObject scrambleEmailField(sObject objectToModify, List<String> fieldList) {
        for (String field : fieldList) {
            String originalEmail = (String)objectToModify.get(field);
            if(!String.isEmpty(originalEmail) && originalEmail.right(4) != orgType) {
                String scrambledEmail = originalEmail + orgType;
                objectToModify.put(field, scrambledEmail);
            }
        }
        return objectToModify;
    }
    
    public static Date scrambleBirthday(Date originalBirthday) {
        Integer intRandom = Math.round(Math.random()*1000);
        intRandom = Math.mod(intRandom, 60) - 30;
        return originalBirthday.addDays(intRandom);
    }
    
    public static sObject removeSilverPopId(sObject objectToRemoveField) {
        objectToRemoveField.put('silverpop__Silverpop_RecipientID__c', '');
        return objectToRemoveField;
    }
}