public with sharing class ViewAllCasesController 
{
    private ServiceCenter sc;
    public ViewAllCasesController(ServiceCenter sc) { this.sc = sc; }

    public List<Case> getAllClosedCases()
    {
        List<Contact> loggedInContacts = new List<Contact> { sc.userContact };

        Map<Id, List<Case>> closedCaseMap = CaseService.getVisibleClosedCases(loggedInContacts);

        return closedCaseMap.get(sc.userContact.Id) == null ? new List<Case>() : closedCaseMap.get(sc.userContact.Id);
    }
}