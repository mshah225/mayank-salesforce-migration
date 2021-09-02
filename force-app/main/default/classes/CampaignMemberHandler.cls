public without sharing class CampaignMemberHandler extends AbstractTriggerHandler {
    private Map<Id, List<CampaignMember>> campaignMembersByContact = new Map<Id, List<CampaignMember>>();
    private Map<Id, List<CampaignMember>> campaignMembersByLead = new Map<Id, List<CampaignMember>>();
    private static Map<Id, Opportunity> opportunitiesByContact = new Map<Id, Opportunity>();
    private Set<Id> memberIds = new Set<Id>();
    private Set<CampaignMember> membersToMarkNotPrimary = new Set<CampaignMember>();
    private Set<CampaignMember> membersToMarkPrimary = new Set<CampaignMember>();
    private static Set<CampaignMember> externalMemberstoMarkNotPrimary = new Set<CampaignMember>();
    private static Set<CampaignMember> externalMemberstoMarkPrimary = new Set<CampaignMember>();
    private static Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
    private static List<Lead> leadsToUpdate = new List<Lead>();
    private static Boolean ranCampaignMembersUpdatePrimary = false;

    private Set<Id> contactIdsInTrigger = new Set<Id>();
    private Set<Id> leadIdsInTrigger = new Set<Id>();
    private List<CampaignMember> membersInTriggerWithContacts = new List<CampaignMember>();
    private List<CampaignMember> membersInTriggerWithLeads = new List<CampaignMember>();
    private Map<Id, String> campaignRecordTypesById = new Map<Id, String>();
    private List<String> userAvailableBusinessUnits = new List<string>();
    private Map<Id, List<CampaignMember>> campaignIdToMembers = new Map<Id, List<CampaignMember>>();
    private List<Profile> exceptions = [
        SELECT Id
        FROM Profile
        WHERE Name = 'Unsubscribe Profile' OR Name = 'System Administrator'
    ];
    private List<CampaignMember> affectedCampaignMembers;
    private Set<CampaignMember> setOfAffectedMembers;

    private static final Set<String> NATIONAL_MERIT_CAMPAIGN_NAMES = new Set<String>{
        'National Achievement Finalist',
        'National Achievement Semifinalist',
        'National Hispanic Scholar Finalist',
        'National Merit Finalist',
        'National Merit Semifinalist',
        'Gammage Scholar',
        'Flinn Designate',
        'Flinn Semifinalist',
        'Flinn Finalist'
    };

    private static final Set<String> ACCEPTABLE_MAJORS = new Set<String>{
        'PSMajors',
        'Academic',
        'ASU Colleges',
        'Degree Search by Interest'
    };

    public CampaignMemberHandler() {
    }

    public override void beforeInsert() {
        System.debug('CARL');
        if (!ranCampaignMembersUpdatePrimary) {
            affectedCampaignMembers = Trigger.new;
            processingBefore();
        }

        for (CampaignMember member : (List<CampaignMember>) Trigger.new) {
            if (membersToMarkNotPrimary.contains(member)) {
                member.Is_Primary_Interest__c = false;
            }
            if (membersToMarkPrimary.contains(member)) {
                member.Is_Primary_Interest__c = true;
            }
            if (member.ContactId != null) {
                Opportunity opportunity = opportunitiesByContact.get(member.ContactId);
                if (opportunity != null) {
                    member.Opportunity__c = opportunity.Id;
                }
            }
        }
    }

    public override void afterInsert() {
        Set<Id> memberIdsInTrigger = Trigger.newMap.keySet();
        assignNationalMeritFlag(memberIdsInTrigger);
        List<CampaignMember> campaignMembersToUpdate = setPrimaryInterestOnCampaignMembers();
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(campaignMembersToUpdate);
        AutoSubscriberService autoSubService = new AutoSubscriberService(Trigger.New, 'CampaignMember');
        autoSubService.processCampaignMemberRecords();
        clearDataAfter();
    }

    public override void beforeUpdate() {
        if (!ranCampaignMembersUpdatePrimary) {
            affectedCampaignMembers = Trigger.new;
            processingBefore();
        }

        for (CampaignMember oldMember : (List<CampaignMember>) Trigger.old) {
            CampaignMember member = (CampaignMember) Trigger.newMap.get(oldMember.Id);
            if (oldMember.Status != 'No Longer Interested' && member.Status == 'No Longer Interested') {
                member.Is_Primary_Interest__c = false;
            }
            if (membersToMarkNotPrimary.contains(member)) {
                member.Is_Primary_Interest__c = false;
            }
            if (membersToMarkPrimary.contains(member)) {
                member.Is_Primary_Interest__c = true;
            }
        }
    }

    public override void afterUpdate() {
        Set<Id> memberIdsInTrigger = Trigger.newMap.keySet();
        assignNationalMeritFlag(memberIdsInTrigger);
        List<CampaignMember> campaignMembersToUpdate = setPrimaryInterestOnCampaignMembers();
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(campaignMembersToUpdate);
        clearDataAfter();
    }

    public override void beforeDelete() {
        if (!ranCampaignMembersUpdatePrimary) {
            affectedCampaignMembers = Trigger.old;
            processingBefore();
        }
    }

    public override void afterDelete() {
        Set<Id> memberIdsInTrigger = Trigger.oldMap.keySet();
        assignNationalMeritFlag(memberIdsInTrigger);
        List<CampaignMember> campaignMembersToUpdate = setPrimaryInterestOnCampaignMembers();
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(campaignMembersToUpdate);
        clearDataAfter();
    }

    /**
     * processingBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void processingBefore() {
        for (CampaignMember campaignMember : affectedCampaignMembers) {
            organizeDataBefore(campaignMember);
        }
        getUserPermissionsByBusinessUnit();
        checkSecurityOnCampaign();
        getRelatedCampaignMembers();
        setOfAffectedMembers = new Set<CampaignMember>(affectedCampaignMembers);
        if (!campaignMembersByContact.isEmpty()) {
            processContacts();
        }
        if (!campaignMembersByLead.isEmpty()) {
            processLeads();
        }
    }

    private void organizeDataBefore(CampaignMember member) {
        //Add the CM ID to a set
        memberIds.add(member.Id);

        //Add the CM's campaign ID to the set
        if (campaignIdToMembers.get(member.CampaignId) == null) {
            campaignIdToMembers.put(member.CampaignId, new List<CampaignMember>());
        }
        campaignIdToMembers.get(member.CampaignId).add(member);

        //If the CM has a contact, add the Contact ID to the set
        if (member.ContactId != null) {
            contactIdsInTrigger.add(member.ContactId);
            membersInTriggerwithContacts.add(member);
            if (!campaignMembersByContact.containsKey(member.ContactId)) {
                campaignMembersByContact.put(member.ContactId, new List<CampaignMember>());
            }
        }

        //If the CM has a lead, add the Lead ID to the set
        if (member.LeadId != null) {
            leadIdsInTrigger.add(member.LeadId);
            membersInTriggerWithLeads.add(member);
            if (!campaignMembersByLead.containsKey(member.LeadId)) {
                campaignMembersByLead.put(member.LeadId, new List<CampaignMember>());
            }
        }

        //Deal with updating the Last Member Status Change
        if (Trigger.isInsert) {
            if (member.Last_Member_Status_Change__c == null) {
                member.Last_Member_Status_Change__c = Datetime.now();
            }
        } else if (Trigger.isUpdate) {
            CampaignMember oldMember = (CampaignMember) Trigger.oldMap.get(member.Id);
            if (oldMember.Status != member.Status) {
                member.Last_Member_Status_Change__c = Datetime.now();
            }
        }
    }

    // Validation to ensure that user is a member of the correct Business Unit
    // Added to ensure that a campaignMember will error if the following rule is violated
    // User MC Business Unit must match Campaign business unit in order to add a campaign
    // member to the campaign
    private void getUserPermissionsByBusinessUnit() {
        User runningUser = [SELECT MC_Business_Unit_User__c FROM User WHERE Id = :userInfo.getUserId()];
        if (runningUser.MC_Business_Unit_User__c != null) {
            userAvailableBusinessUnits = runningUser.MC_Business_Unit_User__c.split(';');
        }
    }

    private void checkSecurityOnCampaign() {
        //For all Campaigns on the CMs in this trigger, get their names and link id to name
        for (Campaign campaign : [
            SELECT Id, RecordType.DeveloperName, Marketing_Cloud_Business_Unit__r.Name
            FROM Campaign
            WHERE Id IN :campaignIdToMembers.keySet()
        ]) {
            campaignRecordTypesById.put(campaign.Id, campaign.RecordType.DeveloperName);

            if (userInfo.getProfileId() == exceptions[0].Id) {
                continue;
            }
            if (userInfo.getProfileId() == exceptions[1].Id) {
                continue;
            }
            if (campaign.RecordType.DeveloperName != 'Subscription_Center') {
                continue;
            }

            Boolean found = false;
            for (String userBusinessUnit : userAvailableBusinessUnits) {
                if (campaign.Marketing_Cloud_Business_Unit__r.Name == userBusinessUnit) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                for (CampaignMember campaignMember : campaignIdToMembers.get(campaign.Id)) {
                    campaignMember.addError('Cannot insert Campaign Members for campaigns outside your business unit');
                }
            }
        }
    }

    private void getRelatedCampaignMembers() {
        //Get the list of CMs on the contacts and leads. Ignore any that are in this trigger, they will be added in later
        List<CampaignMember> membersForContactsOrLeads = [
            SELECT
                Id,
                CampaignId,
                Status,
                CreatedDate,
                ContactId,
                LeadId,
                Is_Primary_Interest__c,
                Last_Member_Status_Change__c,
                Campaign_Type__c,
                Campaign.RecordType.DeveloperName
            FROM CampaignMember
            WHERE
                (ContactId IN :contactIdsInTrigger
                OR LeadId IN :leadIdsInTrigger)
                AND Id NOT IN :memberIds
                AND Status != 'No Longer Interested'
                AND Campaign.RecordType.DeveloperName = 'Interest'
                AND Campaign.Type IN :ACCEPTABLE_MAJORS
        ];

        //Parse the Contact and Lead CMs into maps
        for (CampaignMember addedCampaignMembers : membersForContactsOrLeads) {
            if (contactIdsInTrigger.contains(addedCampaignMembers.ContactId)) {
                campaignMembersByContact.get(addedCampaignMembers.ContactId).add(addedCampaignMembers);
            }

            if (leadIdsInTrigger.contains(addedCampaignMembers.LeadId)) {
                campaignMembersByLead.get(addedCampaignMembers.LeadId).add(addedCampaignMembers);
            }
        }
    }

    //We now have the CMs attached to all affected Contacts / Leads queued up
    //We need to go through each Contact / Lead, and reset the primary for each set of CMs
    //Reset the primary for the Contacts
    private void processContacts() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (CampaignMember member : membersInTriggerWithContacts) {
                if (
                    ACCEPTABLE_MAJORS.contains(member.Campaign_Type__c) &&
                    campaignRecordTypesById.get(member.CampaignId) == 'Interest' &&
                    member.Status != 'No Longer Interested'
                ) {
                    if (campaignMembersByContact.containsKey(member.ContactId)) {
                        campaignMembersByContact.get(member.ContactId).add(member);
                    } else {
                        List<CampaignMember> newList = new List<CampaignMember>();
                        newList.add(member);
                        campaignMembersByContact.put(member.ContactId, newList);
                    }
                }
            }
        }

        List<Opportunity> opportunitiesInTrigger = [
            SELECT Id, Contact__c, National_Merit_Semifinalist__c, Primary_Interest__c
            FROM Opportunity
            WHERE Contact__c IN :contactIDsInTrigger AND CloseDate > :Date.today()
            ORDER BY CreatedDate ASC
        ];

        for (Opportunity o : opportunitiesInTrigger) {
            opportunitiesByContact.put(o.Contact__c, o);
        }

        for (Id contactId : campaignMembersByContact.keySet()) {
            List<CampaignMember> membersForContact = campaignMembersByContact.get(contactId);

            //Update the Primary Interest on the CM
            CampaignMember primary;

            //Pass 1 - Find PSMajor w/ greatest Last Member Status Change
            for (CampaignMember member : membersForContact) {
                if (
                    member.Campaign_Type__c == 'PSMajors' &&
                    (primary == null ||
                    member.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) &&
                    member.Status != 'No Longer Interested'
                ) {
                    primary = member;
                }
            }

            //Pass 2 - Find any CM w/ greatest Last Member Status Change
            if (primary == null) {
                for (CampaignMember member : membersForContact) {
                    if (
                        member.Status != 'No Longer Interested' &&
                        (primary == null ||
                        member.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c)
                    ) {
                        primary = member;
                    }
                }
            }

            //By now we should have a Primary
            //There are three possibilities
            //1. None of the CMs have primary
            //2. One of the CMs has a primary, and it is the one we have identified (e.g. no change)
            //3. One of the CMs has a primary, and it is different from the one we have identified, so we must update the new and falsify the old
            if (primary != null) {
                //If the primary is in the trigger
                if (setOfAffectedMembers.contains(primary)) {
                    membersToMarkPrimary.add(primary);
                } else {
                    externalMemberstoMarkPrimary.add(primary);
                }

                for (CampaignMember member : membersForContact) {
                    if (member.Is_Primary_Interest__c == true && member != primary) {
                        if (setOfAffectedMembers.contains(member)) {
                            membersToMarkNotPrimary.add(member);
                        } else {
                            externalMemberstoMarkNotPrimary.add(member);
                        }
                    }
                }

                Opportunity opp = opportunitiesByContact.get(contactId);
                if (opp != null) {
                    if (opp.Primary_Interest__c != primary.CampaignId) {
                        opp.Primary_Interest__c = primary.CampaignId;
                        opportunitiesToUpdate.put(opp.Id, opp);
                    }
                }
            } else {
                Opportunity opp = opportunitiesByContact.get(contactId);
                if (opp != null) {
                    if (opp.Primary_Interest__c != null) {
                        opp.Primary_Interest__c = null;
                        opportunitiesToUpdate.put(opp.Id, opp);
                    }
                }
            }
        }
    }

    private void processLeads() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (CampaignMember member : membersInTriggerWithLeads) {
                if (
                    ACCEPTABLE_MAJORS.contains(member.Campaign_Type__c) &&
                    campaignRecordTypesById.get(member.CampaignId) == 'Interest' &&
                    member.Status != 'No Longer Interested'
                ) {
                    if (campaignMembersByLead.containsKey(member.LeadId)) {
                        campaignMembersByLead.get(member.LeadId).add(member);
                    } else {
                        List<CampaignMember> membersForLead = new List<CampaignMember>();
                        membersForLead.add(member);
                        campaignMembersByLead.put(member.LeadId, membersForLead);
                    }
                }
            }
        }

        Map<Id, Lead> leadsInTrigger = new Map<Id, Lead>(
            [SELECT Id, Primary_Interest__c FROM Lead WHERE Id IN :leadIdsInTrigger]
        );

        for (Id leadId : campaignMembersByLead.keySet()) {
            List<CampaignMember> leadMembers = campaignMembersByLead.get(leadId);

            //Update the Primary Interest on the CM
            CampaignMember primary;

            //Pass 1 - Find PSMajor w/ greatest Last Member Status Change
            for (CampaignMember leadMember : leadMembers) {
                if (
                    leadMember.Campaign_Type__c == 'PSMajors' &&
                    (primary == null ||
                    leadMember.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) &&
                    leadMember.Status != 'No Longer Interested'
                ) {
                    primary = leadMember;
                }
            }

            //Pass 2 - Find any CM w/ greatest Last Member Status Change
            if (primary == null) {
                for (CampaignMember leadMember : leadMembers) {
                    if (
                        leadMember.Status != 'No Longer Interested' &&
                        (primary == null ||
                        leadMember.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c)
                    ) {
                        primary = leadMember;
                    }
                }
            }

            //By now we should have a Primary
            //There are three possibilities
            //1. None of the CMs have primary
            //2. One of the CMs has a primary, and it is the one we have identified (e.g. no change)
            //3. One of the CMs has a primary, and it is different from the one we have identified, so we must update the new and falsify the old
            if (primary != null) {
                //If the primary is in the trigger
                if (setOfAffectedMembers.contains(primary)) {
                    membersToMarkPrimary.add(primary);
                } else {
                    externalMemberstoMarkPrimary.add(primary);
                }

                for (CampaignMember leadMember : leadMembers) {
                    if (leadMember.Is_Primary_Interest__c == true && leadMember != primary) {
                        if (setOfAffectedMembers.contains(leadMember)) {
                            membersToMarkNotPrimary.add(leadMember);
                        } else {
                            externalMemberstoMarkNotPrimary.add(leadMember);
                        }
                    }
                }

                Lead leadToUpdate = leadsInTrigger.get(leadId);
                if (leadToUpdate != null && leadToUpdate.Primary_Interest__c != primary.CampaignId) {
                    leadToUpdate.Primary_Interest__c = primary.CampaignId;
                    leadsToUpdate.add(leadToUpdate);
                }
            } else {
                Lead leadToUpdate = leadsInTrigger.get(leadId);
                if (leadToUpdate != null && leadToUpdate.Primary_Interest__c != null) {
                    leadToUpdate.Primary_Interest__c = null;
                    leadsToUpdate.add(leadToUpdate);
                }
            }
        }
    }

    private void assignNationalMeritFlag(Set<Id> memberIdsInTrigger) {
        for (CampaignMember nationalMeritCampaignMember : getNationalMeritCampaignMembers(memberIdsInTrigger)) {
            Opportunity nationalMeritOpportunity = opportunitiesByContact.get(nationalMeritCampaignMember.ContactId);
            setOpportunityAsNationMerit(nationalMeritOpportunity);
        }
    }

    private List<CampaignMember> getNationalMeritCampaignMembers(Set<Id> memberIdsInTrigger) {
        return [
            SELECT Id, ContactId
            FROM CampaignMember
            WHERE
                Id IN :memberIdsInTrigger
                AND ContactId != NULL
                AND Campaign.RecordType.DeveloperName = 'Scholarship'
                AND Campaign.Name IN :NATIONAL_MERIT_CAMPAIGN_NAMES
        ];
    }

    private void setOpportunityAsNationMerit(Opportunity nationalMeritOpportunity) {
        if (nationalMeritOpportunity != null && nationalMeritOpportunity.National_Merit_Semifinalist__c != true) {
            if (opportunitiesToUpdate.get(nationalMeritOpportunity.Id) != null) {
                opportunitiesToUpdate.get(nationalMeritOpportunity.Id).National_Merit_Semifinalist__c = true;
            } else if (nationalMeritOpportunity.National_Merit_Semifinalist__c != true) {
                nationalMeritOpportunity.National_Merit_Semifinalist__c = true;
                opportunitiesToUpdate.put(nationalMeritOpportunity.Id, nationalMeritOpportunity);
            }
        }
    }

    private List<CampaignMember> setPrimaryInterestOnCampaignMembers() {
        List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();
        for (CampaignMember member : externalMemberstoMarkNotPrimary) {
            if (member.Is_Primary_Interest__c != false) {
                member.Is_Primary_Interest__c = false;
                campaignMembersToUpdate.add(member);
            }
        }

        for (CampaignMember member : externalMemberstoMarkPrimary) {
            if (member.Is_Primary_Interest__c != true) {
                member.Is_Primary_Interest__c = true;
                campaignMembersToUpdate.add(member);
            }
        }

        return campaignMembersToUpdate;
    }

    private void updateOpportunities() {
        if (!opportunitiesToUpdate.isEmpty()) {
            List<Opportunity> oppsToUpdateList = new List<Opportunity>();
            oppsToUpdateList.addAll(opportunitiesToUpdate.values());
            update oppsToUpdateList;
        }
    }

    private void updateLeads() {
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    private void updateCampaignMembers(List<CampaignMember> campaignMembersToUpdate) {
        if (!campaignMembersToUpdate.isEmpty()) {
            ranCampaignMembersUpdatePrimary = true;
            update campaignMembersToUpdate;
        }
    }

    private void clearDataAfter() {
        externalMemberstoMarkPrimary = new Set<CampaignMember>();
        externalMemberstoMarkNotPrimary = new Set<CampaignMember>();
        opportunitiesToUpdate = new Map<Id, Opportunity>();
        leadsToUpdate = new List<Lead>();
    }
}
