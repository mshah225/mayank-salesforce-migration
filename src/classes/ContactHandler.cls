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

    // Vars related to Scanbiz process
    private static Id EngineeringGOEECampaignId;
    private static Id scanbizRelationshipRTId;
    private List<CampaignMember> scanbizCampaignMembers = new List<CampaignMember>();
    private List<Relationship__c> scanbizRelationships = new List<Relationship__c>();

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

                // Exclude Scanbiz created contacts
                if (c.scanbizcards__ScanBizCards__c && Trigger.IsInsert)
                {
                    continue;
                }

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

        //Scanbiz and GOEE Stuff
        
        List<Campaign> goeeCampaign = [
            SELECT Id
            FROM Campaign
            WHERE Name LIKE 'Engineering%GOEE'
            AND IsActive = true
        ];

        if (goeeCampaign.size() > 0)
        {
            EngineeringGOEECampaignId = goeeCampaign[0].Id;
        }
        else
        {
            EngineeringGOEECampaignId = null;
            System.debug(LoggingLevel.WARN, 'No Engineering - GOEE campaign was found. ' +
                'Scanbiz Contacts will not be associated to any campaigns');
        }
    }
    
    public void beforeInsert(SObject so)
    {
        Contact c = (Contact)so;

        // Cache the Account Id that was on this scanbiz contact
        if (c.scanbizcards__ScanBizCards__c)
        {
            c.Scanbiz_Account__c = c.AccountId;
            c.Corporate_Relations_Contact_Owner__c = UserInfo.getUserId();
            c.AccountId = null;
        }
        else
        {
            //Automatically generate a PIN for a new contact
            c.Self_Service_PIN__c = ContactService.generateRandomPin(c.Birthdate);
        }
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

        if(Trigger.isInsert)
        {
            for(Contact c : (List<Contact>) Trigger.new)
            {
                // We need to create a relationship and a campaign member for this
                // Contact that was provided by Scanbiz
                if (c.Scanbiz_Account__c != null)
                {

                    //Get Scanbiz Relationship RT ID if we haven't already
                    if(scanbizRelationshipRTId == null)
                    {
                        List<RecordType> scanbizRecordTypes = [
                            SELECT Id
                            FROM RecordType
                            WHERE SobjectType = 'Relationship__c'
                            AND Name = 'Contact to Account'
                        ];

                        if (scanbizRecordTypes.size() > 0)
                        {
                            scanbizRelationshipRTId = scanbizRecordTypes[0].Id;
                        }
                        else
                        {
                            break;
                            System.debug(LoggingLevel.WARN, 'No Scanbiz Record type for Relationship was found.');
                        }
                    }

                    scanbizRelationships.add(
                        RelationshipService.createScanbizRelationship(
                            c, scanbizRelationshipRTId
                        )
                    );

                    if (EngineeringGOEECampaignId != null)
                    {

                        //Get EngineeringGOEE Campaign ID if we haven't already
                        if(EngineeringGOEECampaignId == null)
                        {
                            List<Campaign> goeeCampaign = [
                                SELECT Id
                                FROM Campaign
                                WHERE Name LIKE 'Engineering%GOEE'
                                AND IsActive = true
                            ];

                            if (goeeCampaign.size() > 0)
                            {
                                EngineeringGOEECampaignId = goeeCampaign[0].Id;
                            }
                            else
                            {
                                break;
                                System.debug(LoggingLevel.WARN, 'No Engineering - GOEE campaign was found. ' +
                                    'Scanbiz Contacts will not be associated to any campaigns');
                            }
                        }

                        scanbizCampaignMembers.add(
                            CampaignMemberService.createScanbizCampaignMember(
                                c, EngineeringGOEECampaignId
                            )
                        );
                    }
                }
            }
        }
    }

    public void afterInsert(SObject so) { }

    public void afterUpdate(SObject oldSo, SObject so) { }

    public void afterDelete(SObject so) { }

    public void andFinally() 
    { 
        if (!scanbizRelationships.isEmpty())
        {
            insert scanbizRelationships;
        }

        if (!scanbizCampaignMembers.isEmpty())
        {
            insert scanbizCampaignMembers;
        }
    }

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