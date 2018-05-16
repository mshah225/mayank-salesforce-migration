public class UploadContactValidator {
    
    public static Boolean validateId(String potentialFieldId, Schema.sObjectType schemaToVerify) {
        try {
            Id validIdForField = Id.ValueOf(potentialFieldId);
            return (validIdForField.getSobjectType() == schemaToVerify);
        } catch (Exception e) {
            return false;
        }
    }
    
    public static String cleanPhoneNumber(String phoneNumber) {
        return phoneNumber.replaceAll('[^0-9]', '');
    }
    
    public static Boolean validContactUploadDetail(Contact_Upload_Detail__c cud) {
        if (cud.Status__c == 'Error' || cud.Contact__c == null || cud.Subscription__c == null) {
            return false;
        }
        return true;
    }
}