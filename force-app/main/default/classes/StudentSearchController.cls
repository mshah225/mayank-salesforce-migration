global with sharing class StudentSearchController {
    public List<String> studentSearchMessages { get; set; }
    public String textToSearch { get; set; }

    public void init() {
        setStudentSearchMessages();
    }

    public void setStudentSearchMessages() {
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
    }

    @RemoteAction
    global static StudentSearchResultsWrapper getStudentSearchResults(String emergencyContactsListJson) {
        // List<Emergency_Contact__c> emergencyContactsList = (List<Emergency_Contact__c>) JSON.deserialize(
        //     emergencyContactsListJson,
        //     List<Emergency_Contact__c>.class
        // );

        // StudentSearchResultsWrapper searchResults = new StudentSearchResultsWrapper();
        // for (Emergency_Contact__c emergencyContact : emergencyContactsList) {
        //     searchResults.emergencyContactsData.add(emergencyContact);
        // }

        // return searchResults;
        return null;
    }

    global class StudentSearchResultsWrapper {
        public Set<String> asrClasses = new Set<String>();
        public List<PS_ASU_SP_CLASS_V__x> academicIntegrityData = new List<PS_ASU_SP_CLASS_V__x>();
    }
}