public class CaseListTransferController {
    private final List<Case> cs;
    private Boolean isUserPageLoaded;
    private Boolean isCARPageLoaded;
    private List<User> asUsersToAdd;
    private Set<Id> asRoleIds;
    private Set<Id> uberRoleIds;

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
    public String searchString { get; set; }
    public String source { get; set; }

    public CaseListTransferController(ApexPages.StandardController stdController) {
        page = 1;
        isUserPageLoaded = false;
        isCARPageLoaded = false;
        userList = new List<User>();
        serviceCARS = new Map<String, List<Case_Assignment_Rule__c>>();
        collegeCARS = new Map<String, List<Case_Assignment_Rule__c>>();

        this.cs = [
            SELECT
                Subject,
                Description,
                CC_Sub_Category__c,
                CC_Category__c,
                CC_Functional_Group__c,
                CC_Functional_Group__r.Is_Functional_Group_Private__c
            FROM Case
            WHERE Id = :((Case) stdController.getRecord()).Id
        ];

        for (Case c : this.cs) {
            if (String.isBlank(c.Subject) || String.isBlank(c.Description)) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'The Subject and Description ' +
                        'are required fields for case transfer. Please fill out the missing fields ' +
                        'before transferring the case(s).'
                    )
                );
                break;
            }
        }
    }

    public CaseListTransferController(ApexPages.StandardSetController stdController) {
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
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Id: ' + s));
                }
            }
        } else {
            for (SObject so : stdController.getSelected()) {
                CaseIds.add(so.Id);
            }
        }

        this.cs = [
            SELECT
                Subject,
                Description,
                CC_Sub_Category__c,
                CC_Category__c,
                CC_Functional_Group__c,
                CC_Functional_Group__r.Is_Functional_Group_Private__c
            FROM Case
            WHERE Id IN :CaseIds
        ];

        for (Case c : this.cs) {
            if (String.isBlank(c.Subject) || String.isBlank(c.Description)) {
                ApexPages.addmessage(
                    new ApexPages.message(
                        ApexPages.severity.ERROR,
                        'The Subject and Description ' +
                        'are required fields for case transfer. Please fill out the missing fields ' +
                        'before transferring the case(s).'
                    )
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
        PageReference nextPage;
        boolean allSubsAndDescsValidated = true;
        boolean transferToPrivate = false;

        // Verify that all cases have descriptions and subjects
        for (Case c : this.cs) {
            if (String.isBlank(c.Description) || string.isBlank(c.Subject)) {
                allSubsAndDescsValidated = false;
            }
        }

        if (allSubsAndDescsValidated) {
            Case_Assignment_Rule__c selectedCar;
            if (!toUser) {
                selectedCar = CARService.getCARWithSharingGroup(selectedId);
                transferToPrivate = selectedCar.CC_Functional_Group__r.Is_Functional_Group_Private__c;
            }

            for (Case c : this.cs) {
                /*
                 * Transfer to a department by setting the case information
                 * according to the selected CAR
                 */
                if (toUser) {
                    c.OwnerId = selectedId;
                } else {
                    c.OwnerId = selectedCar.Queue_ID__c;
                    c.CC_Functional_Group__c = selectedCar.CC_Functional_Group__c;
                    c.CC_Category__c = selectedCar.CC_Category__c;
                    c.CC_Sub_Category__c = selectedCar.CC_Sub_Category__c;
                    //Nulls them out to prevent erros while transfering
                    c.Functional_Group__c = null;
                    c.Category__c = null;
                    c.Sub_Category__c = null;
                    c.Case_Feed_Email__c = selectedCar.Email_Address__c;
                    c.Case_Feed_Email_Template_Id__c = selectedCar.Case_Feed_Email_Template_Id__c;
                    c.Campus__c = selectedCar.Campus__c;
                    c.RecordTypeId = selectedCar.Case_Record_Type_Id__c;
                }
            }
            try {
                update this.cs;
            } catch (Exception e) {
                ApexPages.addMessages(e);

                return null;
            }
        } else {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'The Subject and ' +
                    'Description are required fields for case transfer. Please fill ' +
                    'out the missing fields before transferring the case.'
                )
            );
            return null;
        }

        if (this.cs.size() == 1) {
            nextPage = new PageReference('/' + cs[0].Id);
            nextPage.setRedirect(true);
        } else {
            nextPage = new ApexPages.action('{!list}').invoke();
        }

        if (transferToPrivate) {
            page = 5;
            return ApexPages.currentPage();
        }
        return nextPage;
    }

    /**
     * Release case ownership back to the queue
     */
    public pageReference releaseOwnership() {
        PageReference nextPage;
        Boolean allSubsAndDescsValidated;
        Boolean allCasesSameGroup;
        String fGroup;
        List<Case_Assignment_Rule__c> selectedCar;

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

                    if (c.CC_Functional_Group__c != fGroup) {
                        allCasesSameGroup = false;
                    }
                }

                if (allSubsAndDescsValidated && allCasesSameGroup) {
                    selectedCar = new List<Case_Assignment_Rule__c>(
                        [
                            SELECT Queue_ID__c
                            FROM Case_Assignment_Rule__c
                            WHERE CC_Functional_Group__c = :fGroup
                            ORDER BY Priority__c ASC
                            LIMIT 1
                        ]
                    );

                    if (selectedCar.size() == 1) {
                        for (Case c : this.cs) {
                            c.ownerId = selectedCar[0].Queue_ID__c;
                        }

                        update cs;
                    } else {
                        ApexPages.addmessage(
                            new ApexPages.message(
                                ApexPages.severity.ERROR,
                                'Could not locate assignment rule.' +
                                ' Please ensure that the functional group, category and sub-category fields are filled out' +
                                ' correctly for all cases.'
                            )
                        );

                        return null;
                    }
                } else {
                    if (!allSubsAndDescsValidated) {
                        ApexPages.addmessage(
                            new ApexPages.message(
                                ApexPages.severity.ERROR,
                                'The Subject and ' +
                                'Description are required fields for case transfer. Please fill ' +
                                'out the missing fields before transferring the case.'
                            )
                        );
                    }

                    if (!allCasesSameGroup) {
                        ApexPages.addmessage(
                            new ApexPages.message(
                                ApexPages.severity.ERROR,
                                'All of the selected cases' + ' must be assigned to the same functional group.'
                            )
                        );
                    }
                    return null;
                }

                if (this.cs.size() == 1) {
                    nextPage = new PageReference('/' + string.ValueOf(this.cs[0].Id));
                } else {
                    return new ApexPages.action('{!list}').invoke();
                }

                return nextPage;
            }
        }

        return null;
    }

    /**
     * Navigate to the previous page
     */
    public pageReference goBack() {
        pageReference lastPage;

        if (page == 1 || page == 5) {
            // Go back to case or list view
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
            param = param.replace('(', '');
            param = param.replace(')', '');
        }

        return param;
    }
}
