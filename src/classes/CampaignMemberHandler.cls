public without sharing class CampaignMemberHandler extends AbstractTriggerHandler {
    private Map<Id, List<CampaignMember>> campaignMembersByContact = new Map<Id, List<CampaignMember>>();
    private Map<Id, List<CampaignMember>> campaignMembersByLead = new Map<Id, List<CampaignMember>>();
    private static Map<Id, Opportunity> opportunitiesByContact = new Map<Id, Opportunity>();
    private Set<Id> cmIds = new Set<Id>();
    private Set<CampaignMember> triggerCMsToFalsify = new Set<CampaignMember>();
    private Set<CampaignMember> triggerCMsToPrimary = new Set<CampaignMember>();
    private static Set<CampaignMember> externalCMsToFalsify = new Set<CampaignMember>();
    private static Set<CampaignMember> externalCMsToPrimary = new Set<CampaignMember>();
    private static Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
    private static List<Lead> leadsToUpdate = new List<Lead>();
    private static Boolean ranCampaignMembersUpdatePrimary = false;
    
    private Set<Id> contactIdsInTrigger = new Set<Id>();
    private Set<Id> leadIdsInTrigger = new Set<Id>();
    private List<CampaignMember> cmsInTriggerWithContacts = new List<CampaignMember>();
    private List<CampaignMember> cmsInTriggerWithLeads = new List<CampaignMember>();
    private Map<Id, String> campaignRecordTypesById = new Map<Id, String>();
    private List<String> userAvailableBusinessUnits = new List<string>();
    private Map<Id, List<CampaignMember>> campaignIdToMembers = new Map<Id, List<CampaignMember>>();
    private List<Profile> exceptions = [SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' OR Name = 'System Administrator'];
    private List<CampaignMember> affectedCampaignMembers;
    private Set<CampaignMember> setOfAffectedCMs;
    
    private static final Set<String> NATIONAL_MERIT_CAMPAIGN_NAMES = new Set<String> {
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
    
    private static final Set<String> ACCEPTABLE_MAJORS = new Set<String> {
        'PSMajors',
        'Academic',
        'ASU Colleges',
        'Degree Search by Interest'
    };
    
    public CampaignMemberHandler() {}
    
    public override void beforeInsert() {
        if (!ranCampaignMembersUpdatePrimary) {
            affectedCampaignMembers = Trigger.new;
            processigBefore();
        }
        
        for (SObject so : Trigger.new) {
            CampaignMember cm = (CampaignMember)so;

            if (triggerCMsToFalsify.contains(cm)) {
              cm.Is_Primary_Interest__c = FALSE;
            }
            if (triggerCMsToPrimary.contains(cm)) {
              cm.Is_Primary_Interest__c = TRUE;
            }
            if (cm.ContactId != null) {
                Opportunity opp = opportunitiesByContact.get(cm.ContactId);
                if (opp != null) {
                    cm.Opportunity__c = opp.Id;
                }
            }
        }
    }
        
    public override void afterInsert() {
        Set<Id> triggerIDs = Trigger.newMap.keySet();
        assignNationalMeritFlag(triggerIDs);
        List<CampaignMember> campaignMembersToUpdate = setPrimaryInterestOnCampaignMembers();
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(campaignMembersToUpdate);
        clearDataAfter();
    }
        
    public override void beforeUpdate() {
        if (!ranCampaignMembersUpdatePrimary) {
            affectedCampaignMembers = Trigger.new;
            processigBefore();
        }
        
        for (SObject oldSo : Trigger.old) {
            SObject so = Trigger.newMap.get(oldSo.Id);
            CampaignMember cm = (CampaignMember)so;
            CampaignMember oldCm = (CampaignMember)oldSo;

            if (oldCm.Status != 'No Longer Interested' && cm.Status == 'No Longer Interested') {
                cm.Is_Primary_Interest__c = FALSE;
            }

            if (triggerCMsToFalsify.contains(cm)) {
                cm.Is_Primary_Interest__c = FALSE;
            }
            
            if (triggerCMsToPrimary.contains(cm)) {
                cm.Is_Primary_Interest__c = TRUE;
            }
        }
    }
        
    public override void afterUpdate() {
        Set<Id> triggerIDs = Trigger.newMap.keySet();
        assignNationalMeritFlag(triggerIDs);
        List<CampaignMember> campaignMembersToUpdate = setPrimaryInterestOnCampaignMembers();
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(campaignMembersToUpdate);
        clearDataAfter();
    }
        
    public override void beforeDelete() {
        if (!ranCampaignMembersUpdatePrimary) {
            affectedCampaignMembers = Trigger.old;
            processigBefore();
        }
    }
        
    public override void afterDelete() {
        Set<Id> triggerIDs = Trigger.oldMap.keySet(); 
        assignNationalMeritFlag(triggerIDs);
        List<CampaignMember> campaignMembersToUpdate = setPrimaryInterestOnCampaignMembers();
        updateOpportunities();
        updateLeads();
        updateCampaignMembers(campaignMembersToUpdate);
        clearDataAfter();
    }

    /**
     * processigBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void processigBefore() {
        for (CampaignMember campaignMember : affectedCampaignMembers) {
            organizeDataBefore(campaignMember);
        }
        getUserPermissionsByBusinessUnit();
        checkSecurityOnCampaign();
        getRelatedCampaignMembers();
        setOfAffectedCMs = new Set<CampaignMember>(affectedCampaignMembers);
        if (!campaignMembersByContact.isEmpty()) {
            processContacts();
        }
        if (!campaignMembersByLead.isEmpty()) {
            processLeads();
        }
    }
    
    private void organizeDataBefore(CampaignMember cm) {
        //Add the CM ID to a set
        cmIds.add(cm.Id);

        //Add the CM's campaign ID to the set
        if (campaignIdToMembers.get(cm.CampaignId) == null) {
            campaignIdToMembers.put(cm.CampaignId, new List<CampaignMember>());
        }
        campaignIdToMembers.get(cm.CampaignId).add(cm);

        //If the CM has a contact, add the Contact ID to the set
        if (cm.ContactId != null) {
            contactIdsInTrigger.add(cm.ContactId);
            cmsInTriggerwithContacts.add(cm);
            if (!campaignMembersByContact.containsKey(cm.ContactId)) {
                campaignMembersByContact.put(cm.ContactId, new List<CampaignMember>());
            }
        }

        //If the CM has a lead, add the Lead ID to the set
        if (cm.LeadId != null) {
            leadIdsInTrigger.add(cm.LeadId);
            cmsInTriggerWithLeads.add(cm);
            if (!campaignMembersByLead.containsKey(cm.LeadId)) {
                campaignMembersByLead.put(cm.LeadId, new List<CampaignMember>());
            }
        }

        //Deal with updating the Last Member Status Change
        if (Trigger.isInsert) {
            if (cm.Last_Member_Status_Change__c == null) {
                cm.Last_Member_Status_Change__c = Datetime.now();
            }
        } else if (Trigger.isUpdate) {
            CampaignMember oldCM = (CampaignMember) Trigger.oldMap.get(cm.Id); 
            if (oldCM.Status != cm.Status) {
                cm.Last_Member_Status_Change__c = Datetime.now();
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
        List<CampaignMember> cmsForContactsOrLeads = [
            SELECT Id, CampaignId, Status, CreatedDate, ContactId, LeadId, Is_Primary_Interest__c, Last_Member_Status_Change__c, Campaign_Type__c, Campaign.RecordType.DeveloperName 
            FROM CampaignMember 
            WHERE (ContactId IN :contactIdsInTrigger 
            OR LeadId IN :leadIdsInTrigger)
            AND Id NOT IN :cmIds
            AND Status != 'No Longer Interested' 
            AND Campaign.RecordType.DeveloperName = 'Interest' 
            AND Campaign.Type IN :ACCEPTABLE_MAJORS
        ];

        //Parse the Contact and Lead CMs into maps
        for (CampaignMember addedCampaignMembers : cmsForContactsOrLeads) {
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
            for (CampaignMember cm : cmsInTriggerWithContacts) {
                if (ACCEPTABLE_MAJORS.contains(cm.Campaign_Type__c) && campaignRecordTypesById.get(cm.CampaignId) == 'Interest' && cm.Status != 'No Longer Interested') {
                    if (campaignMembersByContact.containsKey(cm.ContactId)) {
                        campaignMembersByContact.get(cm.ContactId).add(cm);
                    } else {
                        List<CampaignMember> newList = new List<CampaignMember>();
                        newList.add(cm);
                        campaignMembersByContact.put(cm.ContactId, newList);
                    }
                }
            }
        }
        
        List<Opportunity> opportunitiesInTrigger = [
            SELECT Id, Contact__c, National_Merit_Semifinalist__c, Primary_Interest__c 
            FROM Opportunity 
            WHERE Contact__c IN :contactIDsInTrigger
            ORDER BY IsClosed DESC, CloseDate DESC, CreatedDate DESC
        ];

        for (Opportunity o : opportunitiesInTrigger) {
            opportunitiesByContact.put(o.Contact__c, o);
        }
        
        for (Id contactId : campaignMembersByContact.keySet()) {
            List<CampaignMember> contactCMs = campaignMembersByContact.get(contactId);

            //Update the Primary Interest on the CM
            CampaignMember primary;
            
            //Pass 1 - Find PSMajor w/ greatest Last Member Status Change 
            for (CampaignMember ccm : contactCMs) {
                if (ccm.Campaign_Type__c == 'PSMajors' && (primary == null || ccm.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) && ccm.Status != 'No Longer Interested') {
                    primary = ccm;
                }
            }
            
            //Pass 2 - Find any CM w/ greatest Last Member Status Change 
            if (primary == null) {
                for (CampaignMember ccm : contactCMs) {
                    if (ccm.Status != 'No Longer Interested' && (primary == null || ccm.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c)) {
                        primary = ccm;
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
                if (setOfAffectedCMs.contains(primary)) {
                    triggerCMsToPrimary.add(primary);
                } else {
                    externalCMsToPrimary.add(primary);    
                }

                for (CampaignMember ccm : contactCMs) {
                    if (ccm.Is_Primary_Interest__c == TRUE && ccm != primary) {
                        if (setOfAffectedCMs.contains(ccm)) {
                            triggerCMsToFalsify.add(ccm);
                        } else {
                            externalCMsToFalsify.add(ccm);    
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
            for (CampaignMember cm : cmsInTriggerWithLeads) {
                if (ACCEPTABLE_MAJORS.contains(cm.Campaign_Type__c) && campaignRecordTypesById.get(cm.CampaignId) == 'Interest' && cm.Status != 'No Longer Interested') {
                    if (campaignMembersByLead.containsKey(cm.LeadId)) {
                        campaignMembersByLead.get(cm.LeadId).add(cm);
                    } else {
                        List<CampaignMember> newList = new List<CampaignMember>();
                        newList.add(cm);
                        campaignMembersByLead.put(cm.LeadId, newList);
                    }
                }
            }
        }
        
        Map<Id, Lead> leadsInTrigger = new Map<Id, Lead>([
            SELECT Id, Primary_Interest__c 
            FROM Lead 
            WHERE Id IN :leadIDsInTrigger
        ]);
        
        for (Id leadId : campaignMembersByLead.keySet()) {
            List<CampaignMember> leadCMs = campaignMembersByLead.get(leadId);

            //Update the Primary Interest on the CM
            CampaignMember primary;
            
            //Pass 1 - Find PSMajor w/ greatest Last Member Status Change 
            for (CampaignMember lcm : leadCMs) {
                if (lcm.Campaign_Type__c == 'PSMajors' 
                        && (primary == null || lcm.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) 
                        && lcm.Status != 'No Longer Interested') {
                    primary = lcm;
                }
            }
            
            //Pass 2 - Find any CM w/ greatest Last Member Status Change 
            if (primary == null) {
                for (CampaignMember lcm : leadCMs) {
                    if (lcm.Status != 'No Longer Interested' 
                            && (primary == null || lcm.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c)) {
                        primary = lcm;
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
                if (setOfAffectedCMs.contains(primary)) {
                    triggerCMsToPrimary.add(primary);
                } else {
                    externalCMsToPrimary.add(primary);    
                }

                for (CampaignMember lcm : leadCMs) {
                    if (lcm.Is_Primary_Interest__c == TRUE && lcm != primary) {
                        if (setOfAffectedCMs.contains(lcm)) {
                            triggerCMsToFalsify.add(lcm);
                        } else {
                            externalCMsToFalsify.add(lcm);    
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
 
    private void assignNationalMeritFlag(Set<Id> triggerIDs) {
        for (CampaignMember nationalMeritCampaignMember : getNationalMeritCampaignMembers(triggerIDs)) {
            Opportunity nationalMeritOpportunity = opportunitiesByContact.get(nationalMeritCampaignMember.ContactId);
            setOpportunityAsNationMerit(nationalMeritOpportunity);
        }
    }
    
    private List<CampaignMember> getNationalMeritCampaignMembers(Set<Id> triggerIDs) {
        return [
            SELECT Id, ContactId 
            FROM CampaignMember 
            WHERE Id IN :triggerIDs 
            AND ContactId != null
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
        for (CampaignMember cm : externalCMsToFalsify) {
            if (cm.Is_Primary_Interest__c != FALSE) {
                cm.Is_Primary_Interest__c = FALSE;
                campaignMembersToUpdate.add(cm);
            }
        }

        for (CampaignMember cm : externalCMsToPrimary) {
            if (cm.Is_Primary_Interest__c != TRUE) {
                cm.Is_Primary_Interest__c = TRUE;
                campaignMembersToUpdate.add(cm);
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
        externalCMsToPrimary = new Set<CampaignMember>();
        externalCMsToFalsify = new Set<CampaignMember>();
        opportunitiesToUpdate = new Map<Id, Opportunity>();
        leadsToUpdate = new List<Lead>();
    }
}