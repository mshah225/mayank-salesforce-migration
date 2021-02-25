public inherited sharing class ASUBrandUtilities {
    @AuraEnabled(cacheable=true)
    public static String getFirstName() {
        if (UserInfo.getUserId() != null && !UserInfo.getLastName().containsIgnoreCase('site guest user')) {
            return UserInfo.getFirstName();
        } else {
            throw new ASUBrandUtilitiesException('Not Logged In');
        }
    }

    public class ASUBrandUtilitiesException extends Exception {
    }
}
