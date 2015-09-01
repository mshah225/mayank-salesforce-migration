public without sharing class CampaignMemberHandler implements ITrigger 
{
    Map<Id, List<Opportunity>> OpportunitiesByContactMap = new Map<Id, List<Opportunity>>();
    Map<Id, List<CampaignMember>> CampaignMembersByContactMap = new Map<Id, List<CampaignMember>>();
    Map<Id, List<CampaignMember>> CampaignMembersByLeadMap = new Map<Id, List<CampaignMember>>();
    Set<Id> cmIds = new Set<Id>();
    Set<Id> cmIds2 = new Set<Id>();
    Set<CampaignMember> objectsToFalsify = new Set<CampaignMember>();
    Set<CampaignMember> primaries = new Set<CampaignMember>();
    private static Boolean run = true;
    
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() 
    {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> campaignIds = new Set<Id>();
        List<CampaignMember> listOfAffectedCMs;
        List<CampaignMember> triggerObjectListContact = new List<CampaignMember>();
        List<CampaignMember> triggerObjectListLead = new List<CampaignMember>();
        List<CampaignMember> triggerObjectListContactOld = new List<CampaignMember>();
        List<CampaignMember> triggerObjectListLeadOld = new List<CampaignMember>();
        Map<Id, String> campaignRecordTypesById = new Map<Id, String>();

        // TODO: Some way to limit this to recruitment CM records?
        // If we are inserting or updating Campaign Member(s) we fill a Set with their IDs
        if (Trigger.isInsert || Trigger.isUpdate) 
        {
            listOfAffectedCMs = Trigger.new;
        }
        else if(Trigger.isDelete)
        {
            listOfAffectedCMs = Trigger.old;
        }
        
        for (Integer x = 0; x < listOfAffectedCMs.size(); x++) 
        {
            CampaignMember cm = listOfAffectedCMs.get(x);
            cmIds2.add(cm.Id);
            campaignIds.add(cm.CampaignId);
            if (cm.ContactId != null)
            {
                triggerObjectListContact.add(cm);
                if(Trigger.isUpdate)
                {
                    triggerObjectListContactOld.add((CampaignMember) Trigger.old.get(x));
                }
                contactIds.add(cm.ContactId);
            }
            
            if(cm.LeadId != null)
            {
                triggerObjectListLead.add(cm);
                if(Trigger.isUpdate)
                {
                    triggerObjectListLeadOld.add((CampaignMember) Trigger.old.get(x));
                }
                leadIds.add(cm.LeadId);
            }
        }

        List<Campaign> campaignList = [SELECT Id, RecordType.DeveloperName FROM Campaign WHERE Id IN :campaignIds];
        for(Campaign c : campaignList)
        {
            campaignRecordTypesById.put(c.Id, c.RecordType.DeveloperName);
        }
        System.debug('Campaign Record Types By Id ' + campaignRecordTypesById);

        if(Trigger.isInsert || Trigger.isUpdate)
        {
            //Get all Opportunities that are linked to the Contacts we are Inserting / Updating, ordered by Created Date
            List<Opportunity> OpportunityList = new List<Opportunity>([SELECT Id, Contact__c FROM Opportunity WHERE Contact__c IN :contactIds AND IsClosed = false ORDER BY CreatedDate DESC]);
            
            //If we got any opportunities
            if (opportunityList.size() > 0) 
            {
                //Fill the OpportunitiesByContact Map - a map linking Contact IDs to a List of Opportunities that are linked to that contact
                //The Opportunities listed will be ordered by Created Date (descending)
                for (Opportunity o: opportunityList) 
                {
                    //If we have a List in our Map for this Opportunity's Contact, append to that List
                    if (OpportunitiesByContactMap.containsKey(o.Contact__c)) 
                    {
                        // This may not be necessary; we only want the first Opportunity found
                        OpportunitiesByContactMap.get(o.Contact__c).add(o);
                    }
                    //If the List has not yet been created, add it
                    else 
                    {
                        List<Opportunity> newList = new List<Opportunity>();
                        newList.add(o);
                        OpportunitiesByContactMap.put(o.Contact__c, newList);
                    }
                }
            }
        }
        
        if(run)
        {
            Set<String> acceptableMajors = new Set<String> {'PSMajors', 'Academic', 'ASU Colleges', 'Degree Search by Interest'};

            //Build the list of CMs that we will be searching for for primaries, sorted by Contacts / Leads
            //Concern: what to do with the CMs that are being affected by the trigger?
            //If we're inserting, always include them.
            //If we're updating or deleting, don't include them (for now). The updated ones will be included later, the deleted ones won't be included
            List<CampaignMember> cmsForContacts = [SELECT Id, Status, CreatedDate, ContactId, Is_Primary_Interest__c, Last_Member_Status_Change__c, Campaign_Type__c, Campaign.RecordType.DeveloperName 
                                        FROM CampaignMember 
                                        WHERE ContactId IN :contactIds 
                                        AND Id NOT IN :cmIds2
                                        AND Status != 'No Longer Interested' 
                                        AND Campaign.RecordType.DeveloperName = 'Interest' 
                                        AND Campaign.Type IN :acceptableMajors];

            System.debug('CMs For Contact ' + cmsForContacts);

            for(CampaignMember cm : cmsForContacts)
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

            System.debug('Campaign Members By Contact Map 1 ' + CampaignMembersByContactMap);
            
            //When inserting or updating, need to add the new CMs to the map
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                for(Integer x = 0; x < triggerObjectListContact.size(); x++)
                {
                    CampaignMember cm = triggerObjectListContact.get(x);
                    if(Trigger.isUpdate)
                    {
                        if(cm.Status != triggerObjectListContactOld.get(x).Status)
                        {
                            cm.Last_Member_Status_Change__c = Datetime.now();
                        }
                    }
                    
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

            System.debug('Campaign Members By Contact Map 2 ' + CampaignMembersByContactMap);
            
            List<CampaignMember> cmsForLeads = [SELECT Id, Status, CreatedDate, LeadId, Is_Primary_Interest__c, Campaign_Type__c, Last_Member_Status_Change__c, Campaign.RecordType.DeveloperName
                                    FROM CampaignMember 
                                    WHERE LeadId IN :leadIds 
                                    AND Id NOT IN :cmIds2
                                    AND Status != 'No Longer Interested' 
                                    AND Campaign.RecordType.DeveloperName = 'Interest' 
                                    AND Campaign.Type IN :acceptableMajors];
            for(CampaignMember cm : cmsForLeads)
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
            
            //When inserting or updating, need to add the new CMs to the map
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                for(Integer x = 0; x < triggerObjectListLead.size(); x++)
                {
                    CampaignMember cm = triggerObjectListLead.get(x);
                    if(Trigger.isUpdate)
                    {
                        if(cm.Status != triggerObjectListLeadOld.get(x).Status)
                        {
                            cm.Last_Member_Status_Change__c = Datetime.now();
                        }
                    }
                    
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
    
            if(CampaignMembersByContactMap.size() > 0)
            {
                for(List<CampaignMember> objectList : CampaignMembersByContactMap.values())
                {
                    //Update the Primary Interest on the CM
                    CampaignMember primary;
                    
                    //Pass 1 - Find PSMajor w/ greatest Last Member Status Change 
                    for(CampaignMember ocm : objectList)
                    {
                        if(ocm.Campaign_Type__c == 'PSMajors' && (primary == null || ocm.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) && ocm.Status != 'No Longer Interested')
                        {
                            primary = ocm;
                        }
                    }
                    
                    //Pass 2 - Find any CM w/ greatest Last Member Status Change 
                    if(primary == null)
                    {
                        for(CampaignMember ocm : objectList)
                        {
                            if(ocm.Status != 'No Longer Interested' && (primary == null || ocm.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c))
                            {
                                primary = ocm;
                            }
                        }
                    }
                    
                    //By now we should have a Primary
                    //Set all CMs which need to be made FALSE
                    if(primary != null)
                    {
                        if(primary.Is_Primary_Interest__c != TRUE)
                        {
                            primaries.add(primary);
                        }
                        for(CampaignMember ocm : objectList)
                        {
                            if(ocm.Is_Primary_Interest__c == TRUE && ocm != primary)
                            {
                                objectsToFalsify.add(ocm);
                            }
                        }
                    }
                }
            }
            
            if(CampaignMembersByLeadMap.size() > 0)
            {
                for(List<CampaignMember> objectList : CampaignMembersByLeadMap.values())
                {  
                    //Update the Primary Interest on the CM
                    CampaignMember primary;
                    
                    //Pass 1 - Find PSMajor w/ greatest Last Member Status Change 
                    for(CampaignMember ocm : objectList)
                    {
                        if(ocm.Campaign_Type__c == 'PSMajors' && (primary == null || ocm.Last_Member_Status_Change__c > primary.Last_Member_Status_Change__c) && ocm.Status != 'No Longer Interested')
                        {
                            primary = ocm;
                        }
                    }
                    
                    //Pass 2 - Find any CM w/ greatest Last Member Status Change 
                    if(primary == null)
                    {
                        for(CampaignMember ocm : objectList)
                        {
                            if(ocm.Status != 'No Longer Interested' && (primary == null || ocm.Last_Member_Status_Change__c >= primary.Last_Member_Status_Change__c))
                            {
                                primary = ocm;
                            }
                        }
                    }
                    
                    //By now we should have a Primary
                    //Set all CMs which need to be made FALSE
                    if(primary != null)
                    {
                        if(primary.Is_Primary_Interest__c != TRUE)
                        {
                            primaries.add(primary);
                            for(CampaignMember ocm : objectList)
                            {
                                if(ocm.Is_Primary_Interest__c == TRUE && ocm != primary)
                                {
                                    objectsToFalsify.add(ocm);
                                }
                            }
                        } 
                    }
                }
            }
        }
        
        System.debug('Primary ' + primaries);
        System.debug('Objects To Falsify ' + objectsToFalsify);
    }
    
    /** 
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() 
    {
        //If we're deleting, get the IDs of the CMs we're deleting
        if (Trigger.IsDelete) 
        {
            cmIds = Trigger.oldMap.keySet();
        }
        //Else, get the IDs of the CMs we're inserting / updating / whatever
        else
        {
            cmIds = Trigger.newMap.keySet();
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

        if(objectsToFalsify.contains(cm))
        {
          objectsToFalsify.remove(cm);
          cm.Is_Primary_Interest__c = FALSE;
        }
        
        if(primaries.contains(cm))
        {
          primaries.remove(cm);
          cm.Is_Primary_Interest__c = TRUE;
        }

        //Update the Last Member Status Change date of the CM to now
        cm.Last_Member_Status_Change__c = Datetime.now();
        
        //If this CM is not linked to an Opportunity and the CM's Contact has Opportunities, link the first (most recent) Opportunity to the CM
        if (cm.Opportunity__c == null && OpportunitiesByContactMap.containsKey(cm.ContactId)) 
        {
            cm.Opportunity__c = OpportunitiesByContactMap.get(cm.ContactId)[0].Id;
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

        if(run)
        {
          if(objectsToFalsify.contains(cm))
          {
            objectsToFalsify.remove(cm);
            cm.Is_Primary_Interest__c = FALSE;
          }
            
          if(primaries.contains(cm))
          {
            primaries.remove(cm);
            cm.Is_Primary_Interest__c = TRUE;
          }
        }
        else
        {
            run = TRUE;
        }
        
        //If we've changed contacts and the new contact has Opportunities, link the first (most recent) Opportunity on the new Contact to the CM
        if (cm.ContactId != oldCm.ContactId && OpportunitiesByContactMap.containsKey(cm.ContactId))
        {
            cm.Opportunity__c = OpportunitiesByContactMap.get(cm.ContactId)[0].Id;
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
    public void andFinally() 
    {
        Set<Id> interestOpportunityIds = new Set<Id>();
        Set<Id> interestContactIds = new Set<Id>();
        Set<Id> interestLeadIds = new Set<Id>();
        Set<Id> nationalMeritContactIds = new Set<Id>();
        
        Map<Id, List<CampaignMember>> interestRecordsByContactOrLeadMap = new Map<Id, List<CampaignMember>>(); 
        List<Opportunity> interestOpportunities = new List<Opportunity>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();
        
        List<Lead> interestLeads = new List<Lead>();
        List<Lead> leadsToUpdate = new List<Lead>();
        
        //Get all Interest / Scholarship CMs from the list that is being affected
        List<CampaignMember> cmList = new List<CampaignMember>([SELECT Id, CampaignId, Opportunity__c, ContactId, LeadId, Campaign.RecordType.DeveloperName FROM CampaignMember WHERE Id IN :cmIds AND Campaign.RecordType.DeveloperName IN ('Interest', 'Scholarship')]);
        
        //Populate the list of Interest Opportunities / Contacts / Leads
        for (CampaignMember cm : cmList) 
        {
            if (cm.Opportunity__c != null)
            {
                interestOpportunityIds.add(cm.Opportunity__c);
            }
            if (cm.ContactId != null)
            {
                interestContactIds.add(cm.ContactId);
            }
            if (cm.LeadId != null)
            {
                interestLeadIds.add(cm.LeadId);
            }
        }
        
        Set<String> NationalMeritCampaignNames = new Set<String>{'National Achievement Finalist', 
            'National Achievement Semifinalist', 
            'National Hispanic Scholar Finalist',
            'National Merit Finalist', 
            'National Merit Semifinalist', 
            'Gammage Scholar',
            'Flinn Designate', 
            'Flinn Semifinalist', 
            'Flinn Finalist'};
                
        // Build a List of all Campaign Members for Contacts who have a Scholarship that should indicate that they are a National Merit Scholar
        List<CampaignMember> nmsList = new List<CampaignMember>([SELECT Id, ContactId 
                                                                 FROM CampaignMember 
                                                                 WHERE ContactId IN :interestContactIds 
                                                                 AND Campaign.RecordType.DeveloperName = 'Scholarship' 
                                                                 AND Campaign.Name IN :NationalMeritCampaignNames]);
        
        //Extract the Contact IDs from our CM set
        for (CampaignMember cm: nmsList) 
        {
            nationalMeritContactIds.add(cm.ContactId);
        }
        
        //If any of the CMs we are working with have Opportunities or Leads
        if (interestOpportunityIds.size() > 0)
        {
            //Get info about those Opportunities / Leads
            interestOpportunities = new List<Opportunity>([SELECT Id, Contact__c, primary_interest__c, primary_interest__r.Type, National_Merit_Semifinalist__c 
                                                           FROM Opportunity 
                                                           WHERE Id IN :interestOpportunityIds]);
        }

        if(interestContactIds.size() > 0 || interestLeadIds.size() > 0)
        {
            interestLeads = new List<Lead>([SELECT Id, primary_interest__c, primary_interest__r.Type 
                                            FROM Lead 
                                            WHERE Id IN :interestLeadIds]);
            
            //Get all Interest CMs for those Contacts / Leads, ordered by Last Member Status Change
            //Note that these may include CMs that we're not affecting in this trigger!
            List<CampaignMember> allCmList = new List<CampaignMember>([SELECT Id, Status, ContactId, LeadId, CampaignId, Campaign.Type, CreatedDate 
                                                                       FROM CampaignMember 
                                                                       WHERE (ContactId IN :interestContactIds OR LeadId IN :interestLeadIds) 
                                                                       AND Campaign.Type IN ('PSMajors', 'Academic', 'ASU College', 'Degree Search by Interest') 
                                                                       AND Campaign.RecordType.DeveloperName = 'Interest' 
                                                                       AND Status = 'Interested' 
                                                                       ORDER BY Last_Member_Status_Change__c DESC]);
            
            //Parse the CMs up into lists by their Contact / Lead. This will remain ordered by Last Member Status Change
            for (CampaignMember cm: allCmList)
            {
                if (interestRecordsByContactOrLeadMap.containsKey(cm.ContactId))
                {
                    interestRecordsByContactOrLeadMap.get(cm.ContactId).add(cm);
                }
                else if (interestRecordsByContactOrLeadMap.containsKey(cm.LeadId)) 
                {
                    interestRecordsByContactOrLeadMap.get(cm.LeadId).add(cm);
                }
                else 
                {
                    List<CampaignMember> mapCmList = new List<CampaignMember>();
                    mapCmList.add(cm);
                    if (cm.ContactId != null) 
                    {
                        interestRecordsByContactOrLeadMap.put(cm.ContactId, mapCmList);
                    }
                    else if (cm.LeadId != null) 
                    {
                        interestRecordsByContactOrLeadMap.put(cm.LeadId, mapCmList);
                    }
                }
            }
        }
        
        //For each Opportunity attached to the CMs we are affecting
        for (Opportunity o: interestOpportunities) 
        {
            Boolean updateOpportunity = false;
            
            //Is this opportunity's Contact a NM scholar?
            Boolean nationalMerit = nationalMeritContactIds.contains(o.Contact__c);
            
            //If the Opportunity's National Merit data is out of sync, update it
            if (o.National_Merit_Semifinalist__c != nationalMerit) 
            {
                o.National_Merit_Semifinalist__c = nationalMerit;
                updateOpportunity = true;
            }
            
            List<CampaignMember> oppCmList;
            //If this Opportunity's Contact has Campaign Members that were affected by this trigger's change, get those CMs
            if (interestRecordsByContactOrLeadMap.containsKey(o.Contact__c)) 
            {
                oppCmList = interestRecordsByContactOrLeadMap.get(o.Contact__c);
            }
            
            //If we have affected CMs
            if (oppCmList != null && oppCmList.size() > 0) 
            {
                Id interestCampaignId;
                //Get the ID of the Campaign of the first PSMajor Interest CM (i.e. the most recently changed)
                for (CampaignMember cm: oppCmList) 
                {
                    if (cm.Campaign.Type == 'PSMajors') 
                    {
                        interestCampaignId = cm.CampaignId;
                        break;
                    }
                }
                // If we did not find a PSMajors Interest record, use the most recent Interest in the list as a whole
                if (interestCampaignId == null)
                {
                    interestCampaignId = oppCmList[0].CampaignId;
                }
                
                //We now have the primary interest CM for the Opportunity
                //If the primary Interest record we found isn't already set on the Opportunity, it's time to update it
                if (interestCampaignId != null && o.Primary_Interest__c != interestCampaignId) 
                {
                    o.Primary_Interest__c = interestCampaignId;
                    updateOpportunity = true;
                }
            }
            
            if (updateOpportunity)
            {
                opportunitiesToUpdate.add(o);
            }
        }
        
        //Update the Opportunities if we need to
        if (opportunitiestoUpdate.size() > 0) 
        {
            update opportunitiestoUpdate;
        }
        
        //For each Lead attached to the CMs we are affecting
        for (Lead l: interestLeads) 
        {
            List<CampaignMember> leadCmList;
            
            //If this Lead has Campaign Members that were affected by this trigger's change, get those CMs
            if (interestRecordsByContactOrLeadMap.containsKey(l.Id)) 
            {
                leadCmList = interestRecordsByContactOrLeadMap.get(l.Id);
            }
            
            //If we have affected CMs 
            if (leadCmList != null && leadCmList.size() > 0) 
            {
                Id interestCampaignId;
                
                //Get the ID of the Campaign of the first PSMajor Interest CM (i.e. the most recently changed)
                for (CampaignMember cm: leadCmList) 
                {
                    if (cm.Campaign.Type == 'PSMajors') 
                    {
                        interestCampaignId = cm.CampaignId;
                        break;
                    }
                }
                
                // If we did not find a PSMajors Interest record, use the most recent Interest in the list as a whole
                if (interestCampaignId == null)
                {
                    interestCampaignId = leadCmList[0].CampaignId;
                }
                
                //We now have the primary interest CM for the Lead 
                // If the Interest record we found isn't already set on the Lead, it's time to update it
                if (interestCampaignId != null && l.Primary_Interest__c != interestCampaignId) 
                {
                    l.Primary_Interest__c = interestCampaignId;
                    leadsToUpdate.add(l);
                }
            }
        }
        
        //Update the Leads if we need to
        if (leadsToUpdate.size() > 0) 
        {
            update leadsToUpdate;
        }
        
        if(objectsToFalsify.size() > 0 || primaries.size() > 0)
        {
            List<CampaignMember> itemsToUpdate = new List<CampaignMember>();
            for(CampaignMember cm : objectsToFalsify)
            {
                cm.Is_Primary_Interest__c = FALSE;
                itemsToUpdate.add(cm);
            }
            for(CampaignMember cm : primaries)
            {
                cm.Is_Primary_Interest__c = TRUE;
                itemsToUpdate.add(cm);
            }
            run = FALSE;
            update itemsToUpdate;
        }
    }
}