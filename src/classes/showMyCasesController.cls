public class showMyCasesController {
    // Constants
    private final Integer cookieExpiration = 22592000; // 30 days in seconds (30 Days * 24 hours * 60 minutes * 60 seconds)
    private final Integer defaultPageSize = 25; // The default page size to use if no cookie exists
    private final String pageSizeCookieName = 'pageSize'; // The name of the cookie storing the desired number of records to display per page
    
    // Properties with standard getters/setters
    public Id proactiveCaseRTID {get; set;} // The record type Id of the proactive cases
    private String oldQuery {get; set;} // Used to determine if the query changes
    public Map<Id, relatedCases> caseCounts {get; set;} // Stores the contact Id to summarized case counts
    public List<caseWrapper> caseList {get; set;} // List of Case Wrappers (cases) to display on the page
    public Id ownerId {get; set;} // Stores the Id of the new owner of the selected cases
    public Id portalEmailRTID {get; set;} // The record type of the portal email object

    // Transient properties (cookies cannot be stored in the view state)
    private transient Map<String, Cookie> cookieMap; // Stores the pages cookies
    private transient Cookie pageSizeCookie; // Stores the cookie containing the desired page size

    // Properties with custom getters and setters
    
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
            system.debug('query set');
            query = value;
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }
    }
    
    /*
     * The standard set controller instatiation that controls the pagination
     * for the page. When this variable is reconstructed, case list is rebuilt.
     */
    public ApexPages.StandardSetController setCon {
        get;
        
        set {
            system.debug('setCon Set');
            setCon = value;
            setCon.setPageSize(pageSize);
            resetCaseList();
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
     * Get the list of cases selected by the end user.
     */
    public List<Case> selectedCases {
        get {
            if (selectedCases == null) {
                selectedCases = new List<Case>();
                
                for (caseWrapper cw : caseList) {
                    if (cw.selected) {
                        selectedCases.add(cw.obj);
                    }
                }
            }
            
            return selectedCases;
        }
        
        set {
            selectedCases = value;
            
            if (selectedCases == null) {
                for (caseWrapper cw : caseList) {
                    cw.selected = false;
                }
            }
        }
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
     * Used to force a refresh of the setCon.
     * 
     * <p>
     * Used in the following locations:
     * -Transfering cases
     * -Refresh button on vf page
     * </p>
     */
    public boolean refreshList {
        get;
        
        set {
            system.debug('refreshList: ' + value);
            refreshList = value;
            
            if (refreshList == true) {
                refreshList = false;
                query = query;
            }
        }
    }
    
    /* 
     * Used to store imput from users for mass emails
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
    
    // Transient getters/setters
    
    /*
     * Gets the pages current cookies
     */
    private Map<String, Cookie> getCookieMap() {
        cookieMap = ApexPages.currentPage().getCookies();
        
        return cookieMap;
    }
    
    /*
     * Gets the page size cookie if it exists. If it does not exist,
     * create the default cookie.
     */
    private Cookie getPageSizeCookie() {
        if (getCookieMap() != null) {
            pageSizeCookie = cookieMap.get(pageSizeCookieName);
        }
        
        if (pageSizeCookie == null) {
            pageSizeCookie = new Cookie(pageSizeCookieName, string.valueOf(defaultPageSize), null, cookieExpiration, false);
            cookieMap.put(pageSizeCookieName, pageSizeCookie);
            ApexPages.currentPage().setCookies(cookieMap.values());
        }
        
        return pageSizeCookie;
    }
    
    // Methods
    
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
    public void resetCaseList() {
        system.debug('caseList rebuilt');
        Case tempCase;
        
        caseList = new List<CaseWrapper>();
        
        for (SObject so : setCon.getRecords()) {
            tempCase = (Case) so;
            caseList.add(new CaseWrapper(tempCase));
        }
        
        resetCaseCounts();
    }
    
    /*
     * Resets the caseCounts map
     */
    public void resetCaseCounts() {
        system.debug('caseCount rebuilt');
        caseCounts = new Map<Id, relatedCases>();
        Set<Id> contactIds = new Set<Id>();
        
        if (caseList != null) {
            for (caseWrapper cw : caseList) {
                contactIds.add(cw.obj.contactid);
            }
        
            for (Contact c : [SELECT id,
                (SELECT RecordTypeId
                    FROM Cases
                    WHERE isClosed = false)
                FROM Contact
                WHERE Id IN :ContactIds]) {
                caseCounts.put(c.id, new relatedCases());
                        
                for (Case cc : c.cases) {
                    if (cc.recordTypeId == proactiveCaseRTID) {
                        caseCounts.get(c.Id).proactiveCount++;
                    } else {
                        caseCounts.get(c.Id).reactiveCount++;
                    }
                }
            }
        }
    }
    
    /*
     * Transfer Cases
     */
    public void transferCases() {
        for (case c : selectedCases) {
            c.ownerId = ownerId;
        }
        
        update selectedCases;
        
        selectedCases = null;
        refreshList = true;
    }
    
    /*
     * Create portal email records for sending emails through marketing cloud
     */
    public void massEmail() {
        List<Portal_Email__c> emails = new List<Portal_Email__c>();
        
        for (case c : selectedCases) {
           emails.add(new Portal_Email__c(
            	Case__c = c.Id,
                Contact__c = c.contactId,
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
        selectedCases = null;
    }
    
    /*
     * Override the default next() method of setCon
     */
    public void setConNext() {
        system.debug('setConNext');
        setCon.next();
        resetCaseList();
    }
    
    /*
     * Override the default prev() method of setCon
     */
    public void setConPrev() {
        system.debug('setConPrevious');
        setCon.previous();
        resetCaseList();
    }
    
    /*
     * Override the default setpageSize() method of setCon
     */
    public void setConPageSize(integer newSize) {
        system.debug('setConPageSize');
        setCon.setPageSize(newSize);
        resetCaseList();
    }
    
    // Sub-classes
    
    /*
     * Used to track the number of proactive and reactive cases at the contact level
     */
    public class relatedCases {
        public Integer reactiveCount {get; set;}
        public Integer proactiveCount {get; set;}
        
        public relatedCases () {
            reactiveCount = 0;
            proactiveCount = 0;
        }
    }
    
    /*
     * Used to create a trackable way to select cases via a check box
     */
    public class caseWrapper {
        public Boolean selected {get; set;}
        public Case obj {get; set;}
        
        public caseWrapper (Case wrappedCase) {
            selected = false;
            obj = wrappedCase;
        }
    }
}