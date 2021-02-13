public with sharing class IndividualEmailResultService {
    public static void enforceOwnerPolicies(et4ae5__IndividualEmailResult__c ier) {
        ier.OwnerId = ier.Apex_Owner_Should_Be__c;
        ier.Private_in_Salesforce__c = Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c);
    }
}
