@isTest(SeeAllData=true)
public with sharing class TopFiveArticleControllerTest {
    static void setUpTest() {
        // setup test data
        List<FAQ__kav> faqList = new List<FAQ__kav>();
        for (Integer i = 0; i <= 4; i++) {
            FAQ__kav faq = new FAQ__kav(Title = 'TestFaq' + i, UrlName = 'TestFaq1' + i);
            faqList.add(faq);
        }

        insert faqList;

        List<FAQ__DataCategorySelection> faqDCSList = new List<FAQ__DataCategorySelection>();
        for (FAQ__kav faq : faqList) {
            FAQ__DataCategorySelection faqDCS = new FAQ__DataCategorySelection(
                ParentId = faq.Id,
                DataCategoryGroupName = 'Finances',
                DataCategoryName = 'My_ASU_Financial_Aid'
            );
            faqDCSList.add(faqDCS);
        }

        insert faqDCSList;
    }

    static testMethod void testDoGet() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/TopFiveArticles';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        List<TopFiveArticleController.ArticleInfo> getResults = TopFiveArticleController.getTopFiveArticles();
        List<TopFiveArticleController.ArticleInfo> postResults1 = TopFiveArticleController.getTopFiveArticles2(
            'Classes'
        );
        List<TopFiveArticleController.ArticleInfo> postResults2 = TopFiveArticleController.getTopFiveArticles2(
            'Programs and eAdvisor'
        );
        List<TopFiveArticleController.ArticleInfo> postResults3 = TopFiveArticleController.getTopFiveArticles2(
            'Application Status'
        );
        List<TopFiveArticleController.ArticleInfo> postResults4 = TopFiveArticleController.getTopFiveArticles2(
            'Devil2Devil'
        );
        List<TopFiveArticleController.ArticleInfo> postResults5 = TopFiveArticleController.getTopFiveArticles2(
            'Account Charges'
        );
        List<TopFiveArticleController.ArticleInfo> postResults6 = TopFiveArticleController.getTopFiveArticles2(
            'Financial Aid and Scholarships'
        );

        //System.assertEquals('true', results.success);
        //System.assertEquals(10, results.records.size());
        //System.assertEquals('Query executed successfully.', results.message);
    }

    @isTest
    private static void checkArticleUrl() {
        KnowledgeArticleVersion kav1 = null;
        KnowledgeArticleVersion kav2 = null;
        KnowledgeArticleVersion kav3 = null;
        KnowledgeArticleVersion kavX = null;

        for (KnowledgeArticleVersion kav : [SELECT Id, UrlName FROM KnowledgeArticleVersion]) {
            string articleIdPrefix = String.valueOf(kav.Id).substring(0, 3);
            if (articleIdPrefix == 'ka1') {
                kav1 = kav;
            } else if (articleIdPrefix == 'ka2') {
                kav2 = kav;
            } else if (articleIdPrefix == 'ka3') {
                kav3 = kav;
            } else {
                kavX = kav;
            }
        }

        String domain = '';
        if ([SELECT IsSandbox FROM Organization].IsSandbox) {
            domain = 'http://utocomm-uto.cs10.force.com/pkb/articles/';
        } else {
            domain = 'https://asu.secure.force.com/kb/articles/';
        }

        if (kav1 != null) {
            String url = TopFiveArticleController.getArticleUrl(kav1);
            System.assertEquals(domain + 'FAQ/' + kav1.UrlName, url);
        }
        if (kav2 != null) {
            String url = TopFiveArticleController.getArticleUrl(kav2);
            System.assertEquals(domain + 'How_To/' + kav2.UrlName, url);
        }
        if (kav3 != null) {
            String url = TopFiveArticleController.getArticleUrl(kav3);
            System.assertEquals(domain + 'Informational/' + kav3.UrlName, url);
        }
        if (kavX != null) {
            String url = TopFiveArticleController.getArticleUrl(kavX);
            System.assertEquals(domain + String.valueOf(kavX.Id).substring(0, 3) + kavX.UrlName, url);
        }
    }

    @isTest
    private static void checkMoreArticleTransformation() {
        String domain = '';
        if ([SELECT IsSandbox FROM Organization].IsSandbox) {
            domain = 'http://utocomm-uto.cs10.force.com/pkb/pkb_Home?l=en_US&c=';
        } else {
            domain = 'https://asu.secure.force.com/kb/pkb_Home?l=en_US&c=';
        }

        String dcGroup = 'dcGroupId__c';
        String dataCategory = 'dataCatagoryId__c';
        String expectedUrl = domain + 'dcGroupId%3AdataCatagoryId';

        System.assertEquals(expectedUrl, TopFiveArticleController.getMoreArticlesUrl(dcGroup, dataCategory));
    }

    @isTest
    private static void verifySandbox() {
        Boolean expected = [SELECT IsSandbox FROM Organization].IsSandbox;
        Boolean suspected = TopFiveArticleController.isSandbox();
        System.assertEquals(expected, suspected);
    }
}
