public class AdvisorPortalContact {
    private static final Set<String> OUTREACH_CUSTOMER_STATUSES = new Set<String>{
        'Outreach Required',
        'Outreach Required - Transferred',
        'Customer Replied'
    };

    @AuraEnabled
    public Contact portalContact;

    @AuraEnabled
    public Boolean isSelected;

    @AuraEnabled
    public Boolean isOutreachCustomer;
    @AuraEnabled
    public Boolean isGradStudent;
    @AuraEnabled
    public Boolean hasCases;
    @AuraEnabled
    public Boolean hasMultipleCases;

    @AuraEnabled
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
