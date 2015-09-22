public with sharing class LeadService 
{
	public static Lead createTestLead() 
	{
		Lead testLead = new Lead();
        testLead.FirstName = 'Jonny';
        testLead.LastName = 'Test';
        testLead.Email = 'test@nomail.com';
        testLead.Company = 'Test Company';
		return testLead;
	}

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

        // Get all the opportunities associated with these contacts
        opportunitiesToUpdate = [SELECT Id FROM Opportunity WHERE Id IN :contactIds];

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

        return opportunitiesToUpdate;
    }
}