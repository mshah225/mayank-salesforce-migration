public without sharing class MyAsuViewAs {
    
    private Map<String, String> response;
    public Boolean hasViewAsRights;

    public MyASUViewAs(String idCookie, String asurite) {
        response = MyAsuViewAsCallout.getCalloutResponseContents(idCookie, asurite);
        checkViewAsRights(response, asurite);
    }
    
    public String getResponseValueFromMap(String specificResponse) {
        return String.valueOf(response.get(specificResponse));
    }
    
    private void checkViewAsRights(Map<String, String> viewAsMap, String userAsurite) {
        hasViewAsRights = !viewAsMap.isEmpty()
                && viewAsMap.get('authorizedToViewAs') == 'true'
                && viewAsMap.get('isViewingAs') == 'true'
                && userAsurite != viewAsMap.get('effectiveAsurite');
    }
    
    public Contact getContact(String asurite) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getContact(asurite);
        } else {
            return MyAsuViewAsWithSharing.getContact(asurite);
        }
    }

    public Case getCaseDetails(Id caseId) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getCaseDetails(caseId);
        } else {
            return MyAsuViewAsWithSharing.getCaseDetails(caseId);
        }
    }
    
    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getOpenCases(contacts);
        } else {
            return MyAsuViewAsWithSharing.getOpenCases(contacts);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getClosedCases(contacts);
        } else {
            return MyAsuViewAsWithSharing.getClosedCases(contacts);
        }
    }

    public List<EmailMessage> getCaseEmails(Date launchDate, Id caseId, List<String> contactEmails) {
        if (hasViewAsRights) {
            return MyAsuViewAsWithoutSharing.getCaseEmails(launchDate, caseId, contactEmails);
        } else {
            return MyAsuViewAsWithSharing.getCaseEmails(launchDate, caseId, contactEmails);
        }
    }
        
    private with sharing class MyAsuViewAsWithSharing extends MyAsuViewAsSharingService{}
    
    private without sharing class MyAsuViewAsWithoutSharing extends MyAsuViewAsSharingService{}
}