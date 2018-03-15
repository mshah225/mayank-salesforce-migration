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
    
    private sObject scrambleEmailField(sObject objectToModify, List<String> fieldList) {
        for (String field : fieldList) {
            String originalEmail = objectToModify.get(field);
            if(!String.isEmpty(originalEmail) && originalEmail.right(4) != orgType) {
                String scrambledEmail = originalEmail + orgType;
                objectToModify.put(field, scrambledEmail);
            }
        }
        return objectToModify;
    } 
}