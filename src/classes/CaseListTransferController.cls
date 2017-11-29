public class CaseListTransferController {
    public final List<Case> cs {get; set;}
    private Boolean isUserPageLoaded;
    private Boolean isCARPageLoaded;
    private List<User> asUsersToAdd;
    private Set<Id> asRoleIds;
    private Set<Id> uberRoleIds;

    public Boolean toUser {get; set;}
    public Integer page {get; set;}
    public List<Case_Assignment_Rule__c> allNonGenCARs;
    public List<Case_Assignment_Rule__c> allGenCARs;
    public List<User> userList {get; set;}
    public Map<String, List<Case_Assignment_Rule__c>> serviceCARS {get; set;}
    public Map<String, List<Case_Assignment_Rule__c>> collegeCARS {get; set;}
    public String selectedGroupName {get; set;}
    public String selectedCARLabel {get; set;}
    public Case_Assignment_Rule__c selectedCAR {get; set;}
    public User selectedUser {get; set;}
    public String searchString {get; set;}
    public String source {get; set;}
    public Id selectedId {
        get;

        set {
            selectedId = value;
            if (validator.validateId(selectedId, user.class)) {
                selectedUser = [SELECT Name FROM User WHERE Id = :selectedId];
            }
        }
    }

    public CaseListTransferController(ApexPages.StandardController stdController) {
        page = 1;
        isUserPageLoaded = false;
        isCARPageLoaded = false;
        userList = new List<User>();
        serviceCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        collegeCARS = new Map<String, List<Case_Assignment_Rule__c>>();

        this.cs = [
            SELECT Subject, Description, CC_Sub_Category__c, CC_Category__c, CC_Functional_Group__c
            FROM Case
            WHERE Id = :((Case) stdController.getRecord()).Id
        ];

        for (Case c : this.cs) {
            if (String.isBlank(c.Subject) || String.isBlank(c.Description)) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR, 'The Subject and Description ' +
                        'are required fields for case transfer. Please fill out the missing fields ' +
                        'before transferring the case(s).')
                );
                break;
            }
        }
    }

    public CaseListTransferController (ApexPages.StandardSetController stdController) {
        String tstring; // Used to store temporary data
        String selectedIds = fixParameter(apexpages.currentpage().getparameters().get('caseIds'));

        List<Id> CaseIds = new List<Id>();
        page = 1;
        isUserPageLoaded = false;
        isCARPageLoaded = false;
        userList = new List<User>();
        serviceCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        collegeCARS = new Map<String, List<Case_Assignment_Rule__c>>();

        if (selectedIds != null) {
            Validator.setPrefix(Case.class);

            for (String s : selectedIds.split(',')) {
                if (Validator.validateId(s)) {
                    caseIds.add(s);
                } else {
                    ApexPages.addMessage(
                        new ApexPages.message(
                            ApexPages.severity.ERROR,
                            'Invalid Id: ' + s
                    	)
                    );
                }
            }
        } else {
            for (SObject so : stdController.getSelected()) {
	            CaseIds.add(so.Id);
	        }
        }

        this.cs = [SELECT Subject, Description, CC_Sub_Category__c, CC_Category__c, CC_Functional_Group__c
            FROM Case WHERE Id IN :CaseIds];

        for (Case c : this.cs) {
            if (String.isBlank(c.Subject) || String.isBlank(c.Description)) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR, 'The Subject and Description ' +
                        'are required fields for case transfer. Please fill out the missing fields ' +
                        'before transferring the case(s).')
                );
                break;
            }
        }
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

                if (asUsersToAdd.size() == 0) asUsersToAdd = new List<User>();
            }

            // Get Uber Role Ids
            List<UserRole> uberRoleIdList = [
                SELECT Id, Name
                FROM UserRole
                WHERE (NOT Name LIKE 'Z Unassigned%')
                AND ParentRoleId = null
            ];

            // Add Uber Role Ids to set for later.
            uberRoleIds = new Set<Id>();

            for (UserRole ur: uberRoleIdList) {
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
                        serviceCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c> { car });
                    }
                } else if (car.CTPColumn__c.equals('Colleges')) {
                    if (collegeCARS.containsKey(car.CTPGroup__c)) {
                        collegeCARS.get(car.CTPGroup__c).add(car);
                    } else {
                        collegeCARS.put(car.CTPGroup__c, new List<Case_Assignment_Rule__c> { car });
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

            if (subordinateList.size() > 0) {
                usersToAdd.addAll(subordinateList);
            }
        }

        // If the user isn't an AS user, grab their managers
        if (!asRoleIds.contains(UserInfo.getUserRoleId())) {
            // Grab users parent role id
            Id usersParentRoleId = [
                SELECT UserRole.ParentRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ].UserRole.ParentRoleId;

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
            String sosl = '' +
                'FIND \'' + String.escapeSingleQuotes(searchString.trim()) + '*\' ' +
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
        Id asUberRoleId = [
            SELECT Id
            FROM UserRole
            WHERE Name = 'AS Admission Services'
        ].Id;

        asRoleIds.add(asUberRoleId);

        // Get Admission Services manager roles
        List<UserRole> asManagerRoleIds = [
            SELECT Id
            FROM UserRole
            WHERE ParentRoleId = :asUberRoleId
        ];

        for (UserRole manRoles : asManagerRoleIds) {
            asRoleIds.add(manRoles.Id);
        }

        // Get Adminssion Services subordinate roles
        List<UserRole> asSubRoleIds = [
            SELECT Id
            FROM UserRole
            WHERE ParentRoleId IN :asManagerRoleIds
        ];

        for (UserRole subRoles : asSubRoleIds) {
            asRoleIds.add(subRoles.Id);
        }

        return asRoleIds;
    }

    // Transfer the case and redirect
    public PageReference transferCase() {
        PageReference nextPage;
        boolean allSubsAndDescsValidated = true;
		Id securedCaseRTID = IDHelper.getRTID('Case', 'ASU_Secured_Service');
        Id securedCaseRTID15 = securedCaseRTID == null ? null : (Id) String.valueOf(securedCaseRTID).left(15);

        // Note: While we could put this into the loop
        // since the loop already has to check for toUser,
        // That would effectively put a SOQL query into a loop.
        // We can't fix this with a null check in the selectedCar
        // getter since selectedCar is used in more then 1 place
        // and the query logic is different in each place.
        if (!toUser) {
            selectedCAR = [
                SELECT Queue_Id__c, CC_Functional_Group__c, CC_Category__c,
                    CC_Sub_Category__c, Email_Address__c, Case_Feed_Email_Template_Id__c,
                    Campus__c, Case_Record_Type_Id__c, CC_Functional_Group__r.Name
                FROM Case_Assignment_Rule__c
                WHERE Id = :selectedId
            ];
        }

        // Verify that all cases have descriptions and subjects
        // Note: While it would be possible to combine these loops,
        // that would change the business logic in a manner that does
        // not adhere to functional requirements.
        for (Case c : this.cs) {
            if (String.isBlank(c.Description) || string.isBlank(c.Subject)) {
                allSubsAndDescsValidated = false;
            }
        }

        if (allSubsAndDescsValidated) {
            for (Case c : this.cs) {
                /*
                * Transfer to a department by setting the case information
                * according to the selected CAR
                */
                if (toUser) {
                    c.OwnerId = selectedId;
                } else {
                    c.OwnerId = selectedCAR.Queue_ID__c;
                    c.CC_Functional_Group__c = selectedCAR.CC_Functional_Group__c;
                    c.CC_Category__c = selectedCAR.CC_Category__c;
                    c.CC_Sub_Category__c = selectedCAR.CC_Sub_Category__c;
                    c.Case_Feed_Email__c = selectedCAR.Email_Address__c;
                    c.Case_Feed_Email_Template_Id__c = selectedCar.Case_Feed_Email_Template_Id__c;
                    c.Campus__c = selectedCAR.Campus__c;
                    c.RecordTypeId = selectedCAR.Case_Record_Type_Id__c;
                }
            }

            try {
                update this.cs;
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        } else {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'The Subject and ' +
                    'Description are required fields for case transfer. Please fill ' +
                    'out the missing fields before transferring the case.')
            );
        }

        // If the selected car is a secured record type, show success message
        if (securedCaseRTID15 != null && selectedCar.Case_Record_Type_Id__c == securedCaseRTID15) {
            page = 5;
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.CONFIRM,
                    'Successfully transfered case(s) to ' + SelectedCar.CC_Functional_Group__r.Name
                )
            );
            return null;
        } else if (this.cs.size() == 1) { // else, if this is only 1 case, return to the desired case
            nextPage = new PageReference('/' + this.cs[0].Id);
            nextPage.setRedirect(true);
            return nextPage;
        } else if (this.cs.size() > 1) { // else, if there is more than 1 case, return to the desired list view
            return new ApexPages.action('{!list}').invoke();
        }

        return null;
    }

    /**
     * Release case ownership back to the queue
     */
    public void releaseOwnership() {
        Boolean allSubsAndDescsValidated;
        Boolean allCasesSameGroup;
        String fGroup;

        if (this.cs != null) {
            if (this.cs.size() > 0) {
                allSubsAndDescsValidated = true;
                allCasesSameGroup = true;

                // Get Car info
                fGroup = this.cs[0].CC_functional_Group__c;

                // Verify that all cases have descriptions and subjects
                for (Case c : this.cs) {
                    if (String.isBlank(c.Description) || string.isBlank(c.Subject)) {
                        allSubsAndDescsValidated = false;
                    }

                    if (c.CC_functional_Group__c != fGroup) {
                        allCasesSameGroup = false;
                    }
                }

                if (allSubsAndDescsValidated && allCasesSameGroup) {
                    selectedCar = [SELECT Queue_ID__c
                        FROM Case_Assignment_Rule__c
                        WHERE CC_Functional_Group__c = :fGroup
                        ORDER BY Priority__c ASC
                        LIMIT 1][0];

                    for (Case c : this.cs) {
                        c.ownerId = selectedCar.Queue_ID__c;
                    }

                    update cs;
                } else {
                    if (!allSubsAndDescsValidated) {
                        ApexPages.addmessage(
                            new ApexPages.message(ApexPages.severity.ERROR, 'The Subject and ' +
                                'Description are required fields for case transfer. Please fill ' +
                                'out the missing fields before transferring the case.')
                        );
                    }

                    if (!allCasesSameGroup) {
                        ApexPages.addmessage(
                            new ApexPages.message(ApexPages.severity.ERROR, 'All of the selected cases' +
                            ' must be assigned to the same functional group.')
                        );
                    }
                }
            }
        }

        page = 5;
    }

    /**
     * Navigate to the previous page
     */
    public pageReference goBack() {
        pageReference lastPage;

        if (page == 1) { // Go back to case or list view
            if (this.cs.size() == 1) {
                lastPage = new PageReference('/' + string.ValueOf(this.cs[0].Id));
                lastPage.setRedirect(true);
            } else if (this.cs.size() > 1) {
                lastPage = new ApexPages.action('{!list}').invoke();
            }
        } else if (page == 2 || page == 3) {
            page = 1;
        } else if (page == 4) {
            if (toUser) {
                page = 2;
            } else {
                page = 3;
            }
        } else if (page == 5) {
            page = 4;
        }

        return lastPage;
    }

    /**
     * Fix the parameters provided by the success portal
     */
    public string fixParameter(string param) {
        if (param != null) {
            param = param.trim();
            param = param.replaceAll('(\\s+)', '');
	        param = param.replace('(','');
	        param = param.replace(')','');
        }

        return param;
    }
}
