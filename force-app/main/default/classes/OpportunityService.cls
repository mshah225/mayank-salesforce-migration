public class OpportunityService {
    /**
     * Creates an undergraduate prospect opportunity
     * @param contactToAssociate A contact that will be associated
     * @return undergradProspect An undergraduate prospect opportunity
     */

    static Id undergradProspectId;
    static Id gradProspectId;

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
            Opportunity o = new Opportunity();
            o.Contact__c = con.Id;
            o.RecordTypeId = undergradProspectId;
            o.StageName = 'Prospect';
            o.CloseDate = closeDate.addYears(1);
            o.Name = 'Test Opportunity for ' + con.Name;
            o.AccountId = con.AccountId;
            undergradProspects.add(o);
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
            Opportunity o = new Opportunity();
            o.Contact__c = con.Id;
            o.RecordTypeId = gradProspectId;
            o.StageName = 'Prospect';
            o.CloseDate = closeDate.addYears(1);
            o.Name = 'Test Opportunity for ' + con.Name;
            o.AccountId = con.AccountId;
            gradProspects.add(o);
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
}
