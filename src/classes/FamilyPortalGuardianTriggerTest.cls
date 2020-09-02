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
                WHERE First_Name__c = :guardian.First_Name__c AND Email__c = :guardian.Email__c
            ];
        }

        System.assertEquals(guardian.Id, matchedGuardians[0].Id);
    }
}
