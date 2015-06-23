public without sharing class TerritoryAssignmentHelper 
{
    public static Boolean accountTADone = false;
    public static Boolean contactTADone = false;
    public static Boolean opportunityTADone = false;
    public static Boolean previousEducationTADone = false;
    public static Boolean leadTADone = false;
    public static Boolean territoryAssignmentRuleTADone = false;
    static List<sObject> triggerNew;

    private static Map<String, List<PS_Country_Map__c>> psCountryMap = PSCountryMapService.mapPSCountryToIntegrationValue(); 
    private static Boolean batchMode = false;

    /**
    * Account
    */
    public void AccountTA()
    {
        if (accountTADone)
        {
            return;
        }

        if (Trigger.isBefore)
        {
            Map<String, String> KVMap = new Map<String, String>();
            Set<String> ZipsInTrigger = new Set<String>();
            for (Account InsZip :(List<Account>)Trigger.New)
            {
                ZipsInTrigger.add(InsZip.ShippingPostalCode);
            }

            LIST<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c FROM Key_Value__c WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :ZipsInTrigger];

            for (Key_Value__c K :KVList)
            {
                KVMap.put(K.Geomarket_ZIP__c,K.Geomarket_Code__c);
            }

            for (Account AccGeo :(List<Account>)Trigger.New)
            {
                AccGeo.Geomarket_Code__c = KVMap.get(AccGeo.ShippingPostalCode);
            }

            if (Trigger.isUpdate)
            {
                Map<ID, Account> AcountOldMap = (Map<ID, Account>)Trigger.oldMap;

                for (Account A: (List<Account>)Trigger.New)
                {
                    if (A.Defer_Territory_Assignment__c == false && AcountOldMap.get(A.Id).Defer_Territory_Assignment__c == true)
                    {
                        continue;
                    }

                    if(A.Territory_Manager__c != null && AcountOldMap.get(A.Id).Territory_Manager__c != A.Territory_Manager__c && AcountOldMap.get(A.Id).Territory_Manager__c != null)
                    {
                        System.debug('got here: ' + AcountOldMap.get(A.Id).Territory_Manager__c);
                        A.Defer_Territory_Assignment__c = true;
                        A.Previous_Territory_Manager_ID__c = AcountOldMap.get(A.Id).Territory_Manager__c;
                    }
                }
            }
        }

        if (Trigger.isAfter)
        {
            accountTADone = true;
        }

    }

    /**
    * Contact
    */
    public void ContactTA()
    {
        if (contactTADone)
        {
            return;
        }

        if (Trigger.isAfter && Trigger.isUpdate)
        {
            Set<Id> contactIdsWithTAChanges = new Set<Id>();
            Map<Id, Contact> oldContactMap = (Map<Id, Contact>)Trigger.oldMap;

            for (Contact c: (List<Contact>)Trigger.new)
            {
                System.debug('GRF ContactTA States: ' + c.MailingState + ' -> ' + oldContactMap.get(c.Id).MailingState);

                if (c.MailingState != oldContactMap.get(c.Id).MailingState)
                {
                    contactIdsWithTAChanges.add(c.Id);
                }
            }

            List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Territory_Assignment_Required__c
                                                               FROM Opportunity
                                                               WHERE Contact__c IN :contactIdsWithTAChanges]);

            if (oppList.size() > 0)
            {
                for (Opportunity o: oppList)
                {
                    o.Territory_Assignment_Required__c = true;
                }

                update oppList;

                contactTADone = true;
            }
        }
    }


    /**
    * Opportunity
    */
    public void OpportunityTA()
    {

        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> locationSet = new Set<Id>();

        /**
        * Start Contact Geomarket Code Evaluation
        */
        if (Trigger.isBefore)
        {
            Set<String> ContactZips = new Set<String>();
            Map<String, String> KVMap = new Map<String, String>();
            Set<Id> InstitutionIdSet = new Set<Id>();
            Set<Id> ConIdsInTrigger = new Set<Id>();
            Set<Id> ContactIsFTF = new Set<Id>();

            Id KVRecordType = [SELECT Id
                               FROM RecordType
                               WHERE DeveloperName = 'Geomarket_Code_Map'
                               AND SObjectType = 'Key_Value__c'
                               LIMIT 1].Id;

            for (Opportunity OppsToGetContact : (List<Opportunity>)trigger.new)
            {
                ConIdsInTrigger.Add(OppsToGetContact.Contact__c);

                if(OppsToGetContact.Type =='First Time Freshman')
                {
                    ContactIsFTF.add(OppsToGetContact.Contact__c);
                }
            }

            List<Contact> ConsToUpdate = [SELECT Id, MailingPostalCode,Geomarket_Code__c, Last_HS_Attended__c, Last_College_Attended__c
                                          FROM Contact
                                          WHERE Id
                                          IN :ConIdsInTrigger];

            for (Contact c : ConsToUpdate )
            {
                if(!InstitutionIdSet.contains(c.Last_HS_Attended__c))
                {
                    InstitutionIdSet.add(c.Last_HS_Attended__c);
                }

                if(!InstitutionIdSet.contains(c.Last_College_Attended__c))
                {
                    InstitutionIdSet.add(c.Last_College_Attended__c);
                }

                ContactZips.add(c.MailingPostalCode);
            }

            Map<Id, Account> InstMap = new Map<Id, Account>([SELECT Id, Geomarket_Code__c
                                                             FROM Account
                                                             WHERE Id
                                                             IN :InstitutionIdSet]);

            List<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
                                         FROM Key_Value__c
                                         WHERE RecordTypeId = :KVRecordType
                                         AND Geomarket_ZIP__c
                                         IN :ContactZips];

            System.debug('GRF KVList: ' + KVList);

            for (Key_Value__c K :KVList)
            {
                KVMap.put(K.Geomarket_ZIP__c,K.Geomarket_Code__c);
            }

            for (Contact Cons :ConsToUpdate)
            {
                if(Cons.Last_HS_Attended__c != null && ContactIsFTF.contains(Cons.Id))
                {
                    Account thisInstitution = InstMap.get(Cons.Last_HS_Attended__c);

                    if (thisInstitution.Geomarket_Code__c != null)
                    {
                        Cons.Geomarket_Code__c = thisInstitution.Geomarket_Code__c;
                    }
                    else
                    {
                        Cons.Geomarket_Code__c = KVMap.get(Cons.MailingPostalCode);
                    }
                }
                else if (Cons.Last_College_Attended__c != null && !ContactIsFTF.contains(Cons.Id))
                {
                    Account thisInstitution = InstMap.get(Cons.Last_College_Attended__c);

                    if (thisInstitution.Geomarket_Code__c != null)
                    {
                        Cons.Geomarket_Code__c = thisInstitution.Geomarket_Code__c;
                    }
                    else
                    {
                        Cons.Geomarket_Code__c = KVMap.get(Cons.MailingPostalCode);
                    }
                }
                else
                {
                    Cons.Geomarket_Code__c = KVMap.get(Cons.MailingPostalCode);
                }
            }

            if(ConsToUpdate.size()>0)
            {
                Update ConsToUpdate;
            }
        }

        /**
        * Start Territory Assignment Evaluation
        */
        for (Opportunity o: (List<Opportunity>)Trigger.new)
        {
            if(!contactIdSet.contains(o.Contact__c))
            {
                contactIdSet.add(o.Contact__c);
            }

            locationSet.add(o.Admitted_Location__c==null?o.Location__c:o.Admitted_Location__c);
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Geomarket_Code__c, MailingState, MailingCountry, Last_HS_Attended__c, Last_HS_Attended__r.Territory_Manager__c, Last_HS_Attended__r.Territory_Manager__r.IsActive, Last_HS_Attended__r.Territory_Manager__r.Name, Last_College_Attended__r.Territory_Manager__c,Last_College_Attended__r.Territory_Manager__r.Name, Last_College_Attended__r.Territory_Manager__r.IsActive
                                                            FROM Contact
                                                            WHERE Id
                                                            IN :contactIdSet]);

        Map<Id, Location__c> locationMap = new Map<Id, Location__c>([SELECT Id, Name, Location_Code__c
                                                                     FROM Location__c
                                                                     WHERE Id
                                                                     IN :locationSet]);

        // Build map with Territory_Assignment_Rule__c Rule_Key__c values
        Map<String,Territory_Assignment_Rule__c> TerritoryAssignmentRuleMap = new Map<String,Territory_Assignment_Rule__c>();

        List<Territory_Assignment_Rule__c> TerritoryAssignmentRuleList = new List<Territory_Assignment_Rule__c>([SELECT Id,Rule_Key__c,User__c,User__r.IsActive
                                           FROM Territory_Assignment_Rule__c]);

        for (Territory_Assignment_Rule__c TARM : TerritoryAssignmentRuleList)
        {
            TerritoryAssignmentRuleMap.put(TARM.Rule_Key__c,TARM);
        }

        // Force all new undergraduate opportunities to be evaluated for territory assignment
        if (Trigger.isInsert)
        {
            for (Opportunity NewOpps : (List<Opportunity>)Trigger.New)
            {
                if (NewOpps.Career__c != 'Undergraduate')
                {
                    NewOpps.Territory_Assignment_Required__c = false;
                }
                else
                {
                    NewOpps.Territory_Assignment_Required__c = true;
                }
            }
        }

        // Only evaluate territory assignment for opportunities where a field changes that could impact an assignment
        if (Trigger.isUpdate)
        {
            Map<ID, Opportunity> OpportunityOldMap = (Map<ID, Opportunity>)Trigger.oldMap;

            for (Opportunity OppsToAssign : (List<Opportunity>)Trigger.New)
            {
                if (OppsToAssign.Career__c != 'Undergraduate')
                {
                    OppsToAssign.Territory_Assignment_Required__c = false;
                }
                else if(OppsToAssign.Territory_Assignment_Required__c == true
                    || OpportunityOldMap.get(OppsToAssign.Id).Type != OppsToAssign.Type
                    || OpportunityOldMap.get(OppsToAssign.Id).International_Student__c != OppsToAssign.International_Student__c
                    || OpportunityOldMap.get(OppsToAssign.Id).Location__c != OppsToAssign.Location__c
                    || OpportunityOldMap.get(OppsToAssign.Id).Potential_National_Scholar__c != OppsToAssign.Potential_National_Scholar__c)
                {
                    OppsToAssign.Territory_Assignment_Required__c = true;
                }
            }
        }

        // Get all of the tars keyed by rule key. Used for international assignment now.
        Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentRuleService.mapTerritoryAssignmentRulesToRuleKey();

        for(Opportunity Opp: (List<Opportunity>)Trigger.New)
        {
            Boolean inactiveUserFound = false;
            Contact thisContact = contactMap.get(Opp.Contact__c);
            Location__c thisLocation = locationMap.get(Opp.Admitted_Location__c==null?Opp.Location__c:Opp.Admitted_Location__c);

            if (thisLocation == null)
            {
                thisLocation = new Location__c();
            }

            // Start Territory Assignment Rules Evaluation
            if (Opp.Territory_Assignment_Required__c && thisContact != null)
            {
                Opp.Territory_Assignment_Required__c = false;
                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();

                // Freshman Scholar
                System.debug('About to Test Freshman Scholar');

                if (Opp.Type == 'First Time Freshman' && Opp.Potential_National_Scholar__c)
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Freshman Scholar');

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';

                            continue;
                        }
                    }
                }

                // Location
                System.debug('About to Test Location');
                if (thisLocation != null && thisLocation.Location_Code__c != null && thisLocation.Location_Code__c.equalsIgnoreCase('CALHC'))
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Location' + '|' + 'Lake Havasu');

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Location - Lake Havasu';

                            continue;
                        }
                    }
                }

                // International
                System.debug('About to Test International');

                if (Opp.International_Student__c)
                {
                    List<Territory_Assignment_Rule__c> possibleTars = new List<Territory_Assignment_Rule__c>();
                    Territory_Assignment_Rule__c tar = null;
                    Decimal oppAssignNumber = Opp.Opportunity_Assignment_Number_Rand__c;
                    String oppCountry = thisContact.MailingCountry;

                    if (String.isNotEmpty(oppCountry))
                    {
                        oppCountry = getSFCountry(oppCountry);
                    }

                    // Avoid NPE on Opportunity Assignment Number Rand. At least one of these should be populated.
                    if (oppAssignNumber == null)
                    {
                        oppAssignNumber = Opp.Opportunity_Assignment_Number__c;
                    }

                    // Begin filter hierarchy
                    if (Opp.StageName == 'Admitted - Conditional')
                    {
                        possibleTars = mapOfTarsByRuleKey.get('International Admitted - Conditional');
                    }
                    else if (Opp.Type == 'Transfer')
                    {
                        possibleTars = mapOfTarsByRuleKey.get('International|Transfer|' + oppCountry);

                        /**
                        * The oppCountry may be defined, but we don't have a Transfer TAR for it.
                        * Use the default TAR for International Transfer
                        */
                        if (possibleTars == null || possibleTars.isEmpty())
                        {
                            possibleTars = mapOfTarsByRuleKey.get('International|Transfer|');
                        }
                    }
                    else if (String.isNotEmpty(oppCountry))
                    {
                        possibleTars = mapOfTarsByRuleKey.get('International|' + Opp.Type + '|' + oppCountry);
                    }

                    // Hit the default International manager
                    if (possibleTars == null || possibleTars.isEmpty())
                    {
                        possibleTars = mapOfTarsByRuleKey.get('International||');
                    }

                    tar = TerritoryAssignmentRuleService.getTerritoryAssignmentRule(possibleTars, oppAssignNumber);
                    
                    // As long as we found a relevant Territory Assignment Rule, populate the information on the Opportunity
                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar != null && Opp.Territory_Assignment_Last_Rule_Type__c != 'International'? tar.User__c : Opp.OwnerId;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = tar.Rule_Key__c;

                            continue;
                        }
                    }
                }

                // Last High School Attended
                System.debug('About to Test Last HS');

                if(thisContact.Last_HS_Attended__c != null && thisContact.Last_HS_Attended__r.Territory_Manager__c != null && Opp.Type == 'First Time Freshman')
                {
                    if (thisContact.Last_HS_Attended__r.Territory_Manager__r.IsActive == false)
                    {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else
                    {
                        Opp.OwnerId = thisContact.Last_HS_Attended__r.Territory_Manager__c;
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended High School';

                        continue;
                    }
                }

                // Last College Attended
                System.debug('About to Test Last College');

                System.debug('About to Test Last College -- First Time Freshman');

                if (thisContact.Last_College_Attended__c != null && thisContact.Last_College_Attended__r.Territory_Manager__c != null && Opp.Type == 'First Time Freshman')
                {
                    if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false)
                    {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else
                    {
                        Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type First Time Freshman';

                        continue;
                    }
                }

                System.debug('About to Test Last College -- Readmission');

                if (thisContact.Last_College_Attended__c != null && thisContact.Last_College_Attended__r.Territory_Manager__c != null && Opp.Type == 'Readmission')
                {
                    if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false)
                    {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else
                    {
                        Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Readmission';

                        continue;
                    }

                }

                if (thisContact.Last_College_Attended__c != null && thisContact.Last_College_Attended__r.Territory_Manager__c != null && Opp.Type == 'Transfer')
                {
                    if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false)
                    {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else
                    {
                        Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Transfer';

                        continue;
                    }
                }

                // Geomarket Code
                System.debug('About to Test Geomarket');

                if (thisContact.Geomarket_Code__c != null && Opp.Type == 'First Time Freshman')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type First Time Freshman';

                            continue;
                        }
                    }
                }

                if (thisContact.Geomarket_Code__c != null  && Opp.Type == 'Readmission')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Readmission';

                            continue;
                        }
                    }
                }

                if (thisContact.Geomarket_Code__c != null  && Opp.Type == 'Transfer')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer';

                            continue;
                        }
                    }
                }

                // State
                System.debug('About to Test Mailing State');

                if (thisContact.MailingState != null)
                {
                    String USState = thisContact.MailingState;
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('State' + '|' + Opp.Type + '|' +  USState);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'State, ' + USState + ', Type ' + Opp.Type;

                            continue;
                        }
                    }
                }

                // Default User
                System.debug('About to Test Default Users');

                if (Opp.Type == 'Graduate')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                            continue;
                        }
                    }
                }
                else if (Opp.Type == 'Law')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                            continue;
                        }
                    }
                }
                else if (Opp.Type == 'First Time Freshman')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            if (!inactiveUserFound) Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Opp.Territory_Assignment_Required__c = false;

                            continue;
                        }
                    }
                }
                else if (Opp.Type == 'Transfer')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                            continue;
                        }
                    }
                }
                else if (Opp.Type == 'Non-Degree')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                            continue;
                        }
                    }
                }
                else if (Opp.Type == 'Readmission')
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else
                        {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                            continue;
                        }
                    }
                }
            }
        }

        opportunityTADone = true;
    }

    /**
    * Previous Education
    */
    public void PreviousEducationTA()
    {
        if (previousEducationTADone)
        {
            return;
        }
        previousEducationTADone = true;

        List<Previous_Education__c> peTriggerList = new List<Previous_Education__c>();

        if (Trigger.IsDelete)
        {
            peTriggerList = (List<Previous_Education__c>)Trigger.old;
        }
        else
        {
            peTriggerList = (List<Previous_Education__c>)Trigger.new;
        }

        Set<Id> contactIdSet = new Set<Id>();

        for (Previous_Education__c PE: peTriggerList)
        {
            contactIdSet.add(PE.Contact__c);
        }

        if (Trigger.IsInsert || Trigger.isUpdate || Trigger.isDelete)
        {
            Map<Id,Account> contactAccountMap = new Map<Id, Account>();
            Map<Id, Id> oppIdToContactIdMap = new Map<Id, Id>();
            Set<Id> peAccountIdSet = new Set<Id>();

            for (Previous_Education__c pe: peTriggerList)
            {
                peAccountIdSet.add(pe.Account__c);
            }

            Map<Id, Account> peAccountMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, Territory_Manager__c, Territory_Manager__r.Name, Territory_Manager__r.IsActive
                                                                  FROM Account
                                                                  WHERE Id IN :peAccountIdSet]);

            List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Contact__c
                                                               FROM Opportunity
                                                               WHERE Contact__c IN :contactIdSet]);
            for (Opportunity o1 : oppList )
            {
                oppIdToContactIdMap.put(o1.Id, o1.Contact__c);
            }

            for (Previous_Education__c prevEd: peTriggerList)
            {
                if (prevEd.Contact__c != null && prevEd.Account__c != null && peAccountMap.containsKey(prevEd.Account__c))
                {
                    contactAccountMap.put(prevEd.Contact__c, peAccountMap.get(prevEd.Account__c));
                }

            }


            List<Opportunity> opp = new List<Opportunity>([SELECT Id, Contact__c, Account.Name, Account.Institution_Type__c, Account.Territory_Manager__c, Type, OwnerId
                                                           FROM Opportunity
                                                           WHERE Contact__c IN :contactIdSet]);

            List<Opportunity> oppToUpdate = new List<Opportunity>();

            for (Opportunity o : opp)
            {
                o.Territory_Assignment_Required__c = true;
                oppToUpdate.add(o);
            }

            if (oppToUpdate.size()>0)
            {
                update oppToUpdate;
            }
        }
    }

    /**
    * Lead
    */
    public void LeadTA()
    {
        if (leadTADone)
        {
            return;
        }

        leadTADone = true;

        /**
        * Start lead geomarket code evaluation
        */
        Set<Id> LeadInstitutionSet = new Set<Id>();
        Set<Id> leadsWithNoLastInstitution = new Set<Id>();

        for (Lead l: (List<Lead>)Trigger.new)
        {
            if (l.Last_Institution_Attended__c != null)
            {
                leadInstitutionSet.add(l.Last_Institution_Attended__c);
            }
            else
            {
                leadsWithNoLastInstitution.add(l.Id);
            }
        }

        Map<Id, Account> institutionMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, Geomarket_Code__c
                                                                FROM Account
                                                                WHERE Id IN :leadInstitutionSet]);

        Id KVRecordType = [SELECT Id
                           FROM RecordType
                           WHERE DeveloperName = 'Geomarket_Code_Map'
                           AND SObjectType = 'Key_Value__c'
                           LIMIT 1].Id;

        Map<String, String> KVMap = new Map<String, String>();
        Set<String> ZipsInTrigger = new Set<String>();

        for (Lead InsZip :(List<Lead>)Trigger.New)
        {
            ZipsInTrigger.add(InsZip.PostalCode);
        }

        LIST<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
                                     FROM Key_Value__c
                                     WHERE RecordTypeId = :KVRecordType
                                     AND Geomarket_ZIP__c
                                     IN :ZipsInTrigger];

        for (Key_Value__c K :KVList)
        {
            KVMap.put(K.Geomarket_ZIP__c,K.Geomarket_Code__c);
        }

        for (Lead leadGeo :(List<Lead>)Trigger.New)
        {
            // TODO: Also, is institution type relevant for the Lead type?  Need clarification on this condition
            if (leadGeo.Last_Institution_Attended__c != null && institutionMap.get(leadGeo.Last_Institution_Attended__c).Geomarket_Code__c != null)
            {
                LeadGeo.Geomarket_Code__c = institutionMap.get(leadGeo.Last_Institution_Attended__c).Geomarket_Code__c;
            }
            else if (leadGeo.PostalCode != null && KVMap.containsKey(leadGeo.PostalCode))
            {
                leadGeo.Geomarket_Code__c = KVMap.get(leadGeo.PostalCode);
            }
        }

        /**
        * Start territory assignment evaluation
        */

        // Build map with Territory_Assignment_Rule__c Rule_Key__c values
        Map<String,Territory_Assignment_Rule__c> TerritoryAssignmentRuleMap = new Map<String,Territory_Assignment_Rule__c>();

        List<Territory_Assignment_Rule__c> TerritoryAssignmentRuleList =[SELECT Id,Rule_Key__c,User__c,User__r.IsActive
                                                                         FROM Territory_Assignment_Rule__c];

        for (Territory_Assignment_Rule__c TARM : TerritoryAssignmentRuleList)
        {
            TerritoryAssignmentRuleMap.put(TARM.Rule_Key__c,TARM);
        }

        // Force all new leads to be evaluated for territory assignment
        if (Trigger.isInsert)
        {
            for (Lead l: (List<Lead>)Trigger.New)
            {
                l.Territory_Assignment_Required__c = true;
            }
        }

        // Only evaluate territory assignment for leads where a field changes that could impact an assignment
        if (Trigger.isUpdate)
        {
            Map<ID, Lead> LeadOldMap = (Map<ID, Lead>)Trigger.oldMap;

            for (Lead l: (List<Lead>)Trigger.New)
            {
                System.debug('GRF State: ' + l.State);
                System.debug('GRF OlDState: ' + LeadOldMap.get(l.Id).State);

                // Fields to check
                Boolean taRequired = l.Territory_Assignment_Required__c = true;
                Boolean typeChanged = LeadOldMap.get(l.Id).Type__c != l.Type__c;
                Boolean geoMarketChanged = LeadOldMap.get(l.Id).Geomarket_Code__c != l.Geomarket_Code__c;
                Boolean stateChanged = LeadOldMap.get(l.Id).State != l.State;
                Boolean lastInstitutionChanged = LeadOldMap.get(l.Id).Last_Institution_Attended__c != l.Last_Institution_Attended__c;
                Boolean interStatusChanged = LeadOldMap.get(l.Id).International_Student__c != l.International_Student__c;
                Boolean natScholarPotentialChanged = LeadOldMap.get(l.Id).Potential_National_Scholar__c != l.Potential_National_Scholar__c;

                if(taRequired || typeChanged || geoMarketChanged || stateChanged || lastInstitutionChanged || interStatusChanged || natScholarPotentialChanged)
                {
                    l.Territory_Assignment_Required__c = true;
                }
            }
        }

        Map<Id, Account> InstMap = new Map<Id, Account>([SELECT Id, Geomarket_Code__c, Institution_Type__c, Territory_Manager__c, Territory_Manager__r.IsActive
                                                         FROM Account
                                                         WHERE Id IN :leadInstitutionSet]);

        System.debug('GRF TARMap: ' + TerritoryAssignmentRuleMap);

        // Get all of the TARs keyed by Rule Key. Used for international assignments.
        Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentRuleService.mapTerritoryAssignmentRulesToRuleKey();

        for (Lead l: (List<Lead>)Trigger.new)
        {
            if (l.Territory_Assignment_Required__c)
            {
                l.Territory_Assignment_Required__c = false;
                l.Territory_Assignment_Last_Run__c = Datetime.Now();

                // Freshman National Scholar
                System.debug('About to Test Freshman Scholar');

                if (l.Type__c == 'First Time Freshman' && l.Potential_National_Scholar__c)
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Freshman Scholar');

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else
                        {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';

                            continue;
                        }
                    }
                }

                // International
                System.debug('About to Test International');

                if (l.International_Student__c)
                {
                    // If already set by International rule, skip it
                    if (l.Territory_Assignment_Last_Rule_Type__c == 'International')
                    {
                        continue;
                    }

                    List<Territory_Assignment_Rule__c> possibleTars = new List<Territory_Assignment_Rule__c>();
                    Territory_Assignment_Rule__c tar = null;
                    Decimal leadAssignNumber = l.Lead_Assignment_Number__c;
                    String leadCountry = l.Silverpop_Mailing_Country__c;

                    // Use the PSCountry mapping to get the correct integration value.
                    if (String.isNotEmpty(leadCountry))
                    {
                        leadCountry = getSFCountry(leadCountry);
                    }

                    // Being filter hierarchy
                    if (l.Type__c == 'First Time Freshman' || l.Type__c == 'Transfer' || l.Type__c == 'Readmission')
                    {
                        possibleTars = mapOfTarsByRuleKey.get('International|' + l.Type__c + '|' + leadCountry);

                        /**
                        * The lead's mailing country may be defined, but we don't have a TAR for 
                        * it. Use the default TAR for this lead type instead.
                        */
                        if (possibleTars == null || possibleTars.isEmpty())
                        {
                            possibleTars = mapOfTarsByRuleKey.get('International|' + l.Type__c + '|');
                        }
                    }

                    // Use the default International manager
                    if (possibleTars == null || possibleTars.isEmpty())
                    {
                        possibleTars = mapOfTarsByRuleKey.get('International||');
                    }

                    tar = TerritoryAssignmentRuleService.getTerritoryAssignmentRule(possibleTars, leadAssignNumber);

                    // As long as we found a relevant Territory Assignment Rule, populate the information on the Opportunity
                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else
                        {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'International';

                            continue;
                        }
                    }
                }

                // Last Institution Attended
                System.debug('About to Test Last Institution Attended');

                if (l.Last_Institution_Attended__c != null)
                {
                    if ((l.Type__c == 'First Time Freshman'
                        && instMap.containsKey(l.Last_Institution_Attended__c)
                        && instMap.get(l.Last_Institution_Attended__c).Institution_Type__c == 'HS'
                        && instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c != null)
                        ||
                       ((l.Type__c == 'Transfer' || l.Type__c == 'Readmission')
                        && instMap.get(l.Last_Institution_Attended__c).Institution_Type__c != 'HS'
                        && instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c != null))
                    {
                        System.debug('GRF TM: ' + instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c);

                        if (instMap.get(l.Last_Institution_Attended__c).Territory_Manager__r.IsActive == false)
                        {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else
                        {
                            l.OwnerId = instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Last Institution Attended';

                            continue;
                        }
                    }
                }

                // GeoMarket
                System.debug('About to Test GeoMarket');

                if (l.Geomarket_Code__c != null && TerritoryAssignmentRuleMap.containsKey('Geomarket' + '|' + l.Type__c + '|' + l.Geomarket_Code__c ))
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + l.Type__c + '|' + l.Geomarket_Code__c);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else
                        {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type ' + l.Type__c;

                            continue;
                        }
                    }
                }

                // Mailing State
                System.debug('About to Test State');

                if (l.State != null && TerritoryAssignmentRuleMap.containsKey('State' + '|' + l.Type__c + '|' + l.State))
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('State' + '|' + l.Type__c + '|' + l.State );

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else
                        {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'State, Type ' + l.Type__c;

                            continue;
                        }
                    }
                }

                // Default User
                System.debug('About to Default User');

                if (TerritoryAssignmentRuleMap.containsKey('Default User' + '|' + l.Type__c))
                {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + l.Type__c);
                    System.debug('GRF Default TAR: ' + tar);

                    if (tar != null)
                    {
                        if (tar.User__r.IsActive == false)
                        {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else
                        {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                            continue;
                        }
                    }
                }
            }
        }
    }

    /**
    * Territory Assignment Rule
    */
    public void TerritoryAssignmentRuleTA()
    {
        if (territoryAssignmentRuleTADone)
        {
            return;
        }

        if (Trigger.isBefore && Trigger.isUpdate)
        {
            Map<ID, Territory_Assignment_Rule__c> tarOldMap = (Map<ID, Territory_Assignment_Rule__c>)Trigger.oldMap;

            for (Territory_Assignment_Rule__c tar: (List<Territory_Assignment_Rule__c>)Trigger.New)
            {
                if (tar.User__c != null && tarOldMap.get(tar.Id).User__c != tar.User__c)
                {
                    tar.Defer_Territory_Assignment__c = true;
                    tar.Previous_User_ID__c = tarOldMap.get(tar.Id).User__c;
                }
            }
        }

        territoryAssignmentRuleTADone = true;
    }

    /**
    * Helper method to get the correct Country text
    */
    private String getSFCountry(String country)
    {
        List<PS_Country_Map__c> possibleCountries = psCountryMap.get(country);

        PS_Country_Map__c psCountry = possibleCountries.get(0);

        String sfCountry = psCountry.Country_Name__c;

        return sfCountry;
    }
}
