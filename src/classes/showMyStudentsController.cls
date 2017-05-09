public class showMyStudentsController {
    private boolean debug = false;
    public Id proactiveCaseRTID {get; set;}
    private String oldQuery {get; set;} // Used to determine if the query changes
    private final Integer cookieExpiration = 22592000; // 30 days in seconds (30 Days * 24 hours * 60 minutes * 60 seconds)
    public Id portalEmailRTID {get; set;}
    public String currentQuery {get; set;}
    private boolean differentField;
    public Boolean emailPreviewMode {get; set;} // Used to determine which set of buttons to show in the email modal
    public List<Database.SaveResult> emailInsertResults {get; set;} // Used to display the results of the email send to the user

    public Map<Id,caseWrapper> caseCountMap  {get; set;}
    public List<studentWrapper> studentList {get; set;}
    
    // Transient properties (cookies cannot be stored in the view state)
    private transient Map<String, Cookie> cookieMap; // Stores the pages cookies
    private transient Cookie pageSizeCookie; // Stores the cookie containing the desired page size

    /*
     * Get the query from the component attribute and assign it to the
     * internal query variable.
     * 
     * <p>
     * This unbinds query from the attribute. SFDC prevents updating of variables.
     * that are bound to component attributes.
     * </p>
     */
    public String queryAttr {
        get;
        
        set {
            queryAttr = value;
            if (queryAttr != oldQuery || query == null) {
                query = queryAttr;
                oldQuery = queryAttr;
            }
        }
    }
    
    /*
     * The query used to retrieve data from the database. When the query is
     * set, setCon is rebuilt.
     */
    public String query {
        get;
        
        set {
            List<String> vars = new List<String>();
            try{
                query = value;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            } catch(Exception e){
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(string.valueOf(setCon));
                ErrorLogger.log(e, vars, debug);
            }
        }
    }
    
    
    public ApexPages.StandardSetController setCon {
        get;
        
        set {
            setCon = value;
            setCon.setPageSize(pageSize);
            resetStudentList();
        }
    }
    /*
     * Keeps track of the desired page size.
     * 
     * <p>
     * Setter creates a cookie to store user specific preferences. Cookie
     * expires after ~ 30 days.
     * </p>
     */
    public Integer pageSize {
        get {
            pageSize = integer.valueOf(getPageSizeCookie().getValue());
            return pageSize; // Return current page size to the field for display
        }
        
        set {
            // When pagesize is changed, set the setCon and create a new cookie       
            pageSize = value;
            pageSizeCookie = new Cookie('pageSize', string.valueOf(pageSize), null, cookieExpiration, false);
            getCookieMap().put('pageSize', pageSizeCookie);
            ApexPages.currentPage().setCookies(cookieMap.values());
            setConPageSize(pageSize);
        }
    }

    /*
     * Cannot define getter of transient property
     * 
     * <p>
     * Gets the pages current cookies
     * </p>
     */
    private Map<String, Cookie> getCookieMap() {
        cookieMap = ApexPages.currentPage().getCookies();
        
        return cookieMap;
    }
    
    /*
     * Cannot define getter of transient property
     * 
     * <p>
     * Gets the page size cookie if it exists. If it does not exist,
     * create the default cookie.
     * </p>
     */
    private Cookie getPageSizeCookie() {
        if (getCookieMap() != null) {
            pageSizeCookie = cookieMap.get('pageSize');
        }
        
        if (pageSizeCookie == null) {
            pageSizeCookie = new Cookie('pageSize', '25', null, cookieExpiration, false);
            cookieMap.put('pageSize', pageSizeCookie);
            ApexPages.currentPage().setCookies(cookieMap.values());
        }
        
        return pageSizeCookie;
    }
    
    /*
     * A String to keep track of the Case list sort direction
     */
    public String sortDir {
        get{
            if(sortDir == NULL) {
                if(query.indexOf('ASC') >= 0){
                    System.debug('ASC');
                    return 'ASC';
                }
                else if (query.indexOf('DESC') >= 0){
                    System.debug('DESC');
                    return 'DESC';
                }
                else
                    return NULL;
            }
            else {
                return sortDir;
            }
        }
        
        set {
            //If first sort is on Name
            if(sortDIR == NULL && sortField == 'Student_Name__c'){
                sortDir = 'DESC';
            }
            //If previous sort was a different field or the same field with a DESC value
            else if (sortDir == 'DESC' || sortDIR == NULL) {
                sortDir = 'ASC';
            }
            //If previous sort was same field with ASC value
            else {
                sortDir = 'DESC';
            }
        }
    }


    public String sortField{
        get{
            Integer locStart = query.indexOf('ORDER BY');
            if(locStart >= 0) {
                String queryEnd = query.substring(locStart+9);
                Integer locEnd = queryEnd.indexOf(' '); 
                if(locEnd > 0) {
                    return queryEnd.substring(0, locEnd);
                }
            }
            return NULL;
        }
        
        set {
            String tempQuery;
            Integer loc; 
            string oldSort = sortField;            
            sortField = value;
            
            if (!String.isEmpty(sortField)) {               
                if(oldSort == NULL || sortField == oldSort){
                    sortDir = sortDir;
                }
                //Ensures that each column starts ASC
                else if(sortField != oldSort){
                    if(sortDir != 'ASC'){
                        sortDir = sortDir;
                    }
                }
                tempQuery = query;              
                loc = tempQuery.indexOf('ORDER BY');              
                if (loc > 0) {
                    tempQuery = tempQuery.left(loc);
                    tempQuery = tempQuery.trim();
                }               
                tempQuery = tempQuery + ' ORDER BY ' + sortField + ' ' + sortDir + ' NULLS LAST';
                query = tempQuery;
            }          
        }
    }

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
     * Checks to see if caseList is different from setCon.getRecords
     *
     * @return Boolean True if a difference is detected, false otherwise
     */
   /* private Boolean isListDifferent(List<studentWrapper> list1, List<SObject> list2) {
        Boolean result = true;
        List<Success_Student__c> tempList = (List<Success_Student__c>) list2;

        if (list1 != null && tempList != null) {
            if (list1.size() > 0 && tempList.size() > 0) {
                if (list1[0].obj.Id == tempList[0].Id
                    && list1[list1.size() - 1].obj.Id == tempList[tempList.size() - 1].Id
                    && list1.size() == tempList.size()) {
                        result = false;
                }
            }

        // if either is null, return true
        // If both are null, return false
        } else if ((list1 != null || tempList != null)) {
            result = false;
        }

        return result;
    }*/
    
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
        try{
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
        }
        catch(Exception e){
            vars.add(string.valueOf(emails));
            ErrorLogger.log(e, vars, debug);
        }
    }
    
    /*
     * Rebuild the caseList variable (what is actually displayed to the page).
     * 
     * <p>
     * This is primarily bound to the set con:
     * -Called when setCon is reset (query = query)
     * -Called in setCon override methods
     * --setConNext()
     * --setConPrevious()
     * --SetConPageSize()
     * </p>
     */
    public void resetStudentList() {
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
        
        public studentWrapper(Success_Student__c student) {
            selected = false;
            obj = student;
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
    
    /**
    *Used to modify the query based on search parameter inputted by user
    *
    */
    public string searchString{
        get{
            return searchString;
        }
        set{
            searchString = value;
            if(searchString != NULL){
                String tempQuery = removeSearchString();  
                Integer loc = tempQuery.indexOf('WHERE');
                String tempQueryLeft = tempQuery.substring(0, loc + 5);
                tempQueryLeft = tempQueryLeft.trim();
                String tempQueryRight = tempQuery.subString(loc + 6);
                tempQueryRight = tempQueryRight.trim();
                
                String searchCon = value.trim();
                String tmp = tempQueryLeft +' (' +
                    'Student_Name__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\' ' +
                    'OR EMPLID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
                ') AND ' + tempQueryRight;
                query=tmp;
            }
        }  
    }
    
    /*
     * Used to refresh the list to it's orignal state
     */
    public void resetSearch(){
        searchString = NULL;
        query = removeSearchString();
    }
    
    /*
     * Trims the query to remove any specific searches
     */
    @TestVisible
    private string removeSearchString(){
        String tmpQuery = query;
        if(searched){
            Integer loc = tmpQuery.indexOf('AND');
            String left = tmpQuery.substring(0, tmpQuery.indexOf('WHERE')+6);
            String right = tmpQuery.substring(loc+3);
            tmpQuery = left + right;
        }
        return tmpQuery;
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

    /*
     * Override the default next() method of setCon
     */
    public void setConNext() {
        setCon.next();
        resetStudentList();
    }
    
    /*
     * Override the default prev() method of setCon
     */
    public void setConPrev() {
        setCon.previous();
        resetStudentList();
    }
    
    /*
     * Override the default setpageSize() method of setCon
     */
    public void setConPageSize(integer newSize) {
        setCon.setPageSize(newSize);
        resetStudentList();
    }
}