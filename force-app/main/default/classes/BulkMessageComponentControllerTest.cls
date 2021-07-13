@isTest
private class BulkMessageComponentControllerTest {
    @isTest
    private static void studentListTest() {
        Success_Coach_Mapping__c mapping = new Success_Coach_Mapping__c();
        mapping.Success_Coach__c = UserInfo.getUserId();
        mapping.PeopleSoft_Student_Group_Code__c = 'R100';
        mapping.Supervisor__c = UserInfo.getUserId();
        Database.insert(mapping);

        RecordType recordTypeForContact = [
            SELECT Id, Name
            FROM RecordType
            WHERE sobjecttype = 'Contact' AND Name = 'External Mastered'
            LIMIT 1
        ];
        Contact c = new Contact();
        c.RecordTypeId = recordTypeForContact.Id;
        c.EMPLID__c = '12345';
        c.LastName = 'Test SMS';
        Database.insert(c);

        Student_Group__c studentGrp = new Student_Group__c();
        studentGrp.SG_Contact__c = c.Id;
        studentGrp.SG_Status__c = true;
        studentGrp.SG_PeopleSoft_Code__c = 'R100';
        Database.insert(studentGrp);

        FYSStudentWrapper studentWrap = BulkMessageComponentController.studentList(UserInfo.getUserId());
        System.assertEquals(true, studentWrap != null);
        System.assertEquals(1, studentWrap.students.size());
    }
}
