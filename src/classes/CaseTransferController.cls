public with sharing class CaseTransferController
{
	private final Case c;
	public Boolean showChatter { get;set; }
	public Id selectedCARId { get;set; }
	public List<Case_Assignment_Rule__c> allCARs;
	public List<Case_Assignment_Rule__c> allGenCARs;
	public List<Schema.PickListEntry> columnList;
	public Map<String, List<Case_Assignment_Rule__c>> serviceCARS { get;set; }
	public Map<String, List<Case_Assignment_Rule__c>> collegeCARS { get;set; }
	public String selectedGroupName { get;set; }
	public String selectedCARLabel { get;set; }

	public CaseTransferController(ApexPages.StandardController stdController)
	{
		showChatter = false;
		serviceCARS = new Map<String, List<Case_Assignment_Rule__c>>();
		collegeCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        this.c = (Case)stdController.getRecord();
		allGenCARs = [SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c, Functional_Group__c, Label__c, Name, Queue_ID__c
				   FROM Case_Assignment_Rule__c
				   WHERE CTPColumn__c != null
				   AND CTPGroup__c != null
				   AND Label__c != null
				   AND CTPVisible__c = true
				   AND Label__c LIKE '%(General)%'];
		allCARs = [SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c, Functional_Group__c, Label__c, Name, Queue_ID__c
				   FROM Case_Assignment_Rule__c
				   WHERE CTPColumn__c != null
				   AND CTPGroup__c != null
				   AND Label__c != null
				   AND CTPVisible__c = true
				   AND (NOT Label__c LIKE '%(General)%')
				   ORDER BY Label__c ASC];
		allGenCARs.addAll(allCARS);

		for (Case_Assignment_Rule__c car : allGenCARs)
        {
        	if (car.CTPColumn__c.equals('Service Departments'))
			{
	        	if (serviceCARS.containsKey(car.CTPGroup__c))
	        	{
	        		serviceCARS.get(car.CTPGroup__c).add(car);
	        	}
	        	else
	        	{
	        		serviceCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c> { car });
	        	}
	        }
	        else if (car.CTPColumn__c.equals('Colleges'))
	        {
	        	if (collegeCARS.containsKey(car.CTPGroup__c))
	        	{
	        		collegeCARS.get(car.CTPGroup__c).add(car);
	        	}
	        	else
	        	{
	        		collegeCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c> { car });
	        	}
	        }
        }
	}

	public List<Schema.PickListEntry> getColumnList()
	{
		Schema.DescribeFieldResult fieldResult = Case_Assignment_Rule__c.CTPColumn__c.getDescribe();
		columnList = fieldResult.getPicklistValues();
		return columnList;
	}

	public void showChatterBox()
	{
		showChatter = true;
		selectedCARLabel = [SELECT Label__c FROM Case_Assignment_Rule__c WHERE Id = :selectedCARId].Label__c;
	}

	public PageReference transferCase()
	{
        try
        {
        	Case_Assignment_Rule__c selectedCAR = [SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c, Functional_Group__c, Category__c, Sub_Category__c, Label__c, Name, Queue_ID__c
				   		   						   FROM Case_Assignment_Rule__c
				   		   						   WHERE Id = :selectedCARId];
            c.OwnerId = selectedCAR.Queue_ID__c;
            c.Functional_Group__c = selectedCAR.Functional_Group__c;
            c.Category__c = selectedCAR.Category__c;
            c.Sub_Category__c = selectedCAR.Sub_Category__c;
            update c;
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Message: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return null;
        }

        PageReference save = new PageReference('/' + c.Id);
        save.setRedirect(true);
        return save;
    }
}
