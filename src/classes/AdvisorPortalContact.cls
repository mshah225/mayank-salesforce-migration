public class AdvisorPortalContact {
    private static final Set<String> OUTREACH_CUSTOMER_STATUSES = new Set<String>{
        'Outreach Required',
        'Outreach Required - Transferred',
        'Customer Replied'
    };

    @AuraEnabled
    public Boolean isSelected { get; set; }

    @AuraEnabled
    public Boolean isOutreachCustomer { get; set; }

    @AuraEnabled
    public Contact portalContact { get; set; }

    public List<AdvisorPortalCase> cases;

    public AdvisorPortalContact(Contact theContact) {
        this.isSelected = false;
        this.isOutreachCustomer = false;
        this.portalContact = theContact;
        this.cases = new List<AdvisorPortalCase>();
    }

    public void addCases(List<AdvisorPortalCase> cases) {
        for (AdvisorPortalCase c : cases) {
            this.addCase(c);
        }
    }

    public void addCase(AdvisorPortalCase advisorCase) {
        this.cases.add(advisorCase);

        if (OUTREACH_CUSTOMER_STATUSES.contains(advisorCase.portalCase.Status)) {
            this.isOutreachCustomer = true;
        }
    }

    @AuraEnabled
    public List<AdvisorPortalCase> getCases() {
        return this.cases;
    }
}
