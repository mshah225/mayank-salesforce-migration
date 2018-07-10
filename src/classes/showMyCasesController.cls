public class showMyCasesController extends ListViewController {

    private boolean debug = false;

    // Properties with standard getters/setters
    public Id proactiveCaseRTID {get; set;} // The record type Id of the proactive cases
    public Map<Id, relatedCases> caseCounts {get; set;} // Stores the contact Id to summarized case counts
    public List<caseWrapper> caseList {get; set;} // List of Case Wrappers (cases) to display on the page
    public Id ownerId {get; set;} // Stores the Id of the new owner of the selected cases
    public Id portalEmailRTID {get; set;} // The record type of the portal email object
    private string originalQuery {get; set;} // Justin is this still required?
    public Boolean emailPreviewMode {get; set;} // Used to determine which set of buttons to show in the email modal
    public List<Database.SaveResult> emailInsertResults {get; set;} // Used to display the results of the email send to the user
    public String caseSubject {get; set;}
    public String collegeFilter {get; set;}
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    public String searchString{ get; set;}
    public String caseStatusFilter {
        get {
            if (caseStatusFilter == null) {
                caseStatusFilter = '--';
            }
            return caseStatusFilter;
    	}
        set;
    }

    public List<SelectOption> caseStatusOptions {
        get {
            if (caseStatusOptions == null) {
                caseStatusOptions = new List<SelectOption>();
                List<String> allCaseStatusOptions = getPicklistValues();
                for (String statusOption : allCaseStatusOptions) {
                    caseStatusOptions.add(new SelectOption(statusOption, statusOption));
                }
                caseStatusOptions.add(new SelectOption('--', '--'));
            }
            return caseStatusOptions;
        }

        set;
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
    public override void resetRecordList() {
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
        public String changeDir {get; set;}
        public String imageName {get; set;}

        public caseWrapper (Case wrappedCase) {
            selected = false;
            obj = wrappedCase;

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

    /*
     * Used to refresh the list to it's orignal state
     */
    public void resetSearch(){
        searchString = NULL;
        caseStatusFilter = '--';
        caseSubject = NULL;
        collegeFilter = NULL;
        query = queryAttr;
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

    private List<String> getPicklistValues() {
        List<String> pickListValuesForCaseStatus= new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
    	List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
    	for (Schema.PicklistEntry pickListVal : picklistEntries){
	    	pickListValuesForCaseStatus.add(pickListVal.getLabel());
    	}
    	return pickListValuesForCaseStatus;
    }

    public void insertFilterIntoQuery() {
        String modifiedQuery = queryAttr;
        String filter = createFilterForCase();

        Integer loc = modifiedQuery.indexOf('WHERE');
        String leftSideOfQuery = modifiedQuery.substring(0, loc + 5);
        leftSideOfQuery = leftSideOfQuery.trim();
        String rightSideOfQuery = modifiedQuery.subString(loc + 6);
        rightSideOfQuery = rightSideOfQuery.trim();

        modifiedQuery = leftSideOfQuery + filter + rightSideOfQuery;
        query = modifiedQuery;
    }

    private String createFilterForCase() {
        String filter = createFilterStringForStatus();
        filter += createFilterStringForCollege();
        filter += createFilterStringForSubject();
        filter += createFilterStringForCreatedDate();
        filter += createFilterStringForStudent();
        return filter;
    }

    private String createFilterStringForCollege() {
        if (!String.isEmpty(collegeFilter)) {
            return ' (ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c ' +
                   'WHERE Status__c = \'Active in Program\' AND Program_Description__c LIKE \'%' +
                   collegeFilter + '%\')) AND ';
        }
        return ' ';
    }

    private String createFilterStringForStatus() {
        if (caseStatusFilter != '--') {
            return ' Status = \'' + caseStatusFilter + '\' AND ';
        }
        return ' ';
    }

    private String createFilterStringForSubject() {
        if (!String.isEmpty(caseSubject)) {
            return ' Subject LIKE \'%' + caseSubject + '%\' AND ';
        }
        return ' ';
    }

    private String createFilterStringForCreatedDate() {
        String createdQuery = ' ';
        if(startDate != null) {
            String startDateSection = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            startDateSection += 'T00:00:00+0000';
            createdQuery += ' CreatedDate >= ' + startDateSection + ' AND ';
        }
        if(endDate != null) {
            String endDateSection = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            endDateSection += 'T23:59:59+0000';
            createdQuery += ' CreatedDate <= ' + endDateSection + ' AND ';
        }
        return createdQuery;
    }

    private String createFilterStringForStudent() {
        String searchCon = searchString.trim();
        String createdQuery = ' (' +
            'Contact.Name LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\' ' +
            'OR Contact.EMPLID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
            'OR Contact.ASURite_ID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
        ') AND ';
        return createdQuery;
    }
}
