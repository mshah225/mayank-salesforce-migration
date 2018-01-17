public with sharing class ViewEmailButtonController {
	private final Sobject controllerObject;

    // The extension constructor initializes the private member
    // variable controllerObject by using the getRecord method from the standard
    // controller.
    public ViewEmailButtonController(ApexPages.StandardController stdController) {
        this.controllerObject = (Sobject) stdController.getRecord();
    }

    public PageReference viewEmail() {
        et4ae5__IndividualEmailResult__c email = [
            SELECT et4ae5__MergeId__c, et4ae5__SendDefinition__r.et4ae5__JobId__c 
            FROM et4ae5__IndividualEmailResult__c
            WHERE id = :controllerObject.id
        ];

        String jobId = email.et4ae5__SendDefinition__r.et4ae5__JobId__c;
        String cssfId = email.et4ae5__MergeId__c.right(18);

        ExactTargetWebService etws = new ExactTargetWebService('dataext');
        String authToken = etws.requestAuthToken();
        
        if (String.isNotEmpty(authToken)) {
            String url = etws.retrieveViewEmailUrl(authToken, jobId, cssfId);

            if (String.isNotBlank(url)) {
                return new PageReference(url).setRedirect(true);   
            } else {
                ApexPages.Message msg = new ApexPages.Message(
                    ApexPages.Severity.INFO,'View As web page link unavailable for this record.');
                ApexPages.addMessage(msg);
            }
        } else {
            ApexPages.Message msg = new ApexPages.Message(
                ApexPages.Severity.INFO,'Failed to authenticate with Marketing Cloud.');
            ApexPages.addMessage(msg);
        }
        return null;
    }
}