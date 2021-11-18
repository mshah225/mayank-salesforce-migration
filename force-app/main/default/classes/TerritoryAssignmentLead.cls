public without sharing class TerritoryAssignmentLead {
    public static Boolean assignTerritoryDone = false;

    public void assignTerritory() {
        if (assignTerritoryDone) {
            return;
        }
        assignTerritoryDone = true;

        /**
         * Start lead geomarket code evaluation
         */
        Set<Id> LeadInstitutionSet = new Set<Id>();
        Set<String> ZipsInTrigger = new Set<String>();
        Map<String, String> KVMap = new Map<String, String>();
        Map<Id, Account> institutionMap;

        for (Lead l : (List<Lead>) Trigger.new) {
            //Ensures Zipcode is five digits or less
            string shortZip = TerritoryAssignmentService.shortenZipCode(l.postalCode);
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
            String shortZip = TerritoryAssignmentService.shortenZipCode(leadGeo.PostalCode);
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
        Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentService.mapTerritoryAssignmentRulesToRuleKey();

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
                        leadCountry = TerritoryAssignmentService.getSFCountry(leadCountry);
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

                    tar = TerritoryAssignmentService.getTerritoryAssignmentRule(possibleTars, leadAssignNumber);

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
}
