public with sharing class ViewAllCasesController 
{
    Contact loggedInContact;
    Id caseId;

    public ViewAllCasesController() 
    {
        loggedInContact = ContactService.getLoggedInContact();
    }

    public List<Case> getOpenCases()
    {
        List<Contact> loggedInContacts = new List<Contact> { loggedInContact };

        Map<Id, List<Case>> openCaseMap = CaseService.getVisibleOpenCases(loggedInContacts);

        return openCaseMap.get(loggedInContact.Id)==null ? new List<Case>() : openCaseMap.get(loggedInContact.Id);
    }

    public List<Case> getClosedCases()
    {
        List<Contact> loggedInContacts = new List<Contact> { loggedInContact };

        Map<Id, List<Case>> closedCaseMap = CaseService.getVisibleClosedCases(loggedInContacts);

        return closedCaseMap.get(loggedInContact.Id)==null ? new List<Case>() : closedCaseMap.get(loggedInContact.Id);
    }

    public PageReference viewCase()
    {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        PageReference viewCasePage = Page.viewcase;
        viewCasePage.getParameters().put('id', caseId);
        viewCasePage.getParameters().put('source', 'viewAllCases');

        return viewCasePage;
    }

    public String getSource()
    {
        String source = ApexPages.currentPage().getParameters().get('source');

        return source;
    } 
}