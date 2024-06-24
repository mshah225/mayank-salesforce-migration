/**
 * Controller class for handling student search functionalities in a Salesforce environment.
 * This class is responsible for loading and managing messages displayed on the student search interface,
 * allowing for dynamic content based on active data in the Salesforce org.
 */
global class StudentSearchController {
    public List<String> studentProfileGlobalMessages { get; set; }

    public void init() {
        setStudentProfileGlobalMessages();
    }

    /**
     * Retrieves active student search messages from the Student_Profile_Message__mdt custom metadata type.
     * Only messages associated with the 'Student 360: Student Search' profile tab are added.
     * If an error occurs during retrieval, it logs the error using a custom error logger.
     */
    public void setStudentProfileGlobalMessages() {
        try {
            studentProfileGlobalMessages = new List<String>();

            List<Student_Profile_Message__mdt> messages = [
                SELECT Message_to_Display__c, Student_Profile_Tab__c
                FROM Student_Profile_Message__mdt
                WHERE Is_Active__c = TRUE
            ];

            for (Student_Profile_Message__mdt message : messages) {
                if (message.Student_Profile_Tab__c == 'Student 360: Student Search') {
                    studentProfileGlobalMessages.add(message.Message_to_Display__c);
                }
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertMapToJSON(
                    'studentProfileGlobalMessages',
                    new Map<String, String>{ 'studentProfileGlobalMessages' => studentProfileGlobalMessages + '' }
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }
}