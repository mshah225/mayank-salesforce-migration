public class CoachPortalCaseRecodingController extends ListViewController {
    private boolean debug = false;

    // Properties with standard getters/setters
    public List<CaseWrapper> caseList { get; set; } // List of Case Wrappers (cases) to display on the page
    public Id ownerId { get; set; } // Stores the Id of the new owner of the selected cases

    /*
     * Get the list of cases selected by the end user.
     */
    public List<Case> selectedCases {
        get {
            selectedCases = new List<Case>();

            for (CaseWrapper cw : caseList) {
                if (cw.selected) {
                    selectedCases.add(cw.obj);
                }
            }

            return selectedCases;
        }
        set {
            selectedCases = value;

            if (selectedCases == null) {
                for (CaseWrapper cw : caseList) {
                    cw.selected = false;
                }
            }
        }
    }

    /*
     * Indicates whether the string has been previously searched
     */
    public Boolean searched {
        get {
            if (query == null || !query.contains('LIKE')) {
                searched = false;
            } else {
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
    public String searchString {
        get {
            return searchString;
        }
        set {
            searchString = value;
            if (searchString != '') {
                String tempQuery = removeSearchString();
                Integer loc = tempQuery.indexOf('WHERE');
                String tempQueryLeft = tempQuery.substring(0, loc + 5);
                tempQueryLeft = tempQueryLeft.trim();
                String tempQueryRight = tempQuery.subString(loc + 6);
                tempQueryRight = tempQueryRight.trim();

                String searchCon = value.trim();
                String tmp =
                    tempQueryLeft +
                    ' (' +
                    'Contact.Name LIKE \'%' +
                    String.escapeSingleQuotes(searchCon) +
                    '%\' ' +
                    'OR Contact.EMPLID__c LIKE \'%' +
                    String.escapeSingleQuotes(searchCon) +
                    '%\'' +
                    ') AND ' +
                    tempQueryRight;

                query = tmp;
            }
        }
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
        List<Case> cases = (List<Case>) setCon.getRecords();
        this.caseList = new List<CaseWrapper>();
        Map<Id, Success_Student__c> successStudents = getRelatedSuccessStudentData(cases);

        for (Case c : cases) {
            CaseWrapper cw = new CaseWrapper(c);
            cw.successStudent = successStudent.containsKey(c.ContactId)
                ? successStudents.get(c.ContactId)
                : new Success_Student__c();
            this.caseList.add(cw);
        }
    }

    private Map<Id, Success_Student__c> getRelatedSuccessStudentData(List<Case> cases) {
        Map<Id, Success_Student__c> successStudents = new Map<Id, Success_Student__c>();
        for (Success_Student__c successStudent : [
            SELECT Id, Student__c, Coach__c, Success_Resource__r.Delegated_Resource__c
            FROM Success_Student__c
            WHERE Student__c IN :getContactIds(cases)
        ]) {
            successStudents.put(successStudent.Student__c, successStudent);
        }

        return successStudents;
    }

    /**
     *  Gets a list of Contact IDs associated with the given list of Cases.
     */
    @TestVisible
    private List<Id> getContactIds(List<Case> cases) {
        List<Id> contactIds = new List<Id>();
        for (Case c : cases) {
            contactIds.add(c.ContactId);
        }

        return contactIds;
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
     * Used to refresh the list to it's orignal state
     */
    public void resetSearch() {
        searchString = '';
        query = removeSearchString();
    }

    /*
     * Trims the query to remove any specific searches
     */
    @TestVisible
    private string removeSearchString() {
        String tmpQuery = query;
        if (searched) {
            Integer loc = tmpQuery.indexOf('AND');
            String left = tmpQuery.substring(0, tmpQuery.indexOf('WHERE') + 6);
            String right = tmpQuery.substring(loc + 3);
            tmpQuery = left + right;
        }
        return tmpQuery;
    }

    /*
     * Used to create a trackable way to select cases via a check box
     */
    public class CaseWrapper {
        public Boolean selected { get; set; }
        public Case obj { get; set; }
        public Success_Student__c successStudent { get; set; }

        public CaseWrapper(Case wrappedCase) {
            selected = false;
            obj = wrappedCase;
            successStudent = new Success_Student__c();
        }
    }
}