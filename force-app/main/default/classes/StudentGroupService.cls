public class StudentGroupService {
    /**
     * Returns all the fields on Student Group in a String
     * @return A string containing all the Student Group fields
     */
    public static String sGroupFieldsToString() {
        Map<String, SObjectField> sGroupFieldMap = ObjectService.getObjectFieldMap('Student_Group__c');

        String sGroupFields = ObjectService.objectFieldsToString(sGroupFieldMap);

        return sGroupFields;
    }

    /**
     * Get the Student Groups for this contact
     * @param the contact Id
     * @return a list of Student Groups for that contact
     */
    public static List<Student_Group__c> getContactActiveStudentGroups(Id contactId) {
        String sGroupFields = sGroupFieldsToString();

        String selectStudentGroup =
            'SELECT ' +
            sGroupFields +
            ' ' +
            'FROM Student_Group__c ' +
            'WHERE SG_Status__c = true ' +
            'AND SG_Contact__c = :contactId' +
            ' ORDER BY SG_Effective_Date__c DESC, SG_PeopleSoft_Code__c ASC ';

        List<Student_Group__c> sGroupList = Database.query(selectStudentGroup);

        return sGroupList;
    }
}
