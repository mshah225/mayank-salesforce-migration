public without sharing class CampaignMemberHandler implements ITrigger 
{
    Map<Id, List<CampaignMember>> CampaignMembersByContactMap = new Map<Id, List<CampaignMember>>();
    Map<Id, List<CampaignMember>> CampaignMembersByLeadMap = new Map<Id, List<CampaignMember>>();
    private static Map<Id, Opportunity> OpportunitiesByContactMap = new Map<Id, Opportunity>();

    Set<Id> cmIds = new Set<Id>();

    Set<CampaignMember> triggerCMsToFalsify = new Set<CampaignMember>();
    Set<CampaignMember> triggerCMsToPrimary = new Set<CampaignMember>();
    private static Set<CampaignMember> externalCMsToFalsify = new Set<CampaignMember>();
    private static Set<CampaignMember> externalCMsToPrimary = new Set<CampaignMember>();
    private static Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
    private static List<Lead> leadsToUpdate = new List<Lead>();
    private static Boolean ranCampaignMembersUpdatePrimary = false;

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() 
    {
        if(!ranCampaignMembersUpdatePrimary)
        {
            Set<Id> campaignIdsInTrigger = new Set<Id>();
            Set<Id> contactIdsInTrigger = new Set<Id>();

            List<CampaignMember> cmsInTriggerWithContacts = new List<CampaignMember>();
            Set<Id> leadIdsInTrigger = new Set<Id>();
            Map<Id, Lead> leadsInTrigger = new Map<Id, Lead>();
            List<CampaignMember> cmsInTriggerWithLeads = new List<CampaignMember>();
            List<Opportunity> opportunitiesInTrigger = new List<Opportunity>();

            List<CampaignMember> listOfAffectedCMs;
            Map<Id, String> campaignRecordTypesById = new Map<Id, String>();

            // If we are inserting or updating Campaign Member(s) we fill a Set with their IDs
            if (Trigger.isInsert || Trigger.isUpdate) 
            {
                listOfAffectedCMs = Trigger.new;
            }
            else if(Trigger.isDelete)
            {
                listOfAffectedCMs = Trigger.old;
            }

            //For each Campaign Member in this trigger
            for (Integer x = 0; x < listOfAffectedCMs.size(); x++) 
            {
                CampaignMember cm = listOfAffectedCMs.get(x);

                //Add the CM ID to a set
                cmIds.add(cm.Id);

                //Add the CM's campaign ID to the set
                campaignIdsInTrigger.add(cm.CampaignId);

                //If the CM has a contact, add the Contact ID to the set
                if(cm.ContactId != null)
                {
                    contactIdsInTrigger.add(cm.ContactId);
                    cmsInTriggerwithContacts.add(cm);
                    if(!CampaignMembersByContactMap.containsKey(cm.ContactId))
                    {
                        CampaignMembersByContactMap.put(cm.ContactId, new List<CampaignMember>());
                    }
                }

                //If the CM has a lead, add the Lead ID to the set
                if(cm.LeadId != null)
                {
                    leadIdsInTrigger.add(cm.LeadId);
                    cmsInTriggerWithLeads.add(cm);
                    if(!CampaignMembersByLeadMap.containsKey(cm.LeadId))
                    {
                        CampaignMembersByLeadMap.put(cm.LeadId, new List<CampaignMember>());
                    }
                }

                //Deal with updating the Last Member Status Change
                if(Trigger.isInsert)
                {
                    if(cm.Last_Member_Status_Change__c == null)
                    {
                        cm.Last_Member_Status_Change__c = Datetime.now();
                    }
                }
                else if(Trigger.isUpdate)
                {
                    CampaignMember oldCM = (CampaignMember) Trigger.old.get(x); 
                    if(oldCM.Status != cm.Status)
                    {
                        cm.Last_Member_Status_Change__c = Datetime.now();
                    }
                }
            }

            opportunitiesInTrigger = [
                SELECT Id, Contact__c, National_Merit_Semifinalist__c, Primary_Interest__c 
                FROM Opportunity 
                WHERE Contact__c IN :contactIDsInTrigger
            ];

            for(Opportunity o : opportunitiesInTrigger)
            {
                OpportunitiesByContactMap.put(o.Contact__c, o);
            }

            leadsInTrigger = new Map<Id, Lead>([
                SELECT Id, Primary_Interest__c 
                FROM Lead 
                WHERE Id IN :leadIDsInTrigger
            ]);

            Set<CampaignMember> setOfAffectedCMs = new Set<CampaignMember>(listOfAffectedCMs);

            //For all Campaigns on the CMs in this trigger, get their names and link id to name
            List<Campaign> campaignList = [
                SELECT Id, RecordType.DeveloperName 
                FROM Campaign 
                WHERE Id IN :campaignIdsInTrigger
            ];

            for(Campaign c : campaignList)
            {
                campaignRecordTypesById.put(c.Id, c.RecordType.DeveloperName);
            }

            Set<String> acceptableMajors = new Set<String> {'PSMajors', 'Academic', 'ASU Colleges', 'Degree Search by Interest'};

            //Get the list of CMs on the contacts and leads. Ignore any that are in this trigger, they will be added in later
            List<CampaignMember> cmsForContactsOrLeads = [
                SELECT Id, CampaignId, Status, CreatedDate, ContactId, LeadId, Is_Primary_Interest__c, Last_Member_Status_Change__c, Campaign_Type__c, Campaign.RecordType.DeveloperName 
                FROM CampaignMember 
                WHERE (ContactId IN :contactIdsInTrigger 
                OR LeadId IN :leadIdsInTrigger)
                AND Id NOT IN :cmIds
                AND Status != 'No Longer Interested' 
                AND Campaign.RecordType.DeveloperName = 'Interest' 
                AND Campaign.Type IN :acceptableMajors
            ];

            //Parse the Contact and Lead CMs into maps
            for(CampaignMember cm : cmsForContactsOrLeads)
            {              
                if(contactIdsInTrigger.contains(cm.ContactId))
                {
                    CampaignMembersByContactMap.get(cm.ContactId).add(cm);
                }

                if(leadIdsInTrigger.contains(cm.LeadId))
                {
                    CampaignMembersByLeadMap.get(cm.LeadId).add(cm);
                }
            }

            //When inserting or updating, need to add the new CMs to the Contact map
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                for(Integer x = 0; x < cmsInTriggerwithContacts.size(); x++)
                {
                    CampaignMember cm = cmsInTriggerWithContacts.get(x);
                    if(acceptableMajors.contains(cm.Campaign_Type__c) && campaignRecordTypesById.get(cm.CampaignId) == 'Interest' && cm.Status != 'No Longer Interested')
                    {
                        if(CampaignMembersByContactMap.containsKey(cm.ContactId))
                        {
                            CampaignMembersByContactMap.get(cm.ContactId).add(cm);
                        }
                        else
                        {
                            List<CampaignMember> newList = new List<CampaignMember>();
                            newList.add(cm);
                            CampaignMembersByContactMap.put(cm.ContactId, newList);
                        }
                    }
                }
            }

            //When inserting or updating, need to add the new CMs to the Lead map
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                for(Integer x = 0; x < cmsInTriggerWithLeads.size(); x++)
                {
                    CampaignMember cm = cmsInTriggerWithLeads.get(x);
                    
                    if(acceptableMajors.contains(cm.Campaign_Type__c) && campaignRecordTypesById.get(cm.CampaignId) == 'Interest' && cm.Status != 'No Longer Interested')
                    {
                        if(CampaignMembersByLeadMap.containsKey(cm.LeadId))
                        {
                            CampaignMembersByLeadMap.get(cm.LeadId).add(cm);
                        }
                        else
                        {
                            List<CampaignMember> newList = new List<CampaignMember>();
                            newList.add(cm);
                            CampaignMembersByLeadMap.put(cm.LeadId, newList);
                        }
                    }
                }
            }

            //We now have the CMs attached to all affected Contacts / Leads queued up
            //We need to go through each Contact / Lead, and reset the primary for each set of CMs

            //Reset the primary for the Contacts
            if(CampaignMembersByContactMap.size() > 0)
            {
                for(Id contactId : CampaignMembersByContactMap.keySet())
                {
                    List<CampaignMember> contactCMs = CampaignMembersByContactMap.get(contactId);

                    //Update the Primary Interest on the CM
                    CampaignMember primary;
                    
                    //Pass 1 - Find PSMajor w/ greatest Last Member Status Change 
                    for(CampaignMember ccm : contactCMs)
                    {
                        if(ccm.Campaign_Type__c == 'PSMajors' && (primary == null || ccm.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) && ccm.Status != 'No Longer Interested')
                        {
                            primary = ccm;
                        }
                    }
                    
                    //Pass 2 - Find any CM w/ greatest Last Member Status Change 
                    if(primary == null)
                    {
                        for(CampaignMember ccm : contactCMs)
                        {
                            if(ccm.Status != 'No Longer Interested' && (primary == null || ccm.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c))
                            {
                                primary = ccm;
                            }
                        }
                    }

                    //By now we should have a Primary
                    //There are three possibilities
                    //1. None of the CMs have primary
                    //2. One of the CMs has a primary, and it is the one we have identified (e.g. no change)
                    //3. One of the CMs has a primary, and it is different from the one we have identified, so we must update the new and falsify the old
                    if(primary != null)
                    {
                        //If the primary is in the trigger
                        if(setOfAffectedCMs.contains(primary))
                        {
                            triggerCMsToPrimary.add(primary);
                        }
                        else
                        {
                            externalCMsToPrimary.add(primary);    
                        }

                        for(CampaignMember ccm : contactCMs)
                        {
                            if(ccm.Is_Primary_Interest__c == TRUE && ccm != primary)
                            {
                                if(setOfAffectedCMs.contains(ccm))
                                {
                                    triggerCMsToFalsify.add(ccm);
                                }
                                else
                                {
                                    externalCMsToFalsify.add(ccm);    
                                }
                            }
                        }

                        Opportunity opp = OpportunitiesByContactMap.get(contactId);
                        if(opp != null)
                        {
                            if(opp.Primary_Interest__c != primary.CampaignId)
                            {
                                opp.Primary_Interest__c = primary.CampaignId;
                                opportunitiesToUpdate.put(opp.Id, opp);
                            }
                        }
                    }
                    else
                    {
                        Opportunity opp = OpportunitiesByContactMap.get(contactId);
                        if(opp != null)
                        {
                            if(opp.Primary_Interest__c != null)
                            {
                                opp.Primary_Interest__c = null;
                                opportunitiesToUpdate.put(opp.Id, opp);
                            }
                        }
                    }
                }
            }

            //Reset the primary for the Leads 
            if(CampaignMembersByLeadMap.size() > 0)
            {
                for(Id leadId : CampaignMembersByLeadMap.keySet())
                {
                    List<CampaignMember> leadCMs = CampaignMembersByLeadMap.get(leadId);

                    //Update the Primary Interest on the CM
                    CampaignMember primary;
                    
                    //Pass 1 - Find PSMajor w/ greatest Last Member Status Change 
                    for(CampaignMember lcm : leadCMs)
                    {
                        if(lcm.Campaign_Type__c == 'PSMajors' 
                            && (primary == null || lcm.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) 
                            && lcm.Status != 'No Longer Interested')
                        {
                            primary = lcm;
                        }
                    }
                    
                    //Pass 2 - Find any CM w/ greatest Last Member Status Change 
                    if(primary == null)
                    {
                        for(CampaignMember lcm : leadCMs)
                        {
                            if(lcm.Status != 'No Longer Interested' 
                                && (primary == null || lcm.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c))
                            {
                                primary = lcm;
                            }
                        }
                    }

                    //By now we should have a Primary
                    //There are three possibilities
                    //1. None of the CMs have primary
                    //2. One of the CMs has a primary, and it is the one we have identified (e.g. no change)
                    //3. One of the CMs has a primary, and it is different from the one we have identified, so we must update the new and falsify the old
                    if(primary != null)
                    {
                        //If the primary is in the trigger
                        if(setOfAffectedCMs.contains(primary))
                        {
                            triggerCMsToPrimary.add(primary);
                        }
                        else
                        {
                            externalCMsToPrimary.add(primary);    
                        }

                        for(CampaignMember lcm : leadCMs)
                        {
                            if(lcm.Is_Primary_Interest__c == TRUE && lcm != primary)
                            {
                                if(setOfAffectedCMs.contains(lcm))
                                {
                                    triggerCMsToFalsify.add(lcm);
                                }
                                else
                                {
                                    externalCMsToFalsify.add(lcm);    
                                }
                            }
                        }

                        Lead leadToUpdate = leadsInTrigger.get(leadId);
                        if(leadToUpdate.Primary_Interest__c != primary.CampaignId)
                        {
                            leadToUpdate.Primary_Interest__c = primary.CampaignId;
                            leadsToUpdate.add(leadToUpdate);
                        }
                    }
                    else
                    {
                        Lead leadToUpdate = leadsInTrigger.get(leadId);
                        if(leadToUpdate.Primary_Interest__c != null)
                        {
                            leadToUpdate.Primary_Interest__c = null;
                            leadsToUpdate.add(leadToUpdate);
                        }
                    }
                }
            }
        }
    }
 
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) 
    {
        CampaignMember cm = (CampaignMember)so;

        if(triggerCMsToFalsify.contains(cm))
        {
          cm.Is_Primary_Interest__c = FALSE;
        }
        
        if(triggerCMsToPrimary.contains(cm))
        {
          cm.Is_Primary_Interest__c = TRUE;
        }

        if(cm.ContactId != null)
        {
            Opportunity opp = OpportunitiesByContactMap.get(cm.ContactId);
            if(opp != null)
            {
                cm.Opportunity__c = opp.Id;
            }
        }
    }
    
    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) 
    {
        CampaignMember cm = (CampaignMember)so;
        CampaignMember oldCm = (CampaignMember)oldSo;

        if(oldCm.Status != 'No Longer Interested' && cm.Status == 'No Longer Interested')
        {
            cm.Is_Primary_Interest__c = FALSE;
        }

        if(triggerCMsToFalsify.contains(cm))
        {
            cm.Is_Primary_Interest__c = FALSE;
        }
        
        if(triggerCMsToPrimary.contains(cm))
        {
            cm.Is_Primary_Interest__c = TRUE;
        }
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so) {}
    
    /**
     * beforeFinally
     *
     * This method is called at the end of the execution of a BEFORE trigger. Use this to finalize
     * any bulk operations for a BEFORE trigger.
     */
    public void beforeFinally(){}

    /** 
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() 
    {
        Set<Id> triggerIDs = new Set<Id>();
        List<Id> nationalMeritContactIds = new List<Id>();
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            triggerIDs = Trigger.newMap.keySet();
        }
        else if(Trigger.isDelete)
        {
            triggerIDs = Trigger.oldMap.keySet(); 
        }

        //Deal with National Merit Stuff
        Set<String> NationalMeritCampaignNames = new Set<String>{'National Achievement Finalist', 
            'National Achievement Semifinalist', 
            'National Hispanic Scholar Finalist',
            'National Merit Finalist', 
            'National Merit Semifinalist', 
            'Gammage Scholar',
            'Flinn Designate', 
            'Flinn Semifinalist', 
            'Flinn Finalist'};

        List<CampaignMember> nmsList = new List<CampaignMember>([
            SELECT Id, ContactId 
            FROM CampaignMember 
            WHERE Id IN :triggerIDs 
            AND ContactId != null
            AND Campaign.RecordType.DeveloperName = 'Scholarship' 
            AND Campaign.Name IN :NationalMeritCampaignNames
        ]);

        //Extract the Contact IDs from our CM set
        for (CampaignMember cm : nmsList) 
        {
            Opportunity nmsOpp = OpportunitiesByContactMap.get(cm.ContactId);
            if(nmsOpp != null)
            {
                if(nmsOpp.National_Merit_Semifinalist__c != true)
                {
                    if(opportunitiesToUpdate.get(nmsOpp.Id) != null)
                    {
                       opportunitiesToUpdate.get(nmsOpp.Id).National_Merit_Semifinalist__c = true; 
                    }
                    else
                    {
                        if(nmsOpp.National_Merit_Semifinalist__c != true)
                        {
                            nmsOpp.National_Merit_Semifinalist__c = true;
                            opportunitiesToUpdate.put(nmsOpp.Id, nmsOpp);
                        }
                    }
                }
            }
        }

        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        for(CampaignMember cm : externalCMsToFalsify)
        {
            if(cm.Is_Primary_Interest__c != FALSE)
            {
                cm.Is_Primary_Interest__c = FALSE;
                cmsToUpdate.add(cm);
            }
        }

        for(CampaignMember cm : externalCMsToPrimary)
        {
            if(cm.Is_Primary_Interest__c != TRUE)
            {
                cm.Is_Primary_Interest__c = TRUE;
                cmsToUpdate.add(cm);
            }
        }

        externalCMsToPrimary = new Set<CampaignMember>();
        externalCMsToFalsify = new Set<CampaignMember>();

        if(opportunitiesToUpdate.size() > 0)
        {
            List<Opportunity> oppsToUpdateList = new List<Opportunity>();
            oppsToUpdateList.addAll(opportunitiesToUpdate.values());
            update oppsToUpdateList;
        }
        opportunitiesToUpdate = new Map<Id, Opportunity>();

        if(leadsToUpdate.size() > 0)
        {
            update leadsToUpdate;
        }
        leadsToUpdate = new List<Lead>();

        if(cmsToUpdate.size() > 0)
        {
            ranCampaignMembersUpdatePrimary = true;
            update cmsToUpdate;
        }
    }

    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so) {}
    
    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {}
    
    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so){}
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {}
}