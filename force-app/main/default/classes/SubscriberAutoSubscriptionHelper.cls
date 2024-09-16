public with sharing class SubscriberAutoSubscriptionHelper {
    String typeOfObject;
    public Map<Subscriber_Auto_Subscription_Mapping__mdt, List<String>> settingToSubscription;
    @TestVisible
    Map<Id, List<Subscriber__c>> contactToSubscriber;
    public static Map<Id, String> campaignToRecordTypeName;
    public static Map<Id, String> contactToCareer;
    public static Map<Id, String> subscriptionToParent;

    /**
     * Constructor to initialize the helper with the object type.
     *
     * @param typeOfObject Type of the object being processed.
     */
    public SubscriberAutoSubscriptionHelper(String typeOfObject) {
        settingToSubscription = new Map<Subscriber_Auto_Subscription_Mapping__mdt, List<String>>();
        contactToSubscriber = new Map<Id, List<Subscriber__c>>();
        this.typeOfObject = typeOfObject;
        createSubscriptionMap();
    }

    /**
     * Creates a map of subscription settings to subscriptions.
     */
    private void createSubscriptionMap() {
        List<Subscriber_Auto_Subscription_Mapping__mdt> subscriberSettings = [
            SELECT Subscriptions_To_Add__c, DeveloperName
            FROM Subscriber_Auto_Subscription_Mapping__mdt
            WHERE Active__c = TRUE AND Related_Object__r.DeveloperName = :typeOfObject
        ];

        for (Subscriber_Auto_Subscription_Mapping__mdt subSetting : subscriberSettings) {
            List<String> subscriptionIds = new List<String>();

            if (subSetting.Subscriptions_To_Add__c != null) {
                subscriptionIds = subSetting.Subscriptions_To_Add__c.split(',');
            }

            settingToSubscription.put(subSetting, subscriptionIds);
        }
    }

    /**
     * Creates a map of subscription IDs to their parent subscriptions.
     *
     * @param subscriptionIds List of subscription IDs.
     */
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

    /**
     * Creates subscriber records for the given contact and subscription list.
     *
     * @param contactId Contact ID.
     * @param subList List of subscription IDs.
     * @return List of created subscriber records.
     */
    public List<Subscriber__c> createSubscriber(Id contactId, List<String> subList) {
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();

        for (String subscriptionId : subList) {
            Subscriber__c newSub = new Subscriber__c();
            newSub.Subscription__c = subscriptionId;
            newSub.Contact__c = contactId;
            newSub.Subscriber_Status__c = 'Subscribed';

            if (shouldNewSubBeUpserted(newSub)) {
                subsToCreate.add(newSub);
            }
        }

        return subsToCreate;
    }

    /**
     * Builds a map of contacts to their subscribers based on relationships.
     *
     * @param relationships List of relationship records.
     */
    public void buildContactToSubscriberMapWithRelationship(List<Relationship__c> relationships) {
        Set<Id> contactsFromRelationships = new Set<Id>();
        for (Relationship__c relationship : relationships) {
            if (relationship.Contact__c != null) {
                contactsFromRelationships.add(relationship.Contact__c);
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
            WHERE Contact__c IN :contactsFromRelationships
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

    /**
     * Builds a map of contacts to their subscribers based on program plans.
     *
     * @param programPlans List of program plan records.
     */
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

    /**
     * Builds a map of contacts to their subscribers based on campaign members.
     *
     * @param campaignMemberList List of campaign member records.
     */
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

    /**
     * Sets campaign and opportunity information for the given campaign members.
     *
     * @param campaignMemberList List of campaign member records.
     */
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

    /**
     * Sets career information for the given contacts based on their opportunities.
     *
     * @param contactIds Set of contact IDs.
     */
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

    /**
     * Sets campaign record type names for the given campaigns.
     *
     * @param campaignFromCampaignMembers Set of campaign IDs.
     */
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

    /**
     * Determines if a new subscriber should be upserted.
     *
     * @param newSub The subscriber to check.
     * @return True if the subscriber should be upserted, false otherwise.
     */
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