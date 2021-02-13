public class showMyStudentsController extends ListViewController {
    private boolean debug = false;
    public Id proactiveCaseRTID { get; set; }
    private String oldQuery { get; set; } // Used to determine if the query changes
    private final Integer cookieExpiration = 22592000; // 30 days in seconds (30 Days * 24 hours * 60 minutes * 60 seconds)
    public Id portalEmailRTID { get; set; }
    private boolean differentField;
    public Boolean emailPreviewMode { get; set; } // Used to determine which set of buttons to show in the email modal
    public List<Database.SaveResult> emailInsertResults { get; set; } // Used to display the results of the email send to the user
    public String studentGroup { get; set; }
    public string searchString { get; set; }
    public String campusFilter { get; set; }
    public String majorFilter { get; set; }
    public Date persistenceStartDate { get; set; }
    public Date persistenceEndDate { get; set; }
    public Map<Id, caseWrapper> caseCountMap { get; set; }
    public List<studentWrapper> studentList { get; set; }

    public String outlookScoreFilter {
        get {
            if (outlookScoreFilter == null) {
                outlookScoreFilter = '--';
            }
            return outlookScoreFilter;
        }
        set;
    }

    public List<SelectOption> outlookScoreOptions {
        get {
            if (outlookScoreOptions == null) {
                outlookScoreOptions = new List<SelectOption>();

                outlookScoreOptions.add(new SelectOption('--', '--'));
                outlookScoreOptions.add(new SelectOption('1', 'Very Low'));
                outlookScoreOptions.add(new SelectOption('2', 'Low'));
                outlookScoreOptions.add(new SelectOption('3', 'Moderate'));
                outlookScoreOptions.add(new SelectOption('4', 'High'));
                outlookScoreOptions.add(new SelectOption('5', 'Very High'));
            }
            return outlookScoreOptions;
        }
        set;
    }

    public String outlookChangeFilter {
        get {
            if (outlookChangeFilter == null) {
                outlookChangeFilter = '--';
            }
            return outlookChangeFilter;
        }
        set;
    }

    public List<SelectOption> outlookChangeOptions {
        get {
            if (outlookChangeOptions == null) {
                outlookChangeOptions = new List<SelectOption>();

                outlookChangeOptions.add(new SelectOption('--', '--'));
                outlookChangeOptions.add(new SelectOption('1', 'Up'));
                outlookChangeOptions.add(new SelectOption('-1', 'Down'));
                outlookChangeOptions.add(new SelectOption('0', 'No Change'));
            }
            return outlookChangeOptions;
        }
        set;
    }

    /*
     * Updats the setCon query with the ORDER BY clause sortField and sortDir
     */
    public void updateQuery() {
        List<String> vars = new List<String>();
        try {
            String tmpQuery = query;
            Integer loc = tmpQuery.indexOf('ORDER');
            tmpQuery = tmpQuery.substring(0, loc);
            setCon = new ApexPages.StandardSetController(
                DataBase.getQueryLocator(tmpQuery += ' ORDER BY ' + sortField + ' ' + sortDir)
            );
        } catch (Exception e) {
            vars.add(ErrorLogger.convertStringToJSON('query', query));
            vars.add(ErrorLogger.convertStringToJSON('sortField', sortField));
            vars.add(ErrorLogger.convertStringToJSON('sortDir', sortDir));
            ErrorLogger.log(e, vars, debug);
        }
    }

    /*
     * Get the list of students selected by the end user.
     */
    public List<Success_Student__c> selectedStudents {
        get {
            selectedStudents = new List<Success_Student__c>();

            for (studentWrapper sw : studentList) {
                if (sw.selected) {
                    selectedStudents.add(sw.obj);
                }
            }

            return selectedStudents;
        }
        set {
            selectedStudents = value;

            if (selectedStudents == null) {
                for (studentWrapper sw : studentList) {
                    sw.selected = false;
                }
            }
        }
    }

    /*
     * Portal Email object to store user input for mass emails
     */
    public Portal_Email__c tempEmail {
        get {
            if (tempEmail == null) {
                tempEmail = new Portal_Email__c(
                    RecordTypeId = portalEmailRTID,
                    Subject__c = 'A Message from your College and Department'
                );
            }

            return tempEmail;
        }
        set;
    }

    /*
     * Create portal email records for sending emails through marketing cloud
     */
    public void massEmail() {
        List<String> vars = new List<String>();
        List<Portal_Email__c> emails = new List<Portal_Email__c>();
        try {
            for (Success_Student__c ss : selectedStudents) {
                // Most of the object is formula fields
                emails.add(
                    new Portal_Email__c(
                        Success_Student__c = ss.Id,
                        Contact__c = ss.Student__c,
                        Additional_Message_Text__c = tempEmail.Additional_Message_Text__c,
                        Subject__c = tempEmail.Subject__c,
                        RecordTypeId = portalEmailRTID,
                        Email_Template_Name__c = tempEmail.Email_Template_Name__c
                    )
                );
            }

            if (emails.size() > 0) {
                emailInsertResults = dataBase.insert(emails);
            }

            // Reset the tempEmail
            tempEmail = null;
            emailPreviewMode = false;
        } catch (Exception e) {
            vars.add(string.valueOf(emails));
            ErrorLogger.log(e, vars, debug);
        }
    }

    public override void resetRecordList() {
        Success_Student__c tempStudent;

        studentList = new List<studentWrapper>();
        for (SObject so : setCon.getRecords()) {
            tempStudent = (Success_Student__c) so;
            if (tempStudent.Student__c != null) {
                studentList.add(new studentWrapper(tempStudent));
            }
        }

        resetCaseCounts();
    }

    /*
     * Resets the caseCounts map
     */
    public void resetCaseCounts() {
        caseCountMap = new Map<Id, caseWrapper>();
        Set<Id> contactIds = new Set<Id>();

        if (studentList != null) {
            for (studentWrapper sw : studentList) {
                contactIds.add(sw.obj.Student__c);
            }

            for (Contact c : [
                SELECT id, (SELECT RecordTypeId FROM Cases WHERE isClosed = FALSE)
                FROM Contact
                WHERE Id IN :contactIds
            ]) {
                caseCountMap.put(c.id, new caseWrapper());
                for (Case cc : c.cases) {
                    if (cc.recordTypeId == proactiveCaseRTID) {
                        caseCountMap.get(c.Id).proactiveCount++;
                    } else {
                        caseCountMap.get(c.Id).reactiveCount++;
                    }
                }
            }
        }
    }

    /*
     * Used to track the number of proactive and reactive cases at the contact level
     */
    public class caseWrapper {
        public Integer reactiveCount { get; set; }
        public Integer proactiveCount { get; set; }

        public caseWrapper() {
            reactiveCount = 0;
            proactiveCount = 0;
        }
    }

    /*
     * Class to facilitate selection of students for mass actions
     */
    public class studentWrapper {
        public Boolean selected { get; set; }
        public Success_Student__c obj { get; set; }
        public String changeDir { get; set; }
        public String imageName { get; set; }

        public studentWrapper(Success_Student__c student) {
            selected = false;
            obj = student;

            if (obj.Most_Recent_Outlook_Change_Direction__c == 1) {
                changeDir = 'Up';
            } else if (obj.Most_Recent_Outlook_Change_Direction__c == -1) {
                changeDir = 'Down';
            } else if (obj.Most_Recent_Outlook_Change_Direction__c == 0) {
                changeDir = ' ';
            } else {
                changeDir = ' ';
            }

            if (obj.Curr_Cont_Prediction_Level__c < 4) {
                imageName = 'icon-1.png';
            } else if (obj.Curr_Cont_Prediction_Level__c < 6) {
                imageName = 'icon-2.png';
            } else if (obj.Curr_Cont_Prediction_Level__c == 6) {
                imageName = 'icon-3.png';
            } else if (obj.Curr_Cont_Prediction_Level__c == 7) {
                imageName = 'icon-4.png';
            } else {
                imageName = 'icon-5.png';
            }
        }
    }

    /*
     * Class to hold all of the data needed for Civitas
     */
    public class CivitasWrapper {
        public Integer outlookScore { get; set; }
        //Direction is negative for down, 0 for same, and positive for up
        public Integer direction { get; set; }
        public Date changeDate { get; set; }

        public CivitasWrapper(Integer oScore, Integer dir, Date change) {
            outlookScore = oScore;
            direction = dir;
            changeDate = change;
        }
    }

    /*
     * Used to refresh the list to it's orignal state
     */
    public void resetSearch() {
        searchString = null;
        campusFilter = null;
        persistenceStartDate = null;
        persistenceEndDate = null;
        studentGroup = null;
        majorFilter = null;

        outlookChangeFilter = '--';
        outlookScoreFilter = '--';

        query = queryAttr;
    }

    /*
     * The page can't pass a null value to the setter so we have to use
     * an action call instead.
     */
    public void clearSaveResults() {
        emailInsertResults = null;
        // Had to move this to the end of the execution order (was in mass email)
        // because the page wasn't rerendering after mass email and the selections
        // were being re-submitted.
        selectedStudents = null;
    }

    public void insertFilterIntoQuery() {
        String modifiedQuery = queryAttr;
        String filter = createFilterForStudent();

        Integer loc = modifiedQuery.indexOf('WHERE');
        String leftSideOfQuery = modifiedQuery.substring(0, loc + 5);
        leftSideOfQuery = leftSideOfQuery.trim();
        String rightSideOfQuery = modifiedQuery.subString(loc + 6);
        rightSideOfQuery = rightSideOfQuery.trim();

        modifiedQuery = leftSideOfQuery + filter + rightSideOfQuery;
        query = modifiedQuery;
    }

    private String createFilterForStudent() {
        String filter = createFilterStringForStudentIdSearch();
        filter += createFilterStringForStudentGroup();
        filter += createFilterStringForOutlookChange();
        filter += createFilterStringForOutlookScore();
        filter += createFilterStringForOutlookDate();
        filter += createFilterStringForCollegeDegreeAndCampus();
        return filter;
    }

    private String createFilterStringForStudentGroup() {
        if (!String.isEmpty(studentGroup)) {
            return '(Student__c IN (SELECT SG_Contact__c FROM Student_Group__c ' +
                'WHERE SG_PeopleSoft_Code__c LIKE \'%' +
                studentGroup +
                '%\')) AND ';
        }
        return ' ';
    }

    private String createFilterStringForStudentIdSearch() {
        String searchCon = searchString.trim();
        String createdQuery = ' ';
        if (!String.isEmpty(searchCon)) {
            createdQuery =
                ' (' +
                'Student_Name__c LIKE \'%' +
                String.escapeSingleQuotes(searchCon) +
                '%\' ' +
                'OR EMPLID__c LIKE \'%' +
                String.escapeSingleQuotes(searchCon) +
                '%\'' +
                'OR ASURiteID__c LIKE \'%' +
                String.escapeSingleQuotes(searchCon) +
                '%\'' +
                ') AND ';
        }
        return createdQuery;
    }

    private String createFilterStringForOutlookChange() {
        if (outlookChangeFilter != '--') {
            return ' Student__r.Most_Recent_Outlook_Change_Direction__c  = ' + outlookChangeFilter + ' AND ';
        }
        return ' ';
    }

    private String createFilterStringForOutlookScore() {
        String outlookScoreQueryFilter;
        switch on outlookScoreFilter {
            when '1' {
                outlookScoreQueryFilter = ' Student__r.Curr_Cont_Prediction_Level__c < 4 AND ';
            }
            when '2' {
                outlookScoreQueryFilter = ' Student__r.Curr_Cont_Prediction_Level__c >= 4 AND Student__r.Curr_Cont_Prediction_Level__c < 6 AND ';
            }
            when '3' {
                outlookScoreQueryFilter = ' Student__r.Curr_Cont_Prediction_Level__c = 6 AND ';
            }
            when '4' {
                outlookScoreQueryFilter = ' Student__r.Curr_Cont_Prediction_Level__c = 7 AND ';
            }
            when '5' {
                outlookScoreQueryFilter = ' Student__r.Curr_Cont_Prediction_Level__c > 7 AND ';
            }
            when '--' {
                outlookScoreQueryFilter = '';
            }
        }
        return outlookScoreQueryFilter;
    }

    private String createFilterStringForOutlookDate() {
        String createdQuery = ' ';
        if (persistenceStartDate != null) {
            String persistenceSearchStartDate = DateTime.newInstance(persistenceStartDate, Time.newInstance(0, 0, 0, 0))
                .format('yyyy-MM-dd');
            createdQuery += ' Student__r.Change_Date__c >= ' + persistenceSearchStartDate + ' AND ';
        }
        if (persistenceEndDate != null) {
            String persistenceSearchEndDate = DateTime.newInstance(persistenceEndDate, Time.newInstance(0, 0, 0, 0))
                .format('yyyy-MM-dd');
            createdQuery += ' Student__r.Change_Date__c <= ' + persistenceSearchEndDate + ' AND ';
        }
        return createdQuery;
    }

    private String createFilterStringForCollegeDegreeAndCampus() {
        if (!String.isEmpty(campusFilter) || !String.isEmpty(majorFilter)) {
            String collegeDegreeAndCampusFilter =
                ' (Student__c IN (SELECT Contact__c FROM Student_Program_Plan__c ' +
                'WHERE Status__c = \'Active in Program\' ';

            if (!String.isEmpty(campusFilter) && campusFilter != '--') {
                collegeDegreeAndCampusFilter += ' AND Campus__c = \'' + campusFilter + '\' ';
            }
            if (!String.isEmpty(majorFilter)) {
                collegeDegreeAndCampusFilter +=
                    ' AND (Plan_Description__c LIKE \'%' +
                    majorFilter +
                    '%\' ' +
                    'OR Plan_Code__c LIKE \'%' +
                    majorFilter +
                    '%\' )';
            }
            collegeDegreeAndCampusFilter += ')) AND ';
            return collegeDegreeAndCampusFilter;
        }
        return ' ';
    }

    public List<SelectOption> campusFilterOptions {
        get {
            if (campusFilterOptions == null || campusFilterOptions.isEmpty()) {
                campusFilterOptions = new List<SelectOption>();
                campusFilterOptions.add(new SelectOption('--', '--'));

                List<Location__c> campusLocationOptions = [
                    SELECT Name
                    FROM Location__c
                    WHERE Location_Status__c = TRUE
                ];

                for (Location__c campusOption : campusLocationOptions) {
                    campusFilterOptions.add(new SelectOption(campusOption.Name, campusOption.Id));
                }
                campusFilterOptions.sort();
            }
            return campusFilterOptions;
        }
        set;
    }
}
