public with sharing class CaseTransferController
{
    private final Case c;
    private String caseSub;
    private String caseDesc;

    public Boolean toUser;
    public Integer page { get; set; }
    public Id selectedId { get; set; }
    public List<Case_Assignment_Rule__c> allNonGenCARs;
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
        this.c = (Case) stdController.getRecord();

        // The general list of CARs. Their labels should have '(General)' in them.
        allGenCARs = CARService.getGeneralCARs();

        // All the CARs for this org that do not have the '(General)' tag
        allNonGenCARs = CARService.getNonGeneralCARs();

        // Add the non General CARs to the main list. This way General ones are first.
        allGenCARs.addAll(allNonGenCARs);
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

        Case cValidate = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE Id = :c.Id
        ];

        caseSub = cValidate.Subject;
        caseDesc = cValidate.Description;

        if (caseSub == null || caseDesc == null)
        {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'The Subject and Description ' +
                    'are required fields for case transfer. Please fill out the missing fields ' +
                    'before transferring the case.')
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
        userList.clear();
        Set<Id> ASroleIds = getASRoleIds();
        List<User> usersToAdd = new List<User>();

        //Check if user is AS, else query for specific user roles
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
            usersToAdd = [
                SELECT Id, Name, UserRole.ParentRoleId, Title, Department
                FROM User
                WHERE UserRoleId = :UserInfo.getUserRoleId()
                AND Id != :UserInfo.getUserId()
                AND IsActive = true
                AND UserPermissionsSupportUser = true
            ];

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

        //If the user isn't an AS user, grab their managers
        if(!asRoleIds.contains(UserInfo.getUserRoleId()))
        {
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
            ].UserRole.ParentRoleId;

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
        }

        //If we're performing a search, filter on search term, else add all to userList
        if(searchString != null)
        {
            String sosl = '' +
                'FIND \'' + String.escapeSingleQuotes(searchString.trim()) + '*\' ' +
                'IN ALL FIELDS RETURNING ' +
                'User(' +
                'Id, Name, Title, Department ' +
                'WHERE Id IN :usersToAdd ' +
                'AND IsActive = true ' +
                'AND UserPermissionsSupportUser = true)';

            List<List<SObject>> soslResults = Search.query(sosl);

            if (soslResults.size() > 0)
            {
                userList = soslResults[0];
            }
            else
            {
                userList = new List<User>();
            }
        }
        else
        {
            userList.addAll(usersToAdd);
        }

        userList.sort();
    }

    //Helper method to get all AS role ids
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

    //Transfer the case and redirect
    public PageReference transferCase()
    {
        try
        {
            if (caseSub != null && caseDesc != null)
            {
                /*
                 *  Transfer to a department by setting the case information
                 * according to the selected CAR
                 */
                if (!toUser)
                {
                    Case_Assignment_Rule__c selectedCAR = CARService.getCAR(selectedId);
                    c.OwnerId = selectedCAR.Queue_ID__c;
                    c.Functional_Group__c = selectedCAR.Functional_Group__c;
                    c.Category__c = selectedCAR.Category__c;
                    c.Sub_Category__c = selectedCAR.Sub_Category__c;
                    c.Case_Feed_Email__c = selectedCAR.Email_Address__c;
                    c.Case_Feed_Email_Template_Id__C = selectedCar.Case_Feed_Email_Template_Id__c;
                    c.Campus__c = selectedCAR.Campus__c;
                }
                else
                {
                    c.OwnerId = selectedId;
                }

                update c;
            }
            else
            {
                ApexPages.getMessages().clear();
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR, 'The Subject and ' +
                        'Description are required fields for case transfer. Please fill ' +
                        'out the missing fields before transferring the case.')
                );

                return null;
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);

            return null;
        }

        PageReference save = new PageReference('/' + c.Id);
        save.setRedirect(true);

        return save;
    }
}