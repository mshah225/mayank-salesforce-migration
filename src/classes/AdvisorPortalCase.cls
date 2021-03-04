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

    public AdvisorPortalCase(Case theCase) {
        this.isSelected = false;
        this.portalCase = theCase;
    }
}
