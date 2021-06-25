public class SummaryListController {
    private boolean debug = false;
    public Id proactiveCaseRTID { get; set; } // Stores the ID of the case record type to be summarized
    public String query { get; set; } // Stores the aggregate query that is used to generate the list
    public String Subject { get; set; } // Stores the subject to filter by in the dynamic query
    public String followupDate { get; set; } // Stores the followupDate to filter by in the dynamic query
    private String oldQuery; // Stores the query after generating a list to track if query changes
    public boolean excludeFollowUpDate { get; set; } // Determine if the followup date should be included in the dynamic query
    public boolean coaching { get; set; }

    /*
     * Run query to generate results
     */
    public List<AggregateResult> summaryResult {
        get {
            List<String> vars = new List<String>();
            try {
                oldQuery = query; // Store new query
                summaryResult = Database.query(query);
                return summaryResult;
            } catch (Exception e) {
                vars.add(ErrorLogger.convertStringToJSON('query', query));
                vars.add(ErrorLogger.convertListToJSON('summaryResult', summaryResult));
                ErrorLogger.log(e, vars, debug);
                return summaryResult;
            }
        }
        set;
    }

    /*
     * Get the OwnerId from the provided query.
     *
     * <p>
     * Note, we always convert to the 15 digit Id for simplicity of the algorithm
     * </p>
     */
    public Id ownerId {
        get {
            String temp = query; // Used to store query for processing
            integer loc; // Stores the index at which the owner id appears in the query

            // Strip all spaces from query
            temp = temp.replaceAll('\\s+', '');
            //temp = temp.toLowerCase();

            // Locate OwnerId=
            loc = temp.indexOf('OwnerId=') + 9;

            // Grab next 15 characters
            temp = temp.substring(loc, loc + 15);

            ownerId = temp;

            return ownerId;
        }
        set;
    }

    /*
     * Stores the dynmically generated query to be displayed in the modal list
     * SELECT CaseNumber, ContactId, Contact.Name, Contact.EMPLID__c, Subject, Description, Status, FollowUp_Date__c FROM Case WHERE OwnerId = :ownerId && Followup_Date__c = :followupDate && subject = :subject
     */
    public String dynamicQuery {
        get {
            // Need to figure out why this is being called 3 times per action.
            if (subject != null) {
                subject = String.escapeSingleQuotes(subject);
            }
            dynamicQuery =
                '' +
                'SELECT CaseNumber, ContactId, Owner.Name, CreatedDate, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.Email, ' +
                'Subject, Description, Status, FollowUp_Date__c, Curr_Cont_Prediction_Level__c, Most_Recent_Outlook_Change_Direction__c, Prev_Cont_Prediction_Level__c, Change_Date__c, STRM__c, Session__c ' +
                'FROM Case ' +
                'WHERE OwnerId = \'' +
                ownerId +
                '\' ' +
                'AND subject =  \'' +
                subject +
                '\' ' +
                'AND CC_Category__c NOT IN (SELECT Id FROM Case_Classification__c WHERE RecordType.Name = \'Category\' AND Active__c = true AND Name = \'WatchList\' AND Parent__r.Name = \'ASU Advisor Outreach\') ' +
                'AND RecordTypeId = \'' +
                proactiveCaseRTID +
                '\' ' +
                'AND IsClosed = false';

            if (!excludeFollowUpDate && coaching == null) {
                if (followUpDate != null && followUpDate != '') {
                    dynamicQuery = dynamicQuery + ' AND Followup_Date__c = ' + followUpDate;
                } else {
                    dynamicQuery = dynamicQuery + ' AND Followup_Date__c = null';
                }
            }

            dynamicQuery += ' ORDER BY Contact.LastName ASC';
            return dynamicQuery;
        }
        set;
    }
}
