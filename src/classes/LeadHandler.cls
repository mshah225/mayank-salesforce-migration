public without sharing class LeadHandler
	implements ITrigger

{
	private LeadStatus convertedStatus = new LeadStatus();
	private List<Lead> leadsToConvert = new List<Lead>();
	private Set<Id> leadIdsCleanUpLeadInterests = new Set<Id>();
	private boolean LeadInterestsConverted = false;

	/**
	 * bulkBefore
	 *
	 * This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkBefore(){}

	/**
	 * bulkAfter
	 *
	 * This method is called prior to execution of an AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkAfter()
	{
		// Grab the status for converted Leads
		List<LeadStatus> statusList = [SELECT Id, MasterLabel
									   FROM LeadStatus
									   WHERE IsConverted=true LIMIT 1];

		if (statusList.size() > 0)
		{
			convertedStatus = statusList[0];
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
		Lead newLead = (Lead) so;

		newLead.Lead_Assignment_Number__c = OpportunityService.generateOpportunityAssignmentNumber();
	}

	/**
	 * beforeUpdate
	 *
	 * This method is called iteratively for each record to be updated during a BEFORE
	 * trigger.
	 */
	public void beforeUpdate(SObject oldSo, SObject so){}

	/**
	 * beforeDelete
	 *
	 * This method is called iteratively for each record to be deleted during a BEFORE
	 * trigger.
	 */
	public void beforeDelete(SObject so){}

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
	public void afterInsert(SObject so)
	{
		Lead l = (Lead)so;

		if (l.Convert_Perform_Conversion__c)
		{
			leadsToConvert.add(l);
		}
	}

	/**
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	public void afterUpdate(SObject oldSo, SObject so)
	{
		Lead l = (Lead)so;
		Lead oldL = (Lead)oldSo;

		if (l.Convert_Perform_Conversion__c && oldL.Convert_Perform_Conversion__c == false)
		{
			leadsToConvert.add(l);
		}
	}

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
		convertLeads();
	}

	private void convertLeads()
	{
		if (leadsToConvert.size() == 0)
		{
			return;
		}

		List<Database.Leadconvert> leadConvertList = new List<Database.Leadconvert>();
		List<List<Database.Leadconvert>> leadConvertBatches = new List<List<Database.Leadconvert>>();
		List<Database.LeadConvertResult> leadConversionResults = new List<Database.LeadConvertResult>();
		Set<Id> LeadsRequiringLIReparenting = new Set<Id>();
		Integer count = 0;

		for (Lead l : leadsToConvert)
		{
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.SetLeadId(l.Id);
			lc.setConvertedStatus(convertedStatus.MasterLabel);

			if (l.Convert_Contact__c != null)
			{
				lc.setContactId(l.Convert_Contact__c);
				lc.setAccountId(l.Convert_Contact_Account_ID__c);
			}

			// Reparent related Lead Interests if we're not creating an Opportunity
			// Deactivate related Lead Interests if we are creating an Opportunity
			if (!l.Convert_Create_Opportunity__c)
			{
				LeadsRequiringLIReparenting.add(l.Id);
			}
			else
			{
				leadIdsCleanUpLeadInterests.add(l.Id);
			}

			lc.setDoNotCreateOpportunity(!l.Convert_Create_Opportunity__c);

			leadConvertList.add(lc);
			count++;

			// ConvertLead allows up to 100 leads per call according to docs, but 99 seems to be the actual limit
			if (count == 100)
			{
				leadConvertBatches.add(leadConvertList.clone());
				leadConvertList.clear();
				count = 0;
			}
		}

		// If we have any Leadconverts left over, add the final batch
		if (count > 0)
		{
			leadConvertBatches.add(leadConvertList);
		}

		for (List<Database.Leadconvert> lcList : leadConvertBatches)
		{
	        List<Database.LeadConvertResult> lcResultList = Database.convertLead(lcList, false);
	        leadConversionResults.addAll(lcResultList);
		}

        Set<Id> convertedLeadIds = new Set<Id>();

        for (Database.LeadConvertResult lcr : leadConversionResults)
        {
            if (lcr.isSuccess())
            {
                convertedLeadIds.add(lcr.getLeadId());
            }
        }

		reparentRelatedLeadInterests(LeadsRequiringLIReparenting);

		System.debug('!!! Mapping data from these leads ' + convertedLeadIds);

        List<Opportunity> oppsToUpdate = OpportunityService.mapLeadDataToOpportunity(convertedLeadIds);

		System.debug('About to update these opps: ' + oppsToUpdate);

        update oppsToUpdate;
	}

	private void reparentRelatedLeadInterests(Set<Id> leadIds)
	{
		if (leadIds.size() == 0)
		{
			return;
		}

		List<Lead_Interest__c> leadInterestList = [SELECT Id, OwnerId, IsDeleted, Name, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Leads__c, Eligibility__c, Plan__c, Contact__c, Status__c, Term__c, Primary_Source__c, Secondary_Source__c, Type__c, College__c, Academic_Interest__c, Test_Record__c, Qualifying__c, Send_Email__c, External_Application_Number__c, Send_Email_ID__c
												   FROM Lead_Interest__c
												   WHERE Leads__c IN :leadIds];

		if (leadInterestList.size() == 0)
		{
			return;
		}

		// Need to requery to get the Converted Contact Ids
		Map<Id, Lead> leadToContactIdMap = new Map<Id, Lead>([SELECT Id, ConvertedContactId
															  FROM Lead
															  WHERE Id IN :leadIds]);

		for (Lead_Interest__c li: leadInterestList)
		{
			li.Contact__c = leadToContactIdMap.get(li.leads__c).ConvertedContactId;
		}

		update leadInterestList;
	}

}