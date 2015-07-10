public with sharing class CaseTransferController
{
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
	}

	public PageReference page1()
	{
		page = 1;
		return ApexPages.currentPage();
	}

	public PageReference page2()
	{
		page = 2;
		return ApexPages.currentPage();
	}

	public PageReference page3()
	{
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

	public void searchUsers()
	{
		/*List<GroupMember> groupsUserIsIn = [SELECT GroupId, UserOrGroupId, Group.Name 
										    FROM GroupMember 
										  	WHERE UserOrGroupId = :UserInfo.getUserId()];

		Set<Id> idSet = new Set<Id>();
		for (GroupMember gm : groupsUserIsIn)
		{
			List<GroupMember> individualGroupMembers = [SELECT UserOrGroupId 
														FROM GroupMember 
														WHERE GroupId = :gm.GroupId];

			for (GroupMember igm : individualGroupMembers)
			{
				String groupId = igm.UserOrGroupId;
				if (groupId.startsWith('005'))
				{
					idSet.add(igm.UserOrGroupId);
				}

				if(groupId.startsWith('00G'))
				{
					List<GroupMember> subGroupList = [SELECT GroupId, UserOrGroupId, Group.Name 
											      	  FROM GroupMember 
											  	  	  WHERE GroupId = :gm.UserOrGroupId];

					for (GroupMember sgm : subGroupList)
					{
						String subGroupId = sgm.UserOrGroupId;
						if (groupId.startsWith('005'))
						{
							idSet.add(sgm.UserOrGroupId);
						}
					}
				}
			}
		}
		List<User> userList = [SELECT Id, Name FROM User WHERE Id IN :idSet ORDER BY Name ASC];*/

		/*Id proId = [SELECT ProfileId FROM User WHERE Id = :UserInfo.getUserId()].ProfileId;
		List<User> userList = [SELECT Id, Name FROM User WHERE ProfileId = :proId];
		userList.sort();*/

		if (searchString == null)
		{
			userList = [SELECT Id, Name, UserRole.ParentRoleId 
						FROM User 
						WHERE UserRoleId = :UserInfo.getUserRoleId()
						AND (NOT Name LIKE '%API%')
						AND (NOT Name LIKE '%zz%')];

			Id sServiceId = [SELECT Id FROM UserRole WHERE Name = 'S Service'].Id;
			Set<Id> roleIdsToAdd = new Set<Id>();

			for (User u : userList)
			{
				if (u.UserRole.ParentRoleId != null && u.UserRole.ParentRoleId != sServiceId)
				{
					roleIdsToAdd.add(u.UserRole.ParentRoleId);
				}
			}

			List<User> usersToAdd = [SELECT Id, Name 
									 FROM User 
									 WHERE UserRoleId 
									 IN :roleIdsToAdd];

			userList.addAll(usersToAdd);
			userList.sort();
		}
		else 
		{
			Id userRole = UserInfo.getUserRoleId();
			String queryString = 'SELECT Id, Name, UserRole.ParentRoleId FROM User WHERE UserRoleId = :userRole AND (NOT Name LIKE \'%API%\') AND (NOT Name LIKE \'%zz%\') AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
			userList = Database.query(queryString);

			Id sServiceId = [SELECT Id FROM UserRole WHERE Name = 'S Service'].Id;
			Set<Id> roleIdsToAdd = new Set<Id>();

			for (User u : userList)
			{
				if (u.UserRole.ParentRoleId != null && u.UserRole.ParentRoleId != sServiceId)
				{
					roleIdsToAdd.add(u.UserRole.ParentRoleId);
				}
			}

			String query2String = 'SELECT Id, Name FROM User WHERE UserRoleId IN :roleIdsToAdd AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
			List<User> usersToAdd = Database.query(query2String);

			userList.addAll(usersToAdd);
			userList.sort();
		}
	}

	public PageReference transferCase()
	{
        try
        {
        	Case_Assignment_Rule__c selectedCAR = [SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c, Functional_Group__c, Category__c, Sub_Category__c, Label__c, Name, Queue_ID__c
				   		   						   FROM Case_Assignment_Rule__c
				   		   						   WHERE Id = :selectedId];
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
