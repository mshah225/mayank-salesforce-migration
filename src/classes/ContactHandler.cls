public without sharing class ContactHandler implements ITrigger 
{
    private Map<Id, Account> existingAccountMap = new Map<Id, Account>();
    private List<Account> accountList;
    private Set<Id> accountIdsToUpdate = new Set<Id>();
    private static Id ExtMasteredContactRTId;
    private static Id SFMasteredContactRTId;
    private static Id ExtMasteredContactAccountRTId;
    private static Id SFMasteredContactAccountRTId;
    private static Id bucketAccountId;
    private Map<Id, Id> contactToAccountRTIdMap = new Map<Id, Id>();
    private Map<Id, Id> accountIdsByContactId = new Map<Id, Id>();
    private static List<Account> accountsToCreate;
    private List<Account> accountsToUpdate = new List<Account>();
    private List<Contact> contactsToCheckIfUpdate = new List<Contact>();

    public void bulkBefore()
    {
        accountsToCreate = new List<Account>();

        if (Trigger.IsInsert || Trigger.IsUpdate) 
        {
            if(ExtMasteredContactRTId == null
                || SFMasteredContactRTId == null
                || ExtMasteredContactAccountRTId == null
                || SFMasteredContactAccountRTId == null)
            {
                // Get the pertinent RecordType IDs
                List<RecordType> recordTypeList = new List<RecordType>([
                    SELECT Id, sObjectType, DeveloperName 
                    FROM RecordType 
                    WHERE sObjectType IN ('Account', 'Contact')
                ]);

                for (RecordType rt : recordTypeList) 
                {
                    if (rt.SobjectType == 'Contact') 
                    {
                        if (rt.DeveloperName == 'External_Mastered')
                        {
                            ExtMasteredContactRTId = rt.Id;
                        }
                        else if (rt.DeveloperName == 'SF_Mastered')
                        {
                            SFMasteredContactRTId = rt.Id;
                        }
                    }
                    else if (rt.SobjectType == 'Account') 
                    {
                        if (rt.DeveloperName == 'External_Mastered_Contact')
                        {
                            ExtMasteredContactAccountRTId = rt.Id;
                        }
                        else if (rt.DeveloperName == 'SF_Mastered_Contact')
                        {
                            SFMasteredContactAccountRTId = rt.Id;
                        }
                    }
                }
            }    

            // Populate a Map that we use to translate from Contact RT Id to Accound RT Id
            contactToAccountRTIdMap.put(ExtMasteredContactRTId, ExtMasteredContactAccountRTId);
            contactToAccountRTIdMap.put(SFMasteredContactRTId, SFMasteredContactAccountRTId);

            // Get the Id for the old bucket Account to check
            if(bucketAccountId == null)
            {
                List<Account> bucketAccountList = new List<Account>([
                    SELECT Id 
                    FROM Account 
                    WHERE Name = 'Arizona State University'
                ]);

                if (bucketAccountList.size() > 0)
                {
                    bucketAccountId = bucketAccountList[0].Id;
                }
            }

            for(SObject so : Trigger.new)
            {
                Contact c = (Contact) so;

                if (c.EMPLID__c == null && c.RecordTypeId != SFMasteredContactRTId)
                {
                    c.RecordTypeId = SFMasteredContactRTId;
                }
                else if(c.EMPLID__c != null && c.RecordTypeId != ExtMasteredContactRTId)
                {
                    c.RecordTypeId = ExtMasteredContactRTId;
                }

                if(Trigger.IsInsert)
                {
                    accountsToCreate.add(createAccount(c));
                }
                else if(Trigger.IsUpdate)
                {
                    if(c.AccountId == null || c.AccountId == bucketAccountId)
                    {
                        accountsToCreate.add(createAccount(c));
                    }
                    else
                    {
                        contactsToCheckIfUpdate.add(c);    
                    }
                }
            }

            if(accountsToCreate.size() > 0)
            {
                insert accountsToCreate;
                for(Integer x = 0; x < Trigger.new.size(); x++)
                {
                    Contact c = (Contact) Trigger.new.get(x);
                    Account a = accountsToCreate.get(x);
                    c.AccountId = a.Id;
                }
            }

            if(contactsToCheckIfUpdate.size() > 0)
            {
                // Get a Map of all the existing related Accounts
                Set<Id> existingAccountIds = new Set<Id>();
                for (Contact c : contactsToCheckIfUpdate)
                {
                    existingAccountIds.add(c.AccountId);
                }

                existingAccountMap = new Map<Id, Account>([
                    SELECT Id, Name, Contact__c, OwnerId, RecordType.Name 
                    FROM Account 
                    WHERE Id IN :existingAccountIds
                ]);
            }
        }  
    }
    
    public void beforeInsert(SObject so)
    {
        Contact c = (Contact)so;
        //Automatically generate a PIN for a new contact
        c.Self_Service_PIN__c = ContactService.generateRandomPin(c.Birthdate);
    }
    
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        Contact c = (Contact) so;
        Account a = existingAccountMap.get(c.AccountId);
        if(a != null && 
            (a.Name != c.FirstName + ' ' + c.LastName 
                || a.OwnerId != c.OwnerId
                || a.RecordTypeId != contactToAccountRTIdMap.get(c.RecordTypeID)
                || a.Contact__c != c.Id
            ))
        {
            a.Name = c.FirstName + ' ' + c.LastName;
            a.OwnerId = c.OwnerId;
            a.RecordTypeId = contactToAccountRTIdMap.get(c.RecordTypeID);
            a.Contact__c = c.Id;

            accountsToUpdate.add(a);
        }
    }

    public void beforeDelete(SObject so) { }
    
    public void beforeFinally() 
    { 
        if(accountsToUpdate.size() > 0)
        {
            update accountsToUpdate;
        }
    }

    public void bulkAfter()
    {   
        if(Trigger.IsInsert && accountsToCreate.size() > 0)
        {
            for(Integer x = 0; x < Trigger.new.size(); x++)
            {
                Contact c = (Contact) Trigger.new.get(x);
                Account a = accountsToCreate.get(x);
                a.Contact__c = c.Id;
                accountsToCreate[x] = a;
            } 

            update accountsToCreate;
        }
    }

    public void afterInsert(SObject so) { }

    public void afterUpdate(SObject oldSo, SObject so) { }

    public void afterDelete(SObject so) { }

    public void andFinally() { }

    private Account createAccount(Contact c)
    {
        // Create the new 1:1 Account record for this Contact
        Account a = new Account(
            Name = c.FirstName + ' ' + c.LastName, 
            RecordTypeId = contactToAccountRTIdMap.get(c.RecordTypeID),
            OwnerId = c.OwnerId
        );

        return a;
    }
}