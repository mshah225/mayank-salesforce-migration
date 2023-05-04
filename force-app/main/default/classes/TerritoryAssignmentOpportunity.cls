public without sharing class TerritoryAssignmentOpportunity {
    public static Boolean assignTerritoryDone = false;

    public void assignTerritory() {
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
                string shortZip = TerritoryAssignmentHelper.shortenZipCode(c.MailingPostalCode);
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
                    string shortZip = TerritoryAssignmentHelper.shortenZipCode(Cons.MailingPostalCode);

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
                    TerritoryAssignmentHelper.updateContactList(geoMarketChanged);
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
            Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentHelper.mapTerritoryAssignmentRulesToRuleKey();

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
                            'Location' + '|' + 'Lake Havasu'
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
                            oppCountry = TerritoryAssignmentHelper.getSFCountry(oppCountry);
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

                        tar = TerritoryAssignmentHelper.getTerritoryAssignmentRule(possibleTars, oppAssignNumber);

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
                            'Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c
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
                            'Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c
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
                            'Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c
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
                            'State' + '|' + Opp.Type + '|' + USState
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
                            'Default User' + '|' + Opp.Type
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
                            'Default User' + '|' + Opp.Type
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
                            'Default User' + '|' + Opp.Type
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
                            'Default User' + '|' + Opp.Type
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
                            'Default User' + '|' + Opp.Type
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
                            'Default User' + '|' + Opp.Type
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

        assignTerritoryDone = true;
    }
}