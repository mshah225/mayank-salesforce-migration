@isTest
private class GlobalKnowledgeSearchControllerTest {

    @isTest
    static void testSearchArticlesWithCategoryFilter() {
        FAQ__kav article = new FAQ__kav(
            Title = 'Test Article',
            UrlName = 'test-article',
            Language = 'en_US',
            PublishStatus = 'Online',
            Answer__c = 'This is the answer.',
            Functional_Group__c = 'Academic Support'
        );
        insert article;

        FAQ__DataCategorySelection dc = new FAQ__DataCategorySelection(
            ParentId = article.Id,
            DataCategoryGroupName = 'Academics',
            DataCategoryName = 'Admission_Services'
        );
        insert dc;

        System.debug('✅ Inserted category with Id: ' + dc.Id);

        GlobalKnowledgeSearchController.isTesting = true;
        GlobalKnowledgeSearchController.testSelections = new List<FAQ__DataCategorySelection>{ dc };

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GlobalKnowledgeSearchMock.MockSearchResponseWithArticleId(article.Id));

        GlobalKnowledgeSearchController.PagedResult result =
            GlobalKnowledgeSearchController.searchArticles('Test', 10, 1, 'Academics');

        Test.stopTest();

        System.debug('✅ Final result: ' + result);

        System.assertEquals(1, result.articles.size(), 'One article should be returned');
        System.assertEquals(article.Id, result.articles[0].Id);
        System.assertEquals('Academics:Admission_Services', result.articles[0].Categories[0]);
    }

    @isTest
    static void testPaginationLogic() {
        // No category filtering in this test — pure pagination
        Test.setMock(HttpCalloutMock.class, new GlobalKnowledgeSearchMock.LargeMockSearchResponse());

        Test.startTest();
        GlobalKnowledgeSearchController.PagedResult result =
            GlobalKnowledgeSearchController.searchArticles('test', 10, 2, '*');
        Test.stopTest();

        System.debug('✅ Pagination Result: ' + result);

        System.assertEquals(10, result.articles.size(), 'Page size should be 10');
        System.assertEquals(2, result.currentPage, 'Should be on page 2');
        System.assertEquals(3, result.totalPages, 'Total pages should be 3 for 25 results');
        System.assert(result.hasNextPage, 'Should have next page');
        System.assert(result.hasPreviousPage, 'Should have previous page');
    }
}
