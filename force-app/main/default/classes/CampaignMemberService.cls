public without sharing class CampaignMemberService {
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

    public CampaignMemberService() {
    }

    public void processNewMembers(List<CampaignMember> memberList) {
        processAffectedMembers(memberList);
        for (CampaignMember member : memberList) {
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

    public void processOldMembers(
        List<CampaignMember> memberList,
        Map<Id, CampaignMember> memberMap,
        List<CampaignMember> oldMemberList
    ) {
        processAffectedMembers(memberList);
        for (CampaignMember oldMember : (List<CampaignMember>) oldMemberList) {
            CampaignMember member = (CampaignMember) memberMap.get(oldMember.Id);
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

    public void processAffectedMembers(List<CampaignMember> affectedCampaignMembers) {
        if (!ranCampaignMembersUpdatePrimary) {
            for (CampaignMember campaignMember : affectedCampaignMembers) {
                organizeMemberData(campaignMember);
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
    }

    public void updateRelatedRecords(Map<Id, CampaignMember> memberMap) {
        assignNationalMeritFlag(memberMap.keySet());
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(setPrimaryInterestOnCampaignMembers());
    }

    public void updateRelatedRecords(Map<Id, CampaignMember> memberMap, List<CampaignMember> memberList) {
        updateRelatedRecords(memberMap);
        AutoSubscriberService autoSubService = new AutoSubscriberService(memberList, 'CampaignMember');
        autoSubService.processCampaignMemberRecords();
    }

    private void organizeMemberData(CampaignMember member) {
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
    //
    ////
    ////////
    ////////////////
    ////////
    ////
    //
    public static RelationWrapper filterToProperCampaignMembers(RelationWrapper wrapper) {
        RelationWrapper filteredWrapper = new RelationWrapper(wrapper);
        for (CampaignMember member : wrapper.superSetCampaignMembersMap.values()) {
            if (
                ACCEPTABLE_MAJORS.contains(member.Campaign_Type__c) &&
                wrapper.campaignIdToRecordTypeNameMap.get(member.CampaignId) == 'Interest' &&
                member.Status != 'No Longer Interested'
            ) {
                // Include
            } else {
                // Remove
                filteredWrapper.remove(member);
            }
        }
        return filteredWrapper;
    }

    public static void populateLastMemberStatusChange(
        List<CampaignMember> memberList,
        Map<Id, CampaignMember> oldMemberMap
    ) {
        for (CampaignMember member : memberList) {
            if (member.Last_Member_Status_Change__c == null) {
                member.Last_Member_Status_Change__c = System.now();
            } else if (
                oldMemberMap != null &&
                oldMemberMap.containsKey(member.Id) &&
                oldMemberMap.get(member.Id).Status != member.Status
            ) {
                member.Last_Member_Status_Change__c = System.now();
            }
        }
    }

    public static void populateOpportunityNatMeritFlag(RelationWrapper wrapper) {
        for (Id contactId : wrapper.contactIdToCampaginMembers.keySet()) {
            Opportunity opportunity = wrapper.contactIdToOpportunitiesMap.get(contactId);
            if (opportunity != null) {
                for (CampaignMember member : wrapper.contactIdToCampaginMembers.get(contactId)) {
                    if (wrapper.nationalMeritScholarshipMemberIds.contains(member.Id)) {
                        opportunity.National_Merit_Semifinalist__c = true;
                        break;
                    }
                }
            }
        }
    }

    public static void populateCampaignSecurities(
        List<Campaign> campaignList,
        Map<Id, List<CampaignMember>> campaignIdToMembersMap,
        Set<Id> campaignMemberIdsToConsider
    ) {
        // Validation to ensure that user is a member of the correct Business Unit
        // Added to ensure that a campaignMember will error if the following rule is violated
        // User MC Business Unit must match Campaign business unit in order to add a campaign
        // member to the campaign
        List<String> availableBusinessUnits = new List<String>();
        User runningUser = [SELECT MC_Business_Unit_User__c FROM User WHERE Id = :userInfo.getUserId()];
        if (runningUser.MC_Business_Unit_User__c != null) {
            availableBusinessUnits = runningUser.MC_Business_Unit_User__c.split(';');
        }

        // Profiles that don't need security checks
        Set<Id> permittedProfileIds = new Set<Id>();
        for (Profile p : [SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' OR Name = 'System Administrator']) {
            permittedProfileIds.add(p.Id);
        }

        // Go through each campaign to check if user is allowed to be adding members
        for (Campaign campaign : campaignList) {
            if (permittedProfileIds.contains(UserInfo.getProfileId())) {
                continue;
            } else if (campaign.RecordType.DeveloperName != 'Subscription_Center') {
                continue;
            }

            Boolean found = false;
            for (String businessUnit : availableBusinessUnits) {
                if (campaign.Marketing_Cloud_Business_Unit__r.Name == businessUnit) {
                    found = true;
                    break;
                }
            }
            if (!found)
                for (CampaignMember member : campaignIdToMembersMap.get(campaign.Id))
                    if (campaignMemberIdsToConsider.contains(member.Id))
                        member.addError('Cannot insert Campaign Members for campaigns outside your business unit');
        }
    }

    public static List<CampaignMember> populatePrimaryOrNot(
        List<CampaignMember> members,
        Map<Id, CampaignMember> oldMembersMap,
        Set<Id> markPrimary,
        Set<Id> markNotPrimary
    ) {
        List<CampaignMember> membersUpdated = new List<CampaignMember>();
        for (CampaignMember member : members) {
            if (oldMembersMap != null && oldMembersMap.containsKey(member.Id)) {
                CampaignMember oldMember = oldMembersMap.get(member.Id);
                if (oldMember.Status != 'No Longer Interested' && member.Status == 'No Longer Interested') {
                    member.Is_Primary_Interest__c = false;
                }
            }

            if (markPrimary.contains(member.Id)) {
                member.Is_Primary_Interest__c = true;
                membersUpdated.add(member);
            } else if (markNotPrimary.contains(member.Id)) {
                member.Is_Primary_Interest__c = false;
                membersUpdated.add(member);
            }
        }
        return membersUpdated;
    }

    public static void populateMemberOpportunities(
        List<CampaignMember> memberList,
        Map<Id, Opportunity> contactIdToOpportunityMap
    ) {
        for (CampaignMember member : memberList) {
            if (member.ContactId != null && contactIdToOpportunityMap.containsKey(member.ContactId)) {
                Opportunity opportunity = contactIdToOpportunityMap.get(member.ContactId);
                member.Opportunity__c = opportunity.Id;
            }
        }
    }

    //We now have the CMs attached to all affected Contacts / Leads queued up
    //We need to go through each Contact / Lead, and reset the primary for each set of CMs
    //Reset the primary for the Contacts
    public static MarkPrimaryWrapper processContacts(
        Map<Id, List<CampaignMember>> contactIdToCampaginMembers,
        Set<Id> originalCampaignMemberIdSet,
        Map<Id, Opportunity> contactIdToOpportunityMap
    ) {
        MarkPrimaryWrapper whatToMarkPrimary = new MarkPrimaryWrapper();

        for (Id contactId : contactIdToCampaginMembers.keySet()) {
            List<CampaignMember> membersForContact = contactIdToCampaginMembers.get(contactId);

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
                if (originalCampaignMemberIdSet.contains(primary.Id)) {
                    whatToMarkPrimary.membersToMarkPrimaryIds.add(primary.Id);
                } else {
                    whatToMarkPrimary.relatedMembersToMarkPrimaryIds.add(primary.Id);
                }

                for (CampaignMember member : membersForContact) {
                    if (member.Is_Primary_Interest__c == true && member != primary) {
                        if (originalCampaignMemberIdSet.contains(member.Id)) {
                            whatToMarkPrimary.membersToMarkNotPrimaryIds.add(member.Id);
                        } else {
                            whatToMarkPrimary.relatedMembersToMarkNotPrimaryIds.add(member.Id);
                        }
                    }
                }

                Opportunity opp = contactIdToOpportunityMap.get(contactId);
                if (opp != null) {
                    if (opp.Primary_Interest__c != primary.CampaignId) {
                        opp.Primary_Interest__c = primary.CampaignId;
                    }
                }
            } else {
                Opportunity opp = contactIdToOpportunityMap.get(contactId);
                if (opp != null) {
                    if (opp.Primary_Interest__c != null) {
                        opp.Primary_Interest__c = null;
                    }
                }
            }
        }
        return whatToMarkPrimary;
    }
    // and now the Leads
    public static MarkPrimaryWrapper processLeads(
        Map<Id, List<CampaignMember>> leadIdToCampaginMembers,
        Set<Id> originalCampaignMemberIdSet,
        Map<Id, Lead> leadIdToLeadMap
    ) {
        MarkPrimaryWrapper whatToMarkPrimary = new MarkPrimaryWrapper();

        for (Id leadId : leadIdToCampaginMembers.keySet()) {
            List<CampaignMember> leadMembers = leadIdToCampaginMembers.get(leadId);

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
                if (originalCampaignMemberIdSet.contains(primary.Id)) {
                    whatToMarkPrimary.membersToMarkPrimaryIds.add(primary.Id);
                } else {
                    whatToMarkPrimary.relatedMembersToMarkPrimaryIds.add(primary.Id);
                }

                for (CampaignMember leadMember : leadMembers) {
                    if (leadMember.Is_Primary_Interest__c == true && leadMember != primary) {
                        if (originalCampaignMemberIdSet.contains(leadMember.Id)) {
                            whatToMarkPrimary.membersToMarkNotPrimaryIds.add(leadMember.Id);
                        } else {
                            whatToMarkPrimary.relatedMembersToMarkNotPrimaryIds.add(leadMember.Id);
                        }
                    }
                }

                Lead leadToUpdate = leadIdToLeadMap.get(leadId);
                if (leadToUpdate != null && leadToUpdate.Primary_Interest__c != primary.CampaignId) {
                    leadToUpdate.Primary_Interest__c = primary.CampaignId;
                }
            } else {
                Lead leadToUpdate = leadIdToLeadMap.get(leadId);
                if (leadToUpdate != null && leadToUpdate.Primary_Interest__c != null) {
                    leadToUpdate.Primary_Interest__c = null;
                }
            }
        }

        return whatToMarkPrimary;
    }

    public static void updateRelatedRecords(RelationWrapper wrapper) {
        if (
            wrapper.contactIdToOpportunitiesMap.values() != null &&
            !wrapper.contactIdToOpportunitiesMap.values().isEmpty()
        ) {
            Database.update(wrapper.contactIdToOpportunitiesMap.values());
        }
        if (wrapper.leadIdToLeadMap.values() != null && !wrapper.leadIdToLeadMap.values().isEmpty()) {
            Database.update(wrapper.leadIdToLeadMap.values());
        }
        if (
            wrapper.relatedCampaignMembersMap.values() != null && !wrapper.relatedCampaignMembersMap.values().isEmpty()
        ) {
            Database.update(wrapper.relatedCampaignMembersMap.values());
        }
    }

    public static RelationWrapper getRelationships(List<CampaignMember> memberList) {
        RelationWrapper wrapper = new RelationWrapper();

        for (CampaignMember member : memberList) {
            wrapper.originalCampaignMembersMap.put(member.Id, member);

            // Campaign Id to members
            if (!wrapper.campaignIdToCampaginMembers.containsKey(member.CampaignId))
                wrapper.campaignIdToCampaginMembers.put(member.CampaignId, new List<CampaignMember>());
            wrapper.campaignIdToCampaginMembers.get(member.CampaignId).add(member);
            // Contact Id to members
            if (member.ContactId != null) {
                if (!wrapper.contactIdToCampaginMembers.containsKey(member.ContactId))
                    wrapper.contactIdToCampaginMembers.put(member.ContactId, new List<CampaignMember>());
                wrapper.contactIdToCampaginMembers.get(member.ContactId).add(member);
            }
            // Lead Id to members
            if (member.LeadId != null) {
                if (!wrapper.leadIdToCampaginMembers.containsKey(member.LeadId))
                    wrapper.leadIdToCampaginMembers.put(member.LeadId, new List<CampaignMember>());
                wrapper.leadIdToCampaginMembers.get(member.LeadId).add(member);
            }
        }

        // Related campaigns
        wrapper.relatedCampaignMembersMap = new Map<Id, CampaignMember>(
            [
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
                    (ContactId IN :wrapper.contactIdToCampaginMembers.keySet()
                    OR LeadId IN :wrapper.leadIdToCampaginMembers.keySet())
                    AND Id NOT IN :wrapper.originalCampaignMembersMap.keySet()
                    AND Status != 'No Longer Interested'
                    AND Campaign.RecordType.DeveloperName = 'Interest'
                    AND Campaign.Type IN :ACCEPTABLE_MAJORS
            ]
        );

        for (CampaignMember member : wrapper.relatedCampaignMembersMap.values()) {
            // Campaign Id to members
            if (!wrapper.campaignIdToCampaginMembers.containsKey(member.CampaignId))
                wrapper.campaignIdToCampaginMembers.put(member.CampaignId, new List<CampaignMember>());
            wrapper.campaignIdToCampaginMembers.get(member.CampaignId).add(member);
            // Contact Id to members
            if (member.ContactId != null) {
                if (!wrapper.contactIdToCampaginMembers.containsKey(member.ContactId))
                    wrapper.contactIdToCampaginMembers.put(member.ContactId, new List<CampaignMember>());
                wrapper.contactIdToCampaginMembers.get(member.ContactId).add(member);
            }
            // Lead Id to members
            if (member.LeadId != null) {
                if (!wrapper.leadIdToCampaginMembers.containsKey(member.LeadId))
                    wrapper.leadIdToCampaginMembers.put(member.LeadId, new List<CampaignMember>());
                wrapper.leadIdToCampaginMembers.get(member.LeadId).add(member);
            }
        }

        for (Id memberId : wrapper.originalCampaignMembersMap.keySet()) {
            wrapper.superSetCampaignMembersMap.put(memberId, wrapper.originalCampaignMembersMap.get(memberId));
        }
        for (Id memberId : wrapper.relatedCampaignMembersMap.keySet()) {
            wrapper.superSetCampaignMembersMap.put(memberId, wrapper.relatedCampaignMembersMap.get(memberId));
        }

        // Campaign data
        wrapper.touchedCampaigns = [
            SELECT Id, RecordType.DeveloperName, Marketing_Cloud_Business_Unit__r.Name
            FROM Campaign
            WHERE Id IN :wrapper.campaignIdToCampaginMembers.keySet()
        ];
        for (Campaign c : wrapper.touchedCampaigns) {
            wrapper.campaignIdToRecordTypeNameMap.put(c.Id, c.RecordType.DeveloperName);
        }

        // Opportunities related to contacts
        for (Opportunity o : [
            SELECT Id, Contact__c, National_Merit_Semifinalist__c, Primary_Interest__c
            FROM Opportunity
            WHERE Contact__c IN :wrapper.contactIdToCampaginMembers.keySet() AND CloseDate > :System.today()
            ORDER BY CreatedDate ASC
        ]) {
            wrapper.contactIdToOpportunitiesMap.put(o.Contact__c, o);
        }

        for (CampaignMember member : [
            SELECT Id
            FROM CampaignMember
            WHERE
                Id IN :wrapper.superSetCampaignMembersMap.keySet()
                AND ContactId != NULL
                AND Campaign.RecordType.DeveloperName = 'Scholarship'
                AND Campaign.Name IN :NATIONAL_MERIT_CAMPAIGN_NAMES
        ]) {
            wrapper.nationalMeritScholarshipMemberIds.add(member.Id);
        }

        wrapper.leadIdToLeadMap = new Map<Id, Lead>(
            [SELECT Id, Primary_Interest__c FROM Lead WHERE Id IN :wrapper.leadIdToCampaginMembers.keySet()]
        );

        return wrapper;
    }

    public class RelationWrapper {
        public Map<Id, CampaignMember> originalCampaignMembersMap;
        public Map<Id, CampaignMember> relatedCampaignMembersMap;
        public Map<Id, CampaignMember> superSetCampaignMembersMap;
        public Map<Id, List<CampaignMember>> campaignIdToCampaginMembers;
        public Map<Id, List<CampaignMember>> contactIdToCampaginMembers;
        public Map<Id, List<CampaignMember>> leadIdToCampaginMembers;
        public Map<Id, String> campaignIdToRecordTypeNameMap;
        public Map<Id, Opportunity> contactIdToOpportunitiesMap;
        public Map<Id, Lead> leadIdToLeadMap;
        public List<Campaign> touchedCampaigns;
        Set<Id> nationalMeritScholarshipMemberIds;
        public RelationWrapper() {
            originalCampaignMembersMap = new Map<Id, CampaignMember>();
            relatedCampaignMembersMap = new Map<Id, CampaignMember>();
            superSetCampaignMembersMap = new Map<Id, CampaignMember>();
            campaignIdToCampaginMembers = new Map<Id, List<CampaignMember>>();
            contactIdToCampaginMembers = new Map<Id, List<CampaignMember>>();
            leadIdToCampaginMembers = new Map<Id, List<CampaignMember>>();
            campaignIdToRecordTypeNameMap = new Map<Id, String>();
            contactIdToOpportunitiesMap = new Map<Id, Opportunity>();
            leadIdToLeadMap = new Map<Id, Lead>();
            touchedCampaigns = new List<Campaign>();
            nationalMeritScholarshipMemberIds = new Set<Id>();
        }
        public RelationWrapper(RelationWrapper copyFrom) {
            originalCampaignMembersMap = copyFrom.originalCampaignMembersMap;
            relatedCampaignMembersMap = copyFrom.relatedCampaignMembersMap;
            superSetCampaignMembersMap = copyFrom.superSetCampaignMembersMap;
            campaignIdToCampaginMembers = copyFrom.campaignIdToCampaginMembers;
            contactIdToCampaginMembers = copyFrom.contactIdToCampaginMembers;
            leadIdToCampaginMembers = copyFrom.leadIdToCampaginMembers;
            campaignIdToRecordTypeNameMap = copyFrom.campaignIdToRecordTypeNameMap;
            contactIdToOpportunitiesMap = copyFrom.contactIdToOpportunitiesMap;
            leadIdToLeadMap = copyFrom.leadIdToLeadMap;
            touchedCampaigns = copyFrom.touchedCampaigns;
            nationalMeritScholarshipMemberIds = copyFrom.nationalMeritScholarshipMemberIds;
        }

        public void remove(CampaignMember member) {
            superSetCampaignMembersMap.remove(member.Id);
            if (originalCampaignMembersMap.containsKey(member.Id))
                originalCampaignMembersMap.remove(member.Id);
            if (relatedCampaignMembersMap.containsKey(member.Id))
                relatedCampaignMembersMap.remove(member.Id);
            for (List<CampaignMember> members : campaignIdToCampaginMembers.values())
                if (members.contains(member))
                    members.remove(members.indexOf(member));
            for (List<CampaignMember> members : contactIdToCampaginMembers.values())
                if (members.contains(member))
                    members.remove(members.indexOf(member));
            for (List<CampaignMember> members : leadIdToCampaginMembers.values())
                if (members.contains(member))
                    members.remove(members.indexOf(member));
            if (nationalMeritScholarshipMemberIds.contains(member.Id))
                nationalMeritScholarshipMemberIds.remove(member.Id);
        }
    }

    public class MarkPrimaryWrapper {
        public Set<Id> membersToMarkPrimaryIds;
        public Set<Id> membersToMarkNotPrimaryIds;
        public Set<Id> relatedMembersToMarkPrimaryIds;
        public Set<Id> relatedMembersToMarkNotPrimaryIds;

        public MarkPrimaryWrapper() {
            membersToMarkPrimaryIds = new Set<Id>();
            membersToMarkNotPrimaryIds = new Set<Id>();
            relatedMembersToMarkPrimaryIds = new Set<Id>();
            relatedMembersToMarkNotPrimaryIds = new Set<Id>();
        }

        public MarkPrimaryWrapper(List<MarkPrimaryWrapper> addFromList) {
            membersToMarkPrimaryIds = new Set<Id>();
            membersToMarkNotPrimaryIds = new Set<Id>();
            relatedMembersToMarkPrimaryIds = new Set<Id>();
            relatedMembersToMarkNotPrimaryIds = new Set<Id>();

            addAll(addFromList);
        }

        private void addAll(List<MarkPrimaryWrapper> addFromList) {
            for (MarkPrimaryWrapper addFrom : addFromList) {
                add(addFrom);
            }
        }

        private void add(MarkPrimaryWrapper addFrom) {
            for (Id i : addFrom.membersToMarkPrimaryIds) {
                membersToMarkPrimaryIds.add(i);
            }
            for (Id i : addFrom.membersToMarkNotPrimaryIds) {
                membersToMarkNotPrimaryIds.add(i);
            }
            for (Id i : addFrom.relatedMembersToMarkPrimaryIds) {
                relatedMembersToMarkPrimaryIds.add(i);
            }
            for (Id i : addFrom.relatedMembersToMarkNotPrimaryIds) {
                relatedMembersToMarkNotPrimaryIds.add(i);
            }
        }
    }
}
