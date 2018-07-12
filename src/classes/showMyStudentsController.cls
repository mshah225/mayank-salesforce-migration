public class showMyStudentsController extends ListViewController {
    private boolean debug = false;
    public Id proactiveCaseRTID {get; set;}
    private String oldQuery {get; set;} // Used to determine if the query changes
    private final Integer cookieExpiration = 22592000; // 30 days in seconds (30 Days * 24 hours * 60 minutes * 60 seconds)
    public Id portalEmailRTID {get; set;}
    private boolean differentField;
    public Boolean emailPreviewMode {get; set;} // Used to determine which set of buttons to show in the email modal
    public List<Database.SaveResult> emailInsertResults {get; set;} // Used to display the results of the email send to the user
    public String collegeFilter {get; set;}
    public string searchString {get; set;}
    public Map<Id,caseWrapper> caseCountMap  {get; set;}
    public List<studentWrapper> studentList {get; set;}

    /*
     * Updats the setCon query with the ORDER BY clause sortField and sortDir
     */
    public void updateQuery() {
        List<String> vars = new List<String>();
        try{
            String tmpQuery = query;
            Integer loc = tmpQuery.indexOf('ORDER');
            tmpQuery = tmpQuery.substring(0, loc);
            setCon = new ApexPages.StandardSetController(DataBase.getQueryLocator(tmpQuery += ' ORDER BY ' + sortField + ' ' + sortDir));
        }
        catch(Exception e){
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
                emails.add(new Portal_Email__c(
                    Success_Student__c = ss.Id,
                    Contact__c = ss.Student__c,
                    Additional_Message_Text__c = tempEmail.Additional_Message_Text__c,
                    Subject__c = tempEmail.Subject__c,
                    RecordTypeId = portalEmailRTID,
                    Email_Template_Name__c = tempEmail.Email_Template_Name__c
                ));
            }

            if (emails.size() > 0) {
                emailInsertResults = dataBase.insert(emails);
            }

            // Reset the tempEmail
            tempEmail = null;
            emailPreviewMode = false;
        } catch (Exception e){
            vars.add(string.valueOf(emails));
            ErrorLogger.log(e, vars, debug);
        }
    }


    public override void resetRecordList() {
        Success_Student__c tempStudent;

        studentList = new List<studentWrapper>();
        for (SObject so : setCon.getRecords()) {
            tempStudent = (Success_Student__c) so;
            if(tempStudent.Student__c!=null) {
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

            for (Contact c : [SELECT id,
                              (SELECT RecordTypeId
                               FROM Cases
                               WHERE isClosed = false)
                              FROM Contact
                              WHERE Id IN :contactIds]) {
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
        public Integer reactiveCount {get; set;}
        public Integer proactiveCount {get; set;}

        public caseWrapper() {
            reactiveCount = 0;
            proactiveCount = 0;
        }
    }

    /*
     * Class to facilitate selection of students for mass actions
     */
    public class studentWrapper {
        public Boolean selected {get; set;}
        public Success_Student__c obj {get; set;}
        public String changeDir {get; set;}
        public String imageName {get; set;}

        public studentWrapper(Success_Student__c student) {
            selected = false;
            obj = student;

            if (obj.Most_Recent_Outlook_Change_Direction__c == 1) {
                changeDir = 'Up';
            } else if (obj.Most_Recent_Outlook_Change_Direction__c == -1) {
                changeDir = 'Down';
            } else if(obj.Most_Recent_Outlook_Change_Direction__c == 0){
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
        public Integer outlookScore {get; set;}
        //Direction is negative for down, 0 for same, and positive for up
        public Integer direction {get; set;}
        public Date changeDate {get; set;}

        public CivitasWrapper(Integer oScore, Integer dir, Date change) {
            outlookScore = oScore;
            direction = dir;
            changeDate = change;
        }
    }

    public boolean searched{
        get{
            if(query == NULL || !query.contains('LIKE')){
                searched = false;
            }
            else{
                searched = true;
            }
            return searched;
        }
        set;
    }

    /*
     * Used to refresh the list to it's orignal state
     */
    public void resetSearch(){
        searchString = NULL;
        collegeFilter = NULL;
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
        String filter = createFilterStringForStudent();
        filter += createFilterStringForCollege();
        return filter;
    }

    private String createFilterStringForCollege() {
        if (!String.isEmpty(collegeFilter)) {
            return ' (Student__c IN (SELECT Contact__c FROM Student_Program_Plan__c ' +
                   'WHERE Status__c = \'Active in Program\' AND Program_Description__c LIKE \'%' +
                   collegeFilter + '%\')) AND ';
        }
        return ' ';
    }

    private String createFilterStringForStudent() {
        String searchCon = searchString.trim();
        String createdQuery = ' (' +
            'Student_Name__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\' ' +
                    'OR EMPLID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
                    'OR ASURiteID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
                ') AND ';
        return createdQuery;
    }
}
