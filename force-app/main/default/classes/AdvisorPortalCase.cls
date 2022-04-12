/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-05
 *
 * A wrapper class used on the Advisor Portal for Cases.
 */
public class AdvisorPortalCase {
    @AuraEnabled
    public Boolean isSelected { get; set; }

    @AuraEnabled
    public Case portalCase { get; set; }

    public String formattedFollowupDate;
    public String formattedCreatedDate;

    public AdvisorPortalCase(Case theCase) {
        this.isSelected = false;
        this.portalCase = theCase;

        if (theCase.Followup_Date__c != null) {
            Datetime followUp = Datetime.newInstance(theCase.Followup_Date__c, Time.newInstance(0, 0, 0, 0));
            this.formattedFollowupDate = followUp.format('yyyy-MM-dd');
        }

        if (theCase.CreatedDate != null) {
            this.formattedCreatedDate = theCase.CreatedDate.format('yyyy-MM-dd');
        }
    }
}
