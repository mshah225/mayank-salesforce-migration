public without sharing class FeedbackButtonController {
    private Boolean debug = false; // Debug mode flag
    private String caseContactId; // The Id of the contact to associate the case to
    private Boolean URLParamsExistAndAreValid; // Determines if the required URL parameters were provided and are valid
    private Boolean useLoggedInContact = false; // Determines if we should attempt to automatically detect the contact for the case
    private Feedback_Cars__c settings; // List of cached car Ids for assigning the feedback case

    public String retURL { get; set; } // Deprecated: displays breadcrumbs with a "back" butotn. Do not use.
    public String caseDescription { get; set; } // The comments provided by the end user saved as the case description
    public String carName { get; set; } // The name of the custom setting entry that references the required car
    public AlertHandler alertHandler { get; set; } // Use the custom alerting component
    public Contact loggedInContact;
    public String siteTitleName { get; set; }
    public String siteTitleUrl { get; set; }

    public FeedbackButtonController() {
    }

    /**
     * Initialize the page
     */
    public pageReference init() {
        try {
            alertHandler = new AlertHandler();
            URLParamsExistAndAreValid = false;
            caseDescription = ApexPages.currentPage().getParameters().get('misc');
            retURL = ApexPages.currentPage().getParameters().get('retURL');
            caseContactId = ApexPages.currentPage().getParameters().get('contactId');
            carName = ApexPages.currentPage().getParameters().get('carName');

            if (carName != null) {
                // The only required parameter for the page to function properly
                settings = Feedback_Cars__c.getAll().get(carName);

                siteTitleName = carName;
                siteTitleUrl = System.Label.MyASU_Help_Base_URL + '/myasu/student/servicecenter';

                if (settings != null) {
                    // Validate the contact, if it does not exist or is not valid
                    // Use logged in contact
                    if (!Validator.validateId(caseContactId, contact.class)) {
                        useLoggedInContact = true;
                    }

                    URLParamsExistAndAreValid = true;
                } else {
                    alertHandler.newAlert(
                        customAlert.FATAL,
                        'Invalid carName parameter. Our support team has been notified of this error. ' +
                        'If you require immediate assistance please call 1-855-ASU-5080.'
                    );

                    throw new dynamicFeedbackException('Error: Invalid carName parameter');
                }
            } else {
                alertHandler.newAlert(
                    customAlert.FATAL,
                    'carName parameter not provided. Our support team has been notified of this error. ' +
                    'If you require immediate assistance please call 1-855-ASU-5080.'
                );

                throw new dynamicFeedbackException('carName parameter not provided');
            }

            if (caseDescription != '' && caseDescription != null) {
                caseDescription = CaseDescription + '\n';
            }

            return null;
        } catch (Exception e) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertStringToJSON('carName', carName));
            vars.add(ErrorLogger.convertBooleanToJSON('useLoggedInContact', useLoggedInContact));
            vars.add(ErrorLogger.convertBooleanToJSON('URLParamsExistAndAreValid', URLParamsExistAndAreValid));
            vars.add(ErrorLogger.convertStringToJSON('caseDescription', caseDescription));
            vars.add(ErrorLogger.convertIdToJSON('caseContactId', caseContactId));

            for (customAlert ca : alertHandler.alerts) {
                vars.add(ErrorLogger.convertStringToJSON('Alert:', ca.message));
            }

            ErrorLogger.log(e, vars, debug, caseContactId);
            return null;
        }
    }

    public pageReference submit() {
        Case_Assignment_Rule__c car; // Used to asign the case
        Case feedbackCase; // The case to be created
        string EMPLId; // The EMPL Id of the contact to associate to the case
        boolean proceed; // Used to track if the code should continue to run after validations

        try {
            alertHandler.clear();
            proceed = true;

            if (!URLParamsExistAndAreValid) {
                proceed = false;

                alertHandler.newAlert(
                    customAlert.FATAL,
                    'Form submission after initialization error. Our support team has been notified of this error. ' +
                    'If you require immediate assistance please call 1-855-ASU-5080.'
                );

                throw new dynamicFeedbackException('Error: Form submission after initialization error');
            }

            if (caseDescription == '') {
                proceed = false;

                alertHandler.newAlert(customAlert.WARNING, 'Feedback comments are required.');
            }

            if (proceed) {
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

                if (useLoggedInContact) {
                    loggedInContact = ContactService.getLoggedInContact();
                    if (loggedInContact != null) {
                        caseContactId = loggedInContact.Id;
                    }
                }

                feedbackCase = new Case(
                    status = 'New',
                    contactId = caseContactId,
                    subject = carName + ' feedback',
                    description = caseDescription,
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

                alertHandler.clear();
                alertHandler.newAlert(
                    customAlert.CONFIRM,
                    'Thank you for your feedback about the ' +
                    carName +
                    '. You may now close this window.'
                );

                caseDescription = '';
            }
            return null;
        } catch (Exception e) {
            List<String> vars = new List<String>();

            vars.add(ErrorLogger.convertStringToJSON('carName', carName));
            vars.add(ErrorLogger.convertBooleanToJSON('useLoggedInContact', useLoggedInContact));
            vars.add(ErrorLogger.convertBooleanToJSON('URLParamsExistAndAreValid', URLParamsExistAndAreValid));
            vars.add(ErrorLogger.convertStringToJSON('caseDescription', caseDescription));
            vars.add(ErrorLogger.convertBooleanToJSON('proceed', proceed));
            vars.add(string.valueOf(alertHandler));
            vars.add(ErrorLogger.convertSObjectToJSON('car', car));
            vars.add(ErrorLogger.convertIdToJSON('caseContactId', caseContactId));
            vars.add(ErrorLogger.convertSObjectToJSON('feedbackCase', feedbackCase));

            ErrorLogger.log(e, vars, debug, caseContactId);
            return null;
        }
    }

    private class dynamicFeedbackException extends Exception {
    }
}
