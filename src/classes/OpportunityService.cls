public class OpportunityService
{
    /**
    * Creates an undergraduate prospect opportunity
    * @param Contact A contact that will be associated
    * @return Opportunity An undergraduate prospect opportunity
    */
    public static Opportunity createTestUndergraduateProspect(Contact contactToAssociate)
    {
        Id undergradProspectId = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;

        Opportunity undergradProspect = new Opportunity();
        undergradProspect.Contact__c = contactToAssociate.Id;
        undergradProspect.RecordTypeId = undergradProspectId;
        undergradProspect.StageName = 'Prospect';
        undergradProspect.CloseDate = Date.today();
        undergradProspect.Name = 'Test Opportunity';
        undergradProspect.AccountId = contactToAssociate.AccountId;

        return undergradProspect;
    }

    /**
    * Creates one opportunity for each contact provided.
    * @param List<Contact> A list of contacts
    * @return List<Opportunity> A list of undergraduate prospect opportunities
    */
    public static List<Opportunity> createTestUndergraduateProspects(List<Contact> contactsToAssociate)
    {
        List<Opportunity> oppList = new List<Opportunity>();

        Date closeDate = Date.today();

        Id undergradProspectId = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;

        for (Contact con : contactsToAssociate)
        {
            Opportunity o = new Opportunity();
            o.Contact__c = con.Id;
            o.RecordTypeId = undergradProspectId;
            o.StageName = 'Prospect';
            o.CloseDate = closeDate.addYears(1);
            o.Name = 'Test Opportunity for ' + con.Name;
            o.AccountId = con.AccountId;
            oppList.add(o);
        }

        return oppList;
    }

    /**
    * Generates a random number between 1 and 100. For automated territory assignment.
    * @return Integer A random integer
    */
    public static Integer generateOpportunityAssignmentNumber()
    {
        Double randNumber = Math.random()*100;

        return randNumber.intValue();
    }

    /**
    * Finds all Opportunities that are tied to a Leads Convert_Contact__c and updates information from a Lead on the Opportunites.
    * @param Set<Id> A set of lead ids to map to opportunities
    * @return List<Opportunity> A list of opportunities with the mapped lead data
    */
    public static List<Opportunity> mapLeadDataToOpportunity(Set<Id> leadIds)
    {
        List<Lead> leadsFromConversion = new List<Lead>();
        Map<Id, Lead> contactIdToLeadMap= new Map<Id, Lead>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        leadsFromConversion = [
                SELECT ConvertedContactId, Career__c, Enrollment_Term__c, First_Generation__c, Online__c, International_Student__c, Potential_National_Scholar__c, Potential_WUE__c, Search_Segment__c, Self_Reported_SES__c, Veteran_Status__c
                FROM Lead
                WHERE Id IN :leadIds
        ];

        for (Lead newLead : leadsFromConversion)
        {
            contactIdToLeadMap.put(newLead.ConvertedContactId, newLead);
        }

        Set<Id> contactIds = contactIdToLeadMap.keySet();

        System.debug('!!! Contacts in service ' + contactIds);

        // Get all the opportunities associated with these contacts
        opportunitiesToUpdate = [SELECT Contact__c, Id FROM Opportunity WHERE Contact__c IN :contactIds];

        System.debug('!!! Opportunites in service ' + opportunitiesToUpdate);

        // Update all the opportunity information
        for (Opportunity opp : opportunitiesToUpdate)
        {
            Lead leadData = contactIdToLeadMap.get(opp.Contact__c);

            opp.Career__c = leadData.Career__c;
            opp.Term__c = leadData.Enrollment_Term__c;
            opp.First_Generation__c = leadData.First_Generation__c;
            opp.Online_Degree__c = leadData.Online__c;
            opp.International_Student__c = leadData.International_Student__c;
            opp.Potential_National_Scholar__c = leadData.Potential_National_Scholar__c;
            opp.Potential_WUE__c = leadData.Potential_WUE__c;
            opp.Search_Segment__c = leadData.Search_Segment__c;
            opp.Self_Reported_SES__c = leadData.Self_Reported_SES__c;
            opp.Military_Status__c = leadData.Veteran_Status__c;
        }

        System.debug('!!! After mapping data ' + opportunitiesToUpdate);

        return opportunitiesToUpdate;
    }

}