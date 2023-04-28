public without sharing class PersistenceFeedbackController {
    private Boolean debug = false; // Debug mode flag
    private String caseContactId; // The Id of the contact to associate the case to
    @TestVisible
    private Boolean URLParamsExistAndAreValid; // Determines if the required URL parameters were provided and are valid
    private Feedback_Cars__c settings; // List of cached car Ids for assigning the feedback case

    public String retURL { get; set; } // Deprecated: displays breadcrumbs with a "back" butotn. Do not use.
    public String caseDescription { get; set; } // The comments provided by the end user saved as the case description
    public String carName { get; set; } // The name of the custom setting entry that references the required car
    public AlertHandler alertHandler { get; set; } // Use the custom alerting component
    public Contact loggedInContact;
    public PersistenceFeedbackController() {
    }

    /**
     * Initialize the page
     */
    public pageReference init() {
        try {
            alertHandler = new AlertHandler();
            caseDescription = ApexPages.currentPage().getParameters().get('misc');
            retURL = ApexPages.currentPage().getParameters().get('retURL');

            if (caseDescription != '' && caseDescription != null) {
                caseDescription = CaseDescription + '\n';
            } else {
                URLParamsExistAndAreValid = false;
                throw new MissingUrlParametersException('Error: Missing URL parameter \'misc\' required.');
            }

            URLParamsExistAndAreValid = true;
            return null;
        } catch (Exception e) {
            List<String> params = new List<String> {'URLParamsExistAndAreValid', 'caseDescription', 'caseContactId', 'alertHandler'};

            List<String> vars = LoggerHelper(new List<String>(), params);

            ErrorLogger.log(e, vars, debug, caseContactId);
            return null;
        }
    }

    public pageReference submit() {
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
                    'If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080).'
                );

                throw new dynamicFeedbackException('Error: Form submission after initialization error');
            }

            if (caseDescription.replaceAll('\\s', '') == '') {
                proceed = false;

                alertHandler.newAlert(customAlert.WARNING, 'Feedback comments are required.');
            }

            if (proceed) {
                Feedback_Cars__c settings = Feedback_Cars__c.getAll().get('Persistence Outlook');

                Case_Assignment_Rule__c car = [
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

                caseContactId = ContactService.getLoggedInContactId();

                feedbackCase = new Case(
                    RecordType = [SELECT Id FROM RecordType WHERE Name = 'ASU Service' LIMIT 1],
                    status = 'New',
                    contactId = caseContactId,
                    subject = 'Persistence Outlook feedback',
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
                    'Thank you for your feedback about the Persistence Outlook. You may now close this window.'
                );

                caseDescription = '';
            }
            return null;
        } catch (Exception e) {
            List<String> params = new List<String> {'useLoggedInContact', 'URLParamsExistAndAreValid', 'caseDescription', 'proceed', 'caseContactId', 'alertHandler', 'feedbackCase'};

            List<String> vars = LoggerHelper(new List<String>(), params);

            ErrorLogger.log(e, vars, debug, caseContactId);
            return null;
        }
    }

    private List<String> LoggerHelper(List<String> vars, List<String> params) {
        for(String param : params){
            if(param == 'caseContactId'){
                vars.add(ErrorLogger.convertIdToJSON('caseContactId', caseContactId));
            } else if(param == 'URLParamsExistAndAreValid'){
                vars.add(ErrorLogger.convertBooleanToJSON('URLParamsExistAndAreValid', URLParamsExistAndAreValid));
            } else if(param == 'caseDescription'){
                vars.add(ErrorLogger.convertStringToJSON('caseDescription', caseDescription));
            } else if(param == 'carName'){
                vars.add(ErrorLogger.convertStringToJSON('carName', carName));
            } else if(param == 'alertHandler'){
                vars.add(string.valueOf(alertHandler));
            } else {
                return null;
            }
        }
        return vars;
    }

    private class dynamicFeedbackException extends Exception {
    }

    private class MissingUrlParametersException extends Exception {
    }
    
}