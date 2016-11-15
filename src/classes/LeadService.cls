public class LeadService
{
	/**
	 * Creates a Lead with all required fields, usually for unit testing
	 * @return testLead A lead with all required fields
	 */
	public static Lead createTestLead()
	{
		Lead testLead = new Lead();
        testLead.FirstName = 'Jonny';
        testLead.LastName = 'Test';
        testLead.Email = 'test@nomail.com';
        testLead.Company = 'Test Company';

		return testLead;
	}

	/**
    * Generates a set of test leads to convert
    * @param contactsToConvertOn a set of Contacts to convert to
    * @return leads a list of test lead data
    */
	public static List<Lead> createTestLeadsToConvert(List<Contact> contactsToConvertOn)
	{
		List<Lead> leads = new List<Lead>();

		for (Contact con : contactsToConvertOn)
		{
			Lead testLead = new Lead();
			testLead.FirstName = con.FirstName;
			testLead.LastName = con.LastName;
			testLead.Email = con.Email;
			testLead.LeadSource = 'Email';
			testLead.Company = 'TestCompany';
			testLead.Career__c = 'Undergraduate';
			testLead.Online__c = true;
			testLead.International_Student__c = true;
			testLead.First_Generation__c = true;
			testLead.Potential_National_Scholar__c = true;
			testLead.Potential_WUE__c = true;
			testLead.Search_Segment__c = 'Scholar';
			testLead.Self_Reported_SES__c = 'Moderate';
			testLead.Veteran_Status__c = 'Veteran';
			testLead.Convert_Contact__c = con.Id;

			leads.add(testLead);
		}

		return leads;
	}

    /**
	 * Generates a list of lead interests that should be updated as a result of conversion
	 * @param  leadIds A set of Lead Ids
	 * @return leadInterestList A list of lead interests
	 */
    public static List<Lead_Interest__c> reparentRelatedLeadInterests(Set<Id> leadIds)
    {
        List<Lead_Interest__c> leadInterestList = new List<Lead_Interest__c>();

        if (leadIds.size() == 0)
        {
            return leadInterestList;
        }

        leadInterestList = [
                SELECT Id, OwnerId, IsDeleted, Name, RecordType.Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Leads__c, Eligibility__c, Plan__c, Contact__c, Status__c, Term__c, Primary_Source__c, Secondary_Source__c, Type__c, College__c, Academic_Interest__c, Test_Record__c, Qualifying__c, Send_Email__c, External_Application_Number__c, Send_Email_ID__c
                FROM Lead_Interest__c
                WHERE Leads__c IN :leadIds
        ];

        if (leadInterestList.size() == 0)
        {
            return leadInterestList;
        }

        // Need to requery to get the Converted Contact Ids
        Map<Id, Lead> leadToContactIdMap = new Map<Id, Lead>([
                SELECT Id, ConvertedContactId
                FROM Lead
                WHERE Id IN :leadIds
        ]);

        for (Lead_Interest__c li: leadInterestList)
        {
            li.Contact__c = leadToContactIdMap.get(li.leads__c).ConvertedContactId;
        }

        return leadInterestList;
    }

    /**
	 * Generates a list of previous education records that should be inserted as a result of conversion
	 * @param  leadIds A set of Lead Ids
	 * @return peList A list of previous education records
	 */
    public static List<Previous_Education__c> createConvertedPreviousEducation(Set<Id> leadIds)
    {
        List<Previous_Education__c> peList = new List<Previous_Education__c>();

        if (leadIds.size() == 0)
        {
            return peList;
        }

        List<Lead> leadList = new List<Lead>([
                SELECT Id, ConvertedContactId, Last_Institution_Attended__c, Last_Institution_Attended__r.Institution_Type__c, Last_Institution_GPA__c, Last_Institution_GPA_Scale__c, College_Transfer_Hours__c, High_School_Class_Percent__c, High_School_Class_Rank__c, High_School_Class_Size__c
                FROM Lead
                WHERE Id in :leadIds
        ]);

        for (Lead l : leadList)
        {
            Previous_Education__c pe = new Previous_Education__c(Contact__c = l.ConvertedContactId,
                    Account__c = l.Last_Institution_Attended__c);

            if (l.Last_Institution_Attended__r.Institution_Type__c == 'HS')
            {
                pe.Class_Rank__c = l.High_School_Class_Rank__c;
                pe.Class_Size__c = l.High_School_Class_Size__c;
            }

            pe.GPA__c = l.Last_Institution_GPA__c;
            peList.add(pe);
        }

        return peList;
    }

    /**
     * Generates a map of integers to a List of LeadConvert objects
     * @param leadList A list of leads that have not been converted yet
     * @param conversionStatus The MasterLabel from a LeadStatus that these leads should be converted to
     * @return leadConvertBatches A map of all the leadConvert objects in batches
     */
    public static Map<Integer, List<Database.LeadConvert>> generateLeadConvertBatches(List<Lead> leadList, String conversionStatus)
    {
        Map<Id, List<Lead>> accountToLeadMap = new Map<Id, List<Lead>>();
        Map<Integer, List<Database.LeadConvert>> leadConvertBatches = new Map<Integer, List<Database.LeadConvert>>();
        Id thisLeadsAccount;

        Integer numberOfBatches = 1;
        Integer additionalBatches = 0;

        // Map leads to a single account and track the number of LeadConvert batches we need
        for (Lead thisLead : leadList)
        {
            thisLeadsAccount = thisLead.Convert_Contact_Account_ID__c;

            // This a lead insertion, so it has no account Id, but we need a unique Id so we can batch properly
            if (thisLeadsAccount == null)
            {
                thisLeadsAccount = ObjectService.getFakeId(Account.SObjectType);
            }

            if (accountToLeadMap.containsKey(thisLeadsAccount))
            {
                List<Lead> thisList = accountToLeadMap.get(thisLeadsAccount);

                thisList.add(thisLead);

                if (thisList.size() > numberOfBatches)
                {
                    numberOfBatches = thisList.size();
                }
            }
            else
            {
                List<Lead> newListOfLeads = new List<Lead> { thisLead };
                accountToLeadMap.put(thisLeadsAccount, newListOfLeads);
            }
        }

        // Create LeadConvert objects from the leads and batch them up
        for (Integer batchNumber = 0; batchNumber < numberOfBatches; batchNumber++)
        {
            List<Database.LeadConvert> leadConvertList = new List<Database.LeadConvert>();

            for (List<Lead> leads : accountToLeadMap.values())
            {
                if (batchNumber < leads.size())
                {
                    Lead thisLead = leads.get(batchNumber);

                    // Create a lead convert object for this lead
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(thisLead.Id);
                    lc.setDoNotCreateOpportunity(!thisLead.Convert_Create_Opportunity__c);
                    lc.setConvertedStatus(conversionStatus);

                    if (thisLead.Convert_Contact__c != null)
                    {
                        lc.setContactId(thisLead.Convert_Contact__c);
                        lc.setAccountId(thisLead.Convert_Contact_Account_ID__c);
                    }

                    leadConvertList.add(lc);
                }

                // Check to make sure our lead convert list hasn't grown beyond the limit of Database.convertLeads()
                // Handle it by putting the current contents into the map as a new batch and clearing the list
                if (leadConvertList.size() == 99)
                {
                    additionalBatches++;
                    List<Database.LeadConvert> batchCut = leadConvertList.clone();
                    leadConvertBatches.put(numberOfBatches + additionalBatches, batchCut);
                    leadConvertList.clear();
                }
            }

            leadConvertBatches.put(batchNumber, leadConvertList);
        }

        return leadConvertBatches;
    }

}