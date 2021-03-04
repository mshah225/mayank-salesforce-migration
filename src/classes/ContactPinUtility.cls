public without sharing class ContactPinUtility {
    public static String updatePin(Contact userContact, Decimal origPin, Decimal newPin) {
        if (userContact == null || origPin == newPin || !ContactService.isPinValid(newPin, userContact.Birthdate)) {
            return 'error';
        } else {
            userContact.Self_Service_PIN__c = newPin;
            if (userContact.PIN_lockout__c == true) {
                userContact.PIN_lockout__c = false;
            }

            try {
                update userContact;
                return 'success';
            } catch (Exception e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('First Name', userContact.FirstName));
                vars.add(ErrorLogger.convertStringToJSON('Last Name', userContact.LastName));
                vars.add(ErrorLogger.convertStringToJSON('Employee Id', userContact.EMPLId__c));
                ErrorLogger.log(e, vars, false);
                return 'error';
            }
        }
    }
}
