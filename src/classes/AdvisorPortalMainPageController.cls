public class AdvisorPortalMainPageController {
    public AdvisorPortalMainPageController() {}
    
    /*
     * The ID privded by the view as component
     * 
     * <p>
     * If the ID is null (Page load) use the current Users Id.
     * </p>
     */
    public Id ownerId {
        get {
            if (ownerId == null) {
                ownerId = UserInfo.getUserId();
            }
            
            return ownerId;
        }
        
        set;
    }
    
    /*
     * A list of selectOptions that the currently logged in user
     * has the permission to view as.
     * 
     * <p>
     * Contains the Id of the owner of the cases mapped to a display name (user or pod)
     * </p>
     */
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
                    
                	for (Id i : myCommittees.keySet()) {
                        viewAsOptions.add(new selectOption(i, myCommittees.get(i)));
                    }
            	}
                
				// Insert The committees for which I am a manager
                if (mySubordinateCommittees.size() > 0) {
                    viewAsOptions.add(new selectOption('', '', true));
                    viewAsOptions.add(new selectOption('', '--College Committees--', true));
                    
                    for (Id i : mySubordinateCommittees.keySet()) {
                        viewAsOptions.add(new selectOption(i, mySubordinateCommittees.get(i)));
                    }
                }
                
				// Insert all of the users for all of the comittees for which I am a manager
                if (mySubordinates.size() > 0) {
                    viewAsOptions.add(new selectOption('', '', true));
                    viewAsOptions.add(new selectOption('', '--College Advisors--', true));
                    
                    for (Id i : mySubordinates.keySet()) {
                        viewAsOptions.add(new selectOption(i, mySubordinates.get(i)));
                    }
                }
            }
            
            return viewAsOptions;
        }
        
        set;
    }
    
    /*
     * List of My Committees
     */
    public Map<Id, String> myCommittees {
        get {
            String committeeDisplayName; // The display name for the view as and transfer lists
            
            if (myCommittees == null) {
                Set<Id> myPodIds = new Set<Id>();
            	myCommittees = new Map<Id, String>();
                
                system.debug('myResources: ' + string.valueOf(myResources));
                
                for (Success_Resource__c sr : myResources) {
                    myPodIds.add(sr.Success_Pod__c);
                }
                
                for (Success_Pod__c sp : [SELECT Name, OwnerId, Committee__c
                    FROM Success_Pod__c
                    WHERE Id IN :myPodIds
                    ORDER BY Name ASC]) {
                    committeeDisplayName = sp.Name;
                    
                    if (sp.Committee__c != null && sp.Committee__c != '') {
                        committeeDisplayName = committeeDisplayName + ' - ' + sp.Committee__c;
                    }
                        
                    myCommittees.put(sp.OwnerId, committeeDisplayName);
                }
            }
            
            return myCommittees;
        }
        
        set;
    }
    
    /*
     * List of the committees for which I am a manager/admin
     */
    private Map<Id, String> mySubordinateCommittees {
        get {
            String committeeDisplayName;
            
            if (mySubordinateCommittees == null) {
                mySubordinateCommittees = new Map<Id, String>();
                
                for (Success_Pod__c sp : mySubordinatePods) {
                    committeeDisplayName = sp.Name;
                    
                    if (sp.Committee__c != '' && sp.Committee__c != null) {
                    	committeeDisplayName = committeeDisplayName + ' - ' + sp.Committee__c;
                    }
                    
                    mySubordinateCommittees.put(sp.OwnerId, committeeDisplayName);
                }
            }
            
            return mySubordinateCommittees;
        }
        
        set;
    }
    
    /*
     * List of my subordinate pods. To be converted into comittees and resources.
     */
    private List<Success_Pod__c> mySubordinatePods {
        get {
            if (mySubordinatePods == null) {
                mySubordinatePods = new List<Success_Pod__c>();
                
                if (myAdminProgramCodes.size() > 0) {
                    String query = ''; // The completed query
                    String queryFront = 'SELECT OwnerId, Name, Committee__c ' +
                        'FROM Success_Pod__c ' +
                        'WHERE Program__c INCLUDES ('; // The beginning of the query
                    String queryBack = ') ORDER BY Name ASC'; // The end of the query
                    
                    query = queryFront;
                    
                    for (String s : myAdminProgramCodes) {
                        query += '\'' + s + '\',';
                    }
                    
                    query = query.left(query.length()-1);
                    
                    query += queryBack;
                    
                    for (Success_Pod__c sp : database.query(query)) {
                        mySubordinatePods.add(sp);
                    }
                }
            }
            
            return mySubordinatePods;
        }
        
        set;
    }
    
    /*
     * List of my subordinates
     */
    private Map<Id, String> mySubordinates {
        get {
            String subordinateDisplayName;
            
            if (mySubordinates == null) {
                Set<Id> podIds = new Set<Id>();
                mySubordinates = new Map<Id, String>();
                
                for (Success_Pod__c sp : mySubordinatePods) {
                    podIds.add(sp.Id);
                }
                
                for (Success_Resource__c sr : [SELECT Resource__c, Resource_Name__c, Resource__r.Alias
                    FROM Success_Resource__c
                    WHERE Success_Pod__c IN :podIds
                    ORDER BY Resource_Name__c ASC]) {
                    subordinateDisplayName = sr.Resource_Name__c;
                        
                    if (sr.Resource__r.Alias != null && sr.Resource__r.Alias != '') {
                        subordinateDisplayName = subordinateDisplayName + ' - ' + sr.Resource__r.Alias;
                    }
                    mySubordinates.put(sr.Resource__c, subordinateDisplayName);
                }
            }
            
            return mySubordinates;
        }
        
        set;
    }
    
    /*
     * List of my resources
     */
    private List<Success_Resource__c> myResources {
        get {
            if (myResources == null) {
                myResources = [SELECT Success_Pod__c, Success_Pod__r.OwnerId, Program_Code__c, Role__c 
                	FROM Success_Resource__c
                	WHERE Resource__c = :UserInfo.getUserId()
                	AND IsActive__c = true
                	AND RecordTypeId = :AdvisorResourceRTID];
            }
            
            return myResources;
        }
        
        set;
    }
    
    /*
     * Generates a list of all program codes that the user is an admin/manager for
     */
    private List<String> myAdminProgramCodes {
        get {
            if (myAdminProgramCodes == null) {
                string tempCode; // temporarily stores program code field for splitting
                
                myAdminProgramCodes = new List<String>();
                
                for (Success_Resource__c sr : myResources) {
                    if (sr.Role__c == 'Admin' || sr.Role__c == 'Manager') {
                        tempCode = sr.Program_Code__c;
                        
                        for (String s : tempCode.split(';')) {
                            myAdminProgramCodes.add(s);
                        }
                    }
                }
            }
            
            return myAdminProgramCodes;
        }
        
        set;
    }
    
    private Id AdvisorResourceRTID {
        get {
            if (AdvisorResourceRTID == null) {
                AdvisorResourceRTID = [SELECT Id
                    FROM RecordType
                    WHERE SObjectType = 'Success_Resource__c'
                    AND Name = 'Advisor' LIMIT 1].Id;
            }
            
            return AdvisorResourceRTID;
        }
        
        set;
    }
    
    public Id AdvisorProactiveCaseRTID {
        get {
            if (AdvisorProactiveCaseRTID == null) {
                AdvisorProactiveCaseRTID = RTIDHelper.getRTID('Case', 'ASU Advisor Outreach');
            }
            
            return AdvisorProactiveCaseRTID;
        }
        
        set;
    }
    
    public Id advisorEmailRTID {
        get {
            if (advisorEmailRTID == null) {
                advisorEmailRTID = RTIDHelper.getRTID('Portal_Email__c', 'Advisor');
            }
            
            return advisorEmailRTID;
        }
        
        set;
    }
    
    public Id AdvisorReactiveCaseRTID {
        get {
            if (AdvisorReactiveCaseRTID == null) {
                AdvisorReactiveCaseRTID = RTIDHelper.getRTID('Case', 'ASU Service');
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
            if (ownerId != null) {
                myProactiveQuery = 'SELECT CaseNumber, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.Email, Subject, Description, Status, FollowUp_Date__c ' +
                    'FROM Case ' +
                    'WHERE OwnerId = \'' + ownerId + '\' ' +
                    'AND recordTypeId = \'' + AdvisorProactiveCaseRTID + '\' ' +
                    'AND isClosed = false';
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
            if (ownerId != null) {
                myWatchlistQuery = 'SELECT CaseNumber, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.Email, Subject, Description, Status, FollowUp_Date__c ' +
                    'FROM Case ' +
                    'WHERE OwnerId = \'' + ownerId + '\' ' +
                    'AND recordTypeId = \'' + AdvisorProactiveCaseRTID + '\' ' +
                    'AND Category__c = \'Watchlist\'' +
                    'AND isClosed = false';
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
                myStudentsQuery = 'SELECT Student_Name__c, EMPLID__c, Student__c, Student__r.FirstName, Student__r.LastName ' +
                    'FROM Success_Student__c ' +
                    'WHERE Success_Pod__r.OwnerId = \'' + ownerId + '\' ' +
                        'AND Is_Active__c = true';
            }
            
            return myStudentsQuery;
        }
        
        set;
    }
    
    /*
     * The query used to generate the summary list for the current resource
     */
    public string mySummaryListQuery {
        get {
            if (ownerId != null) {
                mySummaryListQuery = 'SELECT count(Id) total, Subject, Followup_Date__c ' +
                    'FROM Case ' +
                    'WHERE OwnerId = \'' + ownerId + '\' ' +
                    'AND Category__c != \'Watchlist\'' +
                    'AND recordTypeId = \'' + AdvisorProactiveCaseRTID + '\' ' +
                    'AND IsClosed = false ' +
                    'GROUP BY Subject, Followup_Date__c ' +
                    'ORDER BY Followup_Date__c ASC NULLS LAST';
            }
            
            return mySummaryListQuery;
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
}