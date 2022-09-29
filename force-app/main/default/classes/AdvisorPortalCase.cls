/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-05
 *
 * A wrapper class used on the Advisor Portal for Cases.
 */
public class AdvisorPortalCase {
    public Case portalCase;

    public Boolean isSelected;

    public String formattedFollowupDate;
    public String formattedCreatedDate;

    public Boolean hasFollowupDate = false;

    public AdvisorPortalCase(Case theCase) {
        this.isSelected = false;
        this.portalCase = theCase;

        if (theCase.Followup_Date__c != null) {
            Datetime followUp = Datetime.newInstance(theCase.Followup_Date__c, Time.newInstance(0, 0, 0, 0));
            this.formattedFollowupDate = followUp.format('yyyy-MM-dd');
            this.hasFollowupDate = true;
        }

        if (theCase.CreatedDate != null) {
            this.formattedCreatedDate = theCase.CreatedDate.format('yyyy-MM-dd');
        }
    }
}