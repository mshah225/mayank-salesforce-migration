public without sharing class MyASUViewAs {
    private Map<String, String> response;
    public Boolean hasViewAsRights;

    public MyASUViewAs(String idCookie, String asurite) {
        response = EffectiveIdentityCallout.getCalloutResponseContents(idCookie, asurite);
        checkViewAsRights(response, asurite);
    }

    public String getResponseValueFromMap(String specificResponse) {
        return String.valueOf(response.get(specificResponse));
    }

    private void checkViewAsRights(Map<String, String> viewAsMap, String userAsurite) {
        hasViewAsRights =
            !viewAsMap.isEmpty() &&
            viewAsMap.get('authorizedToViewAs') == 'true' &&
            viewAsMap.get('isViewingAs') == 'true' &&
            userAsurite != viewAsMap.get('effectiveAsurite');
    }

    public Contact getContact(String asurite) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getContact(asurite);
        } else {
            return MyASUViewAsWithSharing.getContact(asurite);
        }
    }

    public Case getCaseDetails(Id caseId) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getCaseDetails(caseId);
        } else {
            return MyASUViewAsWithSharing.getCaseDetails(caseId);
        }
    }

    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getOpenCases(contacts);
        } else {
            return MyASUViewAsWithSharing.getOpenCases(contacts);
        }
    }

    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts, Integer queryLimit) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getOpenCases(contacts, queryLimit);
        } else {
            return MyASUViewAsWithSharing.getOpenCases(contacts, queryLimit);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getClosedCases(contacts);
        } else {
            return MyASUViewAsWithSharing.getClosedCases(contacts);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts, Integer queryLimit) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getClosedCases(contacts, queryLimit);
        } else {
            return MyASUViewAsWithSharing.getClosedCases(contacts, queryLimit);
        }
    }

    public List<EmailMessage> getCaseEmails(Date launchDate, Id caseId, List<String> contactEmails) {
        if (hasViewAsRights) {
            return MyASUViewAsWithoutSharing.getCaseEmails(launchDate, caseId, contactEmails);
        } else {
            return MyASUViewAsWithSharing.getCaseEmails(launchDate, caseId, contactEmails);
        }
    }

    private with sharing class MyASUViewAsWithSharing extends MyASUViewAsSharingService {
    }

    private without sharing class MyASUViewAsWithoutSharing extends MyASUViewAsSharingService {
    }
}
