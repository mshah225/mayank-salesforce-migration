public with sharing class AutoSubscriberService {
    List<sObject> recordsToProcess { get; set; }
    AutoSubscriberHelper helper;
    @TestVisible
    List<Database.UpsertResult> results;

    public AutoSubscriberService(List<sObject> recordsToProcess, String typeOfObject) {
        this.recordsToProcess = recordsToProcess;
        helper = new AutoSubscriberHelper(typeOfObject);
    }

    public void processStudentProgramPlanRecords() {
        List<Student_Program_Plan__c> convertedRecordsToProcess = (List<Student_Program_Plan__c>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        List<Id> subscriptionIdsForSubs = new List<Id>();
        helper.buildContactToSubscriberMapWithProgramPlan(convertedRecordsToProcess);

        for (Auto_Subscriber_Setting__mdt subSetting : helper.settingToSubscription.keyset()) {
            subscriptionIdsForSubs.addAll(helper.settingToSubscription.get(subSetting));
        }

        helper.createSubscriptionParentMap(subscriptionIdsForSubs);

        for (Student_Program_Plan__c programPlan : convertedRecordsToProcess) {
            for (Auto_Subscriber_Setting__mdt subSetting : helper.settingToSubscription.keyset()) {
                if (AutoSubscriberFilterHelper.filterProgramPlan(subSetting.DeveloperName, programPlan)) {
                    subsToCreate.addAll(
                        helper.createSubscriber(programPlan.Contact__c, helper.settingToSubscription.get(subSetting))
                    );
                }
            }
        }

        if (!subsToCreate.isEmpty()) {
            results = Database.upsert(subsToCreate, false);
        }
    }

    public void processCampaignMemberRecords() {
        List<CampaignMember> convertedRecordsToProcess = (List<CampaignMember>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        List<Id> subscriptionIdsForSubs = new List<Id>();
        helper.buildContactToSubscriberMapWithCampaignMember(convertedRecordsToProcess);
        helper.setCampaignAndOpportunityInformation(convertedRecordsToProcess);

        for (Auto_Subscriber_Setting__mdt subSetting : helper.settingToSubscription.keyset()) {
            subscriptionIdsForSubs.addAll(helper.settingToSubscription.get(subSetting));
        }

        helper.createSubscriptionParentMap(subscriptionIdsForSubs);

        for (CampaignMember member : convertedRecordsToProcess) {
            for (Auto_Subscriber_Setting__mdt subSetting : helper.settingToSubscription.keyset()) {
                if (AutoSubscriberFilterHelper.filterCampaignMember(subSetting.DeveloperName, member)) {
                    subsToCreate.addAll(
                        helper.createSubscriber(member.ContactId, helper.settingToSubscription.get(subSetting))
                    );
                }
            }
        }

        if (!subsToCreate.isEmpty()) {
            results = Database.upsert(subsToCreate, false);
        }
    }
}
