public without sharing class MyASUHelpViewAsService {
    private Map<String, String> response;
    public Boolean hasViewAsRights;

    public MyASUHelpViewAsService(String idCookie, String asurite) {
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
            return MyASUHelpViewAsServiceWithoutSharing.getContact(asurite);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getContact(asurite);
        }
    }

    public Case getCaseDetails(Id caseId) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceWithoutSharing.getCaseDetails(caseId);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getCaseDetails(caseId);
        }
    }

    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceWithoutSharing.getOpenCases(contacts);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getOpenCases(contacts);
        }
    }

    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts, Integer queryLimit) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceWithoutSharing.getOpenCases(contacts, queryLimit);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getOpenCases(contacts, queryLimit);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceWithoutSharing.getClosedCases(contacts);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getClosedCases(contacts);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts, Integer queryLimit) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceWithoutSharing.getClosedCases(contacts, queryLimit);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getClosedCases(contacts, queryLimit);
        }
    }

    public List<EmailMessage> getCaseEmails(Date launchDate, Id caseId, List<String> contactEmails) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceWithoutSharing.getCaseEmails(launchDate, caseId, contactEmails);
        } else {
            return MyASUHelpViewAsServiceWithSharing.getCaseEmails(launchDate, caseId, contactEmails);
        }
    }

    private with sharing class MyASUHelpViewAsServiceWithSharing extends MyASUHelpViewAsSharingService {
    }

    private without sharing class MyASUHelpViewAsServiceWithoutSharing extends MyASUHelpViewAsSharingService {
    }
}
