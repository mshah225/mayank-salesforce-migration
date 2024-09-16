public with sharing class SubscriberAutoSubscriptionService {
    public List<sObject> recordsToProcess { get; set; }
    public SubscriberAutoSubscriptionHelper helper;
    public List<Database.UpsertResult> results = new List<Database.UpsertResult>();

    @TestVisible
    private static Boolean disableAutoSubscriptions = false;

    /**
     * Constructor to initialize the service with records to process and the object type.
     *
     * @param recordsToProcess List of records to process.
     * @param typeOfObject Type of the object being processed.
     */
    public SubscriberAutoSubscriptionService(List<sObject> recordsToProcess, String typeOfObject) {
        this.recordsToProcess = recordsToProcess;
        helper = new SubscriberAutoSubscriptionHelper(typeOfObject);
    }

    /**
     * Processes relationship records to create subscribers based on predefined mappings.
     */
    public void processRelationshipRecords() {
        List<Relationship__c> convertedRecordsToProcess = (List<Relationship__c>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        List<Id> subscriptionIdsForSubs = new List<Id>();
        helper.buildContactToSubscriberMapWithRelationship(convertedRecordsToProcess);

        for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : helper.settingToSubscription.keySet()) {
            subscriptionIdsForSubs.addAll(helper.settingToSubscription.get(subSetting));
        }

        helper.createSubscriptionParentMap(subscriptionIdsForSubs);

        for (Relationship__c relationship : convertedRecordsToProcess) {
            for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : helper.settingToSubscription.keySet()) {
                if (filterRelationshipByCriteria(subSetting.DeveloperName, relationship)) {
                    subsToCreate.addAll(
                        helper.createSubscriber(relationship.Contact__c, helper.settingToSubscription.get(subSetting))
                    );
                }
            }
        }

        if (!subsToCreate.isEmpty() && !disableAutoSubscriptions) {
            results = Database.upsert(subsToCreate, false);
        }
    }

    /**
     * Filters relationships based on specific criteria.
     *
     * @param methodToCall Name of the method to call for filtering.
     * @param relationshipToCheck The relationship to check against the criteria.
     * @return True if the relationship meets the criteria, false otherwise.
     */
    @TestVisible
    private Boolean filterRelationshipByCriteria(String methodToCall, Relationship__c relationshipToCheck) {
        if (String.isBlank(methodToCall) || relationshipToCheck == null) {
            return false;
        } else {
            return (methodToCall == 'Access_ASU_Parent'
                ? (relationshipToCheck?.Relationship_Type__c == 'Parent/Guardian' &&
                  relationshipToCheck?.Source__c == 'Access ASU Program')
                : false);
        }
    }

    /**
     * Processes student program plan records to create subscribers based on predefined mappings.
     */
    public void processStudentProgramPlanRecords() {
        List<Student_Program_Plan__c> convertedRecordsToProcess = (List<Student_Program_Plan__c>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        List<Id> subscriptionIdsForSubs = new List<Id>();
        helper.buildContactToSubscriberMapWithProgramPlan(convertedRecordsToProcess);

        for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : helper.settingToSubscription.keySet()) {
            subscriptionIdsForSubs.addAll(helper.settingToSubscription.get(subSetting));
        }

        if (!subscriptionIdsForSubs.isEmpty()) {
            helper.createSubscriptionParentMap(subscriptionIdsForSubs);
        }

        for (Student_Program_Plan__c programPlan : convertedRecordsToProcess) {
            for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : helper.settingToSubscription.keySet()) {
                if (filterProgramPlanByCriteria(subSetting.DeveloperName, programPlan)) {
                    subsToCreate.addAll(
                        helper.createSubscriber(programPlan.Contact__c, helper.settingToSubscription.get(subSetting))
                    );
                }
            }
        }

        if (!subsToCreate.isEmpty() && !disableAutoSubscriptions) {
            results = Database.upsert(subsToCreate, false);
        }
    }

    /**
     * Filters student program plans based on specific criteria.
     *
     * @param methodToCall Name of the method to call for filtering.
     * @param planToCheck The program plan to check against the criteria.
     * @return True if the program plan meets the criteria, false otherwise.
     */
    @TestVisible
    private Boolean filterProgramPlanByCriteria(String methodToCall, Student_Program_Plan__c planToCheck) {
        if (String.isBlank(methodToCall) || planToCheck == null) {
            return false;
        } else {
            return (methodToCall == 'Graduate_College'
                ? (planToCheck?.Career__c == 'Graduate' &&
                  planToCheck?.Status__c == 'Active In Program' &&
                  planToCheck?.Plan_Code__c != 'PRISEPGR' &&
                  planToCheck?.Plan_Code__c != 'GRPLUS' &&
                  (planToCheck?.Plan_Code__c == null || !planToCheck?.Plan_Code__c.contains('GERT')) &&
                  (planToCheck?.Plan_Description__c == null || !planToCheck?.Plan_Description__c.contains('UG')))
                : false);
        }
    }

    /**
     * Processes campaign member records to create subscribers based on predefined mappings.
     */
    public void processCampaignMemberRecords() {
        List<CampaignMember> convertedRecordsToProcess = (List<CampaignMember>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        List<Id> subscriptionIdsForSubs = new List<Id>();
        helper.buildContactToSubscriberMapWithCampaignMember(convertedRecordsToProcess);
        helper.setCampaignAndOpportunityInformation(convertedRecordsToProcess);

        for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : helper.settingToSubscription.keySet()) {
            subscriptionIdsForSubs.addAll(helper.settingToSubscription.get(subSetting));
        }

        helper.createSubscriptionParentMap(subscriptionIdsForSubs);

        for (CampaignMember member : convertedRecordsToProcess) {
            for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : helper.settingToSubscription.keySet()) {
                if (filterCampaignMemberByCriteria(subSetting.DeveloperName, member)) {
                    subsToCreate.addAll(
                        helper.createSubscriber(member.ContactId, helper.settingToSubscription.get(subSetting))
                    );
                }
            }
        }

        if (!subsToCreate.isEmpty() && !disableAutoSubscriptions) {
            results = Database.upsert(subsToCreate, false);
        }
    }

    /**
     * Filters campaign members based on specific criteria.
     *
     * @param methodToCall Name of the method to call for filtering.
     * @param memberToCheck The campaign member to check against the criteria.
     * @return True if the campaign member meets the criteria, false otherwise.
     */
    @TestVisible
    private Boolean filterCampaignMemberByCriteria(String methodToCall, CampaignMember memberToCheck) {
        if (String.isBlank(methodToCall) || memberToCheck == null) {
            return false;
        } else {
            return (methodToCall == 'Access_Asu'
                ? SubscriberAutoSubscriptionHelper.campaignToRecordTypeName.get(memberToCheck?.CampaignId) ==
                  'EOSS Event' &&
                  SubscriberAutoSubscriptionHelper.contactToCareer.get(memberToCheck?.ContactId) == 'Undergraduate'
                : false);
        }
    }
}