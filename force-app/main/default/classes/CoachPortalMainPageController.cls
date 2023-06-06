/*****************************************
 * File: CoachPortalMainPageController
 * Author: meruff, adapted from AdvisingPortalMainPageController.cls
 * Description: Controller for CoachPortalMainPage
 ******************************************/
public with sharing class CoachPortalMainPageController {
    public CoachPortalMainPageController() {
    }

    /*
     * The ID provided by the view as component to be passed to the view as Body
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
     * The Success_Resource__c for the current user.
     */
    public Success_Resource__c myResource {
        get {
            if (myResource == null) {
                myResource = [
                    SELECT Id, Role__c, Success_Pod__c, RecordTypeId
                    FROM Success_Resource__c
                    WHERE Resource__c = :ownerId
                    LIMIT 1
                ];
            }
            return myResource;
        }
        set;
    }

    /*
     * The current user's Success_Resource__c Role
     */
    public String mySuccessRole {
        get {
            if (mySuccessRole == null) {
                mySuccessRole = myResource.Role__c;
            }
            return mySuccessRole;
        }
        set;
    }

    /*
     * The current user's Success_Resource__c Success_Pod__c Id
     */
    public Id mySuccessPod {
        get {
            if (mySuccessPod == null) {
                mySuccessPod = myResource.Success_Pod__c;
            }
            return mySuccessPod;
        }
        set;
    }

    private Id mySuccessRTID {
        get {
            if (mySuccessRTID == null) {
                mySuccessRTID = myResource.RecordTypeId;
            }
            return mySuccessRTID;
        }
        set;
    }

    private String mySuccessRT {
        get {
            if (mySuccessRT == null) {
                mySuccessRT = [
                    SELECT Id, DeveloperName
                    FROM RecordType
                    WHERE Id = :mySuccessRTID
                    LIMIT 1
                ]
                .DeveloperName;
            }
            return mySuccessRT;
        }
        set;
    }

    public String allSuccessPodsQueryFilter {
        get {
            if (allSuccessPodsQueryFilter == null) {
                allSuccessPodsQueryFilter = '';
                for (
                    String successPod : System.Label.ASU_Coach_Outreach_Success_Pods.replaceAll('(\\s+)', '').split(',')
                ) {
                    allSuccessPodsQueryFilter += '\'' + successPod + '\',';
                }

                allSuccessPodsQueryFilter = allSuccessPodsQueryFilter.lastIndexOf(',') > 0
                    ? '(' + allSuccessPodsQueryFilter.substring(0, allSuccessPodsQueryFilter.lastIndexOf(',')) + ')'
                    : allSuccessPodsQueryFilter;
            }
            return allSuccessPodsQueryFilter;
        }
        set;
    }

    /*
     * A list of SelectOptions that the currently logged in user
     * has the permission to view as.
     *
     * <p>
     * Contains the Id of the owner of the cases mapped to a display name (user or pod)
     * </p>
     */
    public List<SelectOption> viewAsOptions {
        get {
            if (viewAsOptions == null) {
                viewAsOptions = new List<SelectOption>();

                // Insert myself
                viewAsOptions.add(new SelectOption(UserInfo.getUserId(), UserInfo.getName()));

                // Insert all of the users for all of the comittees for which I am a manager
                if (mySuccessRole == 'Lead' || mySuccessRole == 'Manager' || mySuccessRole == 'Admin') {
                    if (mySubordinates.size() > 0) {
                        viewAsOptions.add(new SelectOption('', '', true));
                        viewAsOptions.add(new SelectOption('', '--Pod Members--', true));

                        for (Id i : mySubordinates.keySet()) {
                            viewAsOptions.add(new SelectOption(i, mySubordinates.get(i)));
                        }
                    }
                }
            }

            return viewAsOptions;
        }
        set;
    }

    /*
     * Returns a List of SelectOptions for users in your pod
     */
    public List<SelectOption> mySubordinateOptions {
        get {
            if (mySubordinateOptions == null) {
                mySubordinateOptions = new List<SelectOption>();

                if (mySubordinates.size() > 0) {
                    mySubordinateOptions.add(new SelectOption('', '--Pod Members--', true));

                    for (Id i : mySubordinates.keySet()) {
                        mySubordinateOptions.add(new SelectOption(i, mySubordinates.get(i)));
                    }
                }
            }

            return mySubordinateOptions;
        }
        set;
    }

    /*
     * List of my subordinates
     */
    private Map<Id, String> mySubordinates {
        get {
            mySubordinates = new Map<Id, String>();

            for (Success_Resource__c sr : [
                SELECT Id, Name, Resource__r.Name, Resource_Name__c
                FROM Success_Resource__c
                WHERE
                    RecordTypeId = :mySuccessRTID
                    AND Success_POD__c = :mySuccessPod
                    AND Resource__c != :ownerId
                    AND isActive__c = TRUE
                ORDER BY Name ASC
            ]) {
                mySubordinates.put(sr.Resource__c, sr.Resource_Name__c);
            }

            return mySubordinates;
        }
        set;
    }

    public List<SelectOption> allCoachResourceOptions {
        get {
            if (allCoachResourceOptions == null) {
                allCoachResourceOptions = new List<SelectOption>();

                if (allCoachResources.size() > 0) {
                    allCoachResourceOptions.add(new SelectOption('', '--Active Coaches--', true));

                    for (Id i : allCoachResources.keySet()) {
                        allCoachResourceOptions.add(new SelectOption(i, allCoachResources.get(i)));
                    }
                }
            }

            return allCoachResourceOptions;
        }
        set;
    }

    // NEED TO FIX THE QUERY BELOW - TRIGGERING TOO MANY SOQL QUERIES ISSUE SOMEHOW
    private Map<Id, String> allCoachResources {
        get {
            allCoachResources = new Map<Id, String>();

            for (Success_Resource__c sr : [
                SELECT Id, Name, Resource__r.Name, Resource_Name__c
                FROM Success_Resource__c
                WHERE
                    (RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Coach')
                    OR RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Financial_Intake')
                    OR RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Reentry'))
                    AND Resource__c != :ownerId
                    AND isActive__c = TRUE
                ORDER BY Name DESC
                LIMIT 50
            ]) {
                allCoachResources.put(sr.Resource__c, sr.Resource_Name__c);
            }

            return allCoachResources;
        }
        set;
    }

    private Id coachStudentRTID {
        get {
            if (coachStudentRTID == null) {
                coachStudentRTID = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Coach');
            }
            return coachStudentRTID;
        }
        set;
    }

    private Id financialIntakeStudentRTID {
        get {
            if (financialIntakeStudentRTID == null) {
                financialIntakeStudentRTID = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Financial_Intake');
            }
            return financialIntakeStudentRTID;
        }
        set;
    }

    private Id reentryStudentRTID {
        get {
            if (reentryStudentRTID == null) {
                reentryStudentRTID = RecordIdHelper.getRecordTypeId('Success_Student__c', 'Reentry');
            }
            return reentryStudentRTID;
        }
        set;
    }

    /*
     * ASU Coach Outreach Case Record Type Id
     */
    public Id coachCaseRTID {
        get {
            if (coachCaseRTID == null) {
                coachCaseRTID = RecordIdHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach');
            }
            return coachCaseRTID;
        }
        set;
    }

    /*
     * Coach Email record Type Id
     */
    public Id coachEmailRTID {
        get {
            if (coachEmailRTID == null) {
                coachEmailRTID = RecordIdHelper.getRecordTypeId('Portal_Email__c', 'Coach');
            }
            return coachEmailRTID;
        }
        set;
    }

    public Id myStudentsRTID {
        get {
            if (myStudentsRTID == null) {
                switch on mySuccessRT {
                    when 'Financial_Intake' {
                        myStudentsRTID = financialIntakeStudentRTID;
                    }
                    when 'Reentry' {
                        myStudentsRTID = reentryStudentRTID;
                    }
                    when else {
                        myStudentsRTID = coachStudentRTID;
                    }
                }
            }
            return myStudentsRTID;
        }
        set;
    }

    /*
     * The query used to generate the summary list for the current resource
     */
    public String mySummaryListQuery {
        get {
            if (ownerId != null) {
                mySummaryListQuery =
                    '' +
                    'SELECT COUNT(Id) total, Subject ' +
                    'FROM Case ' +
                    'WHERE OwnerId = \'' +
                    ownerId +
                    '\' ' +
                    'AND RecordTypeId = \'' +
                    coachCaseRTID +
                    '\' ' +
                    'AND IsClosed = false ' +
                    'AND Category__c != \'Watchlist\' ' +
                    'GROUP BY Subject ' +
                    'ORDER BY Subject ASC NULLS LAST LIMIT 1000';
            }

            return mySummaryListQuery;
        }
        set;
    }

    /*
     * The query used to retrieve the students for the active resource
     */
    public String myStudentsQuery {
        get {
            if (ownerId != null) {
                myStudentsQuery =
                    '' +
                    'SELECT Student_Name__c, EMPLID__c, Student__c, Success_Resource__r.Resource__c, ' +
                    'ASURiteID__c,Student__r.FirstName, Student__r.LastName ' +
                    'FROM Success_Student__c ' +
                    'WHERE Success_Resource__r.Resource__c = \'' +
                    ownerId +
                    '\' ' +
                    'AND Is_Active__c = true ' +
                    'AND Coaching_Student__c = true ' +
                    'AND RecordTypeId = \'' +
                    myStudentsRTID +
                    '\' ' +
                    'ORDER BY Student_Name__c ASC LIMIT 5000';
            }

            return myStudentsQuery;
        }
        set;
    }

    /*
     * The query used to retrieve all proactive cases for the current resource.
     */
    public String myProactiveQuery {
        get {
            if (ownerId != null) {
                myProactiveQuery =
                    '' +
                    'SELECT CaseNumber, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.tz__Local_Time_Short__c, ' +
                    'Subject, Description, Status, FollowUp_Date__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, Prev_Cont_Prediction_Level__c, Change_Date__c, STRM__c, Session__c ' +
                    'FROM Case ' +
                    'WHERE OwnerId = \'' +
                    ownerId +
                    '\' ' +
                    'AND Category__c != \'Watchlist\' ' +
                    'AND RecordTypeId = \'' +
                    coachCaseRTID +
                    '\' ' +
                    'AND isClosed = false ORDER BY Contact.LastName ASC LIMIT 5000';
            }

            return myProactiveQuery;
        }
        set;
    }

    public String caseRecodingQuery {
        get {
            if (allSuccessPodsQueryFilter != null) {
                caseRecodingQuery =
                    '' +
                    'SELECT CaseNumber, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Owner.Name, Status, Subject ' +
                    'FROM Case ' +
                    'WHERE Owner.Name IN ' +
                    allSuccessPodsQueryFilter +
                    ' AND isClosed = false ORDER BY Contact.LastName ASC LIMIT 5000';
            }

            return caseRecodingQuery;
        }
        set;
    }

    /*
     * Whether or not the currently logged in user has the permission to change
     * who they are viewing as.
     *
     * <p>
     * Seriously needs to be updated as this is a very rough method to force the value
     * to true.
     * </p>
     */
    public Boolean hasViewAs {
        get {
            // Has view as if the list of select options is greater than 1 (should always have
            // the current user).

            return viewAsOptions.size() > 1 ? true : false;
        }
        set;
    }
}