@isTest
private class TopFiveArticleControllerAKBTest {
    // Helper method to create articles
    private static void createArticles(
        Integer howMany,
        String titlePrefix,
        String dataCategoryGroupName,
        String dataCategoryName
    ) {
        List<FAQ__kav> faqList = new List<FAQ__kav>();
        List<FAQ__DataCategorySelection> faqDCSList = new List<FAQ__DataCategorySelection>();

        for (Integer i = 0; i < howMany; i++) {
            String uniqueURLName =
                'Top5-Testing-FAQ-Article-' +
                titlePrefix.replace(' ', '-') +
                '-' +
                i +
                '-' +
                System.currentTimeMillis();
            uniqueURLName = uniqueURLName.replaceAll('[^a-zA-Z0-9-]', ''); // Remove any invalid characters

            FAQ__kav faqArticle = new FAQ__kav(
                Title = titlePrefix + ' ' + i,
                Summary = 'Test FAQ From Apex ' + i,
                Answer__c = 'TEST ' + i,
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = uniqueURLName
            );
            faqList.add(faqArticle);
        }

        insert faqList;

        for (FAQ__kav faqArticle : faqList) {
            faqArticle = [SELECT Id, KnowledgeArticleId FROM FAQ__kav WHERE Id = :faqArticle.Id];
            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);

            FAQ__DataCategorySelection faqDCS = new FAQ__DataCategorySelection(
                ParentId = faqArticle.Id,
                DataCategoryGroupName = dataCategoryGroupName,
                DataCategoryName = dataCategoryName
            );
            faqDCSList.add(faqDCS);
        }

        insert faqDCSList;
    }

    @testSetup
    private static void setup() {
        // Create articles for all relevant types
        createArticles(5, 'Classes', 'Academics', 'My_ASU_Classes');
        createArticles(5, 'Programs and eAdvisor', 'Academics', 'My_ASU_Programs_and');
        createArticles(5, 'Application Status', 'Academics', 'My_ASU_Application');
        createArticles(5, 'Devil2Devil', 'Campus_Services', 'My_ASU_Devil2Devil');
        createArticles(5, 'Account Charges', 'Finances', 'My_ASU_Account_Charges');
        createArticles(5, 'Financial Aid and Scholarships', 'Finances', 'My_ASU_Financial_Aid');
    }

    @isTest
    private static void testDoGet() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = System.URL.getOrgDomainUrl() + '/services/apexrest/TopFiveArticlesAKB';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults1 = TopFiveArticleControllerAKB.getTopFiveArticles(
            'Classes'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults2 = TopFiveArticleControllerAKB.getTopFiveArticles(
            'Programs and eAdvisor'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults3 = TopFiveArticleControllerAKB.getTopFiveArticles(
            'Application Status'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults4 = TopFiveArticleControllerAKB.getTopFiveArticles(
            'Devil2Devil'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults5 = TopFiveArticleControllerAKB.getTopFiveArticles(
            'Account Charges'
        );
        List<TopFiveArticleControllerAKB.ArticleInfo> postResults6 = TopFiveArticleControllerAKB.getTopFiveArticles(
            'Financial Aid and Scholarships'
        );
        Test.stopTest();

        System.assert(postResults1.size() == 5, 'Expected 5 articles for Classes but got ' + postResults1.size());
        System.assert(
            postResults2.size() == 5,
            'Expected 5 articles for Programs and eAdvisor but got ' + postResults2.size()
        );
        System.assert(
            postResults3.size() == 5,
            'Expected 5 articles for Application Status but got ' + postResults3.size()
        );
        System.assert(postResults4.size() == 5, 'Expected 5 articles for Devil2Devil but got ' + postResults4.size());
        System.assert(
            postResults5.size() == 5,
            'Expected 5 articles for Account Charges but got ' + postResults5.size()
        );
        System.assert(
            postResults6.size() == 5,
            'Expected 5 articles for Financial Aid and Scholarships but got ' + postResults6.size()
        );

        for (TopFiveArticleControllerAKB.ArticleInfo ai : postResults6) {
            System.assertEquals(
                TopFiveArticleControllerAKB.getUrlPrefix() + '/authkb?id=' + ai.id,
                ai.url,
                'URL mismatch for article ID ' + ai.id
            );
        }
    }
}