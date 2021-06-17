@IsTest
private class CoachPortalMainPageControllerTest {
    @testSetup
    static void setUpTest() {
        Profile p = [SELECT Id FROM Profile WHERE Profile.Name = 'ASU Service - Success Coach'];

        User u1 = TestDataFactory.createUser('Testing1', p.Id);
        insert u1;

        User u2 = TestDataFactory.createUser('Testing2', p.Id);
        insert u2;

        Id successPodId = [SELECT Id FROM RecordType WHERE Name = 'Coach' AND SObjectType = 'Success_Pod__c'].Id;

        Success_Pod__c testPod = new Success_Pod__c(Name = 'Test Pod', RecordTypeId = successPodId);
        insert testPod;

        RecordType coachResourceRT = [
            SELECT Name
            FROM RecordType
            WHERE Name = 'Coach' AND SObjectType = 'Success_Resource__c'
        ];

        Success_Resource__c r1 = new Success_Resource__c(
            Resource__c = u1.Id,
            RecordTypeId = coachResourceRT.Id,
            Success_Pod__c = testPod.Id,
            Role__c = 'Lead',
            IsActive__c = true
        );
        insert r1;

        Success_Resource__c r2 = new Success_Resource__c(
            Resource__c = u2.Id,
            RecordTypeId = coachResourceRT.Id,
            Success_Pod__c = testPod.Id,
            Role__c = 'User',
            IsActive__c = true
        );
        insert r2;
    }

    static testMethod void testViewAsOptions() {
        // Arrange
        List<SelectOption> assertViewOptions;
        List<SelectOption> assertMySubordinates;
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing1'];

        // Act
        CoachPortalMainPageController cpmpc = new CoachPortalMainPageController();
        System.runAs(testUser) {
            assertViewOptions = cpmpc.viewAsOptions;
            assertMySubordinates = cpmpc.mySubordinateOptions;
        }

        // Assert
        System.assert(assertViewOptions.size() > 0);
        System.assert(assertMySubordinates.size() > 0);
        System.assert(cpmpc.hasViewAs);
    }

    static testMethod void testQueryStrings() {
        // Arrange
        String proactiveQuery;
        String myStudentsQuery;
        String mySummaryListQuery;
        String myWatchlistQuery;
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing1'];

        // Act
        CoachPortalMainPageController cpmpc = new CoachPortalMainPageController();
        System.runAs(testUser) {
            proactiveQuery = cpmpc.myProactiveQuery;
            myStudentsQuery = cpmpc.myStudentsQuery;
            mySummaryListQuery = cpmpc.mySummaryListQuery;
            myWatchlistQuery = cpmpc.myWatchlistQuery;
        }

        // Assert
        System.assert(proactiveQuery.contains('Category__c != \'Watchlist\''));
        System.assert(myStudentsQuery.contains('FROM Success_Student__c'));
        System.assert(mySummaryListQuery.contains('ORDER BY Subject ASC NULLS LAST'));
        System.assert(myWatchlistQuery.contains('Category__c = \'Watchlist\''));
    }
}
