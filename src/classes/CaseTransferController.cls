public with sharing class CaseTransferController 
{
	public Case currentCase { get;set; }
	public List<Case_Assignment_Rule__c> allCARs;
	public List<Schema.PickListEntry> columnList;

	public CaseTransferController() 
	{
		currentCase = [SELECT Id 
					   FROM Case 
					   WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
		allCARs = [SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c, Functional_Group__c, Label__c, Name 
				   FROM Case_Assignment_Rule__c 
				   WHERE CTPColumn__c != null 
				   AND CTPGroup__c != null 
				   AND Label__c != null 
				   AND CTPVisible__c = true];
		Schema.DescribeFieldResult fieldResult = Case_Assignment_Rule__c.CTPColumn__c.getDescribe();
		columnList = fieldResult.getPicklistValues();
	}
}