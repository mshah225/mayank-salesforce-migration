@isTest
public with sharing class TopFiveArticleControllerAKBTest {
    class TestArticleInfo {
        string id;
        string url;
        string title;
        integer rank;
    }

    // Create FAQ
    public static void createFAQArticles(Integer howMany) {
        List<FAQ__kav> faqList = new List<FAQ__kav>();
        List<FAQ__DataCategorySelection> faqDCSList = new List<FAQ__DataCategorySelection>();

        for (Integer i = 0; i < howMany; i++) {
            FAQ__kav faqArticle = new FAQ__kav(
                Title = 'Testing FAQ Article' + i,
                Summary = 'Test FAQ From Apex' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'Top5-Testing-FAQ-Article-' + i
            );
            faqList.add(faqArticle);
        }

        insert faqList;

        for (Integer i = 0; i < howMany; i++) {
            FAQ__kav faqArticle = [SELECT Id, KnowledgeArticleId FROM FAQ__kav WHERE Id = :faqList[i].Id];

            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

            FAQ__DataCategorySelection faqDCS = new FAQ__DataCategorySelection(
                ParentId = faqArticle.Id,
                DataCategoryGroupName = 'Finances',
                DataCategoryName = 'My_ASU_Financial_Aid'
            );
            faqDCSList.add(faqDCS);
        }

        insert faqDCSList;
    }

    @testSetup
    static void setUp() {
        // Input the number of each type of Article you'd like to create
        createFAQArticles(10);
    }

    static testMethod void testDoGet() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/TopFiveArticlesAKB';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults1 = TopFiveArticleControllerAKB.getTopFiveArticles2(
            'Classes'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults2 = TopFiveArticleControllerAKB.getTopFiveArticles2(
            'Programs and eAdvisor'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults3 = TopFiveArticleControllerAKB.getTopFiveArticles2(
            'Application Status'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults4 = TopFiveArticleControllerAKB.getTopFiveArticles2(
            'Devil2Devil'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults5 = TopFiveArticleControllerAKB.getTopFiveArticles2(
            'Account Charges'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults6 = TopFiveArticleControllerAKB.getTopFiveArticles2(
            'Financial Aid and Scholarships'
        );
        Test.stopTest();

        System.assert(postResults1.size() == 1);
        System.assert(postResults2.size() == 1);
        System.assert(postResults3.size() == 1);
        System.assert(postResults4.size() == 1);
        System.assert(postResults5.size() == 1);
        System.assert(postResults6.size() == 6);

        for (Integer x = 0; x < 5; x++) {
            TopFiveArticleControllerAKB.ArticleInfo ai = postResults6.get(x);
            System.assert(ai.url == TopFiveArticleControllerAKB.getUrlPrefix() + 'authkb?id=' + ai.id);
        }
    }

    static testMethod void testGetMoreArticlesUrl() {
        String dcGroup = 'Finances__c';
        String dataCategory = 'My_ASU_Devil2Devil';

        Test.startTest();
        String checkUrl = TopFiveArticleControllerAKB.getMoreArticlesUrl(dcGroup, dataCategory);
        Test.stopTest();

        System.assert(checkUrl.contains('viewAllArticles'));
        System.assert(checkUrl.contains('My+ASU+Devil2Devil'));
        System.assert(checkUrl.contains('Finances'));
    }
}
