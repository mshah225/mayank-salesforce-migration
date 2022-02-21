public with sharing class FeedbackButtonService {
    private static Boolean debug = true; // Debug mode flag

    @AuraEnabled
    public static boolean submitFeedback(String carName, String feedbackText) {
        Contact c = ContactService.getLoggedInContact();
        if (c != null) {
            return submitFeedback(carName, feedbackText, c.Id);
        } else {
            LWCFeedbackException e = new LWCFeedbackException('Unable to find logged in contact.');
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertStringToJSON('carName', carName));
            vars.add(ErrorLogger.convertStringToJSON('feedbackText', feedbackText));
            vars.add(
                ErrorLogger.convertSObjectToJSON(
                    'ContactService.getLoggedInContact()',
                    ContactService.getLoggedInContact()
                )
            );

            ErrorLogger.log(e, vars, debug);
            throw e;
        }
    }

    public static boolean submitFeedback(String carName, String feedbackText, String caseContactId) {
        Case_Assignment_Rule__c car; // Used to asign the case
        Case feedbackCase; // The case to be created
        Feedback_Cars__c settings = Feedback_Cars__c.getAll().get(carName);

        try {
            if (Validator.validateId(caseContactId, contact.class)) {
                if (settings != null) {
                    if (feedbackText != null && feedbackText.trim().length() > 0) {
                        car = [
                            SELECT
                                Id,
                                Queue_Id__c,
                                Origin__c,
                                CC_Functional_Group__c,
                                CC_Category__c,
                                CC_Sub_Category__c,
                                Email_Address__c,
                                Case_Feed_Email_Template_Id__c,
                                Campus__c
                            FROM Case_Assignment_Rule__c
                            WHERE Id = :settings.CAR_Id__c
                        ];

                        feedbackCase = new Case(
                            status = 'New',
                            contactId = caseContactId,
                            subject = carName + ' feedback',
                            description = feedbackText,
                            Origin__c = car.Origin__c,
                            CC_Functional_Group__c = car.CC_Functional_Group__c,
                            CC_Category__c = car.CC_Category__c,
                            OwnerId = car.Queue_ID__c,
                            CC_Sub_Category__c = car.CC_Sub_Category__c,
                            Case_Feed_Email__c = car.Email_Address__c,
                            Case_Feed_Email_Template_Id__C = car.Case_Feed_Email_Template_Id__c,
                            Campus__c = car.Campus__c,
                            IsVisibleInSelfService = false
                        );

                        insert feedbackCase;

                        return true;
                    } else {
                        // this is an error because empty feedback should never get to this point - it should be stopped on frontend
                        throw new LWCFeedbackException(
                            'Feedback must contain some text. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).'
                        );
                    }
                } else {
                    throw new LWCFeedbackException(
                        'Invalid carName parameter. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).'
                    );
                }
            } else {
                throw new LWCFeedbackException(
                    'Invalid contactId parameter. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).'
                );
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertStringToJSON('carName', carName));
            vars.add(ErrorLogger.convertStringToJSON('feedbackText', feedbackText));
            vars.add(ErrorLogger.convertStringToJSON('caseContactId', caseContactId));

            ErrorLogger.log(e, vars, debug);
            throw e;
        }
    }

    @TestVisible
    private class LWCFeedbackException extends Exception {
    }
}
