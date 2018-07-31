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
    public String studentGroup {get; set;}
    public String campusFilter {get; set;}
    public String majorFilter {get; set;}
    public Date createdByStartDate {get; set;}
    public Date createdByEndDate {get; set;}
    public Date followupStartDate {get; set;}
    public Date followupEndDate {get; set;}
    public Date persistenceStartDate {get; set;}
    public Date persistenceEndDate {get; set;}
    public String searchString {get; set;}
    public String caseReasonAdministrativelyClosed {get; set;}
    public String caseStatus {get; set;}
    public String caseRecommendedActions {get; set;}
    public String caseRecommendedActionsOther {get; set;}
    public String categoryFilter {get; set;}

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
                caseStatusOptions.add(new SelectOption('--', '--'));
                for (String statusOption : allCaseStatusOptions) {
                    caseStatusOptions.add(new SelectOption(statusOption, statusOption));
                }
            }
            return caseStatusOptions;
        }
        set;
    }

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
            }
            return outlookChangeOptions;
        }

        set;
    }

    /*
     * Get the list of cases selected by the end user.
     */
    public List<Case> selectedCases {
        get {
            selectedCases = new List<Case>();

            for (caseWrapper cw : caseList) {
                if (cw.selected) {
                    selectedCases.add(cw.obj);
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

    /*
    * set the tempemail to null when user closes panel
    */
    public void clearTempEmail() {

            tempEmail = null;

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
        caseSubject = NULL;
        campusFilter = NULL;
        followupStartDate = NULL;
        followupEndDate = NULL;
        createdByStartDate = NULL;
        createdByEndDate = NULL;
        persistenceStartDate = NULL;
        persistenceEndDate = NULL;
        caseSubject = NULL;
        studentGroup = NULL;

        caseStatusFilter = '--';
        outlookChangeFilter = '--';
        outlookScoreFilter = '--';

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
        filter += createFilterStringForStudentGroup();
        filter += createFilterStringForCollegeDegreeAndCampus();
        filter += createFilterStringForSubject();
        filter += createFilterStringForCreatedDate();
        filter += createFilterStringForStudentIdSearch();
        filter += createFilterStringForFollowupDate();
        filter += createFilterStringForOutlookChange();
        filter += createFilterStringForOutlookScore();
        filter += createFilterStringForOutlookDate();
        filter += createFilterStringForCategory();
        return filter;
    }

    private String createFilterStringForStatus() {
        if (caseStatusFilter != '--') {
            return ' Status = \'' + caseStatusFilter + '\' AND ';
        }
        return ' ';
    }

    private String createFilterStringForStudentGroup() {
        if (!String.isEmpty(studentGroup)) {
            return ' (ContactId IN (SELECT SG_Contact__c FROM Student_Group__c ' +
                    'WHERE SG_PeopleSoft_Code__c LIKE \'%' +
                    studentGroup + '%\')) AND ';
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
        if (createdByStartDate != null) {
            String startDateSection = DateTime.newInstance(createdByStartDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            startDateSection += 'T00:00:00+0000';
            createdQuery += ' CreatedDate >= ' + startDateSection + ' AND ';
        }
        if (createdByEndDate != null) {
            String endDateSection = DateTime.newInstance(createdByEndDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            endDateSection += 'T23:59:59+0000';
            createdQuery += ' CreatedDate <= ' + endDateSection + ' AND ';
        }
        return createdQuery;
    }

    private String createFilterStringForFollowupDate() {
        String createdQuery = ' ';
        if (followupStartDate != null) {
            String followupSearchStartDate = DateTime.newInstance(followupStartDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            createdQuery += ' FollowUp_Date__c >= ' + followupSearchStartDate + ' AND ';
        }
        if (followupEndDate != null) {
            String followupSearchEndDate = DateTime.newInstance(followupEndDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            createdQuery += ' FollowUp_Date__c  <= ' + followupSearchEndDate + ' AND ';
        }
        return createdQuery;
    }

    private String createFilterStringForStudentIdSearch() {
        String createdQuery = ' ';
        if(!String.isEmpty(searchString)) {
            String searchCon = searchString.trim();
            if (!String.isEmpty(searchCon)) {
                createdQuery = ' (' +
                    'Contact.Name LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\' ' +
                    'OR Contact.EMPLID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
                    'OR Contact.ASURite_ID__c LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\'' +
                    ') AND ';
            }
        }

        return createdQuery;
    }

    private String createFilterStringForCollegeDegreeAndCampus() {
        if (!String.isEmpty(campusFilter) || !String.isEmpty(majorFilter)) {
            String collegeDegreeAndCampusFilter = ' (ContactId IN (SELECT Contact__c FROM Student_Program_Plan__c ' +
                   'WHERE Status__c = \'Active in Program\' ';

            if (!String.isEmpty(campusFilter)) {
                collegeDegreeAndCampusFilter += ' AND Campus__r.Name LIKE \'%' +
                campusFilter + '%\' ';
            }
            if (!String.isEmpty(majorFilter)) {
                collegeDegreeAndCampusFilter += ' AND Plan_Description__c LIKE \'%' +
                majorFilter + '%\' ';
            }
            collegeDegreeAndCampusFilter += ')) AND ';
            return collegeDegreeAndCampusFilter;
        }
        return ' ';
    }

    private String createFilterStringForOutlookChange() {
        if (outlookChangeFilter != '--') {
            return ' Contact.Most_Recent_Outlook_Change_Direction__c  = ' + outlookChangeFilter + ' AND ';
        }
        return ' ';
    }

    private String createFilterStringForOutlookScore() {
        String outlookScoreQueryFilter;
        switch on outlookScoreFilter {
            when '1' {
                outlookScoreQueryFilter = ' Contact.Curr_Cont_Prediction_Level__c < 4 AND ';
            }
            when '2' {
                outlookScoreQueryFilter = ' Contact.Curr_Cont_Prediction_Level__c >= 4 AND Contact.Curr_Cont_Prediction_Level__c < 6 AND ';
            }
            when '3' {
                outlookScoreQueryFilter = ' Contact.Curr_Cont_Prediction_Level__c = 6 AND ';
            }
            when '4' {
                outlookScoreQueryFilter = ' Contact.Curr_Cont_Prediction_Level__c = 7 AND ';
            }
            when '5' {
                outlookScoreQueryFilter = ' Contact.Curr_Cont_Prediction_Level__c > 7 AND ';
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
            String persistenceSearchStartDate = DateTime.newInstance(persistenceStartDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            createdQuery += ' Change_Date__c >= ' + persistenceSearchStartDate + ' AND ';
        }
        if (persistenceEndDate != null) {
            String persistenceSearchEndDate = DateTime.newInstance(persistenceEndDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            createdQuery += ' Change_Date__c  <= ' + persistenceSearchEndDate + ' AND ';
        }
        return createdQuery;
    }

    public List<SelectOption> caseMassUpdateStatusOptions {
        get {
            if (caseMassUpdateStatusOptions == null) {

                caseMassUpdateStatusOptions = new List<SelectOption>();
                caseMassUpdateStatusOptions.add(new SelectOption('', '--', false));
                caseMassUpdateStatusOptions.add(new SelectOption('Closed: Administratively Resolved (No Outreach)', 'Closed: Administratively Resolved (No Outreach)', false));
                caseMassUpdateStatusOptions.add(new SelectOption('Closed: Customer Self-Resolved', 'Closed: Customer Self-Resolved', false));
                caseMassUpdateStatusOptions.add(new SelectOption('Conferred with Student by Email', 'Conferred with Student by Email', false));
                caseMassUpdateStatusOptions.add(new SelectOption('Conferred with Student by Phone', 'Conferred with Student by Phone', false));
                caseMassUpdateStatusOptions.add(new SelectOption('In Person Meeting', 'In Person Meeting', false));

            }
            return caseMassUpdateStatusOptions;

        }

        set;
    }

    public List<SelectOption> caseRecommendedActionOptions {
        get {
            if (caseRecommendedActionOptions == null) {
                caseRecommendedActionOptions = new List<SelectOption>();
                Schema.DescribeFieldResult caseRecommendedActionDescribe = Case.Recommended_Actions__c.getDescribe();
                List<Schema.PicklistEntry> caseRecommendedActionList = caseRecommendedActionDescribe.getPicklistValues();

                for(Schema.PicklistEntry caseRecommendedAction : caseRecommendedActionList) {
                    caseRecommendedActionOptions.add(new SelectOption(caseRecommendedAction.getValue(), caseRecommendedAction.getLabel(), false));
                }
            }
            return caseRecommendedActionOptions;
        }

        set;
    }

    public void massClose() {

        List<Case> casesToClose = new List<case>();

        if (String.isEmpty(caseStatus) || String.isEmpty(caseRecommendedActions)) {
            ApexPages.addMessage(
                new ApexPages.message(ApexPages.severity.ERROR,'You must select an option for the Case Status AND Recommended Action(s)')
            );
        } else {
            for (case selectedCase : selectedCases) {
                selectedCase.Status = caseStatus;
                selectedCase.Reason_Administratively_Closed__c = caseReasonAdministrativelyClosed;
                selectedCase.Recommended_Actions__c = caseRecommendedActions;
                selectedCase.Recommended_Actions_Other__c = caseRecommendedActionsOther;
                casesToClose.add(selectedCase);
            }
            
            if (casesToClose.size() > 0) {
                try {
                    Database.update(casesToClose);
                } catch(Exception ex) {
                    ApexPages.addMessage(
                        new ApexPages.message(
                            ApexPages.severity.ERROR,
                            'There was an error closing these cases. If the problem persists, contact your system admin with this message: ' + ex)
                    );
                }
            }
            
            clearMassUpdateFields();
        }
    }

    private void clearMassUpdateFields() {
        caseStatus = null;
        caseReasonAdministrativelyClosed = null;
        caseRecommendedActions = null;
        caseRecommendedActionsOther = null;
    }
    
    private String createFilterStringForCategory() {
        String createdQuery = ' ';
        if (!String.isEmpty(categoryFilter)) {
            String searchCon = categoryFilter.trim();
            if (!String.isEmpty(searchCon)) {
                createdQuery = ' (CC_Category__r.Name LIKE \'%' + String.escapeSingleQuotes(searchCon) + '%\' ) AND ';
            }
        }

        return createdQuery;
    }
}