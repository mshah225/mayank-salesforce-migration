public class showMyCasesController {
    
    private boolean debug = false;
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
    private string originalQuery {get; set;} // Justin is this still required?
    public Boolean emailPreviewMode {get; set;} // Used to determine which set of buttons to show in the email modal
    public List<Database.SaveResult> emailInsertResults {get; set;} // Used to display the results of the email send to the user
    
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
    
    /*
     * The standard set controller instatiation that controls the pagination
     * for the page. When this variable is reconstructed, case list is rebuilt.
     */
    public ApexPages.StandardSetController setCon {
        get;
        
        set {
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
        get{
            if(sortDir == NULL) {
                if(query != null && query.indexOf('ASC') >= 0){
                    return 'ASC';
                } else if (query != null && query.indexOf('DESC') >= 0){
                    return 'DESC';
                } else {
                    return NULL;
                }
            } else {
                return sortDir;
            }
        }
        
        set;
    }

    /*
     * Stores the API name of the field that the user wants to sort the list by.
     * Setting this variable updates the query with the proper "ORDER BY" clause.
     */
    public String sortField {
        get{
            if (sortfield == null) {
                Integer locStart = query.indexOf('ORDER BY');
                if(locStart >= 0) {
                    String queryEnd = query.substring(locStart+9);
                    Integer locEnd = queryEnd.indexOf(' '); 
                    if(locEnd > 0) {
                        return queryEnd.substring(0, locEnd);
                    }
                }
            }
            
            return sortfield;
        }
        
        set {
            String tempQuery;
            Integer loc;
            
            if (!String.isEmpty(value)) {
                if (value == sortField) { // Field has not changed
                    if (sortDir == 'ASC') {
                        sortDir = 'DESC';
                    } else {
                        sortDir = 'ASC';
                    }
                } else { // The value has changed
                    sortDir = 'ASC';
                }
                
                sortField = value;
                
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
                	RecordTypeId = portalEmailRTID,
                    Subject__c = 'A Message from your College and Department'
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
    @TestVisible
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
                Subject__c = tempEmail.Subject__c,
                Additional_Message_Text__c = tempEmail.Additional_Message_Text__c,
                RecordTypeId = portalEmailRTID,
                Email_Template_Name__c = tempEmail.Email_Template_Name__c
            ));
        }
        if (emails.size() > 0) {
            emailInsertResults = Database.insert(emails);
        }
        
        tempEmail = null;
        emailPreviewMode = false;
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
        selectedCases = null;
    }
    
    /*
     * Override the default next() method of setCon
     */
    public void setConNext() {
        setCon.next();
        resetCaseList();
    }
    
    /*
     * Override the default prev() method of setCon
     */
    public void setConPrev() {
        setCon.previous();
        resetCaseList();
    }
    
    /*
     * Override the default setpageSize() method of setCon
     */
    public void setConPageSize(integer newSize) {
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
    
    /*
     * Indicates whether the string has been previously searched
     */ 
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
                    'Contact.Name LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\' ' +
                    'OR Contact.EMPLID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
                ') AND ' + tempQueryRight;
                
                query = tmp;
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
}