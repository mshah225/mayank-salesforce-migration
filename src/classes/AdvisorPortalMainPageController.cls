public class AdvisorPortalMainPageController {
    public AdvisorPortalMainPageController() {
    }

    public Id ownerId {
        get {
            if (ownerId == null) {
                ownerId = UserInfo.getUserId();
            }

            return ownerId;
        }
        set;
    }

    public List<String> ownerIdList { get; set; }
    public String ownerIdString { get; set; }

    public PageReference parseOwnerIdString() {
        if (ownerIdString != null && ownerIdString != '') {
            ownerIdList = ownerIdString.split(',');
        } else {
            ownerIdList = null;
        }
        return null;
    }

    public List<selectOption> viewAsOptions {
        get {
            if (viewAsOptions == null) {
                viewAsOptions = new List<selectOption>();

                // Insert myself
                viewAsOptions.add(new selectOption(UserInfo.getUserId(), UserInfo.getName()));

                // Insert My Comittees
                if (myCommittees.size() > 0) {
                    viewAsOptions.add(new selectOption('', '', true));
                    viewAsOptions.add(new selectOption('', '--My Committees--', true));

                    List<selectOption> sortableCommittee = new List<selectOption>();
                    for (Id i : myCommittees.keySet()) {
                        sortableCommittee.add(new selectOption(i, myCommittees.get(i)));
                    }
                    sortableCommittee = sortSelectOptionList(sortableCommittee);
                    for (Integer i = 0; i < sortableCommittee.size(); i++) {
                        viewAsOptions.add(sortableCommittee[i]);
                    }
                }

                // Insert The committees for which I am a manager
                if (mySubordinateCommittees.size() > 0) {
                    viewAsOptions.add(new selectOption('', '', true));

                    if (myRole == 'Department Manager') {
                        viewAsOptions.add(new selectOption('', '--Department Committees--', true));
                    } else if (myRole == 'College Manager') {
                        viewAsOptions.add(new selectOption('', '--College Committees--', true));
                    }

                    List<selectOption> sortableCommittee = new List<selectOption>();
                    for (Id i : mySubordinateCommittees.keySet()) {
                        sortableCommittee.add(new selectOption(i, mySubordinateCommittees.get(i)));
                    }
                    sortableCommittee = sortSelectOptionList(sortableCommittee);
                    for (Integer i = 0; i < sortableCommittee.size(); i++) {
                        viewAsOptions.add(sortableCommittee[i]);
                    }
                }

                // Insert all of the users for all of the comittees for which I am a manager
                if (mySubordinates.size() > 0) {
                    viewAsOptions.add(new selectOption('', '', true));

                    if (myRole == 'Department Manager') {
                        viewAsOptions.add(new selectOption('', '--Department Advisors--', true));
                    } else if (myRole == 'College Manager') {
                        viewAsOptions.add(new selectOption('', '--College Advisors--', true));
                    }

                    List<selectOption> sortableAdvisor = new List<selectOption>();
                    for (Id i : mySubordinates.keySet()) {
                        sortableAdvisor.add(new selectOption(i, mySubordinates.get(i)));
                    }
                    sortableAdvisor = sortSelectOptionList(sortableAdvisor);
                    for (Integer i = 0; i < sortableAdvisor.size(); i++) {
                        viewAsOptions.add(sortableAdvisor[i]);
                    }
                }
            }

            return viewAsOptions;
        }
        set;
    }

    public Map<Id, String> myCommittees {
        get {
            String committeeDisplayName; // The display name for the view as and transfer lists

            if (myCommittees == null) {
                Set<Id> myPodIds = new Set<Id>();
                myCommittees = new Map<Id, String>();

                for (Success_Resource__c sr : myResources) {
                    if (sr.Role__c == 'User') {
                        for (Success_Resource_Pod_Association__c srpa : sr.Success_Resource_Pod_Associations__r) {
                            committeeDisplayName = srpa.Success_Pod__r.Name;

                            if (srpa.Success_Pod__r.Committee__c != null && srpa.Success_Pod__r.Committee__c != '') {
                                committeeDisplayName = committeeDisplayName + ' - ' + srpa.Success_Pod__r.Committee__c;
                            }

                            myCommittees.put(srpa.Success_Pod__r.OwnerId, committeeDisplayName);
                        }
                    }
                }
            }

            return myCommittees;
        }
        set;
    }

    public Map<Id, String> mySubordinateCommittees {
        get {
            String committeeDisplayName;

            if (mySubordinateCommittees == null) {
                mySubordinateCommittees = new Map<Id, String>();

                for (Success_Resource_Pod_Association__c srpa : mySubordinatePods.values()) {
                    committeeDisplayName = srpa.Success_Pod__r.Name;

                    if (srpa.Success_Pod__r.Committee__c != '' && srpa.Success_Pod__r.Committee__c != null) {
                        committeeDisplayName = committeeDisplayName + ' - ' + srpa.Success_Pod__r.Committee__c;
                    }

                    mySubordinateCommittees.put(srpa.Success_Pod__r.OwnerId, committeeDisplayName);
                }
            }

            return mySubordinateCommittees;
        }
        set;
    }

    public Map<Id, Success_Resource_Pod_Association__c> mySubordinatePods {
        get {
            if (mySubordinatePods == null) {
                mySubordinatePods = new Map<Id, Success_Resource_Pod_Association__c>();

                for (Success_Resource__c sr : myResources) {
                    if (sr.Role__c == 'College Manager' || sr.Role__c == 'Department Manager') {
                        for (Success_Resource_Pod_Association__c srpa : sr.Success_Resource_Pod_Associations__r) {
                            mySubordinatePods.put(srpa.Id, srpa);
                        }
                    }
                }
            }

            return mySubordinatePods;
        }
        set;
    }

    public Map<Id, String> mySubordinates {
        get {
            String subordinateDisplayName;

            if (mySubordinates == null) {
                Set<Id> podIds = new Set<Id>();
                mySubordinates = new Map<Id, String>();

                for (Success_Resource_Pod_Association__c srpa : mySubordinatePods.values()) {
                    podIds.add(srpa.Success_Pod__c);
                }

                for (Success_Resource_Pod_Association__c srpa : [
                    SELECT
                        Success_Resource__r.Resource__c,
                        Success_Resource__r.Resource__r.Name,
                        Success_Resource__r.Resource__r.Alias,
                        Success_Resource__r.IsActive__c
                    FROM Success_Resource_Pod_Association__c
                    WHERE Success_Resource__r.IsActive__c = TRUE AND Success_Pod__c IN :podIds
                    ORDER BY Success_Resource__r.Resource__r.Name ASC
                ]) {
                    subordinateDisplayName = srpa.Success_Resource__r.Resource__r.Name;

                    if (
                        srpa.Success_Resource__r.Resource__r.Alias != null &&
                        srpa.Success_Resource__r.Resource__r.Alias != ''
                    ) {
                        subordinateDisplayName =
                            subordinateDisplayName +
                            ' - ' +
                            srpa.Success_Resource__r.Resource__r.Alias;
                    }

                    mySubordinates.put(srpa.Success_Resource__r.Resource__c, subordinateDisplayName);
                }
            }

            return mySubordinates;
        }
        set;
    }

    public List<Success_Resource__c> myResources {
        get {
            if (myResources == null) {
                myResources = [
                    SELECT
                        Role__c,
                        (
                            SELECT
                                Success_Pod__c,
                                Success_Pod__r.OwnerId,
                                Success_Pod__r.Name,
                                Success_Pod__r.Committee__c
                            FROM Success_Resource_Pod_Associations__r
                            ORDER BY Success_Pod__r.Name
                        )
                    FROM Success_Resource__c
                    WHERE
                        Resource__c = :UserInfo.getUserId()
                        AND IsActive__c = TRUE
                        AND RecordTypeId = :AdvisorResourceRTID
                ];

                System.debug(myResources);
            }
            return myResources;
        }
        set;
    }

    public String myRole {
        get {
            if (myRole == null) {
                Map<String, Integer> roleMap = new Map<String, Integer>();
                roleMap.put('College Manager', 3);
                roleMap.put('Department Manager', 2);
                roleMap.put('User', 1);

                myRole = 'User';
                for (Success_Resource__c sr : myResources) {
                    if (roleMap.get(myRole) < roleMap.get(sr.Role__c)) {
                        myRole = sr.Role__c;
                    }
                }
            }

            return myRole;
        }
        set;
    }

    private Id AdvisorResourceRTID {
        get {
            if (AdvisorResourceRTID == null) {
                AdvisorResourceRTID = [
                    SELECT Id
                    FROM RecordType
                    WHERE SObjectType = 'Success_Resource__c' AND Name = 'Advisor'
                    LIMIT 1
                ]
                .Id;
            }

            return AdvisorResourceRTID;
        }
        set;
    }

    public Id AdvisorProactiveCaseRTID {
        get {
            if (AdvisorProactiveCaseRTID == null) {
                AdvisorProactiveCaseRTID = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');
            }

            return AdvisorProactiveCaseRTID;
        }
        set;
    }

    public Id advisorEmailRTID {
        get {
            if (advisorEmailRTID == null) {
                advisorEmailRTID = IDHelper.getRTID('Portal_Email__c', 'Advisor');
            }

            return advisorEmailRTID;
        }
        set;
    }

    public Id AdvisorReactiveCaseRTID {
        get {
            if (AdvisorReactiveCaseRTID == null) {
                AdvisorReactiveCaseRTID = IDHelper.getRTID('Case', 'ASU_Service');
            }

            return AdvisorReactiveCaseRTID;
        }
        set;
    }
    /*
     * The query used to retrieve all proactive cases for the current resource.
     */
    public String myProactiveQuery {
        get {
            String whereClause = '';
            if (ownerId != null) {
                myProactiveQuery =
                    'SELECT CaseNumber, CC_Category__r.Name, ContactId, CreatedDate, Owner.Name, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.Email, Subject, Description, Status, FollowUp_Date__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, Prev_Cont_Prediction_Level__c, Change_Date__c ' +
                    'FROM Case ';
                if (ownerIdList != null) {
                    whereClause = 'WHERE (OwnerId = \'' + ownerIdList[0] + '\' ';
                    for (Id ownerIdFromList : ownerIdList) {
                        whereClause = whereClause + 'OR OwnerId = \'' + ownerIdFromList + '\' ';
                    }
                } else {
                    whereClause = '(WHERE OwnerId = \'' + ownerId + '\' ';
                }
                myProactiveQuery =
                    myProactiveQuery +
                    whereClause +
                    ')AND recordTypeId = \'' +
                    AdvisorProactiveCaseRTID +
                    '\' ' +
                    'AND isClosed = false ORDER BY Contact.LastName ASC LIMIT 3000';
            }
            return myProactiveQuery;
        }
        set;
    }

    /*
     * The query used to retrieve the watchlistCases for the current resource
     */
    public String myWatchlistQuery {
        get {
            String whereClause = '';
            if (ownerId != null) {
                myWatchlistQuery =
                    'SELECT CaseNumber, CC_Category__r.Name, ContactId, CreatedDate, Owner.Name, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.Email, Subject, Description, Status, FollowUp_Date__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, Prev_Cont_Prediction_Level__c, Change_Date__c ' +
                    'FROM Case ' +
                    'WHERE (OwnerId = \'' +
                    ownerId +
                    '\' ';
                if (ownerIdList != null) {
                    for (Id ownerIdFromList : ownerIdList) {
                        whereClause = whereClause + 'OR OwnerId = \'' + ownerIdFromList + '\' ';
                    }
                }
                myWatchlistQuery =
                    myWatchlistQuery +
                    whereClause +
                    ')AND recordTypeId = \'' +
                    AdvisorProactiveCaseRTID +
                    '\' ' +
                    'AND CC_Category__c IN (SELECT Id FROM Case_Classification__c WHERE RecordType.Name = \'Category\' AND Active__c = true AND Name = \'WatchList\' AND Parent__r.Name = \'ASU Advisor Outreach\') ' +
                    'AND isClosed = false ORDER BY Contact.LastName ASC LIMIT 3000';
            }
            return myWatchlistQuery;
        }
        set;
    }

    /*
     * The query used to retrieve the students for the active resource
     */
    public String myStudentsQuery {
        get {
            if (ownerId != null) {
                String whereClause = '';
                myStudentsQuery =
                    'SELECT Student_Name__c, EMPLID__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, ' +
                    'Prev_Cont_Prediction_Level__c, Change_Date__c, ' +
                    'Student__c, Student__r.FirstName, Student__r.LastName ' +
                    'FROM Success_Student__c ' +
                    'WHERE (Success_Pod__r.OwnerId = \'' +
                    ownerId +
                    '\' ';
                if (ownerIdList != null) {
                    for (Id ownerIdFromList : ownerIdList) {
                        whereClause = whereClause + 'OR Success_Pod__r.OwnerId = \'' + ownerIdFromList + '\' ';
                    }
                }
                myStudentsQuery =
                    myStudentsQuery +
                    whereClause +
                    ')AND (Is_Active__c = true) ORDER BY Student_Name__c ASC LIMIT 3000';
            }

            return myStudentsQuery;
        }
        set;
    }

    /*
     * Whether or not the currently logged in user has the permission to change
     * who they are viewing as.
     */
    public boolean hasViewAs {
        get {
            // Has view as if the list of select options is greater than 1 (should always have
            // the current user).
            return viewAsOptions.size() > 1 ? true : false;
        }
        set;
    }

    /*
     * Whether or not the currently logged in user has the permission to mass
     * transfer cases
     */
    public boolean allowedToMassTransfer {
        get {
            if (allowedToMassTransfer == null) {
                List<Success_Resource__c> resourceForCurrentUser = [
                    SELECT Role__c
                    FROM Success_Resource__c
                    WHERE
                        Resource__c = :UserInfo.getUserId()
                        AND (Role__c = 'Department Manager'
                        OR Role__c = 'College Manager')
                        AND IsActive__c = TRUE
                ];

                allowedToMassTransfer = resourceForCurrentUser.size() > 0;
            }

            return allowedToMassTransfer;
        }
        set;
    }

    public List<SelectOption> sortSelectOptionList(List<SelectOption> source) {
        List<string> sortable = new List<string>();
        for (SelectOption so : source) {
            // replace blank with '_!' so we know the final split will have two components
            String stringSpliter =
                (string.isblank(so.getLabel()) ? '_!' : so.getLabel()) +
                '@!@' +
                (string.isblank(so.getValue()) ? '_!' : so.getValue());
            stringSpliter = stringSpliter.toUpperCase() + stringSpliter;
            sortable.Add(stringSpliter);
        }
        // sort the list
        sortable.sort();
        //Remove Capital Prefix
        for (Integer i = 0; i < sortable.size(); i++) {
            sortable[i] = sortable[i].substring(sortable[i].length() / 2);
        }
        List<SelectOption> targetList = new List<SelectOption>();
        // split the value/name components and re create the list
        for (string s : sortable) {
            targetList.Add(new SelectOption(s.split('@!@')[1].replace('_!', ''), s.split('@!@')[0].replace('_!', '')));
        }
        return targetList;
    }
}
