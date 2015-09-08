@IsTest
private class Test_vfListPaginationController
{
    @testSetup static void setUp()
    {
        // create a FAQ
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

        // publish the faq
        faqArticle = [SELECT KnowledgeArticleId
        FROM FAQ__kav
        WHERE Id = :faqArticle.id];
        KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

        // create a HowTo
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

        // publish the howTo
        howArticle = [SELECT KnowledgeArticleId
        FROM How_To__kav
        WHERE Id = :howArticle.id];
        KbManagement.PublishingService.publishArticle(howArticle.KnowledgeArticleId, true);

        // create an info
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

        // publish the info
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
        vf.getNextRequired();
        vf.getPrevRequired();
        vf.next();
        vf.previous();
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
        vf.getPageSize();
        vf.startSearch();
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