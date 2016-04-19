@isTest
private class Test_SearchUsers
{
    @testSetup static void setUp()
    {
        User testUser = UserService.createTestUser();
        testUser.FederationIdentifier = 'test@admin.asu.edu';
        Id p = [SELECT Id FROM Profile LIMIT 1].Id;
        testUser.ProfileId = p;
        insert testUser;
    }

    @isTest static void testUListResults()
    {
        User testUser = [
            SELECT Id
            FROM User
            LIMIT 1
        ];

        PageReference searchUsers = Page.searchUsers;
        Test.setCurrentPage(searchUsers);

        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testUser.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.hideCommunity = true;
        su.searchString = 'test';
        su.search();

        Test.stopTest();

        System.assertNotEquals(null, su.uList);
        System.assertEquals(false, su.getNoResults());
    }

    @isTest static void testClearList()
    {
        User testUser = [
            SELECT Id
            FROM User
            LIMIT 1
        ];

        PageReference searchUsers = Page.searchUsers;
        Test.setCurrentPage(searchUsers);

        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = testUser.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.hideCommunity = true;
        su.searchString = 'test';
        su.search();

        // The clear functionality clears the list, but then repopulates
        // with all users just like when the page loads.
        su.clear();

        Test.stopTest();

        // The list should be greater than just the one result above at this point.
        System.assert(su.uList.size() > 1);
        System.assertEquals(false, su.getNoResults());
    }

    @isTest static void testPageSearchError()
    {
        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.hideCommunity = true;
        su.searchString = 't';
        su.search();

        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean errorPresent = false;

        for (Apexpages.Message msg : msgs)
        {
            if (msg.getDetail().contains('You must enter at least 2 search characters'))
            {
                errorPresent = true;
            }
        }

        System.assert(errorPresent);
    }

    @isTest static void testNoSOSLResults()
    {
        Test.startTest();

        SearchUsers su = new SearchUsers();
        su.searchString = 'test';
        su.search();

        Test.stopTest();

        System.assertEquals(true, su.getNoResults());
        System.assert(su.uList.size() == 0);
    }
}