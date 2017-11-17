public class SummaryListController {
    public Id proactiveCaseRTID {get; set;} // Stores the ID of the case record type to be summarized
    public String query {get; set;} // Stores the aggregate query that is used to generate the list
    public String Subject {get;set;} // Stores the subject to filter by in the dynamic query
    public String followupDate {get;set;} // Stores the followupDate to filter by in the dynamic query
    private String oldQuery; // Stores the query after generating a list to track if query changes
    public boolean excludeFollowUpDate {get; set;} // Determine if the followup date should be included in the dynamic query

    /*
     * Run query to generate results
     */
    public List<AggregateResult> summaryResult {
        get {
            oldQuery = query; // Store new query
            
            summaryResult = Database.query(query);
            
            return summaryResult;
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
        get{
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

            dynamicQuery = '' +
                'SELECT CaseNumber, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.EMPLID__c, Contact.Email, ' +
                    'Subject, Description, Status, FollowUp_Date__c ' +
                'FROM Case ' +
                'WHERE OwnerId = \'' + ownerId + '\' ' +
                'AND subject =  \'' + subject + '\' ' +
                'AND Category__c != \'Watchlist\' ' +
                'AND RecordTypeId = \'' + proactiveCaseRTID + '\' ' +
                'AND IsClosed = false';

            if (!excludeFollowUpDate) {
                if (followUpDate != null && followUpDate != '') {
                    dynamicQuery = dynamicQuery + ' AND Followup_Date__c = ' + followUpDate;
                } else {
                    dynamicQuery = dynamicQuery + ' AND Followup_Date__c = null';
                }
            }
            
            return dynamicQuery;
        }
        
        set;
    }
}