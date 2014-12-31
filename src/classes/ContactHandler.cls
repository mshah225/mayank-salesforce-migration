public without sharing class ContactHandler 
	implements ITrigger 
{
	private boolean okToProcess1to1 = true;
	private boolean alreadyRanForInsert = false;
	private Map<Id, Account> existingAccountMap;
	private List<Account> accountList;
	private Set<Id> accountIdsToUpdate = new Set<Id>();
	private Id ExtMasteredContactRTId;
	private Id SFMasteredContactRTId;
	private Id ExtMasteredContactAccountRTId;
//	private Id ExtMasteredOrgAccountRTId;
	private Id SFMasteredContactAccountRTId;
//	private Id SFMasteredOrgAccountRTId;
	private Map<Id,Id> contactToAccountRTIdMap = new Map<Id,Id>();
	private Id bucketAccountId;
	

	public void bulkBefore()
	{
		if (Trigger.IsInsert)
			alreadyRanForInsert = true;
			 
		if (Trigger.IsInsert || Trigger.IsUpdate) {
			// Get the pertinent RecordType IDs
			List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, sObjectType, DeveloperName FROM RecordType WHERE sObjectType IN ('Account', 'Contact')]);
			for (RecordType rt: recordTypeList) {
				if (rt.SobjectType == 'Contact') {
					if (rt.DeveloperName == 'External_Mastered')
						ExtMasteredContactRTId = rt.Id;
					else if (rt.DeveloperName == 'SF_Mastered')
						SFMasteredContactRTId = rt.Id;
				}
				else if (rt.SobjectType == 'Account') {
					if (rt.DeveloperName == 'External_Mastered_Contact')
						ExtMasteredContactAccountRTId = rt.Id;
					//else if (rt.DeveloperName == 'External_Mastered_Org')
					//	ExtMasteredOrgAccountRTId = rt.Id;
					else if (rt.DeveloperName == 'SF_Mastered_Contact')
						SFMasteredContactAccountRTId = rt.Id;
					//else if (rt.DeveloperName == 'SF_Mastered_Org')
					//	SFMasteredOrgAccountRTId = rt.Id;
				}
			}
			
			// If any RecordTypes that we need could not be found, set a boolean so we don't bother with this 1:1 account logic 
			if (ExtMasteredContactRTId == null || 
				SFMasteredContactRTId == null ||
				ExtMasteredContactAccountRTId == null ||
				SFMasteredContactAccountRTId == null)
			{
					okToProcess1to1 = false;
			}
			else {
				// Get the Id for the old bucket Account to check
				List<Account> bucketAccountList = new List<Account>([SELECT Id FROM Account WHERE Name = 'Arizona State University']);
				if (bucketAccountList.size() > 0)
					bucketAccountId = bucketAccountList[0].Id;
				
				// Populate a Map that we use to translate from Contact RT Id to Accound RT Id
				contactToAccountRTIdMap.put(ExtMasteredContactRTId, ExtMasteredContactAccountRTId);
				contactToAccountRTIdMap.put(SFMasteredContactRTId, SFMasteredContactAccountRTId);
				
				// Get a Map of all the existing related Accounts
				Set<Id> accountIds = new Set<Id>();
				for (SObject so: Trigger.new) {
					Contact c = (Contact)so;
					accountIds.add(c.AccountId);
				}
				existingAccountMap = new Map<Id, Account>([SELECT Id, Name, RecordType.Name FROM Account WHERE Id IN :accountIds]);
				accountList = new List<Account>();
			}
		}  
	}
	
	public void bulkAfter()
	{	
		Set<Id> accountIds = new Set<Id>();
		Map<Id,Id> accountIdToContactIdMap = new Map<Id,Id>();
		if ((Trigger.isInsert || Trigger.isUpdate) && okToProcess1to1) {
			system.debug('GRF4: ' + Trigger.new);
			for (SObject so: Trigger.new) {
				Contact c = (Contact)so;
				accountIds.add(c.AccountId);
				accountIdToContactIdMap.put(c.AccountId, c.Id);
			}
			List<Account> relatedAccounts = new List<Account>([SELECT Id, RecordTypeId, Contact__c FROM Account Where Id IN :accountIds]);
			// Loop through the accounts and set the Contact reference on each Account 
			system.debug('GRF1: ' + relatedAccounts);
			if (relatedAccounts.size() > 0) {
				for (Account a: relatedAccounts) {
					a.Contact__c = accountIdToContactIdMap.get(a.Id);
				}
				update relatedAccounts;
			}
		}
	}
	
	public void beforeInsert(SObject so)
	{
		if (okToProcess1to1) {
			Contact c = (Contact)so;
			checkAccountNew(c);
		}
	}
	
	public void beforeUpdate(SObject oldSo, SObject so)
	{
		if (alreadyRanForInsert)
			return;
			 
		if (okToProcess1to1) {
			Contact c = (Contact)so;
			checkAccountNew(c);
		}
	}

	public void beforeDelete(SObject so)
	{
	}
	
	public void beforeFinally()
	{
		if ((Trigger.isInsert || Trigger.isUpdate) && okToProcess1to1) {
			system.debug('GRF5: ' + accountList);
			if (accountList.size() > 0) {
				upsert accountList;
				
				Integer i = 0;
				// Loop through the accounts and set the Account reference on each Contact 
				for (Account a: accountList) {
					if (a.Id == null)
						continue;
					Contact c = (Contact)Trigger.new[i];
					c.AccountId = a.Id;
					i++;
				}
			}
		}
	}

	public void afterInsert(SObject so)
	{
	}

	public void afterUpdate(SObject oldSo, SObject so)
	{
	}

	public void afterDelete(SObject so)
	{
	}

	public void andFinally()
	{
	}
	
	private void checkAccount (Contact c) {
		// See if we found an associated Account; if so, add it to our list and if not, create it
		// Also, if the old ASU bucket account is related, create/relate a new 1:1 account
		// '001d000000vZbZM'
		Account a = existingAccountMap.get(c.AccountId);
		if (a == null || a.Id == bucketAccountId ) {
			createAccount(c);
		}
		else {
			a.RecordTypeId = contactToAccountRTIdMap.get(c.RecordTypeID);
			accountList.add(a);
		}
		/*
		else {
			createAccount(c);
		}
		*/
	}
	
	private void checkAccountNew (Contact c) {
		// See if we found an associated Account; if so, add it to our list and if not, create it
		// Also, if the old ASU bucket account is related, create/relate a new 1:1 account
		// '001d000000vZbZM'
		
		if (c.EMPLID__c == null) {
			if (c.RecordTypeId == null || c.RecordTypeId != SFMasteredContactRTId) {
				c.RecordTypeId = SFMasteredContactRTId;
			}
		}
		else {
			if (c.RecordTypeId == null || c.RecordTypeId != ExtMasteredContactRTId) {
				c.RecordTypeId = ExtMasteredContactRTId;
			}
		}
		
		if (c.AccountId == null || c.AccountId == bucketAccountId) {
			createAccount(c);
			return;
		}
		
		
		Account a = existingAccountMap.get(c.AccountId);
		if (a == null || a.Id == bucketAccountId ) {
			createAccount(c);
		}
		else {
			if (a.RecordTypeId == null || a.RecordTypeId != contactToAccountRTIdMap.get(c.RecordTypeID)) {
				a.RecordTypeId = contactToAccountRTIdMap.get(c.RecordTypeID);
			}
			a.Name = c.FirstName + ' ' + c.LastName;
			// Fix to prevent accounts from being added to the update list twice
			// GRF, 5/13/14
			if (!accountIdsToUpdate.contains(a.Id)) {
				accountList.add(a);
				accountIdsToUpdate.add(a.Id);
			}
		}

	}	
	private void createAccount (Contact c) {
		// Create the new 1:1 Account record for this Contact
		Account a = new Account(Name = c.FirstName + ' ' + c.LastName, 
								RecordTypeId = contactToAccountRTIdMap.get(c.RecordTypeID),
								OwnerId = c.OwnerId);
		system.debug('GRF3: ' + a);
		accountList.add(a);
	}
	
}