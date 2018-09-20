public virtual class MyAsuViewAsSharingService {
     
    public static Contact getContact(String asurite) {
        return ContactService.getContactToViewAs(asurite);
    }

    public static Case getCaseDetails(Id caseId) {
        return CaseService.getCaseDetails(caseId);
    }
    
    public static Map<Id, List<Case>> getOpenCases(List<Contact> contacts) {
        return CaseService.getVisibleOpenCases(contacts);
    }

    public static Map<Id, List<Case>> getClosedCases(List<Contact> contacts) {
        return CaseService.getVisibleClosedCases(contacts);
    }

    public static List<EmailMessage> getCaseEmails(Date launchDate, Id caseId,
            List<String> contactEmails) {
        return CaseService.getCaseEmailMessages(launchDate, caseId, contactEmails);
    }
}