/*****************************************
 * File: showMyCoachingStudentsController
 * Author: Mathew Ruff, Sierra-Cedar
 * Description: Custom controller logic for showMyCoachingStudents.component
 ******************************************/
public class showMyCoachingStudentsController {
    private final Integer cookieExpiration = 22592000; // 30 days in seconds (30 Days * 24 hours * 60 minutes * 60 seconds)

    public Id proactiveCaseRTID { get; set; }
    private String oldQuery { get; set; } // Used to determine if the query changes
    public Id portalEmailRTID { get; set; }
    public Id studentRTID { get; set; }
    public Id ownerId { get; set; }
    public String searchString { get; set; }
    public List<studentWrapper> studentList { get; set; }
    public Map<Id, caseWrapper> caseCountMap { get; set; }

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
            query = value;
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }
    }

    /*
     * The standard set controller instatiation that controls the pagination
     * for the page. When this variable is reconstructed, student list is rebuilt.
     */
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

            return pageSize;
        }
        set {
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
        get;
        set {
            if (sortDir == 'DESC') {
                sortDir = 'ASC';
            } else {
                sortDir = 'DESC';
            }
        }
    }

    /*
     * Stores the API name of the field that the user wants to sort the list by.
     * Setting this variable updates the query with the proper "ORDER BY" clause.
     */
    public String sortField {
        get;
        set {
            String tempQuery;
            Integer loc;

            sortField = value;

            if (!String.isEmpty(sortField)) {
                sortDir = sortDir;
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
     * Checks to see if caseList is different from setCon.getRecords
     *
     * @return Boolean True if a difference is detected, false otherwise
     */
    private Boolean isListDifferent(List<studentWrapper> list1, List<SObject> list2) {
        Boolean result = true;
        List<Success_Student__c> tempList = (List<Success_Student__c>) list2;

        if (list1 != null && tempList != null) {
            if (list1.size() > 0 && tempList.size() > 0) {
                if (
                    list1[0].obj.Id == tempList[0].Id &&
                    list1[list1.size() - 1].obj.Id == tempList[tempList.size() - 1].Id &&
                    list1.size() == tempList.size()
                ) {
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
                tempEmail = new Portal_Email__c(RecordTypeId = portalEmailRTID);
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
            emails.add(
                new Portal_Email__c(
                    Success_Student__c = ss.Id,
                    Contact__c = ss.Student__c,
                    Additional_Message_Text__c = tempEmail.Additional_Message_Text__c,
                    RecordTypeId = portalEmailRTID,
                    Email_Template_Name__c = tempEmail.Email_Template_Name__c
                )
            );
        }

        if (emails.size() > 0) {
            insert emails;
        }

        // Reset the tempEmail
        tempEmail = null;
    }

    /*
     * Rebuild the studentList variable (what is actually displayed to the page).
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
        if (isListDifferent(studentList, setCon.getRecords()) || studentList == null) {
            caseCountMap = new Map<Id, caseWrapper>();
            studentList = new List<studentWrapper>();

            for (SObject so : setCon.getRecords()) {
                studentList.add(new studentWrapper((Success_Student__c) so));
            }

            for (studentWrapper sw : studentList) {
                caseCountMap.put(sw.obj.Student__c, new caseWrapper());
            }

            // Query for contacts/cases
            for (Contact c : [
                SELECT Id, (SELECT RecordTypeId FROM Cases WHERE IsClosed = FALSE)
                FROM Contact
                WHERE Id IN :caseCountMap.keyset()
            ]) {
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
     * Searches Students for and rerenders the showMyCoachingStudents component list.
     */
    public void myStudentsSearch() {
        String trimmed = searchString.trim();
        String studentsQuery =
            '' +
            'SELECT Student_Name__c, EMPLID__c, Student__c, Success_Resource__r.Resource__c, ASURiteID__c ' +
            'FROM Success_Student__c ' +
            'WHERE Success_Resource__r.Resource__c = \'' +
            ownerId +
            '\' ' +
            'AND RecordTypeId = \'' +
            studentRTID +
            '\' ' +
            'AND Is_Active__c = true ' +
            'AND Coaching_Student__c = true ' +
            'AND (' +
            'Student_Name__c LIKE \'%' +
            String.escapeSingleQuotes(trimmed) +
            '%\' ' +
            'OR EMPLID__c LIKE \'%' +
            String.escapeSingleQuotes(trimmed) +
            '%\'' +
            checkFirstAndLastName(trimmed) +
            ')';

        query = studentsQuery;
    }

    public static String checkFirstAndLastName(String searchTerm) {
        String queryPart = '';
        List<String> dividedSearchTerm = searchTerm.split('\\s+');
        String firstName = dividedSearchTerm.remove(0);
        String lastName = '';
        for (String partOfLastName : dividedSearchTerm) {
            lastName += partOfLastName + ' ';
        }
        lastName = lastName.trim();
        if (!String.isEmpty(firstName) && !String.isEmpty(lastName)) {
            queryPart =
                'OR (Student__r.FirstName LIKE \'' +
                String.escapeSingleQuotes(firstName) +
                '\' ' +
                'AND Student__r.LastName LIKE \'' +
                String.escapeSingleQuotes(lastName) +
                '\')';
        }
        return queryPart;
    }
    /*
     * Resets the myStudentsQuery to initial value
     */
    public void resetMyStudentsSearch() {
        searchString = '';
        query = oldQuery;
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

    /*
     * Class to facilitate selection of students for mass actions
     */
    public class studentWrapper {
        public Boolean selected { get; set; }
        public Success_Student__c obj { get; set; }

        public studentWrapper(Success_Student__c student) {
            selected = false;
            obj = student;
        }
    }

    /*
     * Class to display count of reactive and proactive cases.
     */
    public class caseWrapper {
        public Integer reactiveCount { get; set; }
        public Integer proactiveCount { get; set; }

        public caseWrapper() {
            reactiveCount = 0;
            proactiveCount = 0;
        }
    }
}