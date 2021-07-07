public without sharing class TerritoryAssignmentHelper {
    public static Boolean accountTADone = false;
    public static Boolean contactTADone = false;
    public static Boolean opportunityTADone = false;
    public static Boolean previousEducationTADone = false;
    public static Boolean leadTADone = false;
    public static Boolean territoryAssignmentRuleTADone = false;
    static List<sObject> triggerNew;

    private static Map<String, List<PS_Country_Map__c>> psCountryMap;
    private static Boolean batchMode = false;
    private static Boolean debug = false;

    /**
     * Account
     */
    public void AccountTA() {
        if (accountTADone) {
            return;
        }

        Map<String, String> KVMap = new Map<String, String>();
        Set<String> ZipsInTrigger = new Set<String>();
        List<Key_Value__c> KVList = new List<Key_Value__c>();

        for (Account InsZip : (List<Account>) Trigger.New) {
            //Ensures Zipcode is five digits or less
            string shortZip = shortenZipCode(InsZip.ShippingPostalCode);
            ZipsInTrigger.add(shortZip);
        }

        if (ZipsInTrigger.size() > 0) {
            KVList = [
                SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
                FROM Key_Value__c
                WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :ZipsInTrigger
            ];

            for (Key_Value__c K : KVList) {
                KVMap.put(K.Geomarket_ZIP__c, K.Geomarket_Code__c);
            }

            for (Account AccGeo : (List<Account>) Trigger.New) {
                //Ensures Zipcode is five digits or less
                string shortZip = shortenZipCode(AccGeo.ShippingPostalCode);
                AccGeo.Geomarket_Code__c = KVMap.get(shortZip);
            }
        }

        if (Trigger.isUpdate) {
            Map<ID, Account> AcountOldMap = (Map<ID, Account>) Trigger.oldMap;

            for (Account A : (List<Account>) Trigger.New) {
                if (
                    A.Defer_Territory_Assignment__c == false &&
                    AcountOldMap.get(A.Id).Defer_Territory_Assignment__c == true
                ) {
                    continue;
                }

                if (
                    A.Territory_Manager__c != null &&
                    AcountOldMap.get(A.Id).Territory_Manager__c != A.Territory_Manager__c &&
                    AcountOldMap.get(A.Id).Territory_Manager__c != null
                ) {
                    A.Defer_Territory_Assignment__c = true;
                    A.Previous_Territory_Manager_ID__c = AcountOldMap.get(A.Id).Territory_Manager__c;
                }
            }
        }

        accountTADone = true;
    }

    /**
     * Contact
     */
    public void ContactTA() {
        if (contactTADone) {
            return;
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            Set<Id> contactIdsWithTAChanges = new Set<Id>();
            Map<Id, Contact> oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
            List<Opportunity> oppList;

            for (Contact c : (List<Contact>) Trigger.new) {
                if (c.MailingState != oldContactMap.get(c.Id).MailingState) {
                    contactIdsWithTAChanges.add(c.Id);
                }
            }

            oppList = new List<Opportunity>(
                [
                    SELECT Id, Territory_Assignment_Required__c
                    FROM Opportunity
                    WHERE Contact__c IN :contactIdsWithTAChanges
                ]
            );

            if (oppList.size() > 0) {
                for (Opportunity o : oppList) {
                    o.Territory_Assignment_Required__c = true;
                }

                updateOpportunityList(oppList);

                contactTADone = true;
            }
        }
    }

    /**
     * Opportunity
     */
    public void OpportunityTA() {
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        Set<Id> locationSet = new Set<Id>();
        Set<Id> ContactIsFTF = new Set<Id>();

        //Get all Contact IDs and First Time Freshman Contact Ids linked to the Opportunities
        for (Opportunity o : (List<Opportunity>) Trigger.new) {
            contactIdSet.Add(o.Contact__c);
            locationSet.add(o.Admitted_Location__c == null ? o.Location__c : o.Admitted_Location__c);

            if (o.Type == 'First Time Freshman') {
                ContactIsFTF.add(o.Contact__c);
            }
        }

        if (contactIdSet.size() > 0) {
            //Load all contacts attached to the Opportunities
            contactList = [
                SELECT
                    Id,
                    Geomarket_Code__c,
                    MailingPostalCode,
                    MailingState,
                    MailingCountry,
                    Last_HS_Attended__c,
                    Last_College_Attended__c,
                    Last_HS_Attended__r.Territory_Manager__c,
                    Last_HS_Attended__r.Territory_Manager__r.IsActive,
                    Last_HS_Attended__r.Territory_Manager__r.Name,
                    Last_College_Attended__r.Territory_Manager__c,
                    Last_College_Attended__r.Territory_Manager__r.Name,
                    Last_College_Attended__r.Territory_Manager__r.IsActive
                FROM Contact
                WHERE Id IN :contactIdSet
            ];
        }

        /**
         * Start Contact Geomarket Code Evaluation
         */
        if (Trigger.isBefore && contactList.size() > 0) {
            Set<String> ContactZips = new Set<String>();
            Map<String, String> KVMap = new Map<String, String>();
            Set<Id> InstitutionIdSet = new Set<Id>();

            //Load up the last HS and last College attended for all contacts
            //Also load up the Zip codes for all contacts
            for (Contact c : contactList) {
                if (!InstitutionIdSet.contains(c.Last_HS_Attended__c)) {
                    InstitutionIdSet.add(c.Last_HS_Attended__c);
                }

                if (!InstitutionIdSet.contains(c.Last_College_Attended__c)) {
                    InstitutionIdSet.add(c.Last_College_Attended__c);
                }
                //Ensures Zipcode is five digits or less
                string shortZip = shortenZipCode(c.MailingPostalCode);
                ContactZips.add(shortZip);
            }

            if (ContactZips.size() > 0 && InstitutionIdSet.size() > 0) {
                //Load all Accounts representing HSs or Colleges attended by Contacts on Opps
                Map<Id, Account> InstMap = new Map<Id, Account>(
                    [SELECT Id, Geomarket_Code__c FROM Account WHERE Id IN :InstitutionIdSet]
                );

                List<Key_Value__c> KVList = [
                    SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
                    FROM Key_Value__c
                    WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :ContactZips
                ];

                for (Key_Value__c K : KVList) {
                    KVMap.put(K.Geomarket_ZIP__c, K.Geomarket_Code__c);
                }

                List<Contact> geoMarketChanged = new List<Contact>();
                //For each contact
                for (Contact Cons : contactList) {
                    //Ensures Zipcode is five digits or less
                    string shortZip = shortenZipCode(Cons.MailingPostalCode);

                    //If the contact is a FTF and has a last HS attended
                    //Update the contact's geomarket code to reflect this
                    if (Cons.Last_HS_Attended__c != null && ContactIsFTF.contains(Cons.Id)) {
                        Account thisInstitution = InstMap.get(Cons.Last_HS_Attended__c);
                        if (
                            thisInstitution.Geomarket_Code__c != null &&
                            Cons.Geomarket_Code__c != thisInstitution.Geomarket_Code__c
                        ) {
                            Cons.Geomarket_Code__c = thisInstitution.Geomarket_Code__c;
                            geoMarketChanged.add(Cons);
                        } else if (Cons.Geomarket_Code__c != KVMap.get(shortZip)) {
                            Cons.Geomarket_Code__c = KVMap.get(shortZip);
                            geoMarketChanged.add(Cons);
                        }
                    } else if (Cons.Last_College_Attended__c != null && !ContactIsFTF.contains(Cons.Id)) {
                        //Else if the contact is not an FTF and has a last college attended
                        //Update the contact's geomarket code to reflect this
                        Account thisInstitution = InstMap.get(Cons.Last_College_Attended__c);
                        if (
                            thisInstitution.Geomarket_Code__c != null &&
                            Cons.Geomarket_Code__c != thisInstitution.Geomarket_Code__c
                        ) {
                            Cons.Geomarket_Code__c = thisInstitution.Geomarket_Code__c;
                            geoMarketChanged.add(Cons);
                        } else if (Cons.Geomarket_Code__c != KVMap.get(shortZip)) {
                            Cons.Geomarket_Code__c = KVMap.get(shortZip);
                            geoMarketChanged.add(Cons);
                        }
                    } else if (Cons.Geomarket_Code__c != KVMap.get(shortZip)) {
                        //Else simply update the contact's geomarket code to reflect their postal code
                        Cons.Geomarket_Code__c = KVMap.get(shortZip);
                        geoMarketChanged.add(Cons);
                    }
                }

                if (geoMarketChanged.size() > 0) {
                    updateContactList(geoMarketChanged);
                }
            }
        }

        /**
         * Start Territory Assignment Evaluation
         */
        Boolean anyTerritoryAssignmentRequired = false;

        for (Opportunity o : (List<Opportunity>) Trigger.new) {
            // Force all new undergraduate opportunities to be evaluated for territory assignment
            if (Trigger.isInsert) {
                if (o.Career__c != 'Undergraduate') {
                    o.Territory_Assignment_Required__c = false;
                } else {
                    anyTerritoryAssignmentRequired = true;
                    o.Territory_Assignment_Required__c = true;
                }
            } else if (Trigger.isUpdate) {
                // Only evaluate territory assignment for opportunities where a field changes that could impact an assignment
                Map<ID, Opportunity> OpportunityOldMap = (Map<ID, Opportunity>) Trigger.oldMap;

                if (o.Career__c != 'Undergraduate') {
                    o.Territory_Assignment_Required__c = false;
                } else if (
                    o.Territory_Assignment_Required__c == true ||
                    OpportunityOldMap.get(o.Id).Type != o.Type ||
                    OpportunityOldMap.get(o.Id).International_Student__c != o.International_Student__c ||
                    OpportunityOldMap.get(o.Id).Location__c != o.Location__c ||
                    OpportunityOldMap.get(o.Id).StageName != o.StageName ||
                    OpportunityOldMap.get(o.Id).Potential_National_Scholar__c != o.Potential_National_Scholar__c
                ) {
                    anyTerritoryAssignmentRequired = true;
                    o.Territory_Assignment_Required__c = true;
                }
            }
        }

        if (anyTerritoryAssignmentRequired) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            Map<Id, Location__c> locationMap = new Map<Id, Location__c>(
                [SELECT Id, Name, Location_Code__c FROM Location__c WHERE Id IN :locationSet]
            );

            // Build map with Territory_Assignment_Rule__c Rule_Key__c values
            List<Territory_Assignment_Rule__c> TerritoryAssignmentRuleList = new List<Territory_Assignment_Rule__c>(
                [SELECT Id, Rule_Key__c, User__c, User__r.IsActive FROM Territory_Assignment_Rule__c]
            );

            Map<String, Territory_Assignment_Rule__c> TerritoryAssignmentRuleMap = new Map<String, Territory_Assignment_Rule__c>();
            for (Territory_Assignment_Rule__c TARM : TerritoryAssignmentRuleList) {
                TerritoryAssignmentRuleMap.put(TARM.Rule_Key__c, TARM);
            }

            // Get all of the tars keyed by rule key. Used for international assignment now.
            Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentRuleService.mapTerritoryAssignmentRulesToRuleKey();

            for (Opportunity Opp : (List<Opportunity>) Trigger.New) {
                Boolean inactiveUserFound = false;
                Contact thisContact = contactMap.get(Opp.Contact__c);
                Location__c thisLocation = locationMap.get(
                    Opp.Admitted_Location__c == null ? Opp.Location__c : Opp.Admitted_Location__c
                );

                if (thisLocation == null) {
                    thisLocation = new Location__c();
                }

                // Start Territory Assignment Rules Evaluation
                if (Opp.Territory_Assignment_Required__c && thisContact != null) {
                    Opp.Territory_Assignment_Required__c = false;
                    Opp.Territory_Assignment_Last_Run__c = Datetime.Now();

                    // Freshman Scholar
                    if (Opp.Type == 'First Time Freshman' && Opp.Potential_National_Scholar__c) {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Freshman Scholar');

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';

                                continue;
                            }
                        }
                    }

                    // Location
                    if (
                        thisLocation != null &&
                        thisLocation.Location_Code__c != null &&
                        thisLocation.Location_Code__c.equalsIgnoreCase('CALHC')
                    ) {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Location' +
                            '|' +
                            'Lake Havasu'
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Location - Lake Havasu';

                                continue;
                            }
                        }
                    }

                    // International
                    if (Opp.International_Student__c) {
                        List<Territory_Assignment_Rule__c> possibleTars = new List<Territory_Assignment_Rule__c>();
                        Territory_Assignment_Rule__c tar = null;
                        Decimal oppAssignNumber = Opp.Opportunity_Assignment_Number_Rand__c;
                        String oppCountry = thisContact.MailingCountry;

                        if (String.isNotEmpty(oppCountry)) {
                            oppCountry = getSFCountry(oppCountry);
                        }

                        // Avoid NPE on Opportunity Assignment Number Rand. At least one of these should be populated.
                        if (oppAssignNumber == null) {
                            oppAssignNumber = Opp.Opportunity_Assignment_Number__c;
                        }

                        // Begin filter hierarchy
                        if (Opp.StageName == 'Admitted - Conditional') {
                            possibleTars = mapOfTarsByRuleKey.get('International Admitted - Conditional');
                        } else if (Opp.Type == 'Transfer') {
                            possibleTars = mapOfTarsByRuleKey.get('International|Transfer|' + oppCountry);

                            /**
                             * The oppCountry may be defined, but we don't have a Transfer TAR for it.
                             * Use the default TAR for International Transfer
                             */
                            if (possibleTars == null || possibleTars.isEmpty()) {
                                possibleTars = mapOfTarsByRuleKey.get('International|Transfer|');
                            }
                        } else if (String.isNotEmpty(oppCountry)) {
                            possibleTars = mapOfTarsByRuleKey.get('International|' + Opp.Type + '|' + oppCountry);
                        }

                        // Hit the default International manager
                        if (possibleTars == null || possibleTars.isEmpty()) {
                            possibleTars = mapOfTarsByRuleKey.get('International||');
                        }

                        tar = TerritoryAssignmentRuleService.getTerritoryAssignmentRule(possibleTars, oppAssignNumber);

                        // As long as we found a relevant Territory Assignment Rule, populate the information on the Opportunity
                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar != null &&
                                    Opp.Territory_Assignment_Last_Rule_Type__c != 'International'
                                    ? tar.User__c
                                    : Opp.OwnerId;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = tar.Rule_Key__c;

                                continue;
                            }
                        }
                    }

                    // Last High School Attended
                    if (
                        thisContact.Last_HS_Attended__c != null &&
                        thisContact.Last_HS_Attended__r.Territory_Manager__c != null &&
                        Opp.Type == 'First Time Freshman'
                    ) {
                        if (thisContact.Last_HS_Attended__r.Territory_Manager__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            Opp.OwnerId = thisContact.Last_HS_Attended__r.Territory_Manager__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended High School';

                            continue;
                        }
                    }

                    // Last College Attended
                    if (
                        thisContact.Last_College_Attended__c != null &&
                        thisContact.Last_College_Attended__r.Territory_Manager__c != null &&
                        Opp.Type == 'First Time Freshman'
                    ) {
                        if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type First Time Freshman';

                            continue;
                        }
                    }

                    if (
                        thisContact.Last_College_Attended__c != null &&
                        thisContact.Last_College_Attended__r.Territory_Manager__c != null &&
                        Opp.Type == 'Readmission'
                    ) {
                        if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Readmission';

                            continue;
                        }
                    }

                    if (
                        thisContact.Last_College_Attended__c != null &&
                        thisContact.Last_College_Attended__r.Territory_Manager__c != null &&
                        Opp.Type == 'Transfer'
                    ) {
                        if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Transfer';

                            continue;
                        }
                    }

                    // Geomarket Code
                    if (thisContact.Geomarket_Code__c != null && Opp.Type == 'First Time Freshman') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Geomarket' +
                            '|' +
                            Opp.Type +
                            '|' +
                            thisContact.Geomarket_Code__c
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type First Time Freshman';

                                continue;
                            }
                        }
                    }

                    if (thisContact.Geomarket_Code__c != null && Opp.Type == 'Readmission') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Geomarket' +
                            '|' +
                            Opp.Type +
                            '|' +
                            thisContact.Geomarket_Code__c
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Readmission';

                                continue;
                            }
                        }
                    }

                    if (thisContact.Geomarket_Code__c != null && Opp.Type == 'Transfer') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Geomarket' +
                            '|' +
                            Opp.Type +
                            '|' +
                            thisContact.Geomarket_Code__c
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer';

                                continue;
                            }
                        }
                    }

                    // State
                    if (thisContact.MailingState != null) {
                        String USState = thisContact.MailingState;
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'State' +
                            '|' +
                            Opp.Type +
                            '|' +
                            USState
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'State, ' + USState + ', Type ' + Opp.Type;

                                continue;
                            }
                        }
                    }

                    // Default User
                    if (Opp.Type == 'Graduate') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Default User' +
                            '|' +
                            Opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (Opp.Type == 'Law') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Default User' +
                            '|' +
                            Opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (Opp.Type == 'First Time Freshman') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Default User' +
                            '|' +
                            Opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                if (!inactiveUserFound) {
                                    Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                                }

                                Opp.Territory_Assignment_Required__c = false;

                                continue;
                            }
                        }
                    } else if (Opp.Type == 'Transfer') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Default User' +
                            '|' +
                            Opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (Opp.Type == 'Non-Degree') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Default User' +
                            '|' +
                            Opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (Opp.Type == 'Readmission') {
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                            'Default User' +
                            '|' +
                            Opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                Opp.OwnerId = tar.User__c;
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
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
    public void PreviousEducationTA() {
        if (previousEducationTADone) {
            return;
        }
        previousEducationTADone = true;

        List<Previous_Education__c> peTriggerList = new List<Previous_Education__c>();
        Set<Id> contactIdSet = new Set<Id>();

        if (Trigger.IsDelete) {
            peTriggerList = (List<Previous_Education__c>) Trigger.old;
        } else {
            peTriggerList = (List<Previous_Education__c>) Trigger.new;
        }

        for (Previous_Education__c PE : peTriggerList) {
            contactIdSet.add(PE.Contact__c);
        }

        if (contactIdSet.size() > 0 && (Trigger.IsInsert || Trigger.isUpdate || Trigger.isDelete)) {
            List<Opportunity> opp = new List<Opportunity>(
                [
                    SELECT
                        Id,
                        Contact__c,
                        Account.Name,
                        Account.Institution_Type__c,
                        Account.Territory_Manager__c,
                        Type,
                        OwnerId
                    FROM Opportunity
                    WHERE Contact__c IN :contactIdSet
                ]
            );

            List<Opportunity> oppToUpdate = new List<Opportunity>();

            for (Opportunity o : opp) {
                o.Territory_Assignment_Required__c = true;
                oppToUpdate.add(o);
            }

            if (oppToUpdate.size() > 0) {
                updateOpportunityList(oppToUpdate);
            }
        }
    }

    /**
     * Lead
     */
    public void LeadTA() {
        if (leadTADone) {
            return;
        }

        leadTADone = true;

        /**
         * Start lead geomarket code evaluation
         */
        Set<Id> LeadInstitutionSet = new Set<Id>();
        Set<String> ZipsInTrigger = new Set<String>();
        Map<String, String> KVMap = new Map<String, String>();
        Map<Id, Account> institutionMap;

        for (Lead l : (List<Lead>) Trigger.new) {
            //Ensures Zipcode is five digits or less
            string shortZip = shortenZipCode(l.postalCode);
            ZipsInTrigger.add(shortZip);
            if (l.Last_Institution_Attended__c != null) {
                leadInstitutionSet.add(l.Last_Institution_Attended__c);
            }
        }

        if (leadInstitutionSet.size() > 0) {
            institutionMap = new Map<Id, Account>(
                [
                    SELECT
                        Id,
                        Geomarket_Code__c,
                        Institution_Type__c,
                        Territory_Manager__c,
                        Territory_Manager__r.IsActive
                    FROM Account
                    WHERE Id IN :leadInstitutionSet
                ]
            );
        }

        LIST<Key_Value__c> KVList = [
            SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c
            FROM Key_Value__c
            WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :ZipsInTrigger
        ];

        for (Key_Value__c K : KVList) {
            KVMap.put(K.Geomarket_ZIP__c, K.Geomarket_Code__c);
        }

        for (Lead leadGeo : (List<Lead>) Trigger.New) {
            //Ensure zip code is five characters or less
            String shortZip = shortenZipCode(leadGeo.PostalCode);
            // TODO: Also, is institution type relevant for the Lead type?  Need clarification on this condition
            if (
                leadGeo.Last_Institution_Attended__c != null &&
                institutionMap.get(leadGeo.Last_Institution_Attended__c).Geomarket_Code__c != null
            ) {
                LeadGeo.Geomarket_Code__c = institutionMap.get(leadGeo.Last_Institution_Attended__c).Geomarket_Code__c;
            } else if (shortZip != null && KVMap.containsKey(shortZip)) {
                leadGeo.Geomarket_Code__c = KVMap.get(shortZip);
            }
        }

        /**
         * Start territory assignment evaluation
         */

        // Build map with Territory_Assignment_Rule__c Rule_Key__c values
        Map<String, Territory_Assignment_Rule__c> TerritoryAssignmentRuleMap = new Map<String, Territory_Assignment_Rule__c>();

        List<Territory_Assignment_Rule__c> TerritoryAssignmentRuleList = [
            SELECT Id, Rule_Key__c, User__c, User__r.IsActive
            FROM Territory_Assignment_Rule__c
        ];

        for (Territory_Assignment_Rule__c TARM : TerritoryAssignmentRuleList) {
            TerritoryAssignmentRuleMap.put(TARM.Rule_Key__c, TARM);
        }

        // Force all new leads to be evaluated for territory assignment
        if (Trigger.isInsert) {
            for (Lead l : (List<Lead>) Trigger.New) {
                l.Territory_Assignment_Required__c = true;
            }
        }

        // Only evaluate territory assignment for leads where a field changes that could impact an assignment
        if (Trigger.isUpdate) {
            Map<ID, Lead> LeadOldMap = (Map<ID, Lead>) Trigger.oldMap;

            for (Lead l : (List<Lead>) Trigger.New) {
                // Fields to check
                Boolean taRequired = l.Territory_Assignment_Required__c = true;
                Boolean typeChanged = LeadOldMap.get(l.Id).Type__c != l.Type__c;
                Boolean geoMarketChanged = LeadOldMap.get(l.Id).Geomarket_Code__c != l.Geomarket_Code__c;
                Boolean stateChanged = LeadOldMap.get(l.Id).State != l.State;
                Boolean lastInstitutionChanged =
                    LeadOldMap.get(l.Id).Last_Institution_Attended__c != l.Last_Institution_Attended__c;
                Boolean interStatusChanged =
                    LeadOldMap.get(l.Id).International_Student__c != l.International_Student__c;
                Boolean natScholarPotentialChanged =
                    LeadOldMap.get(l.Id).Potential_National_Scholar__c != l.Potential_National_Scholar__c;

                if (
                    taRequired ||
                    typeChanged ||
                    geoMarketChanged ||
                    stateChanged ||
                    lastInstitutionChanged ||
                    interStatusChanged ||
                    natScholarPotentialChanged
                ) {
                    l.Territory_Assignment_Required__c = true;
                }
            }
        }

        // Get all of the TARs keyed by Rule Key. Used for international assignments.
        Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentRuleService.mapTerritoryAssignmentRulesToRuleKey();

        for (Lead l : (List<Lead>) Trigger.new) {
            if (l.Territory_Assignment_Required__c) {
                l.Territory_Assignment_Required__c = false;
                l.Territory_Assignment_Last_Run__c = Datetime.Now();

                // Freshman National Scholar
                if (l.Type__c == 'First Time Freshman' && l.Potential_National_Scholar__c) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Freshman Scholar');

                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        } else {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';

                            continue;
                        }
                    }
                }

                // International
                if (l.International_Student__c) {
                    List<Territory_Assignment_Rule__c> possibleTars = new List<Territory_Assignment_Rule__c>();
                    Territory_Assignment_Rule__c tar = null;
                    Decimal leadAssignNumber = l.Lead_Assignment_Number__c;
                    String leadCountry = l.Silverpop_Mailing_Country__c;
                    String leadType = l.Type__c;

                    // Use the PSCountry mapping to get the correct integration value.
                    if (String.isNotEmpty(leadCountry)) {
                        leadCountry = getSFCountry(leadCountry);
                    }

                    // Being filter hierarchy
                    if (leadType == 'First Time Freshman' || leadType == 'Transfer' || leadType == 'Readmission') {
                        possibleTars = mapOfTarsByRuleKey.get('International|' + leadType + '|' + leadCountry);

                        /**
                         * The lead's mailing country may be defined, but we don't have a TAR for
                         * it. Use the default TAR for this lead type instead.
                         */
                        if (possibleTars == null || possibleTars.isEmpty()) {
                            possibleTars = mapOfTarsByRuleKey.get('International|' + leadType + '|');
                        }
                    }

                    // Use the default International manager
                    if (possibleTars == null || possibleTars.isEmpty()) {
                        possibleTars = mapOfTarsByRuleKey.get('International||');
                    }

                    tar = TerritoryAssignmentRuleService.getTerritoryAssignmentRule(possibleTars, leadAssignNumber);

                    // As long as we found a relevant Territory Assignment Rule, populate the information on the Opportunity
                    if (tar != null) {
                        if (tar.User__r.IsActive) {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = tar.Rule_Key__c;

                            continue;
                        } else {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                    }
                }

                // Last Institution Attended
                if (l.Last_Institution_Attended__c != null) {
                    if (
                        (l.Type__c == 'First Time Freshman' &&
                        institutionMap.containsKey(l.Last_Institution_Attended__c) &&
                        institutionMap.get(l.Last_Institution_Attended__c).Institution_Type__c == 'HS' &&
                        institutionMap.get(l.Last_Institution_Attended__c).Territory_Manager__c != null) ||
                        ((l.Type__c == 'Transfer' ||
                        l.Type__c == 'Readmission') &&
                        institutionMap.get(l.Last_Institution_Attended__c).Institution_Type__c != 'HS' &&
                        institutionMap.get(l.Last_Institution_Attended__c).Territory_Manager__c != null)
                    ) {
                        if (institutionMap.get(l.Last_Institution_Attended__c).Territory_Manager__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        } else {
                            l.OwnerId = institutionMap.get(l.Last_Institution_Attended__c).Territory_Manager__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Last Institution Attended';

                            continue;
                        }
                    }
                }

                // GeoMarket
                if (
                    l.Geomarket_Code__c != null &&
                    TerritoryAssignmentRuleMap.containsKey('Geomarket' + '|' + l.Type__c + '|' + l.Geomarket_Code__c)
                ) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                        'Geomarket' +
                        '|' +
                        l.Type__c +
                        '|' +
                        l.Geomarket_Code__c
                    );

                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        } else {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type ' + l.Type__c;

                            continue;
                        }
                    }
                }

                // Mailing State
                if (
                    l.State != null && TerritoryAssignmentRuleMap.containsKey('State' + '|' + l.Type__c + '|' + l.State)
                ) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get(
                        'State' +
                        '|' +
                        l.Type__c +
                        '|' +
                        l.State
                    );

                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        } else {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'State, Type ' + l.Type__c;

                            continue;
                        }
                    }
                }

                // Default User
                if (TerritoryAssignmentRuleMap.containsKey('Default User' + '|' + l.Type__c)) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + l.Type__c);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        } else {
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
    public void TerritoryAssignmentRuleTA() {
        if (territoryAssignmentRuleTADone) {
            return;
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            Map<ID, Territory_Assignment_Rule__c> tarOldMap = (Map<ID, Territory_Assignment_Rule__c>) Trigger.oldMap;

            for (Territory_Assignment_Rule__c tar : (List<Territory_Assignment_Rule__c>) Trigger.New) {
                if (tar.User__c != null && tarOldMap.get(tar.Id).User__c != tar.User__c) {
                    tar.Defer_Territory_Assignment__c = true;
                    tar.Previous_User_ID__c = tarOldMap.get(tar.Id).User__c;
                }
            }
        }

        territoryAssignmentRuleTADone = true;
    }

    public static void updateOpportunityList(List<Opportunity> oppList) {
        List<String> vars = new List<String>();
        try {
            update oppList;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertListToJSON('oppList', oppList));
            ErrorLogger.log(e, vars, debug);
        }
    }

    public static void updateContactList(List<Contact> conList) {
        List<String> vars = new List<String>();
        try {
            update conList;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertListToJSON('conList', conList));
            ErrorLogger.log(e, vars, debug);
        }
    }

    /**
     * Helper method to get the correct Country text
     */
    private String getSFCountry(String country) {
        if (psCountryMap == null) {
            psCountryMap = PSCountryMapService.mapPSCountryToIntegrationValue();
        }
        List<PS_Country_Map__c> possibleCountries = psCountryMap.get(country);

        if (possibleCountries != null && possibleCountries.size() > 0) {
            PS_Country_Map__c psCountry = possibleCountries.get(0);
            String sfCountry = psCountry.Country_Name__c;
            return sfCountry;
        } else {
            return '';
        }
    }

    /*
     * Ensures zip code is five characters or less
     * @param Zip code
     * @return formatted Zip code
     * */
    private String shortenZipCode(String zip) {
        if (zip != null) {
            zip = zip.left(5);
        }
        return zip;
    }
}
