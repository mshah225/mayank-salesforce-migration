public inherited sharing class ASUBrandFunctions {
    @AuraEnabled(cacheable=true)
    public static String getFirstName() {
        if (UserInfo.getUserId() != null && !UserInfo.getLastName().containsIgnoreCase('site guest user')) {
            return UserInfo.getFirstName();
        } else {
            throw new ASUBrandFunctionsException('Not Logged In');
        }
    }

    public class ASUBrandFunctionsException extends Exception {}
}
