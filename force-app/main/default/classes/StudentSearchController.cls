/**
 * Controller class for handling student search functionalities in a Salesforce environment.
 * This class is responsible for loading and managing messages displayed on the student search interface,
 * allowing for dynamic content based on active data in the Salesforce org.
 */
global class StudentSearchController {
    /**
     * Property to get or set the substitute user details.
     * @return UserHelper.SubstituteUserWrapper instance with substitute user details.
     */
    public UserHelper.SubstituteUserWrapper substituteUser {
        get {
            if (substituteUser == null) {
                substituteUser = UserHelper.getSubstituteUserDetails();
            }
            return substituteUser;
        }
        set;
    }

    /**
     * Property to check if the substitute user has access to the Student 360 feature.
     * @return Boolean indicating if the substitute user has Student 360 access.
     */
    public Boolean substituteUserHasStudent360Access {
        get {
            return substituteUser.isSubstitutingAsAnotherUser &&
                PermissionsHelper.userHasCustomPermission('Student_360_Visible', substituteUser.substituteUserId);
        }
        set;
    }

    /**
     * Property to determine if the Student 360 feature should be shown to the substitute user.
     * @return Boolean indicating if the Student 360 feature should be shown to the substitute user.
     */
    public Boolean showRestrictedStudent360ToSubstituteUser {
        get {
            return substituteUser.isSubstitutingAsAnotherUser &&
                !substituteUserHasStudent360Access &&
                loggedInUserHasStudent360Access;
        }
        set;
    }

    /**
     * Property to check if the logged-in user has access to the Student 360 feature.
     * @return Boolean indicating if the logged-in user has Student 360 access.
     */
    public Boolean loggedInUserHasStudent360Access {
        get {
            return FeatureManagement.checkPermission('Student_360_Visible');
        }
        set;
    }

    /**
     * Property to check if the current user has access to the Student 360 feature.
     * @return Boolean indicating if the user has access to the Student 360 feature.
     */
    public Boolean hasStudent360Access {
        get {
            return substituteUser.isSubstitutingAsAnotherUser
                ? substituteUserHasStudent360Access && loggedInUserHasStudent360Access
                : loggedInUserHasStudent360Access;
        }
        set;
    }

    public List<String> studentSearchMessages { get; set; }
    public List<String> studentSearchRestrictedMessages { get; set; }

    /**
     * Initializes the controller by setting the student search messages.
     */
    public void init() {
        setStudentSearchMessages();
    }

    /**
     * Retrieves active student search messages from the Student_Profile_Message__mdt custom metadata type.
     * Only messages associated with the 'Student Search' experience are added.
     * If an error occurs during retrieval, it logs the error using a custom error logger.
     */
    public void setStudentSearchMessages() {
        try {
            studentSearchMessages = new List<String>();
            studentSearchRestrictedMessages = new List<String>();

            List<Student_Profile_Message__mdt> messages = [
                SELECT Message_to_Display__c, DeveloperName
                FROM Student_Profile_Message__mdt
                WHERE Is_Active__c = TRUE AND Student_Profile_Tab__c = 'Student Search'
            ];

            for (Student_Profile_Message__mdt message : messages) {
                if (message.DeveloperName == 'Student_Search') {
                    studentSearchMessages.add(message.Message_to_Display__c);
                } else if (
                    showRestrictedStudent360ToSubstituteUser && message.DeveloperName == 'Student_Search_Access'
                ) {
                    studentSearchRestrictedMessages.add(message.Message_to_Display__c);
                }
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertMapToJSON(
                    'studentSearchMessages',
                    new Map<String, String>{ 'studentSearchMessages' => studentSearchMessages + '' }
                )
            );
            vars.add(
                ErrorLogger.convertMapToJSON(
                    'studentSearchRestrictedMessages',
                    new Map<String, String>{ 'studentSearchRestrictedMessages' => studentSearchRestrictedMessages + '' }
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }
}