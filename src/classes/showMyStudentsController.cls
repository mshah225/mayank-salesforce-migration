public class showMyStudentsController {
    public String query {get; set;} // Query passed to component
    public Id proactiveCaseRTID {get; set;}
    private String oldQuery {get; set;} // Used to determine if the query changes
    private final Integer cookieExpiration = 22592000; // 30 days in seconds (30 Days * 24 hours * 60 minutes * 60 seconds)
    public String sortField {get; set;}
    public Id portalEmailRTID {get; set;}
    
    // Transient properties (cookies cannot be stored in the view state)
    private transient Map<String, Cookie> cookieMap; // Stores the pages cookies
    private transient Cookie pageSizeCookie; // Stores the cookie containing the desired page size
    
    public ApexPages.StandardSetController setCon {
        get {
            if (query != oldQuery && query != null) {
                setCon = new ApexPages.StandardSetController(DataBase.getQueryLocator(query));
                setCon.setPageSize(pageSize);
                oldQuery = query;
            }
            
            return setCon;
        }
        
        set;
    }
    
    public List<studentWrapper> studentList {
        get {
            Set<Id> contactIds = new Set<Id>();
            caseCountMap = new Map<Id, caseWrapper>();
            
            if (studentList == null) {
                studentList = new List<studentWrapper>();
            }
            
            if (setCon != null) {
                if (isListDifferent(studentList, setCon.getRecords())) {
                    studentList = new List<studentWrapper>();
                    
                    for (SObject so : setCon.getRecords()) {
                        studentList.add(new studentWrapper((Success_Student__c) so));
                    }
                }
                
                for (studentWrapper sw : studentList) {
                    caseCountMap.put(sw.obj.Student__c, new caseWrapper());
                }
                    
                // Query for contacts/cases
                for (Contact c : [SELECT id,
                    (SELECT RecordTypeId
                        FROM Cases
                        WHERE IsClosed = false)
                    FROM Contact
                    WHERE Id IN :caseCountMap.keyset()]) {
                    for (Case cc : c.cases) {
                        if (cc.recordTypeId == proactiveCaseRTID) {
                            caseCountMap.get(c.Id).proactiveCount++;
                        } else {
                            caseCountMap.get(c.Id).reactiveCount++;
                        }
                    }
                }
            }
            
            return studentList;
        }
        
        set;
    }
    
    public Map<Id, caseWrapper> caseCountMap {get; set;}
    
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
            setCon.setPageSize(pageSize);
            pageSizeCookie = new Cookie('pageSize', string.valueOf(pageSize), null, cookieExpiration, false);
            getCookieMap().put('pageSize', pageSizeCookie);
            ApexPages.currentPage().setCookies(cookieMap.values());
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
    
    public class caseWrapper {
        public Integer reactiveCount {get; set;}
        public Integer proactiveCount {get; set;}
        
        public caseWrapper() {
            reactiveCount = 0;
            proactiveCount = 0;
        }
    }

    /*
     * A String to keep track of the Case list sort direction
     */
    public String sortDir {
        get {
            if (sortDir == null) {
                sortDir = 'DESC';
            }

            return sortDir;
        }

        set;
    }

    /*
     * Toggles the sort direction of query
     */
    public void toggleSort() {
        if (sortDir != null) {
            sortDir = sortDir.equals('ASC') ? 'DESC' : 'ASC';
        }

        updateQuery();
    }

    /*
     * Updats the setCon query with the ORDER BY clause sortField and sortDir
     */
    public void updateQuery() {
        setCon = new ApexPages.StandardSetController(DataBase.getQueryLocator(query += ' ORDER BY ' + sortField + ' ' + sortDir));
    }
    
    /*
     * Checks to see if caseList is different from setCon.getRecords
     *
     * @return Boolean True if a difference is detected, false otherwise
     */
    private Boolean isListDifferent(List<studentWrapper> list1, List<SObject> list2) {
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
        
        set;
    }
    
    /*
     * Portal Email object to store user input for mass emails
     */
    public Portal_Email__c tempEmail {
        get {
            if (tempEmail == null) {
                tempEmail = new Portal_Email__c(
                	RecordTypeId = portalEmailRTID
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
        List<Portal_Email__c> emails = new List<Portal_Email__c>();
        
        for (Success_Student__c ss : selectedStudents) {
            // Most of the object is formula fields
            emails.add(new Portal_Email__c(
                Success_Student__c = ss.Id,
                Contact__c = ss.Student__c,
                Additional_Message_Text__c = tempEmail.Additional_Message_Text__c,
                RecordTypeId = portalEmailRTID,
                Email_Template_Name__c = tempEmail.Email_Template_Name__c
            ));
        }
        
        if (emails.size() > 0) {
            insert emails;
        }
        
        // Reset the tempEmail
        tempEmail = null;
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
}