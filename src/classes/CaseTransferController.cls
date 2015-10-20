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

        // The general list of CARs. Their labels should have '(General)' in them.
        allGenCARs = [
                SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c,
                    Functional_Group__c, Label__c, Name, Queue_ID__c
                FROM Case_Assignment_Rule__c
                WHERE CTPColumn__c != null
                AND CTPGroup__c != null
                AND Label__c != null
                AND CTPVisible__c = true
                AND Label__c LIKE '%(General)%'
        ];

        // All the CARs for this org that do not have the '(General)' tag
        allCARs = [
                SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c,
                    Functional_Group__c, Label__c, Name, Queue_ID__c
                FROM Case_Assignment_Rule__c
                WHERE CTPColumn__c != null
                AND CTPGroup__c != null
                AND Label__c != null
                AND CTPVisible__c = true
                AND (NOT Label__c LIKE '%(General)%')
                ORDER BY Label__c ASC
        ];
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

        Case temp = [
                SELECT Id, Subject, Description
                FROM Case
                WHERE Id = :c.Id
        ];

        caseSub = temp.Subject;
        caseDesc = temp.Description;
        if (caseSub == null || caseDesc == null)
        {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'The Subject and Description are ' +
                'required fields for case transfer. Please fill out the missing fields before ' +
                'transferring the case.')
            );
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
        userList.clear();
        searchUsers();
    }

    public void searchUsers()
    {
        Set<Id> ASroleIds = getASRoleIds();
        List<User> usersToAdd = new List<User>();

        if (asRoleIds.contains(UserInfo.getUserRoleId()))
        {
            List<User> ASusersToAdd = [
                    SELECT Id, Name, Department, Title, UserRole.Id
                    FROM User
                    WHERE UserRole.Id IN : ASroleIds
            ];

            usersToAdd.addAll(ASusersToAdd);
        }
        else
        {
            // Create search query for users.
            String queryString = 'SELECT Id, Name, UserRole.ParentRoleId, Title, Department ' +
                    'FROM User ' +
                    'WHERE UserRoleId = \'' + UserInfo.getUserRoleId() + '\' ' +
                    'AND Id != \'' + UserInfo.getUserId() + '\' ' +
                    'AND IsActive = true ' +
                    'AND UserPermissionsSupportUser = true';

            // If searchString is populated, we'll add another AND LIKE clause.
            if (searchString != null)
            {
                System.debug('searching: ' + searchString);
                String userSearchString = ' AND Name LIKE ' +
                        '\'%' + String.escapeSingleQuotes(searchString) + '%\'';
                queryString += userSearchString;
            }

            System.debug('!!!!Querystring: ' + queryString);
            usersToAdd = Database.query(queryString);

            // Find subordinants for the current user, if they exist.
            List<User> subordinateList = [
                    SELECT Id, Name, Title, Department, UserRole.Id
                    FROM User
                    WHERE UserRole.ParentRoleId = :UserInfo.getUserRoleId()
            ];

            if (subordinateList.size() > 0)
            {
                usersToAdd.addAll(subordinateList);
            }
        }

        if (searchString != null)
        {
            // Reset the userlist if it's populated.
            userList.clear();

            String searchFilterString = 'SELECT Id, Name, Title, Department ' +
                    'FROM User ' +
                    'WHERE Id IN :usersToAdd ' +
                    'AND IsActive = true ' +
                    'AND UserPermissionsSupportUser = true ' +
                    'AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';

            List<User> filterdUsers = Database.query(searchFilterString);
            userList.addAll(filterdUsers);

        }
        else
        {
            userList.addAll(usersToAdd);
        }

        // Get Uber Role Ids
        List<UserRole> uberRoleIdList = [
                SELECT Id, Name
                FROM UserRole
                WHERE (NOT Name LIKE 'Z Unassigned%')
                AND ParentRoleId = null
        ];

        // Add Uber Role Ids to set for later.
        Set<Id> uberRoleIdSet = new Set<Id>();
        for (UserRole ur: uberRoleIdList)
        {
            uberRoleIdSet.add(ur.Id);
        }

        // Grab users parent role id
        Id usersParentRoleId = [
                SELECT UserRole.ParentRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ].Id;

        // Check for null and that the parent role id is not an uber role
        if (usersParentRoleId != null && !uberRoleIdSet.contains(usersParentRoleId))
        {
            List<User> managers = [
                    SELECT Id, Name, Title, Department
                    FROM User
                    WHERE UserRole.Id = :usersParentRoleId
            ];
            userList.addAll(managers);
        }

        System.debug('User list populated');
        userList.sort();
    }

    public Set<Id> getASRoleIds()
    {
        Set<Id> ASroleIds = new Set<Id>();

        // Get Admission Services Uber Role Id
        Id ASuberRoleId = [
                SELECT Id
                FROM UserRole
                WHERE Name = 'AS Admission Services'
        ].Id;

        ASroleIds.add(ASuberRoleId);

        // Get Admission Services manager roles
        List<UserRole> ASmanagerRoleIds = [
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId = :ASuberRoleId
        ];

        for (UserRole manRoles : ASmanagerRoleIds)
        {
            ASroleIds.add(manRoles.Id);
        }

        // Get Adminssion Services subordinate roles
        List<UserRole> ASsubRoleIds = [
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId IN :ASmanagerRoleIds
        ];

        for (UserRole subRoles : ASsubRoleIds)
        {
            ASroleIds.add(subRoles.Id);
        }

        return ASroleIds;
    }

    public PageReference transferCase()
    {
        try
        {
            if (caseSub != null && caseDesc != null)
            {
                // Transfer to a department by setting the case information
                // according to the selected CAR
                if (!toUser)
                {
                    Case_Assignment_Rule__c selectedCAR = [
                            SELECT Id, CTPColumn__c, CTPGroup__c, CTPVisible__c, Email_Address__c,
                                Functional_Group__c, Category__c, Sub_Category__c, Label__c, Name,
                                Queue_ID__c, Case_Feed_Email_Template_Id__c
                            FROM Case_Assignment_Rule__c
                            WHERE Id = :selectedId
                    ];

                    c.OwnerId = selectedCAR.Queue_ID__c;
                    c.Functional_Group__c = selectedCAR.Functional_Group__c;
                    c.Category__c = selectedCAR.Category__c;
                    c.Sub_Category__c = selectedCAR.Sub_Category__c;
                    c.Case_Feed_Email__c = selectedCAR.Email_Address__c;
                    c.Case_Feed_Email_Template_Id__C = selectedCar.Case_Feed_Email_Template_Id__c;
                }
                else
                {
                    System.debug('!!!!!!!!SelectedId: ' + selectedId);
                    c.OwnerId = selectedId;
                }

                update c;
            }
            else{
                ApexPages.getMessages().clear();
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,'The Subject and Description ' +
                    'are required fields for case transfer. Please fill out the missing fields ' +
                    'before transferring the case.')
                );

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