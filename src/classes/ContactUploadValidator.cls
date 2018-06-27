public class ContactUploadValidator {
    private Contact_Upload_Detail__c detail;
    
    public ContactUploadValidator(Contact_Upload_Detail__c detail) {
        this.detail = detail;
    }
    
    public Boolean isInError() {
        return detail.Status__c == 'Error';
    }
    
    public void validateAndClean() {
        cleanOptionalFields();
        checkRequiredFields();
    }
    
    private void checkRequiredFields() {
        checkSubscription();
        checkFirstAndLastName();
        checkEmail();
        checkSubscriberStatusAndValue();
        checkSubscriberStatusValue();
    }
    
    private Boolean checkSubscription() {
        if (detail.Subscription__c != null) {
            return validIdForSubscription();
        }
        setError('Subscription Id is REQUIRED.');
        return false;
    }
    
    private Boolean validIdForSubscription() {
        if (isValidIdFor(detail.Subscription__c, Schema.Subscription__c.SobjectType)) {
            return true;
        }
        detail.Subscription__c = null;
        setError('Subscription Id is invalid.');
        return false;
    }
    
    private Boolean isValidIdFor(String potentialFieldId, Schema.sObjectType schemaToVerify) {
        try {
            Id validIdForField = Id.ValueOf(potentialFieldId);
            return (validIdForField.getSobjectType() == schemaToVerify);
        } catch (Exception e) {
            return false;
        }
    }
    
    private Boolean checkFirstAndLastName() {
        if (!String.isBlank(detail.First_Name__c) && !String.isBlank(detail.Last_Name__c)) {
            return true;
        }
        setError('First and last names are REQUIRED.');
        return false;
    }
    
    private Boolean checkEmail() {
        if (!String.isBlank(detail.Email__c)) {
            detail.Email__c = detail.Email__c.toLowerCase();
            return true;
        }
        setError('Email is REQUIRED.');
        return false;
    }
    
    private Boolean checkSubscriberStatusAndValue() {
        if (checkSubscriberStatus) {
            checkSubscriberStatusValue();
        }
    }
    
    private Boolean checkSubscriberStatus() {
        if (!String.isBlank(detail.Subscriber_Status__c)) {
            return true;
        }
        setError('Subscriber Status is REQUIRED.');
        return false;
    }
    
    private Boolean checkSubscriberStatusValue() {
        if (detail.Subscriber_Status__c.equalsIgnoreCase('Subscribed') || 
                detail.Subscriber_Status__c.equalsIgnoreCase('Unsubscribed') /*|| 
                detail.Subscriber_Status__c.equalsIgnoreCase('No Preference')*/) {
            return true;
        }
        setError('Subscriber Status can only have the values Subscribed, Unsubscribed or No Preference.');
        return false;
    }
    
    private void cleanOptionalFields() {
        cleanPhoneNumber();
    }
    
    private void cleanPhoneNumber() {
        if (detail.Phone__c != null) {
            detail.Phone__c = detail.Phone__c.replaceAll('[^0-9]', '');
        }
    }
    
    private void setError(String errorMessage) {
        detail.Status__c = 'Error';
        detail.Processing_Notes__c += errorMessage + ' ';
    }
}