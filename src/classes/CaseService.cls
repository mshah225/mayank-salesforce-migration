public without sharing class CaseService 
{
	/**
	* Returns all the fields on Case in a String
	* @return A string containing all the Case fields
	*/
	public static String caseFieldsToString()
	{
		String caseFields = null;

		Map<String, SObjectField> caseFieldMap = ObjectService.getObjectFieldMap('Case');

		caseFields = ObjectService.objectFieldsToString(caseFieldMap);
		
		return caseFields;
	}

	/**
    * Get these contact's open visible cases
    * @param A list of contacts
    * @return A map containing the set of contactIds and their associated cases
    */
    public static Map<Id, List<Case>> getVisibleOpenCases(List<Contact> listOfContacts) 
    {
        List<Case> openCases = null;
        String caseFields = caseFieldsToString();

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts)
        {
        	contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try
        {
        	String selectOpenVisibleCases = 'SELECT ' + caseFields + ' ' +
        									'FROM Case ' +
        									'WHERE IsClosed = false ' +
        									'AND Visible_by_Contact__c = true ' +
        									'AND ContactId IN :contactIds ' +
        									'ORDER BY CreatedDate DESC';

            openCases = Database.query(selectOpenVisibleCases);
        }
        catch (Exception e)
        {
            throw new CaseServiceException('!!!ERROR!!!: An error occurred trying to get the Contact\'s open visible cases\n' + e.getStackTraceString());
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : openCases)
        {
        	if (conCaseMap.containsKey(caze.ContactId))
        	{
        		conCaseMap.get(caze.ContactId).add(caze);
        	}
        	else
        	{
        		conCaseMap.put(caze.ContactId, new List<Case> { caze });
        	}
        }

        return conCaseMap;
    }

    /**
    * Get these contact's closed visible cases
    * @param A list of contacts
    * @return A map containing the set of contactIds and their associated cases
    */
    public static Map<Id, List<Case>> getVisibleClosedCases(List<Contact> listOfContacts)
    {
        List<Case> closedCases = null;

        String caseFields = caseFieldsToString();

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts)
        {
        	contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try
        {
           	String selectClosedVisibleCases = 'SELECT ' + caseFields + ' ' +
        									'FROM Case ' +
        									'WHERE IsClosed = true ' +
        									'AND Visible_by_Contact__c = true ' +
        									'AND ContactId IN :contactIds ' +
        									'ORDER BY ClosedDate DESC';

            closedCases = Database.query(selectClosedVisibleCases);
        }
        catch (Exception e)
        {
            throw new CaseServiceException('!!!ERROR!!!: An error occurred trying to get the Contact\'s closed visible cases\n' + e.getStackTraceString());
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : closedCases)
        {
        	if (conCaseMap.containsKey(caze.ContactId))
        	{
        		conCaseMap.get(caze.ContactId).add(caze);
        	}
        	else
        	{
        		conCaseMap.put(caze.ContactId, new List<Case> { caze });
        	}
        }

        return conCaseMap;
    }

    /**
    * Create a number of test cases. Usually for unit tests.
    * @param An integer describing the number of cases to create
    * @param The contact to associate the cases to
    * @return A list of cases
    */
    public static List<Case> createTestCases(Integer numberOfCases, Contact con)
    {
    	List<Case> testCases = new List<Case>();

    	for (Integer i = 0; i < numberOfCases; i++)
    	{
    		Case c = new Case();
    		c.Subject = 'Test Case ' + i;
    		c.Description = 'Auto generated test case';
    		c.ContactId = con.Id;
    		testCases.add(c);
    	}

    	return testCases;
    }

    public class CaseServiceException extends Exception {}
}