public with sharing class ViewEmailButtonController {

	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ViewEmailButtonController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    public PageReference viewEmail() {
        PageReference ref;
        ApexPages.Message msg;
        String jobId, cssfId;

        et4ae5__IndividualEmailResult__c email = [select et4ae5__MergeId__c, et4ae5__SendDefinition__r.et4ae5__JobId__c 
                                                  from et4ae5__IndividualEmailResult__c
                                                  where id = :mysObject.id];

        jobId = email.et4ae5__SendDefinition__r.et4ae5__JobId__c;
        cssfId = email.et4ae5__MergeId__c.right(18);

        ExactTargetWebService etws = new ExactTargetWebService('dataext');
        String authToken = etws.requestAuthToken();

        if (String.isNotEmpty(authToken)) {
            String url = etws.retrieveViewEmailUrl(authToken, jobId, cssfId);

            if (String.isNotBlank(url)) {
                ref = new PageReference(url).setRedirect(true);   
            
            } else {
                msg = new ApexPages.Message(ApexPages.Severity.INFO,'View As web page link unavailable for this record.');
                ApexPages.addMessage(msg);
            }

        } else {
            msg = new ApexPages.Message(ApexPages.Severity.INFO,'Failed to authenticate with Marketing Cloud.');
            ApexPages.addMessage(msg);
        }
   

        return ref;
        
    }
}