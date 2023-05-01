public class OpportunityService {
    /**
     * Creates an undergraduate prospect opportunity
     * @param contactToAssociate A contact that will be associated
     * @return undergradProspect An undergraduate prospect opportunity
     */

    static Id undergradProspectId;
    static Id gradProspectId;
    public static Boolean assignTerritoryDone = false;

    private static void loadIds() {
        List<RecordType> prospectIds = [
            SELECT Id, Name
            FROM RecordType
            WHERE (Name = 'Undergraduate Prospect' OR Name = 'Graduate Prospect') AND SobjectType = 'Opportunity'
        ];

        for (RecordType id : prospectIds) {
            if (id.Name == 'Undergraduate Prospect') {
                undergradProspectId = id.Id;
            }
            if (id.Name == 'Graduate Prospect') {
                gradProspectId = id.Id;
            }
        }
    }

    public static Opportunity createTestUndergraduateProspect(Contact contactToAssociate) {
        Date closeDate = Date.today();
        if (undergradProspectId == null) {
            loadIds();
        }

        Opportunity undergradProspect = new Opportunity();
        undergradProspect.Contact__c = contactToAssociate.Id;
        undergradProspect.RecordTypeId = undergradProspectId;
        undergradProspect.StageName = 'Prospect';
        undergradProspect.CloseDate = closeDate.addYears(1);
        undergradProspect.Name = 'Test Opportunity';
        undergradProspect.AccountId = contactToAssociate.AccountId;

        return undergradProspect;
    }

    /**
     * Creates one Undergraduate Prospect opportunity for each contact provided.
     * @param contactsToAssociate A list of contacts
     * @return oppList A list of undergraduate prospect opportunities
     */
    public static List<Opportunity> createTestUndergraduateProspects(List<Contact> contactsToAssociate) {
        List<Opportunity> undergradProspects = new List<Opportunity>();

        Date closeDate = Date.today();

        if (undergradProspectId == null) {
            loadIds();
        }

        for (Contact con : contactsToAssociate) {
            Opportunity opp = new Opportunity();
            opp.Contact__c = con.Id;
            opp.RecordTypeId = undergradProspectId;
            opp.StageName = 'Prospect';
            opp.CloseDate = closeDate.addYears(1);
            opp.Name = 'Test Opportunity for ' + con.Name;
            opp.AccountId = con.AccountId;
            undergradProspects.add(opp);
        }

        return undergradProspects;
    }

    /**
     * Creates one Graduate Prospect opportunity for each contact provided.
     * @param contactsToAssociate A list of contacts
     * @return oppList A list of undergraduate prospect opportunities
     */
    public static List<Opportunity> createTestGraduateProspects(List<Contact> contactsToAssociate) {
        List<Opportunity> gradProspects = new List<Opportunity>();

        Date closeDate = Date.today();

        if (gradProspectId == null) {
            loadIds();
        }

        for (Contact con : contactsToAssociate) {
            Opportunity opp = new Opportunity();
            opp.Contact__c = con.Id;
            opp.RecordTypeId = gradProspectId;
            opp.StageName = 'Prospect';
            opp.CloseDate = closeDate.addYears(1);
            opp.Name = 'Test Opportunity for ' + con.Name;
            opp.AccountId = con.AccountId;
            gradProspects.add(opp);
        }

        return gradProspects;
    }

    /**
     * Generates a random number for Territory Assignment
     * @return randNumber A random Integer between 0 and 100
     */
    public static Integer generateOpportunityAssignmentNumber() {
        Double randNumber = Math.random() * 100;

        return randNumber.intValue();
    }

    /**
     * Finds all Opportunities that are tied to a Leads Convert_Contact__c and
     * updates information from a Lead on the Opportunites.
     * @param Set<Id> A set of lead ids to map to opportunities
     * @return List<Opportunity> A list of opportunities with the mapped lead data
     */
    public static List<Opportunity> mapLeadDataToOpportunity(Set<Id> leadIds) {
        List<Lead> leadsFromConversion = new List<Lead>();
        Map<Id, Lead> contactIdToLeadMap = new Map<Id, Lead>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        Map<String, String> opportunityToLeadFields = new Map<String, String>{
            'Career__c' => 'Career__c',
            'Term__c' => 'Enrollment_Term__c',
            'First_Generation__c' => 'First_Generation__c',
            'Online_Degree__c' => 'Online__c',
            'International_Student__c' => 'International_Student__c',
            'Potential_National_Scholar__c' => 'Potential_National_Scholar__c',
            'Potential_WUE__c' => 'Potential_WUE__c',
            'Search_Segment__c' => 'Search_Segment__c',
            'Self_Reported_SES__c' => 'Self_Reported_SES__c',
            'Military_Status__c' => 'Veteran_Status__c'
        };

        String leadQueryFields = '';
        String oppQueryFields = '';

        // Build a string for querying all the lead fields
        for (String s : opportunityToLeadFields.values()) {
            leadQueryFields += s + ', ';
        }

        leadQueryFields = leadQueryFields.subString(0, leadQueryFields.length() - 2);

        String leadQuery = 'SELECT ConvertedContactId, ' + leadQueryFields + ' FROM Lead WHERE Id IN :leadIds';

        leadsFromConversion = Database.query(leadQuery);

        // Map the Contact Ids to the Lead Data
        for (Lead newLead : leadsFromConversion) {
            contactIdToLeadMap.put(newLead.ConvertedContactId, newLead);
        }

        Set<Id> contactIds = contactIdToLeadMap.keySet();

        // Bulid a string for querying all the opportunity fields
        for (String s : opportunityToLeadFields.keySet()) {
            oppQueryFields += s + ', ';
        }

        oppQueryFields = oppQueryFields.subString(0, oppQueryFields.length() - 2);

        // Get all the opportunities associated with these contacts
        String oppQuery = 'SELECT Contact__c, ' + oppQueryFields + ' FROM Opportunity WHERE Contact__c IN :contactIds';
        opportunitiesToUpdate = Database.query(oppQuery);

        // Update all the opportunity information
        for (Opportunity opp : opportunitiesToUpdate) {
            Lead leadData = contactIdToLeadMap.get(opp.Contact__c);

            for (String oppField : opportunityToLeadFields.keySet()) {
                if (opp.get(oppField) == null) {
                    String leadField = opportunityToLeadFields.get(oppField);
                    opp.put(oppField, leadData.get(leadField));
                }
            }
        }

        return opportunitiesToUpdate;
    }

    public static void populateNullContactsFromAccounts(List<Opportunity> newOpportunities) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for (Opportunity newOpportunity : newOpportunities) {
            if (newOpportunity.AccountId != null && newOpportunity.Contact__c == null) {
                accountIds.add(newOpportunity.AccountId);
            }
        }

        if (accountIds.size() > 0) {
            accountMap = new Map<Id, Account>([SELECT Id, Contact__c FROM Account WHERE Id IN :accountIds]);
        }

        for (Opportunity newOpportunity : newOpportunities) {
            newOpportunity.Opportunity_Assignment_Number_Rand__c = generateOpportunityAssignmentNumber();
            if (newOpportunity.Contact__c == null) {
                Account oppsAccount = accountMap.get(newOpportunity.AccountId);
                newOpportunity.Contact__c = oppsAccount.Contact__c;
            }
        }
    }

    public static void insertCollegePlan(List<Opportunity> newOpportunities) {
        List<Id> planIds = new List<Id>();
        Map<Id, Id> programColleges = new Map<Id, Id>();
        for (Opportunity newOpportunity : newOpportunities) {
            if (newOpportunity.Academic_Plan__c != null) {
                planIds.add(newOpportunity.Academic_Plan__c);
            }
            if (newOpportunity.Admitted_Plan__c != null) {
                planIds.add(newOpportunity.Admitted_Plan__c);
            }
        }

        for (Plan__c plan : [SELECT Id, Program__c FROM Plan__c WHERE Id IN :planIds]) {
            programColleges.put(plan.Id, plan.Program__c);
        }

        for (Opportunity newOpportunity : newOpportunities) {
            if (newOpportunity.Admitted_Plan__c != null) {
                newOpportunity.College__c = programColleges.get(newOpportunity.Admitted_Plan__c);
            } else if (newOpportunity.Academic_Plan__c != null) {
                newOpportunity.College__c = programColleges.get(newOpportunity.Academic_Plan__c);
            }
        }
    }

    public static void updateCollegeIfPlanChanged(
        List<Opportunity> updatedOpportunities,
        Map<Id, Opportunity> previousOpportunitiesMap
    ) {
        List<Id> planIds = new List<Id>();
        Map<Id, Id> programColleges = new Map<Id, Id>();

        for (Opportunity updatedOpportunity : updatedOpportunities) {
            Opportunity previousOpportunity = previousOpportunitiesMap.get(updatedOpportunity.Id);
            if (updatedOpportunity.Academic_Plan__c != previousOpportunity.Academic_Plan__c) {
                planIds.add(updatedOpportunity.Academic_Plan__c);
            }
            if (updatedOpportunity.Admitted_Plan__c != previousOpportunity.Admitted_Plan__c) {
                planIds.add(updatedOpportunity.Admitted_Plan__c);
            }
        }

        for (Plan__c plan : [SELECT Id, Program__c FROM Plan__c WHERE Id IN :planIds]) {
            programColleges.put(plan.Id, plan.Program__c);
        }

        for (Opportunity updatedOpportunity : updatedOpportunities) {
            Opportunity previousOpportunity = previousOpportunitiesMap.get(updatedOpportunity.Id);
            if (
                updatedOpportunity.Admitted_Plan__c != null &&
                updatedOpportunity.Admitted_Plan__c != previousOpportunity.Admitted_Plan__c
            ) {
                updatedOpportunity.College__c = programColleges.get(updatedOpportunity.Admitted_Plan__c);
            } else if (
                updatedOpportunity.Academic_Plan__c != null &&
                updatedOpportunity.Academic_Plan__c != previousOpportunity.Academic_Plan__c
            ) {
                updatedOpportunity.College__c = programColleges.get(updatedOpportunity.Academic_Plan__c);
            }
        }
    }

    public static void assignTerritory(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        Set<Id> locationSet = new Set<Id>();
        Set<Id> ContactIsFTF = new Set<Id>();

        //Get all Contact IDs and First Time Freshman Contact Ids linked to the Opportunities
        for (Opportunity newOpportunity : newOpportunities) {
            contactIdSet.Add(newOpportunity.Contact__c);
            locationSet.add(
                newOpportunity.Admitted_Location__c == null
                    ? newOpportunity.Location__c
                    : newOpportunity.Admitted_Location__c
            );

            if (newOpportunity.Type == 'First Time Freshman') {
                ContactIsFTF.add(newOpportunity.Contact__c);
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
        if (contactList.size() > 0) {
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
                string shortZip = TerritoryAssignmentService.shortenZipCode(c.MailingPostalCode);
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
                    string shortZip = TerritoryAssignmentService.shortenZipCode(Cons.MailingPostalCode);

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
                    TerritoryAssignmentService.updateContactList(geoMarketChanged);
                }
            }
        }

        /**
         * Start Territory Assignment Evaluation
         */
        Boolean anyTerritoryAssignmentRequired = false;

        for (Opportunity newOpportunity : newOpportunities) {
            // Force all new undergraduate opportunities to be evaluated for territory assignment
            if (oldOpportunitiesMap != null && oldOpportunitiesMap.size() > 0) {
                // Only evaluate territory assignment for opportunities where a field changes that could impact an assignment
                if (newOpportunity.Career__c != 'Undergraduate') {
                    newOpportunity.Territory_Assignment_Required__c = false;
                } else if (
                    newOpportunity.Territory_Assignment_Required__c == true ||
                    oldOpportunitiesMap.get(newOpportunity.Id).Type != newOpportunity.Type ||
                    oldOpportunitiesMap.get(newOpportunity.Id).International_Student__c !=
                    newOpportunity.International_Student__c ||
                    oldOpportunitiesMap.get(newOpportunity.Id).Location__c != newOpportunity.Location__c ||
                    oldOpportunitiesMap.get(newOpportunity.Id).StageName != newOpportunity.StageName ||
                    oldOpportunitiesMap.get(newOpportunity.Id).Potential_National_Scholar__c !=
                    newOpportunity.Potential_National_Scholar__c
                ) {
                    anyTerritoryAssignmentRequired = true;
                    newOpportunity.Territory_Assignment_Required__c = true;
                }
            } else {
                if (newOpportunity.Career__c != 'Undergraduate') {
                    newOpportunity.Territory_Assignment_Required__c = false;
                } else {
                    anyTerritoryAssignmentRequired = true;
                    newOpportunity.Territory_Assignment_Required__c = true;
                }
            }
        }

        if (anyTerritoryAssignmentRequired) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
            Map<Id, Location__c> locationMap = new Map<Id, Location__c>(
                [SELECT Id, Name, Location_Code__c FROM Location__c WHERE Id IN :locationSet]
            );

            // Build map with Territory_Assignment_Rule__c Rule_Key__c values
            List<Territory_Assignment_Rule__c> territoryAssignmentRuleList = new List<Territory_Assignment_Rule__c>(
                [SELECT Id, Rule_Key__c, User__c, User__r.IsActive FROM Territory_Assignment_Rule__c]
            );

            Map<String, Territory_Assignment_Rule__c> territoryAssignmentRuleMap = new Map<String, Territory_Assignment_Rule__c>();
            for (Territory_Assignment_Rule__c TARM : territoryAssignmentRuleList) {
                territoryAssignmentRuleMap.put(TARM.Rule_Key__c, TARM);
            }

            // Get all of the tars keyed by rule key. Used for international assignment now.
            Map<String, List<Territory_Assignment_Rule__c>> mapOfTarsByRuleKey = TerritoryAssignmentService.mapTerritoryAssignmentRulesToRuleKey();

            for (Opportunity opp : newOpportunities) {
                Boolean inactiveUserFound = false;
                Contact thisContact = contactMap.get(opp.Contact__c);
                Location__c thisLocation = locationMap.get(
                    opp.Admitted_Location__c == null ? opp.Location__c : opp.Admitted_Location__c
                );

                if (thisLocation == null) {
                    thisLocation = new Location__c();
                }

                // Start Territory Assignment Rules Evaluation
                if (opp.Territory_Assignment_Required__c && thisContact != null) {
                    opp.Territory_Assignment_Required__c = false;
                    opp.Territory_Assignment_Last_Run__c = Datetime.Now();

                    // Freshman Scholar
                    if (opp.Type == 'First Time Freshman' && opp.Potential_National_Scholar__c) {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get('Freshman Scholar');

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';

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
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Location' + '|' + 'Lake Havasu'
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Location - Lake Havasu';

                                continue;
                            }
                        }
                    }

                    // International
                    if (opp.International_Student__c) {
                        List<Territory_Assignment_Rule__c> possibleTars = new List<Territory_Assignment_Rule__c>();
                        Territory_Assignment_Rule__c tar = null;
                        Decimal oppAssignNumber = opp.Opportunity_Assignment_Number_Rand__c;
                        String oppCountry = thisContact.MailingCountry;

                        if (String.isNotEmpty(oppCountry)) {
                            oppCountry = TerritoryAssignmentService.getSFCountry(oppCountry);
                        }

                        // Avoid NPE on Opportunity Assignment Number Rand. At least one of these should be populated.
                        if (oppAssignNumber == null) {
                            oppAssignNumber = opp.Opportunity_Assignment_Number__c;
                        }

                        // Begin filter hierarchy
                        if (opp.StageName == 'Admitted - Conditional') {
                            possibleTars = mapOfTarsByRuleKey.get('International Admitted - Conditional');
                        } else if (opp.Type == 'Transfer') {
                            possibleTars = mapOfTarsByRuleKey.get('International|Transfer|' + oppCountry);

                            /**
                             * The oppCountry may be defined, but we don't have a Transfer TAR for it.
                             * Use the default TAR for International Transfer
                             */
                            if (possibleTars == null || possibleTars.isEmpty()) {
                                possibleTars = mapOfTarsByRuleKey.get('International|Transfer|');
                            }
                        } else if (String.isNotEmpty(oppCountry)) {
                            possibleTars = mapOfTarsByRuleKey.get('International|' + opp.Type + '|' + oppCountry);
                        }

                        // Hit the default International manager
                        if (possibleTars == null || possibleTars.isEmpty()) {
                            possibleTars = mapOfTarsByRuleKey.get('International||');
                        }

                        tar = TerritoryAssignmentService.getTerritoryAssignmentRule(possibleTars, oppAssignNumber);

                        // As long as we found a relevant Territory Assignment Rule, populate the information on the Opportunity
                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar != null &&
                                    opp.Territory_Assignment_Last_Rule_Type__c != 'International'
                                    ? tar.User__c
                                    : opp.OwnerId;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = tar.Rule_Key__c;

                                continue;
                            }
                        }
                    }

                    // Last High School Attended
                    if (
                        thisContact.Last_HS_Attended__c != null &&
                        thisContact.Last_HS_Attended__r.Territory_Manager__c != null &&
                        opp.Type == 'First Time Freshman'
                    ) {
                        if (thisContact.Last_HS_Attended__r.Territory_Manager__r.IsActive == false) {
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            opp.OwnerId = thisContact.Last_HS_Attended__r.Territory_Manager__c;
                            opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended High School';

                            continue;
                        }
                    }

                    // Last College Attended
                    if (
                        thisContact.Last_College_Attended__c != null &&
                        thisContact.Last_College_Attended__r.Territory_Manager__c != null &&
                        opp.Type == 'First Time Freshman'
                    ) {
                        if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                            opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type First Time Freshman';

                            continue;
                        }
                    }

                    if (
                        thisContact.Last_College_Attended__c != null &&
                        thisContact.Last_College_Attended__r.Territory_Manager__c != null &&
                        opp.Type == 'Readmission'
                    ) {
                        if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                            opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Readmission';

                            continue;
                        }
                    }

                    if (
                        thisContact.Last_College_Attended__c != null &&
                        thisContact.Last_College_Attended__r.Territory_Manager__c != null &&
                        opp.Type == 'Transfer'
                    ) {
                        if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        } else {
                            opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c;
                            opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Transfer';

                            continue;
                        }
                    }

                    // Geomarket Code
                    if (thisContact.Geomarket_Code__c != null && opp.Type == 'First Time Freshman') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Geomarket' + '|' + opp.Type + '|' + thisContact.Geomarket_Code__c
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type First Time Freshman';

                                continue;
                            }
                        }
                    }

                    if (thisContact.Geomarket_Code__c != null && opp.Type == 'Readmission') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Geomarket' + '|' + opp.Type + '|' + thisContact.Geomarket_Code__c
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Readmission';

                                continue;
                            }
                        }
                    }

                    if (thisContact.Geomarket_Code__c != null && opp.Type == 'Transfer') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Geomarket' + '|' + opp.Type + '|' + thisContact.Geomarket_Code__c
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer';

                                continue;
                            }
                        }
                    }

                    // State
                    if (thisContact.MailingState != null) {
                        String USState = thisContact.MailingState;
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'State' + '|' + opp.Type + '|' + USState
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'State, ' + USState + ', Type ' + opp.Type;

                                continue;
                            }
                        }
                    }

                    // Default User
                    if (opp.Type == 'Graduate') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Default User' + '|' + opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (opp.Type == 'Law') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Default User' + '|' + opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (opp.Type == 'First Time Freshman') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Default User' + '|' + opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                if (!inactiveUserFound) {
                                    opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                                }

                                opp.Territory_Assignment_Required__c = false;

                                continue;
                            }
                        }
                    } else if (opp.Type == 'Transfer') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Default User' + '|' + opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (opp.Type == 'Non-Degree') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Default User' + '|' + opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

                                continue;
                            }
                        }
                    } else if (opp.Type == 'Readmission') {
                        Territory_Assignment_Rule__c tar = territoryAssignmentRuleMap.get(
                            'Default User' + '|' + opp.Type
                        );

                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            } else {
                                opp.OwnerId = tar.User__c;
                                opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';

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