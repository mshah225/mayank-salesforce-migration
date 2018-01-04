public with sharing class IndividualEmailResultService {
	public static void enforceOwnerPolicies(List<et4ae5__IndividualEmailResult__c> newIers) {
		for (et4ae5__IndividualEmailResult__c ier: newIers) {
				if (ier.OwnerId != ier.Apex_Owner_Should_Be__c || ier.Private_in_Salesforce__c != Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c)) {
					ier.OwnerId = ier.Apex_Owner_Should_Be__c;
					ier.Private_in_Salesforce__c = Boolean.valueOf(ier.Apex_Private_in_Salesforce_Should_Be__c);
				}
		}
	}

	/**
    * Returns all the fields on IER in a String
    * @return A string containing all the IER fields
    */
    public static String ierFieldsToString()
    {
        String ierFields = null;

        Map<String, SObjectField> ierFieldMap =
            ObjectService.getObjectFieldMap('et4ae5__IndividualEmailResult__c');

        ierFields = ObjectService.objectFieldsToString(ierFieldMap);

        return ierFields;
    }

    /**
    * Get a list of IERs for the provided Contact Id
    * @param The Id of the Contact to search on
	* @param The max number of records to return
    * @return A list of IERs for the provided Contact Id
    */
    public static List<et4ae5__IndividualEmailResult__c> getIERs(Id contactId, Integer recordLimit)
    {
        String ierFields = ierFieldsToString();

        List<et4ae5__IndividualEmailResult__c> IERs = new List<et4ae5__IndividualEmailResult__c>();

        String soql = '' +
            'SELECT ' + ierFields + ' ' +
            'FROM et4ae5__IndividualEmailResult__c ' +
            'WHERE et4ae5__Contact__c = :contactId ';
		if (recordLimit > 0)
		{
			soql += 'LIMIT ' + recordLimit;
		}

        IERs = Database.query(soql);

        return IERs;
    }

	/**
    * Get a list of IERs for the provided Contact Id; overloaded for no max record limit
    * @param The Id of the Contact to search on
    * @return A list of IERs for the provided Contact Id
    */
    public static List<et4ae5__IndividualEmailResult__c> getIERs(Id contactId)
    {
		return getIERs(contactId, 0);
	}

}