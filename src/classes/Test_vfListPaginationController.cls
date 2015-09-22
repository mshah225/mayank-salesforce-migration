@IsTest
private class Test_vfListPaginationController
{
    @testSetup static void setUp()
    {
        FAQ__kav faqArticle = new FAQ__kav(
                Title = 'testFAQ',
                Summary = 'test from apex',
                Answer__c = 'test',
                Question__c = 'test',
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'test-FAQ-asdf');
        insert faqArticle;

        faqArticle = [SELECT KnowledgeArticleId
        FROM FAQ__kav
        WHERE Id = :faqArticle.id];
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        How_To__kav howArticle = new How_To__kav(
                Title = 'testHowTo',
                Summary = 'test from apex',
                Content__c = 'test from apex',
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'testHowTo-asdf');
        insert howArticle;

        howArticle = [SELECT KnowledgeArticleId
        FROM How_To__kav
        WHERE Id = :howArticle.id];
        KbManagement.PublishingService.publishArticle(howArticle.KnowledgeArticleId, true);

        Informational__kav infoArticle = new Informational__kav(
                Title = 'testInfo',
                Summary = 'test from apex',
                Information__c = 'test from apex',
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'testInfo-asdf');
        insert infoArticle;

        infoArticle = [SELECT KnowledgeArticleId
        FROM Informational__kav
        WHERE Id = :infoArticle.id];
        KbManagement.PublishingService.publishArticle(infoArticle.KnowledgeArticleId, true);
    }

    @isTest static void testViewAllArticlesPage()
    {
        PageReference viewAllArticles = Page.viewAllArticles;
        Test.setCurrentPage(viewAllArticles);
        vfListPaginationController vf = new vfListPaginationController();

        vf.searchstring = 'test';
        vf.articleSearch();
        vf.next();
        vf.firstPage();
        vf.getNextRequired();
        vf.getPrevRequired();
        vf.clearSearchString();

        System.assertEquals('', vf.searchstring);
    }

    @isTest static void teststudentSCPage()
    {
        PageReference studentSC = Page.studentSC;
        Test.setCurrentPage(studentSC);
        ApexPages.currentPage().getParameters().put('q', 'test');
        vfListPaginationController vf = new vfListPaginationController();

        vf.getPageNumber();
        vf.articleSearch();
        vf.viewAllResults();

        // Test long search string
        vf.searchstring = 'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test test test test test test ' +
                          'test test test test';
        vf.articleSearch();

        System.assertEquals(99, vf.searchstring.length());
    }
}