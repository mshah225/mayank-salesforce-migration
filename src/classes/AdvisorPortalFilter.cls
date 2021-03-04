/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-08-02
 *
 * Used to help facilitate Advisor Portal Contact/Case filtering.
 */
public class AdvisorPortalFilter {
    /**
     * Represents a Contacts's Name, EMPLID__c, or ASURite_Id__c value.
     */
    @AuraEnabled
    public String studentString { get; set; }

    /**
     * Represents a related CC_Category__r.Name value on Case.
     */
    @AuraEnabled
    public String caseCategory { get; set; }

    /**
     * Represents a Subject value on Case.
     */
    @AuraEnabled
    public String caseSubject { get; set; }

    /**
     * Represents a Status value on Case.
     */
    @AuraEnabled
    public String caseStatus { get; set; }

    /**
     * Represents the number of Cases to match after filtering.
     */
    @AuraEnabled
    public Integer caseCount { get; set; }

    /**
     * Represents filtering on all Cases.
     */
    @AuraEnabled
    public Boolean allCasesState { get; set; }

    /**
     * Represents whether a Case is Watchlist or not.
     */
    @AuraEnabled
    public Boolean watchlistCasesState { get; set; }

    /**
     * Represents whether a Case is Proactive or not.
     */
    @AuraEnabled
    public Boolean proactiveCasesState { get; set; }

    /**
     * Represents a Curr_Cont_Prediction_Level__c value on Case.
     */
    @AuraEnabled
    public String outlookScore { get; set; }

    /**
     * Represents a Most_Recent_Outlook_Change_Direction__c value on Case.
     */
    @AuraEnabled
    public String outlookChange { get; set; }

    /**
     * Represents a CreatedDate value on Case.
     */
    @AuraEnabled
    public String createdFromDate { get; set; }

    /**
     * Represents a CreatedDate value on Case.
     */
    @AuraEnabled
    public String createdToDate { get; set; }

    /**
     * Represents a Followup_Date__c value on Case.
     */
    @AuraEnabled
    public String followUpFromDate { get; set; }

    /**
     * Represents a Followup_Date__c value on Case.
     */
    @AuraEnabled
    public String followUpToDate { get; set; }

    /**
     * Represents a Change_Date__c value on Case.
     */
    @AuraEnabled
    public String persistenceFromDate { get; set; }

    /**
     * Represents a Change_Date__c value on Case.
     */
    @AuraEnabled
    public String persistenceToDate { get; set; }

    /**
     * Represents a SG_PeopleSoft_Code__c value on Student_Group__c.
     */
    @AuraEnabled
    public String studentGroupCode { get; set; }

    /**
     * Represents Cohort__c on Student_Program_Plan__c
     */
    @AuraEnabled
    public String academicLevel { get; set; }

    /**
     * Represents a Campus__r.Name on Student_Program_Plan__c
     */
    @AuraEnabled
    public String campus { get; set; }

    /**
     * Represents text in Plan_Description__c on Student_Program_Plan__c
     */
    @AuraEnabled
    public String major { get; set; }

    /**
     * Represents Residency__c on Student_Program_Plan__c
     */
    @AuraEnabled
    public String residency { get; set; }

    /**
     * Represents an Advisor_Name__c on Student_Program_Plan_Advisor__c
     */
    @AuraEnabled
    public String advisor { get; set; }
}
