public with sharing class AutoSubscriberHelper {
    String typeOfObject;
    public Map<Auto_Subscriber_Setting__mdt, List<String>> settingToSubscription;
    Map<Id, List<Subscriber__c>> contactToSubscriber;
    public static Map<Id, String> campaignToRecordTypeName;
    public static Map<Id, String> contactToCareer;
    public static Map<Id, String> subscriptionToParent;

    public AutoSubscriberHelper(String typeOfObject) {
        settingToSubscription = new Map<Auto_Subscriber_Setting__mdt, List<String>>();
        contactToSubscriber = new Map<Id, List<Subscriber__c>>();
        this.typeOfObject = typeOfObject;

        createSubscriptionMap();
    }

    private void createSubscriptionMap() {
        List<Auto_Subscriber_Setting__mdt> subscriberSettings = [
            SELECT Subscriptions_To_Add__c, DeveloperName
            FROM Auto_Subscriber_Setting__mdt
            WHERE Active__c = TRUE AND Related_Object__r.DeveloperName = :typeOfObject
        ];

        for (Auto_Subscriber_Setting__mdt subSetting : subscriberSettings) {
            List<String> subscriptionIds = new List<String>();

            if (subSetting.Subscriptions_To_Add__c != null) {
                subscriptionIds = subSetting.Subscriptions_To_Add__c.split(',');
            }

            settingToSubscription.put(subSetting, subscriptionIds);
        }
    }

    public void createSubscriptionParentMap(List<Id> subscriptionIds) {
        subscriptionToParent = new Map<Id, String>();
        List<Subscription__c> subscriptionsForSubs = [
            SELECT Id, Parent_Subscription__c
            FROM Subscription__c
            WHERE Id IN :subscriptionIds
        ];

        for (Subscription__c sub : subscriptionsForSubs) {
            if (sub.Parent_Subscription__c != null) {
                subscriptionToParent.put(sub.Id, sub.Parent_Subscription__c);
            }
        }
    }

    public List<Subscriber__c> createSubscriber(Id contactId, List<String> subList) {
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();

        for (String subscriptionId : subList) {
            Subscriber__c subFromProgramPlan = new Subscriber__c();
            subFromProgramPlan.Subscription__c = subscriptionId;
            subFromProgramPlan.Contact__c = contactId;
            subFromProgramPlan.Subscriber_Status__c = 'Subscribed';

            if (shouldNewSubBeUpserted(subFromProgramPlan)) {
                subsToCreate.add(subFromProgramPlan);
            }
        }

        return subsToCreate;
    }

    public void buildContactToSubscriberMapWithProgramPlan(List<Student_Program_Plan__c> programPlans) {
        Set<Id> contactsFromPlans = new Set<Id>();
        for (Student_Program_Plan__c plan : programPlans) {
            if (plan.Contact__c != null) {
                contactsFromPlans.add(plan.Contact__c);
            }
        }

        List<Subscriber__c> subsForContacts = [
            SELECT
                Id,
                Contact__c,
                Subscription__c,
                Subscriber_Status__c,
                Subscription__r.Id,
                Subscription__r.Parent_Subscription__c,
                Subscription__r.Subscription_Type__c
            FROM Subscriber__c
            WHERE Contact__c IN :contactsFromPlans
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

    public void buildContactToSubscriberMapWithCampaignMember(List<CampaignMember> campaignMemberList) {
        Set<Id> contactsFromCampaignMembers = new Set<Id>();
        for (CampaignMember member : campaignMemberList) {
            if (member.ContactId != null) {
                contactsFromCampaignMembers.add(member.ContactId);
            }
        }

        List<Subscriber__c> subsForContacts = [
            SELECT
                Id,
                Contact__c,
                Subscription__c,
                Subscriber_Status__c,
                Subscription__r.Id,
                Subscription__r.Parent_Subscription__c,
                Subscription__r.Subscription_Type__c
            FROM Subscriber__c
            WHERE Contact__c IN :contactsFromCampaignMembers
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

    public void setCampaignAndOpportunityInformation(List<CampaignMember> campaignMemberList) {
        Set<Id> contactsFromCampaignMembers = new Set<Id>();
        Set<Id> campaignFromCampaignMembers = new Set<Id>();
        for (CampaignMember member : campaignMemberList) {
            if (member.ContactId != null) {
                contactsFromCampaignMembers.add(member.ContactId);
            }
            if (member.CampaignId != null) {
                campaignFromCampaignMembers.add(member.CampaignId);
            }
        }

        setCareerFromOpportunity(contactsFromCampaignMembers);
        setCampaignRecordTypeName(campaignFromCampaignMembers);
    }

    private void setCareerFromOpportunity(Set<Id> contactIds) {
        List<Opportunity> opportunityForContacts = [
            SELECT Career__c, Contact__r.Id
            FROM Opportunity
            WHERE Contact__c IN :contactIds
            ORDER BY LastModifiedDate ASC
        ];

        contactToCareer = new Map<Id, String>();

        for (Opportunity oppWithCareer : opportunityForContacts) {
            contactToCareer.put(oppWithCareer.Contact__r.Id, oppWithCareer.Career__c);
        }
    }

    private void setCampaignRecordTypeName(Set<Id> campaignFromCampaignMembers) {
        List<Campaign> campaignsFromMembers = [
            SELECT RecordType.Name
            FROM Campaign
            WHERE Id IN :campaignFromCampaignMembers
        ];

        campaignToRecordTypeName = new Map<Id, String>();
        for (Campaign campaignWithName : campaignsFromMembers) {
            campaignToRecordTypeName.put(campaignWithName.Id, campaignWithName.RecordType.Name);
        }
    }

    private Boolean shouldNewSubBeUpserted(Subscriber__c newSub) {
        List<Subscriber__c> currentSubsForContact = contactToSubscriber.get(newSub.Contact__c);

        Set<Id> unsubscribedParentIds = new Set<Id>();

        if (currentSubsForContact == null || currentSubsForContact.isEmpty()) {
            return true;
        }

        for (Subscriber__c sub : currentSubsForContact) {
            if (
                sub.Subscription__r.Subscription_Type__c == 'Business Unit' &&
                sub.Subscriber_Status__c == 'Unsubscribed'
            ) {
                unsubscribedParentIds.add(sub.Subscription__r.Id);
            }
        }

        if (unsubscribedParentIds.contains(subscriptionToParent.get(newSub.Subscription__c))) {
            return false;
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
