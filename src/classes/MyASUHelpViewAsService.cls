public without sharing class MyASUHelpViewAsServiceewAsService {
    private Map<String, String> response;
    public Boolean hasViewAsRights;

    public MyASUHelpViewAsServiceewAsService(String idCookie, String asurite) {
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
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getContact(asurite);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getContact(asurite);
        }
    }

    public Case getCaseDetails(Id caseId) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getCaseDetails(caseId);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getCaseDetails(caseId);
        }
    }

    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getOpenCases(contacts);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getOpenCases(contacts);
        }
    }

    public Map<Id, List<Case>> getOpenCases(List<Contact> contacts, Integer queryLimit) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getOpenCases(contacts, queryLimit);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getOpenCases(contacts, queryLimit);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getClosedCases(contacts);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getClosedCases(contacts);
        }
    }

    public Map<Id, List<Case>> getClosedCases(List<Contact> contacts, Integer queryLimit) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getClosedCases(contacts, queryLimit);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getClosedCases(contacts, queryLimit);
        }
    }

    public List<EmailMessage> getCaseEmails(Date launchDate, Id caseId, List<String> contactEmails) {
        if (hasViewAsRights) {
            return MyASUHelpViewAsServiceewAsServiceWithoutSharing.getCaseEmails(launchDate, caseId, contactEmails);
        } else {
            return MyASUHelpViewAsServiceewAsServiceWithSharing.getCaseEmails(launchDate, caseId, contactEmails);
        }
    }

    private with sharing class MyASUHelpViewAsServiceewAsServiceWithShariMyASUHelpViewAsServiceMyASUHelpViewAsServiceSharingService {
    }

    private without sharing class MyASUHelpViewAsServiceewAsServiceWithoutShariMyASUHelpViewAsServiceMyASUHelpViewAsServiceSharingService {
    }
}
