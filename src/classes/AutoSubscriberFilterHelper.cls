public with sharing class AutoSubscriberFilterHelper {
    public static Boolean filterProgramPlan(String methodTocall, Student_Program_Plan__c planToCheck) {
        switch on methodToCall {
            when 'Graduate_College' {
                return graduateCollegeForStudentProgramPlan(planToCheck);
            }
            when else {
                return false;
            }
        }
    }

    public static Boolean filterCampaignMember(String methodTocall, CampaignMember memberToCheck) {
        switch on methodToCall {
            when 'Access_Asu' {
                return accessAsuForCampaignMember(memberToCheck);
            }
            when else {
                return false;
            }
        }
    }

    public static Boolean graduateCollegeForStudentProgramPlan(Student_Program_Plan__c planToCheck) {
        if (
            planToCheck.Career__c == 'Graduate' &&
            planToCheck.Status__c == 'Active In Program' &&
            planToCheck.Plan_Code__c != 'PRISEPGR' &&
            planToCheck.Plan_Code__c != 'GRPLUS' &&
            (planToCheck.Plan_Code__c == null || !planToCheck.Plan_Code__c.contains('GERT')) &&
            (planToCheck.Plan_Description__c == null || !planToCheck.Plan_Description__c.contains('UG'))
        ) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean accessAsuForCampaignMember(CampaignMember memberToCheck) {
        if (
            AutoSubscriberHelper.campaignToRecordTypeName.get(memberToCheck.CampaignId) == 'EOSS Event' &&
            AutoSubscriberHelper.contactToCareer.get(memberToCheck.ContactId) == 'Undergraduate'
        ) {
            return true;
        } else {
            return false;
        }
    }
}
