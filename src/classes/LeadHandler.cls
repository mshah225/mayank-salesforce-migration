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
	public void bulkBefore() {
	}
	
	/**
	 * bulkAfter
	 *
	 * This method is called prior to execution of an AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkAfter() {
		// Grab the status for converted Leads
		List<LeadStatus> statusList = new List<LeadStatus>([SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]);
		if (statusList.size() > 0)
			convertedStatus = statusList[0];
	}
	
	/**
	 * beforeInsert
	 *
	 * This method is called iteratively for each record to be inserted during a BEFORE
	 * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
	 */
	public void beforeInsert(SObject so){}
	
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
	public void afterInsert(SObject so) {
		Lead l = (Lead)so;
		if (l.Convert_Perform_Conversion__c) {
			leadsToConvert.add(l);
		}
	}

	/**
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	public void afterUpdate(SObject oldSo, SObject so) {
		Lead l = (Lead)so;
		Lead oldL = (Lead)oldSo;
		if (l.Convert_Perform_Conversion__c && oldL.Convert_Perform_Conversion__c == false) {
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
	public void andFinally() {
		convertLeads();
		//createLeadInterestOpportunities(leadsToConvert);
	}
	
	private void convertLeads() {
		if (leadsToConvert.size() == 0)
			return;

		List<Database.Leadconvert> leadConvertList = new List<Database.Leadconvert>();
		List<List<Database.Leadconvert>> leadConvertBatches = new List<List<Database.Leadconvert>>();
		List<Database.LeadConvertResult> leadConversionResults = new List<Database.LeadConvertResult>();
		Set<Id> LeadsRequiringLIReparenting = new Set<Id>();
		Integer count = 0;
		
		for (Lead l: leadsToConvert) {
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.SetLeadId(l.Id);
			lc.setConvertedStatus(convertedStatus.MasterLabel);
			if (l.Convert_Contact__c != null) {
				lc.setContactId(l.Convert_Contact__c);
				lc.setAccountId(l.Convert_Contact_Account_ID__c);
			}
			
			// Reparent related Lead Interests if we're not creating an Opportunity
			// Deactivate related Lead Interests if we are creating an Opportunity
			//
			if (!l.Convert_Create_Opportunity__c)
				LeadsRequiringLIReparenting.add(l.Id);
			else
				leadIdsCleanUpLeadInterests.add(l.Id);

			lc.setDoNotCreateOpportunity(!l.Convert_Create_Opportunity__c);
						
			leadConvertList.add(lc);
			count++;
			//ConvertLead allows up to 100 leads per call according to docs, but 99 seems to be the actual limit
			//
			if (count == 100) {
				leadConvertBatches.add(leadConvertList.clone());
				leadConvertList.clear();
				count = 0;
			}
		}
		// If we have any Leadconverts left over, add the final batch 
		//
		if (count > 0)
			leadConvertBatches.add(leadConvertList);
			
		for (List<Database.Leadconvert> lcList: leadConvertBatches) {
	        List<Database.LeadConvertResult> lcResultList = Database.convertLead(lcList, false);
	        //system.debug('GRF: ' + lcResultList);
	        leadConversionResults.addAll(lcResultList);
		}
		
		reparentRelatedLeadInterests(LeadsRequiringLIReparenting);
        
	}

/*	
	private void CreateLeadInterestOpportunities(List<Lead> leadList) {
		if (leadList.size() == 0)
			return;
			
		List<Opportunity> oppsToInsert = new List<Opportunity>();
		Set<Id> LeadIds = new Set<Id>();
		for (Lead l: leadList)
			LeadIds.add(l.Id);
		List<Lead_Interest__c> leadInterestList = new List<Lead_Interest__c>([SELECT Id, OwnerId, IsDeleted, Name, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Leads__c, Eligibility__c, Plan__c, Contact__c, Status__c, Term__c, Primary_Source__c, Secondary_Source__c, Type__c, College__c, Academic_Interest__c, Test_Record__c, Qualifying__c, Send_Email__c, External_Application_Number__c, Send_Email_ID__c from Lead_Interest__c WHERE Leads__c IN :leadIds]);
		//Need to requery to get the Converted Contact Ids
		//
		Map<Id, Lead> leadToContactIdMap = new Map<Id, Lead>([SELECT Id, ConvertedContactId FROM Lead WHERE Id in :leadIds]);
		
		for (Lead_Interest__c li: leadInterestList) {
			// Here's the logic for determining which LIs to convert; keeping it simple for now
			//
			if (li.Status__c != null) {
				Opportunity o = new Opportunity();
				o.Academic_Interest__c = li.Academic_Interest__c;
				o.College__c = li.College__c;
				o.Contact__c = li.Contact__c;
				o.Eligibility__c = li.Eligibility__c;
				o.External_Application_Number__c = li.External_Application_Number__c;
				o.Academic_Plan__c = li.Plan__c;
				o.Qualifying__c = li.Qualifying__c;
				o.Secondary_Source__c = li.Secondary_Source__c;
				o.Primary_Source__c = li.Primary_Source__c;
				o.Lead_Interest_Status__c = li.Status__c;
				o.Term__c = li.Term__c;
				o.Test_Record__c = li.Test_Record__c;
				o.Lead_Interest_Type__c = li.Type__c;
				o.Lead_Interest_Key__c = li.Name;
				o.Lead_Interest_Record_Type__c = li.RecordType.Name;
				o.OwnerId = li.OwnerId;
				o.Lead_Interest__c = li.Id;
				o.Contact__c = leadToContactIdMap.get(li.leads__c).ConvertedContactId;
				
				//Defaulting these for now
				o.StageName = 'Applicant - Incomplete';
				o.CloseDate = Date.today();
				o.Name = 'LI Conversion: ' + li.Name;
				
				oppsToInsert.add(o);
			}
			// TODO: Add exception handling 
			if (oppsToInsert.size() > 0) 
				insert oppsToInsert;
				
			leadInterestsConverted = true;
		}
	}
*/
	
	private void reparentRelatedLeadInterests(Set<Id> leadIds) {
		if (leadIds.size() == 0)
			return;
			
		List<Lead_Interest__c> leadInterestList = new List<Lead_Interest__c>([SELECT Id, OwnerId, IsDeleted, Name, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Leads__c, Eligibility__c, Plan__c, Contact__c, Status__c, Term__c, Primary_Source__c, Secondary_Source__c, Type__c, College__c, Academic_Interest__c, Test_Record__c, Qualifying__c, Send_Email__c, External_Application_Number__c, Send_Email_ID__c from Lead_Interest__c WHERE Leads__c IN :leadIds]);
		if (leadInterestList.size() == 0)
			return;
		//Need to requery to get the Converted Contact Ids
		//
		Map<Id, Lead> leadToContactIdMap = new Map<Id, Lead>([SELECT Id, ConvertedContactId FROM Lead WHERE Id in :leadIds]);
		
		for (Lead_Interest__c li: leadInterestList) {
			li.Contact__c = leadToContactIdMap.get(li.leads__c).ConvertedContactId;
		}
		
		update leadInterestList;
		
	}

}