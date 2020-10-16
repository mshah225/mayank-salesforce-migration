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

        if (guardian != null) {
            insert guardian;

            matchedGuardians = [
                SELECT Id
                FROM Family_Portal_Guardian__c
                WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
            ];

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
        }

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
        if (guardian != null) {
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
        }

        Test.startTest();

        List<Family_Portal_Guardian__c> matchedGuardians1 = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
        ];

        Family_Portal_Guardian__c guardian2 = new Family_Portal_Guardian__c();
        guardian2.First_Name__c = 'Testy';
        guardian2.Last_Name__c = 'McTestersen';
        guardian2.Email__c = 'tmct@asu.edu.tmct';
        guardian2.Zip_Code__c = '85281';
        guardian2.Hash_ID__c = 'fsAYX7wlOYnlNTBx5bL6Un25Nb8nosg25H7IPECXk8o5';
        guardian2.Phone__c = '4805555555';
        guardian2.ASU_Alumni__c = 'Yes';
        guardian2.ASURITE_ID__c = 'tmct';
        guardian2.Business_Unit_Source__c = 'testbu';
        guardian2.City__c = 'Tempe';
        guardian2.Country__c = 'United States';
        guardian2.EMPLID__c = '1111111111';
        guardian2.Middle_Name__c = 'Joe';
        guardian2.State__c = 'Arizona';
        guardian2.Street__c = '123 E Happy Dr';
        if (guardian2 != null) {
            insert guardian2;

            Family_Portal_Guardian_Interest__c interest = new Family_Portal_Guardian_Interest__c();
            interest.Active_Interest__c = true;
            interest.Chosen_Interest__c = 'Mentoring';
            interest.Family_Portal_Guardian__c = guardian2.Id;
            insert interest;

            Family_Portal_Student__c student = new Family_Portal_Student__c();
            student.Active_Relationship__c = true;
            student.Enrollment_Status__c = 'K-12 Student';
            student.Enrollment_Status_Year__c = '2035';
            student.Family_Portal_Guardian__c = guardian2.Id;
            insert student;
        }

        List<Family_Portal_Guardian__c> matchedGuardians2 = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
        ];

        Test.stopTest();

        List<Family_Portal_Guardian__c> matchedGuardians = [
            SELECT Id
            FROM Family_Portal_Guardian__c
            WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
        ];

        System.assertEquals(1, matchedGuardians.size());
    }
}
