public virtual class MyASUHelpViewAsSharingService {
    public static Contact getContact(String asurite) {
        return ContactService.getContactToViewAs(asurite);
    }

    public static Case getCaseDetails(Id caseId) {
        return CaseService.getCaseDetails(caseId);
    }

    public static Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        return getOpenCases(contacts, 0);
    }

    public static Map<Id, List<Case>> getOpenCases(List<Contact> contacts, Integer queryLimit) {
        return CaseService.getVisibleOpenCases(contacts, queryLimit);
    }

    public static Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        return getClosedCases(contacts, 0);
    }

    public static Map<Id, List<Case>> getClosedCases(List<Contact> contacts, Integer queryLimit) {
        return CaseService.getVisibleClosedCases(contacts, queryLimit);
    }

    public static List<EmailMessage> getCaseEmails(Date launchDate, Id caseId, List<String> contactEmails) {
        return CaseService.getCaseEmailMessages(launchDate, caseId, contactEmails);
    }
}
