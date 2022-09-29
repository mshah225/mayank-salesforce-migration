public class AdvisorPortalContact {
    private static final Set<String> OUTREACH_CUSTOMER_STATUSES = new Set<String>{
        'Outreach Required',
        'Outreach Required - Transferred',
        'Customer Replied'
    };

    public Contact portalContact;

    public Boolean isSelected;

    public Boolean isOutreachCustomer;
    public Boolean isGradStudent;
    public Boolean hasCases;
    public Boolean hasMultipleCases;

    public List<AdvisorPortalCase> cases;

    public AdvisorPortalContact(Contact theContact) {
        this.isSelected = false;
        this.isOutreachCustomer = false;
        this.isGradStudent = false;
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

        updateCaseStateBools(); // track quantity of cases in some state variables
    }

    private void updateCaseStateBools() {
        this.hasCases = !this.cases.isEmpty();
        this.hasMultipleCases = this.cases.size() > 1;
    }
    
    public List<AdvisorPortalCase> getCases() {
        return this.cases;
    }
}