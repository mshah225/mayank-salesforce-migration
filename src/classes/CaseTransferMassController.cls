public with sharing class CaseTransferMassController {
    public List<Case> cases { get; set; }
    private Boolean isUserPageLoaded;
    private Boolean isCARPageLoaded;
    private List<User> asUsersToAdd;
    private Set<Id> asRoleIds;
    private Set<Id> uberRoleIds;
    private String caseSub;
    private String caseDesc;

    public String selectedIds { get; set; }
    public Boolean toUser;
    public Integer page { get; set; }
    public Id selectedId { get; set; }
    public List<Case_Assignment_Rule__c> allNonGenCARs;
    public List<Case_Assignment_Rule__c> allGenCARs;
    public List<User> userList { get; set; }
    public Map<String, List<Case_Assignment_Rule__c>> serviceCARS { get; set; }
    public Map<String, List<Case_Assignment_Rule__c>> collegeCARS { get; set; }
    public String selectedGroupName { get; set; }
    public String selectedCARLabel { get; set; }
    public String source { get; set; }
    public String searchString { get; set; }

    public CaseTransferMassController(ApexPages.StandardController stdController) {
        selectedIds = fixParameter(apexpages.currentpage().getparameters().get('ids').trim());
        System.Debug('SELECTEDIDS=' + selectedIds);
        List<Id> caseIds = selectedIds.split(',');
        System.Debug('CASEIDS=' + caseIds.size());
        page = 1;
        isUserPageLoaded = false;
        isCARPageLoaded = false;
        userList = new List<User>();
        serviceCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        collegeCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        cases = new List<Case>();
        for (Case ca : [SELECT Id, CaseNumber, Status, Type, Subject FROM Case WHERE Id IN :caseIds]) {
            cases.add(ca);
        }
        System.Debug('CASES=' + cases.size());
    }

    public PageReference page1() {
        page = 1;

        return ApexPages.currentPage();
    }

    public PageReference page2() {
        searchString = null;
        toUser = true;
        page = 2;

        // Populate various page variables on page2 first load.
        if (!isUserPageLoaded) {
            // Populate the admission services user set
            asRoleIds = getAsRoleIds();

            if (asRoleIds.contains(UserInfo.getUserRoleId())) {
                asUsersToAdd = [
                    SELECT Id, Name, Department, Title, UserRole.Id
                    FROM User
                    WHERE UserRole.Id IN :asRoleIds
                ];

                if (asUsersToAdd.size() == 0)
                    asUsersToAdd = new List<User>();
            }

            // Get Uber Role Ids
            List<UserRole> uberRoleIdList = [
                SELECT Id, Name
                FROM UserRole
                WHERE (NOT Name LIKE 'Z Unassigned%') AND ParentRoleId = NULL
            ];

            // Add Uber Role Ids to set for later.
            uberRoleIds = new Set<Id>();

            for (UserRole ur : uberRoleIdList) {
                uberRoleIds.add(ur.Id);
            }

            // After first run, set loaded variable.
            isUserPageLoaded = true;
        }

        // Search for all users.
        searchUsers();

        return ApexPages.currentPage();
    }

    public PageReference page3() {
        toUser = false;
        page = 3;

        // Populate various page variables on page3 first load.
        if (!isCARPageLoaded) {
            // The general list of CARs. Their labels should have '(General)' in them.
            allGenCARs = CARService.getGeneralCARs();

            // All the CARs for this org that do not have the '(General)' tag
            allNonGenCARs = CARService.getNonGeneralCARs();

            // Add the non General CARs to the main list. This way General ones are first.
            allGenCARs.addAll(allNonGenCARs);

            for (Case_Assignment_Rule__c car : allGenCARs) {
                if (car.CTPColumn__c.equals('Service Departments')) {
                    if (serviceCARS.containsKey(car.CTPGroup__c)) {
                        serviceCARS.get(car.CTPGroup__c).add(car);
                    } else {
                        serviceCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c>{ car });
                    }
                } else if (car.CTPColumn__c.equals('Colleges')) {
                    if (collegeCARS.containsKey(car.CTPGroup__c)) {
                        collegeCARS.get(car.CTPGroup__c).add(car);
                    } else {
                        collegeCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c>{ car });
                    }
                }
            }

            // After first run, set loaded variable.
            isCARPageLoaded = true;
        }

        return ApexPages.currentPage();
    }

    public PageReference page4() {
        page = 4;

        return ApexPages.currentPage();
    }

    public void resetSearch() {
        searchString = null;
        userList.clear();
        searchUsers();
    }

    public void searchUsers() {
        userList.clear();
        List<User> usersToAdd = new List<User>();

        // Check if user is AS, else query for specific user roles
        if (asRoleIds.contains(UserInfo.getUserRoleId())) {
            usersToAdd.addAll(asUsersToAdd);
        } else {
            // Create search query for users.
            usersToAdd = [
                SELECT Id, Name, UserRole.ParentRoleId, Title, Department
                FROM User
                WHERE
                    UserRoleId = :UserInfo.getUserRoleId()
                    AND Id != :UserInfo.getUserId()
                    AND IsActive = TRUE
                    AND UserPermissionsSupportUser = TRUE
            ];

            // Find subordinants for the current user, if they exist.
            List<User> subordinateList = [
                SELECT Id, Name, Title, Department, UserRole.Id
                FROM User
                WHERE UserRole.ParentRoleId = :UserInfo.getUserRoleId()
            ];

            if (subordinateList.size() > 0) {
                usersToAdd.addAll(subordinateList);
            }
        }

        // If the user isn't an AS user, grab their managers
        if (!asRoleIds.contains(UserInfo.getUserRoleId())) {
            // Grab users parent role id
            Id usersParentRoleId = [SELECT UserRole.ParentRoleId FROM User WHERE Id = :UserInfo.getUserId()]
            .UserRole.ParentRoleId;

            // Check for null and that the parent role id is not an uber role
            if (usersParentRoleId != null && !uberRoleIds.contains(usersParentRoleId)) {
                List<User> managers = [
                    SELECT Id, Name, Title, Department
                    FROM User
                    WHERE UserRole.Id = :usersParentRoleId
                ];

                usersToAdd.addAll(managers);
            }
        }

        // If we're performing a search, filter on search term, else add all to userList
        if (searchString != null) {
            String sosl =
                '' +
                'FIND \'' +
                String.escapeSingleQuotes(searchString.trim()) +
                '*\' ' +
                'IN ALL FIELDS RETURNING ' +
                'User(' +
                'Id, Name, Title, Department ' +
                'WHERE Id IN :usersToAdd ' +
                'AND IsActive = true ' +
                'AND UserPermissionsSupportUser = true)';

            List<List<SObject>> soslResults = Search.query(sosl);

            if (soslResults.size() > 0) {
                userList = soslResults[0];
                userList.sort();
            } else {
                userList = new List<User>();
            }
        } else {
            userList.addAll(usersToAdd);
            userList.sort();
        }
    }

    // Helper method to get all AS role Ids. Store these in a set for later.
    public Set<Id> getAsRoleIds() {
        Set<Id> asRoleIds = new Set<Id>();

        // Get Admission Services Uber Role Id
        Id asUberRoleId = [SELECT Id FROM UserRole WHERE Name = 'AS Admission Services'].Id;

        asRoleIds.add(asUberRoleId);

        // Get Admission Services manager roles
        List<UserRole> asManagerRoleIds = [SELECT Id FROM UserRole WHERE ParentRoleId = :asUberRoleId];

        for (UserRole manRoles : asManagerRoleIds) {
            asRoleIds.add(manRoles.Id);
        }

        // Get Adminssion Services subordinate roles
        List<UserRole> asSubRoleIds = [SELECT Id FROM UserRole WHERE ParentRoleId IN :asManagerRoleIds];

        for (UserRole subRoles : asSubRoleIds) {
            asRoleIds.add(subRoles.Id);
        }

        return asRoleIds;
    }

    // Transfer the case and redirect
    public PageReference transferCase() {
        /*
         * Transfer to a department by setting the case information
         * according to the selected CAR
         */
        if (toUser) {
            for (Case c : cases) {
                c.OwnerId = selectedId;
                update c;
            }
        } else {
            for (Case c : cases) {
                Case_Assignment_Rule__c selectedCAR = CARService.getCAR(selectedId);
                c.OwnerId = selectedCAR.Queue_ID__c;
                c.CC_Functional_Group__c = selectedCAR.CC_Functional_Group__c;
                c.CC_Category__c = selectedCAR.CC_Category__c;
                c.CC_Sub_Category__c = selectedCAR.CC_Sub_Category__c;
                c.Case_Feed_Email__c = selectedCAR.Email_Address__c;
                c.Case_Feed_Email_Template_Id__C = selectedCar.Case_Feed_Email_Template_Id__c;
                c.Campus__c = selectedCAR.Campus__c;
                update c;
            }
        }

        page = 5;

        return ApexPages.currentPage();
    }

    public string fixParameter(string param) {
        param = param.replaceAll('(\\s+)', '');
        param = param.replace('(', '');
        param = param.replace(')', '');
        return param;
    }
}
