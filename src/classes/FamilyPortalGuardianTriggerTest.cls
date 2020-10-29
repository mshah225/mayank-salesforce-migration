@isTest
private class FamilyPortalGuardianTriggerTest {
    @isTest
    private static void testCreateGuardian() {
        List<Family_Portal_Guardian__c> matchedGuardians;
        Family_Portal_Guardian__c guardian = new Family_Portal_Guardian__c();

        guardian.First_Name__c = 'Testy';
        guardian.Last_Name__c = 'McTesterson';
        guardian.Email__c = 'tmct@asu.edu.tmct';
        guardian.Zip_Code__c = '85284';
        guardian.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        guardian.Phone__c = '4805555555';
        guardian.ASU_Alumni__c = 'Yes';
        guardian.ASURITE_ID__c = 'tmct';
        guardian.Business_Unit_Source__c = 'testbu';
        guardian.City__c = 'Tempe';
        guardian.Country__c = 'United States';
        guardian.EMPLID__c = '1111111111';
        guardian.Middle_Name__c = 'Joe';
        guardian.State__c = 'Arizona';
        guardian.Street__c = '123 E Happy Dr';
        insert guardian;

        Family_Portal_Guardian_Interest__c interest = new Family_Portal_Guardian_Interest__c();
        interest.Active_Interest__c = true;
        interest.Chosen_Interest__c = 'Mentoring';
        interest.Family_Portal_Guardian__c = guardian.Id;
        insert interest;

        Family_Portal_Student__c student = new Family_Portal_Student__c();
        student.Active_Relationship__c = true;
        student.Enrollment_Status__c = 'K-12 Student';
        student.Enrollment_Status_Year__c = '2035';
        student.Family_Portal_Guardian__c = guardian.Id;
        insert student;

        matchedGuardians = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
        ];

        System.assertEquals(guardian.Id, matchedGuardians[0].Id);
    }

    @isTest
    private static void testDuplicateGuardian() {
        Family_Portal_Guardian__c guardian = new Family_Portal_Guardian__c();
        guardian.First_Name__c = 'Testy';
        guardian.Last_Name__c = 'McTesterson';
        guardian.Email__c = 'tmct@asu.edu.tmct';
        guardian.Zip_Code__c = '85284';
        guardian.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        guardian.Phone__c = '4805555555';
        guardian.ASU_Alumni__c = 'Yes';
        guardian.ASURITE_ID__c = 'tmct';
        guardian.Business_Unit_Source__c = 'testbu';
        guardian.City__c = 'Tempe';
        guardian.Country__c = 'United States';
        guardian.EMPLID__c = '1111111111';
        guardian.Middle_Name__c = 'Joe';
        guardian.State__c = 'Arizona';
        guardian.Street__c = '123 E Happy Dr';
        insert guardian;
        Test.setCreatedDate(guardian.Id, DateTime.now().addDays(-10));
        System.debug('guardian1 --> ' + guardian.Id);

        Family_Portal_Guardian_Interest__c interest = new Family_Portal_Guardian_Interest__c();
        interest.Active_Interest__c = true;
        interest.Chosen_Interest__c = 'Mentoring';
        interest.Family_Portal_Guardian__c = guardian.Id;
        insert interest;
        Test.setCreatedDate(interest.Id, DateTime.now().addDays(-10));
        System.debug('interest1 --> ' + interest.Id);

        Family_Portal_Student__c student = new Family_Portal_Student__c();
        student.Active_Relationship__c = true;
        student.Enrollment_Status__c = 'K-12 Student';
        student.Enrollment_Status_Year__c = '2036';
        student.Family_Portal_Guardian__c = guardian.Id;
        insert student;
        Test.setCreatedDate(student.Id, DateTime.now().addDays(-10));
        System.debug('student1 --> ' + student.Id);

        Family_Portal_Guardian__c guardian2 = new Family_Portal_Guardian__c();
        guardian2.First_Name__c = 'Testy';
        guardian2.Last_Name__c = 'McTesterson';
        guardian2.Email__c = 'tmct@asu.edu.tmct';
        guardian2.Zip_Code__c = '85284';
        guardian2.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        guardian2.Phone__c = '4805555555';
        guardian2.ASU_Alumni__c = 'Yes';
        guardian2.ASURITE_ID__c = 'tmct';
        guardian2.Business_Unit_Source__c = 'testbu';
        guardian2.City__c = 'Tempe';
        guardian2.Country__c = 'United States';
        guardian2.EMPLID__c = '1111111111';
        guardian2.Middle_Name__c = 'Joe';
        guardian2.State__c = 'Hawaii';
        guardian2.Street__c = '123 E Happy Dr';
        insert guardian2;
        Test.setCreatedDate(guardian2.Id, DateTime.now().addDays(-5));
        System.debug('guardian2 --> ' + guardian2.Id);

        Family_Portal_Guardian_Interest__c interest2 = new Family_Portal_Guardian_Interest__c();
        interest2.Active_Interest__c = true;
        interest2.Chosen_Interest__c = 'Mentoring';
        interest2.Family_Portal_Guardian__c = guardian2.Id;
        insert interest2;
        Test.setCreatedDate(interest2.Id, DateTime.now().addDays(-5));
        System.debug('interest2 --> ' + interest2.Id);

        Family_Portal_Student__c student2 = new Family_Portal_Student__c();
        student2.Active_Relationship__c = true;
        student2.Enrollment_Status__c = 'K-12 Student';
        student2.Enrollment_Status_Year__c = '2036';
        student2.Family_Portal_Guardian__c = guardian2.Id;
        insert student2;
        Test.setCreatedDate(student2.Id, DateTime.now().addDays(-5));
        System.debug('student2 --> ' + student2.Id);

        Test.startTest();

        Family_Portal_Guardian__c guardian3 = new Family_Portal_Guardian__c();
        guardian3.First_Name__c = 'Testy';
        guardian3.Last_Name__c = 'McTestersen';
        guardian3.Email__c = 'tmct@asu.edu.tmct';
        guardian3.Zip_Code__c = '85284';
        guardian3.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        guardian3.Phone__c = '4805555555';
        guardian3.ASU_Alumni__c = 'Yes';
        guardian3.ASURITE_ID__c = 'tmct';
        guardian3.Business_Unit_Source__c = 'testbu';
        guardian3.City__c = 'Tempe';
        guardian3.Country__c = 'United States';
        guardian3.EMPLID__c = '1111111111';
        guardian3.Middle_Name__c = 'Joe';
        guardian3.State__c = 'Alaska';
        guardian3.Street__c = '123 E Happy Dr';
        insert guardian3;
        System.debug('guardian3 --> ' + guardian3.Id);

        Family_Portal_Guardian_Interest__c interest3 = new Family_Portal_Guardian_Interest__c();
        interest3.Active_Interest__c = false;
        interest3.Chosen_Interest__c = 'Mentoring';
        interest3.Family_Portal_Guardian__c = guardian3.Id;
        insert interest3;
        System.debug('interest3 --> ' + interest3.Id);

        Family_Portal_Student__c student3 = new Family_Portal_Student__c();
        student3.Active_Relationship__c = true;
        student3.Enrollment_Status__c = 'K-12 Student';
        student3.Enrollment_Status_Year__c = '2036';
        student3.Family_Portal_Guardian__c = guardian3.Id;
        insert student3;
        System.debug('student3 --> ' + student3.Id);

        Test.stopTest();

        Integer matchedGuardians = [
            SELECT COUNT()
            FROM Family_Portal_Guardian__c
            WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
        ];
        Integer matchedInterests = [
            SELECT COUNT()
            FROM Family_Portal_Guardian_Interest__c
            WHERE Chosen_Interest__c = :interest.Chosen_Interest__c
        ];
        Integer matchedStudents = [
            SELECT COUNT()
            FROM Family_Portal_Student__c
            WHERE Enrollment_Status__c = :student.Enrollment_Status__c
        ];

        System.assertEquals(1, matchedGuardians);
        System.assertEquals(1, matchedInterests);
        System.assertEquals(1, matchedStudents);
    }
}
