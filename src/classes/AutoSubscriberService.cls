public with sharing class AutoSubscriberService {
    List<sObject> recordsToProcess {get; set;}
    String typeOfObject;
    Map<Auto_Subscriber_Setting__mdt, List<String>> settingToSubscription;
    Map<Id, List<Subscriber__c>> contactToSubscriber;

    public AutoSubscriberService(List<sObject> recordsToProcess, String typeOfObject) {
        settingToSubscription = new Map<Auto_Subscriber_Setting__mdt, List<String>>();
        contactToSubscriber = new Map<Id, List<Subscriber__c>>();
        this.recordsToProcess = recordsToProcess;
        this.typeOfObject = typeOfObject;

        createSubscriptionMap();
    }

    private void createSubscriptionMap() {
        List<Auto_Subscriber_Setting__mdt> subscriberSettings = [
            SELECT Subscriptions_To_Add__c, DeveloperName
            FROM Auto_Subscriber_Setting__mdt
            WHERE Active__c = true AND
            Related_Object__r.DeveloperName =: typeOfObject
        ];

        for (Auto_Subscriber_Setting__mdt subSetting : subscriberSettings) {
            List<String> subscriptionIds = new List<String>();

            if (subSetting.Subscriptions_To_Add__c != null) {
                subscriptionIds = subSetting.Subscriptions_To_Add__c.split(',');
            }

            settingToSubscription.put(subSetting, subscriptionIds);
        }
    }

    public void processStudentProgramPlanRecords() {
        List<Student_Program_Plan__c> convertedRecordsToProcess = (List<Student_Program_Plan__c>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        buildContactToSubscriberMapWithProgramPlan(convertedRecordsToProcess);

        for (Student_Program_Plan__c programPlan : convertedRecordsToProcess) {
            for (Auto_Subscriber_Setting__mdt subSetting : settingToSubscription.keyset()) {
                if (AutoSubscriberFilterHelper.filterProgramPlan(subSetting.DeveloperName, programPlan)) {
                    subsToCreate.addAll(createSubscriberForProgramPlan(programPlan, settingToSubscription.get(subSetting)));
                }
            }
        }

        if (!subsToCreate.isEmpty()) {
            upsert subsToCreate;
        }
    }

    public void processCampaignMemberRecords() {
        List<CampaignMember> convertedRecordsToProcess = (List<CampaignMember>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();
        buildContactToSubscriberMapWithCampaignMember(convertedRecordsToProcess);

        for (CampaignMember member : convertedRecordsToProcess) {
            for (Auto_Subscriber_Setting__mdt subSetting : settingToSubscription.keyset()) {
                if (AutoSubscriberFilterHelper.filterCampaignMember(subSetting.DeveloperName, member)) {
                    subsToCreate.addAll(createSubscriberForCampaignMember(member, settingToSubscription.get(subSetting)));
                }
            }
        }

        if (!subsToCreate.isEmpty()) {
            upsert subsToCreate;
        }
    }

    private List<Subscriber__c> createSubscriberForProgramPlan(Student_Program_Plan__c programPlan, List<String> subList) {
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();

        for (String subscriptionId : subList) {
            Subscriber__c subFromProgramPlan = new Subscriber__c();
            subFromProgramPlan.Subscription__c = subscriptionId;
            subFromProgramPlan.Contact__c = programPlan.Contact__c;
            subFromProgramPlan.Subscriber_Status__c = 'Subscribed';

            if (shouldNewSubBeUpserted(subFromProgramPlan)) {
                subsToCreate.add(subFromProgramPlan);
            }
            
        }
        
        
        return subsToCreate;
    }

    private List<Subscriber__c> createSubscriberForCampaignMember(CampaignMember member, List<String> subList) {
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();

        for (String subscriptionId : subList) {
            if (member.ContactId != null) {
                Subscriber__c subFromProgramPlan = new Subscriber__c();
                subFromProgramPlan.Subscription__c = subscriptionId;
                subFromProgramPlan.Contact__c = member.ContactId;
                subFromProgramPlan.Subscriber_Status__c = 'Subscribed';

                if (shouldNewSubBeUpserted(subFromProgramPlan)) {
                    subsToCreate.add(subFromProgramPlan);
                }
            }
            
        }
        
        
        return subsToCreate;
    }

    private void buildContactToSubscriberMapWithProgramPlan(List<Student_Program_Plan__c> programPlans) {
        Set<Id> contactsFromPlans = new Set<Id>();
        for (Student_Program_Plan__c plan : programPlans) {
            contactsFromPlans.add(plan.Contact__c);
        }

        List<Subscriber__c> subsForContacts = [
            SELECT Id, Contact__c, Subscription__c, Subscriber_Status__c
            FROM Subscriber__c
            WHERE Contact__c IN: contactsFromPlans
            ORDER BY Contact__c
        ];
        
        if (!subsForContacts.isEmpty()) {
            Id currentContact = subsForContacts[0].Contact__c;
            List<Subscriber__c> subsForSpecificContact = new List<Subscriber__c>();
            for (Subscriber__c sub : subsForContacts) {
                if (currentContact == sub.Contact__c) {
                    subsForSpecificContact.add(sub);
                } else {
                    contactToSubscriber.put(currentContact, subsForSpecificContact);
                    subsForSpecificContact = new List<Subscriber__c>();
                    subsForSpecificContact.add(sub);
                }
            }
            contactToSubscriber.put(currentContact, subsForSpecificContact);
        }
    }

    private void buildContactToSubscriberMapWithCampaignMember(List<CampaignMember> campaignMemberList) {
        Set<Id> contactsFromCampaignMembers = new Set<Id>();
        for (CampaignMember member : campaignMemberList) {
            contactsFromCampaignMembers.add(member.ContactId);
        }

        List<Subscriber__c> subsForContacts = [
            SELECT Id, Contact__c, Subscription__c, Subscriber_Status__c
            FROM Subscriber__c
            WHERE Contact__c IN: contactsFromCampaignMembers
            ORDER BY Contact__c
        ];
        
        if (!subsForContacts.isEmpty()) {
            Id currentContact = subsForContacts[0].Contact__c;
            List<Subscriber__c> subsForSpecificContact = new List<Subscriber__c>();
            for (Subscriber__c sub : subsForContacts) {
                if (currentContact == sub.Contact__c) {
                    subsForSpecificContact.add(sub);
                } else {
                    contactToSubscriber.put(currentContact, subsForSpecificContact);
                    subsForSpecificContact = new List<Subscriber__c>();
                    subsForSpecificContact.add(sub);
                }
            }
            contactToSubscriber.put(currentContact, subsForSpecificContact);
        }
    }

    private Boolean shouldNewSubBeUpserted(Subscriber__c newSub) {
        List<Subscriber__c> currentSubsForContact = contactToSubscriber.get(newSub.Contact__c);

        if (currentSubsForContact == null || currentSubsForContact.isEmpty()) {
            return true;
        }

        for (Subscriber__c sub : currentSubsForContact) {
            if (newSub.Subscription__c == sub.Subscription__c) {
                if (sub.Subscriber_Status__c == 'No Preference') {
                    newSub.Id = sub.Id;
                    return true;
                } else {
                    return false;
                }
            }
        }

        return true;
    }
}
