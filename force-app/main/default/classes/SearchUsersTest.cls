@isTest
private class SearchUsersTest {
    @testSetup
    static void setUp() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
        testUser.FederationIdentifier = 'testSU@admin.asu.edu';
        testUser.ProfileId = p.Id;
        insert testUser;
    }

    @isTest
    static void testUListResults() {
        User testUser = [SELECT Id FROM User WHERE FederationIdentifier = 'testSU@admin.asu.edu' LIMIT 1];

        PageReference searchUsers = Page.searchUsers;
        Test.setCurrentPage(searchUsers);

        Id[] fixedSearchResults = new List<Id>{ testUser.Id };
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.searchString = 'test';
        su.search();

        Test.stopTest();

        System.assert(su.uList.size() == 1);
    }

    @isTest
    static void testPageSearchError() {
        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.searchString = 't';
        su.search();

        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean errorPresent = false;

        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains('You must enter at least 2 search characters')) {
                errorPresent = true;
            }
        }

        System.assert(errorPresent);
    }

    @isTest
    static void testNoSOSLResults() {
        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.searchString = 'test';
        su.search();

        Test.stopTest();

        System.assert(su.uList.size() == 0);
    }
}
