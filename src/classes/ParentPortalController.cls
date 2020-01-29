public class ParentPortalController {
    public List<String> chosenTopics {get; set;}
    public String country {get; set;}

    // These four member variables maintain the state of the wizard.
    // When users enter data into the wizard, their input is stored
    // in these variables.
    Account account;
    Contact contact;
    Opportunity opportunity;
    OpportunityContactRole role;
    public List<SelectOption> topicOptions =  new List<SelectOption>();

    // The next four methods return one of each of the four member
    // variables. If this is the first time the method is called,
    // it creates an empty record for the variable.
    public Account getAccount() {
        if (account == null) {account = new Account();}

        return account;
    }

    public Contact getContact() {
        if (contact == null) {contact = new Contact();}

        return contact;
    }

    public Opportunity getOpportunity() {
        if (opportunity == null) {opportunity = new Opportunity();}

        return opportunity;
    }

    public OpportunityContactRole getRole() {
        if (role == null) {role = new OpportunityContactRole();}

        return role;
    }

    public List<SelectOption> getTopicOptions() {
        topicOptions.clear();
        SelectOption topicOptionsScience = new SelectOption('Science', 'Science');
        SelectOption topicOptionsTechnology = new SelectOption('Technology', 'Technology');
        SelectOption topicOptionsEngineering = new SelectOption('Engineering', 'Engineering');
        SelectOption topicOptionsArts = new SelectOption('Arts', 'Arts');
        SelectOption topicOptionsMath = new SelectOption('Math', 'Math');
        topicOptions.add(topicOptionsScience);
        topicOptions.add(topicOptionsTechnology);
        topicOptions.add(topicOptionsEngineering);
        topicOptions.add(topicOptionsArts);
        topicOptions.add(topicOptionsMath);
        return topicOptions;
    }

    // The next three methods control navigation through
    // the wizard. Each returns a PageReference for one of the three pages
    // in the wizard. Note that the redirect attribute does not need to
    // be set on the PageReference because the URL does not need to change
    // when users move from page to page.
    public PageReference parentPortalStep1() {
        return Page.ParentPortalStep1;
    }

    public PageReference parentPortalStep2() {
        return Page.ParentPortalStep2;
    }

    public PageReference parentPortalStep3() {
        return Page.ParentPortalStep3;
    }

    public PageReference parentPortalStep4() {
        return Page.ParentPortalStep4;
    }

    public PageReference parentPortalStep5() {
        return Page.ParentPortalStep5;
    }

    // This method cancels the wizard, and returns the user to the
    // Opportunities tab
    public PageReference cancel() {
        PageReference opportunityPage = new ApexPages.StandardController(opportunity).view();
        opportunityPage.setRedirect(true);

        return opportunityPage;
    }

    // This method performs the final save for all four objects, and
    // then navigates the user to the detail page for the new
    // opportunity.
    public PageReference save() {
        // Create the account. Before inserting, copy the contact's
        // phone number into the account phone number field.
        account.phone = contact.phone;
        insert account;

        // Create the contact. Before inserting, use the id field
        // that's created once the account is inserted to create
        // the relationship between the contact and the account.
        contact.accountId = account.id;
        insert contact;

        // Create the opportunity. Before inserting, create
        // another relationship with the account.
        opportunity.accountId = account.id;
        insert opportunity;

        // Create the junction contact role between the opportunity
        // and the contact.
        role.opportunityId = opportunity.id;
        role.contactId = contact.id;
        insert role;

        // Finally, send the user to the detail page for
        // the new opportunity.

        PageReference opptyPage = new ApexPages.StandardController(opportunity).view();
        opptyPage.setRedirect(true);

        return opptyPage;
    }
}