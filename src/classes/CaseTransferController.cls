public with sharing class CaseTransferController
{
	public Boolean toUser;
	private final Case c;
	public Integer page { get; set; }
	public Id selectedId { get;set; }
	public List<Case_Assignment_Rule__c> allCARs;
	public List<Case_Assignment_Rule__c> allGenCARs;
	public List<Schema.PickListEntry> columnList;
	public List<User> userList { get; set; }
	public Map<String, List<Case_Assignment_Rule__c>> serviceCARS { get; set; }
	public Map<String, List<Case_Assignment_Rule__c>> collegeCARS { get; set; }
	public String selectedGroupName { get; set; }
	public String selectedCARLabel { get; set; }
	public String source { get; set; }
	public String searchString { get; set; }
	private String caseSub;
	private String caseDesc;

	public CaseTransferController(ApexPages.StandardController stdController)
	{
		page = 1;
		userList = new List<User>();
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
		searchUsers();

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

        Case temp = [SELECT Id, Subject, Description 
        			 FROM Case 
        			 WHERE Id = :c.Id];

        caseSub = temp.Subject;
        caseDesc = temp.Description;
        if (caseSub == null || caseDesc == null)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Subject and Description are required fields for case transfer. Please fill out the missing fields before transferring the case.'));
		}
	}

	public PageReference page1()
	{
		page = 1;
		return ApexPages.currentPage();
	}

	public PageReference page2()
	{
		toUser = true;
		page = 2;
		return ApexPages.currentPage();
	}

	public PageReference page3()
	{
		toUser = false;
		page = 3;
		return ApexPages.currentPage();
	}

	public PageReference page4()
	{
		page = 4;
		return ApexPages.currentPage();
	}

	public List<Schema.PickListEntry> getColumnList()
	{
		Schema.DescribeFieldResult fieldResult = Case_Assignment_Rule__c.CTPColumn__c.getDescribe();
		columnList = fieldResult.getPicklistValues();
		return columnList;
	}

	public void resetSearch()
	{
		searchString = null;
		searchUsers();
	}

	public void searchUsers()
	{
		if (searchString == null)
		{
			Set<Id> uberRoleIds = new Set<Id>();
			Set<Id> roleIdsToAdd = new Set<Id>();

			List<User> uberRoles = [SELECT UserRole.Id 
									FROM User 
									WHERE (NOT Name LIKE '%API%')
									AND (NOT Name LIKE '%zz%')
									AND (NOT Name LIKE '%Guest%')
									AND (NOT Name LIKE '%Admin%')
									AND (NOT Name LIKE '%Expert%')
									And UserRole.Name != null
									AND UserRole.ParentRoleId = null];

			userList = [SELECT Id, Name, UserRole.ParentRoleId, Title, Department 
						FROM User 
						WHERE UserRoleId = :UserInfo.getUserRoleId()
						AND Id != :UserInfo.getUserId()
						AND (NOT Name LIKE '%API%')
						AND (NOT Name LIKE '%zz%')];

			List<User> subordinateList = [SELECT UserRole.Id
										  FROM User
										  WHERE UserRole.ParentRoleId = :UserInfo.getUserRoleId()];

			if (subordinateList.size() > 0)
			{
				for (User su : subordinateList)
				{
					roleIdsToAdd.add(su.UserRole.Id);
				}
			}

			for (User ub: uberRoles)
			{
				uberRoleIds.add(ub.UserRole.Id);
			}

			for (User u : userList)
			{
				if (u.UserRole.ParentRoleId != null && !uberRoleIds.contains(u.UserRole.ParentRoleId))
				{
					roleIdsToAdd.add(u.UserRole.ParentRoleId);
				}
			}

			List<User> usersToAdd = [SELECT Id, Name, Title, Department 
									 FROM User 
									 WHERE UserRoleId 
									 IN :roleIdsToAdd];

			userList.addAll(usersToAdd);
			userList.sort();
		}
		else 
		{
			Set<Id> uberRoleIds = new Set<Id>();
			Set<Id> roleIdsToAdd = new Set<Id>();

			List<User> uberRoles = [SELECT UserRole.Id 
									FROM User 
									WHERE (NOT Name LIKE '%API%')
									AND (NOT Name LIKE '%zz%')
									AND (NOT Name LIKE '%Guest%')
									AND (NOT Name LIKE '%Admin%')
									AND (NOT Name LIKE '%Expert%')
									And UserRole.Name != null
									AND UserRole.ParentRoleId = null];

			Id userRole = UserInfo.getUserRoleId();
			Id userId = UserInfo.getUserId();
			String queryString = 'SELECT Id, Name, Title, Department, UserRole.ParentRoleId FROM User WHERE UserRoleId = :userRole AND Id != :userId AND (NOT Name LIKE \'%API%\') AND (NOT Name LIKE \'%zz%\') AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
			userList = Database.query(queryString);

			List<User> subordinateList = [SELECT UserRole.Id
										  FROM User
										  WHERE UserRole.ParentRoleId = :UserInfo.getUserRoleId()];

			if (subordinateList.size() > 0)
			{
				for (User su : subordinateList)
				{
					roleIdsToAdd.add(su.UserRole.Id);
				}
			}

			for (User ub: uberRoles)
			{
				uberRoleIds.add(ub.UserRole.Id);
			}

			for (User u : userList)
			{
				if (u.UserRole.ParentRoleId != null && !uberRoleIds.contains(u.UserRole.ParentRoleId))
				{
					roleIdsToAdd.add(u.UserRole.ParentRoleId);
				}
			}

			String query2String = 'SELECT Id, Name, Title, Department FROM User WHERE UserRoleId IN :roleIdsToAdd AND Id != :userId AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
			List<User> usersToAdd = Database.query(query2String);

			userList.addAll(usersToAdd);
			userList.sort();
		}
	}

	public PageReference transferCase()
	{
        try
        {
	        if (caseSub != null && caseDesc != null)
	        {	
	        	if (!toUser)
	        	{
		        	Case_Assignment_Rule__c selectedCAR = [SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c, Functional_Group__c, Category__c, Sub_Category__c, Label__c, Name, Queue_ID__c
						   		   						   FROM Case_Assignment_Rule__c
						   		   						   WHERE Id = :selectedId];
		            c.OwnerId = selectedCAR.Queue_ID__c;
		            c.Functional_Group__c = selectedCAR.Functional_Group__c;
	            	c.Category__c = selectedCAR.Category__c;
	            	c.Sub_Category__c = selectedCAR.Sub_Category__c;
		        }
		        else
		        {
		        	c.OwnerId = selectedId;
		        }
            	update c;
        	}
        	else{
        		ApexPages.getMessages().clear();
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Subject and Description are required fields for case transfer. Please fill out the missing fields before transferring the case.'));
    			return null;
        	}
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