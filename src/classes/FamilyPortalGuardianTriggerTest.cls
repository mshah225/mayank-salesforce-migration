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

        if (guardian != null) {
            insert guardian;

            matchedGuardians = [
                SELECT Id 
                FROM Family_Portal_Guardian__c 
                WHERE First_Name__c =: guardian.First_Name__c 
                    AND Email__c =: guardian.Email__c
            ];
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
        if (guardian != null) {
            insert guardian;
        }

        Test.startTest();

        List<Family_Portal_Guardian__c> matchedGuardians1 = [
            SELECT Id 
            FROM Family_Portal_Guardian__c 
            WHERE First_Name__c = :guardian.First_Name__c 
                AND Email__c = :guardian.Email__c
        ];

        Family_Portal_Guardian__c guardian2 = new Family_Portal_Guardian__c();
        guardian2.First_Name__c = 'Testy';
        guardian2.Last_Name__c = 'McTestersen';
        guardian2.Email__c = 'tmct@asu.edu.tmct';
        guardian2.Zip_Code__c = '85281';
        if (guardian2 != null) {
            insert guardian2;
        }

        List<Family_Portal_Guardian__c> matchedGuardians2 = [
            SELECT Id 
            FROM Family_Portal_Guardian__c 
            WHERE First_Name__c = :guardian.First_Name__c 
                AND Email__c = :guardian.Email__c
        ];

        Test.stopTest();

        List<Family_Portal_Guardian__c> matchedGuardians = [
            SELECT Id 
            FROM Family_Portal_Guardian__c 
            WHERE First_Name__c = :guardian.First_Name__c 
                AND Email__c = :guardian.Email__c
        ];
        
        System.assertEquals(1, matchedGuardians.size());
    }

}