global class StudentSearchController {
    public List<String> studentSearchMessages { get; set; }
    public String textToSearch { get; set; }

    public void init() {
        setStudentSearchMessages();
    }

    public void setStudentSearchMessages() {
        try {
            studentSearchMessages = new List<String>();

            List<Student_Profile_Message__mdt> messages = [
                SELECT Message_to_Display__c, Student_Profile_Tab__c
                FROM Student_Profile_Message__mdt
                WHERE Is_Active__c = TRUE
            ];

            for (Student_Profile_Message__mdt message : messages) {
                if (message.Student_Profile_Tab__c == 'Student 360: Student Search') {
                    studentSearchMessages.add(message.Message_to_Display__c);
                }
            }
        } catch (Exception e) {
            // setup both ErrorLogger + Salesforce_Log__c
        }
    }

    @RemoteAction
    global static StudentSearchResultsWrapper getStudentSearchResults(String studentSearchResultsJson) {
        try {
            List<Student_Program_Plan__c> studentSearchResults = (List<Student_Program_Plan__c>) JSON.deserialize(
                studentSearchResultsJson,
                List<Student_Program_Plan__c>.class
            );

            StudentSearchResultsWrapper searchResults = new StudentSearchResultsWrapper();
            for (Student_Program_Plan__c studentProgramPlan : studentSearchResults) {
                searchResults.studentProgramPlanData.add(studentProgramPlan);
            }

            return searchResults;
        } catch (Exception e) {
            // setup both ErrorLogger + Salesforce_Log__c
            return null;
        }
    }

    global class StudentSearchResultsWrapper {
        public List<Student_Program_Plan__c> studentProgramPlanData = new List<Student_Program_Plan__c>();
    }
}