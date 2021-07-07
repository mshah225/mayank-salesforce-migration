public class CommunicationHistoryController {
    public List<Message> messages { get; set; }
    public List<Message> filteredMessages { get; set; }
    public List<SelectOption> options { get; set; }

    // List containing communication history from Marketing Cloud.
    // We used Contact for a nested query into multiple objects.
    public List<et4ae5__IndividualEmailResult__c> individualEmailResults { get; set; }
    public List<et4ae5__SendDefinition__c> sendDefinitions { get; set; }

    public List<et4ae5__IndividualEmailResult__c> individualEmailHistory;
    public List<et4ae5__SendDefinition__C> emailSendHistory;

    public Boolean isPrivate;
    public Boolean showExportButton { get; set; }

    User currentUser;
    Id userId;

    // Filter criteria
    public String filterType { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }

    // Constructor
    public CommunicationHistoryController(ApexPages.StandardController controller) {
        messages = new List<Message>();
        filteredMessages = new List<Message>();
        userId = UserInfo.getUserId();

        isPrivate = false;

        // Code to show export button
        User currentUser = [SELECT Id, Role_Export_Reports__c FROM User WHERE Id = :userId];

        if (currentUser != null) {
            showExportButton = currentUser.Role_Export_Reports__c;
        }

        getEmailHistory();
        filteredMessages = messages;
    }

    public void getEmailHistory() {
        // Get the ID of this Contact Record
        Id contactId = ApexPages.currentPage().getParameters().get('id');

        // Query for the communication history
        individualEmailResults = [
            SELECT
                Id,
                Name,
                et4ae5__SubjectLine__c,
                et4ae5__FromName__c,
                et4ae5__FromAddress__c,
                et4ae5__SoftBounce__c,
                et4ae5__HardBounce__c,
                et4ae5__DateSent__c,
                et4ae5__DateOpened__c,
                et4ae5__NumberOfUniqueClicks__c,
                et4ae5__Contact__c,
                et4ae5__SendDefinition__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE et4ae5__Contact__c = :contactId
            ORDER BY et4ae5__DateSent__c DESC
            LIMIT 750
        ];

        // Create a set of Send Definition IDs
        Set<Id> sendDefinitionIds = new Set<Id>();

        // Populate the set with the Send Definition IDs associated with our Individual
        // Email Results
        for (et4ae5__IndividualEmailResult__c results : individualEmailResults) {
            sendDefinitionIds.add(results.et4ae5__SendDefinition__c);
        }

        // Query for the relevant Send Definitions
        sendDefinitions = [
            SELECT
                Id,
                et4ae5__Business_Unit__c,
                et4ae5__fBusiness_Unit__c,
                et4ae5__Campaigns__c,
                et4ae5__Campaign__r.ParentId,
                (SELECT Parent_Campaign_Private__c FROM et4ae5__Campaigns__r)
            FROM et4ae5__SendDefinition__c
            WHERE Id IN :sendDefinitionIds
            LIMIT 750
        ];

        // Create a map of ID to Send Definition
        Map<Id, et4ae5__SendDefinition__c> sendDefinitionMap = new Map<Id, et4ae5__SendDefinition__c>();

        // Populate our map with Send Definition results
        for (et4ae5__SendDefinition__c sd : sendDefinitions) {
            sendDefinitionMap.put(sd.Id, sd);
        }

        // Iterate through all Individual Email Results to populate the data we need to display for each e-mail
        // message that was sent
        for (et4ae5__IndividualEmailResult__c r : individualEmailResults) {
            if (sendDefinitionMap.containsKey(r.et4ae5__SendDefinition__c)) {
                for (
                    et4ae5__SendJunction__c sj : sendDefinitionMap.get(r.et4ae5__SendDefinition__c).et4ae5__Campaigns__r
                ) {
                    if (sj.Parent_Campaign_Private__c) {
                        isPrivate = true;
                    }
                }
            }

            // Only create and display the message if it isn't private.
            if (!isPrivate) {
                // Create a new Message wrapper
                Message tempMessage = new Message();

                tempMessage.id = r.Id;
                tempMessage.name = r.Name;
                tempMessage.subject = r.et4ae5__SubjectLine__c;

                // The 'Sent By' field displays the name of the Business Unit. If the Business Unit is undefined, then we
                // use the name of the sender, instead.
                tempMessage.sender = sendDefinitionMap.get(r.et4ae5__SendDefinition__c) != null
                    ? sendDefinitionMap.get(r.et4ae5__SendDefinition__c).et4ae5__fBusiness_Unit__c
                    : r.et4ae5__FromName__c;

                // Determine the delivery status of the message based on whether or not it returned a hard or soft bounce
                if (r.et4ae5__HardBounce__c) {
                    tempMessage.deliveryStatus = 'Hard Bounce';
                } else if (r.et4ae5__SoftBounce__c) {
                    tempMessage.deliveryStatus = 'Soft Bounce';
                } else {
                    tempMessage.deliveryStatus = 'Delivered';
                }

                tempMessage.timeSent = String.valueOf(r.et4ae5__DateSent__c);
                tempMessage.timeOpened = String.valueOf(r.et4ae5__DateOpened__c);
                tempMessage.uniqueClicks = String.valueOf(r.et4ae5__NumberOfUniqueClicks__c);

                messages.add(tempMessage);
            }

            isPrivate = false;
        }
    }

    public List<SelectOption> getFilterOptions() {
        options = new List<SelectOption>();

        options.add(new SelectOption('Sent', 'Date Sent'));
        options.add(new SelectOption('Opened', 'Date Opened'));

        return options;
    }

    public void getFilterResults() {
        // Create a new list of messages which have been filtered.
        filteredMessages = new List<Message>();

        // Filter by the time messages were opened by the recipient
        if (filterType == 'Opened') {
            for (Message thisMessage : messages) {
                if (startDate != null && endDate != null && thisMessage.timeOpened != null) {
                    if (
                        Date.valueOf(thisMessage.timeOpened) >= startDate &&
                        Date.valueOf(thisMessage.timeOpened) <= endDate
                    ) {
                        filteredMessages.add(thisMessage);
                    }
                }
            }

            // Filter by the time messages were sent
        } else if (filterType == 'Sent') {
            for (Message thisMessage : messages) {
                if (startDate != null && endDate != null) {
                    if (
                        Date.valueOf(thisMessage.timeSent) >= startDate &&
                        Date.valueOf(thisMessage.timeSent) <= endDate
                    ) {
                        filteredMessages.add(thisMessage);
                    }
                }
            }
        } else {
            System.debug('The filter type does not correspond to any expected values, or is null.');
        }
    }

    /*
     * @description: Clears the search filters. As a result, all communication history for the
     * case is displayed.
     */
    public void clearFilter() {
        // Reset the input fields for Start Date and End Date
        this.startDate = null;
        this.endDate = null;

        // Reset the filter type to its default value
        filterType = 'Sent';

        // Set the filtered (displayed) messages to display all available messages
        filteredMessages = messages;
    }

    /*
     * @description: Wrapper class for historical communication
     */
    public class Message {
        public String id { get; set; }
        public String name { get; set; }
        public String subject { get; set; }
        public String sender { get; set; }

        // Hard Bounce, Soft Bounce, Delivered
        public String deliveryStatus { get; set; }

        public String timeSent { get; set; }
        public String timeOpened { get; set; }
        public String uniqueClicks { get; set; }
        public String subscriptionStatus { get; set; }

        public Message() {
            this.id = id;
            this.name = name;
            this.subject = subject;
            this.sender = sender;

            // Formula using hardbounce/softbounce to determine status
            this.deliverystatus = '';

            this.timeSent = timeSent;
            this.timeOpened = timeOpened;
            this.uniqueClicks = uniqueClicks;
            this.subscriptionStatus = subscriptionStatus;
        }
    }

    /*
     * @description: Custom exception handler for Communication History Controller
     */
    public class CommunicationHistoryException extends Exception {
    }
}
