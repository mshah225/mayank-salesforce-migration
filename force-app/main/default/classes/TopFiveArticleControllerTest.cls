/**
 * Unit tests for TopFiveArticleController class.
 */
@IsTest(SeeAllData=true)
public with sharing class TopFiveArticleControllerTest {
    // Check if the current environment is a sandbox
    private static Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;

    // Retrieve the instance name of the current environment
    private static String sandboxInstance = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;

    // Retrieve the sandbox name from the current user's username
    private static String sandboxName = UserInfo.getUserName().substringAfterLast('.');

    /**
     * Tests the methods that retrieve the top five articles.
     */
    @IsTest
    private static void testDoGet() {
        TopFiveArticleController.getTopFiveArticles();
        TopFiveArticleController.getTopFiveArticles2('Classes');
        TopFiveArticleController.getTopFiveArticles2('Programs and eAdvisor');
        TopFiveArticleController.getTopFiveArticles2('Application Status');
        TopFiveArticleController.getTopFiveArticles2('Devil2Devil');
        TopFiveArticleController.getTopFiveArticles2('Account Charges');
        TopFiveArticleController.getTopFiveArticles2('Financial Aid and Scholarships');
    }

    /**
     * Tests the method that generates the article URL.
     */
    @IsTest
    private static void checkArticleUrl() {
        FAQ__kav kav1 = null;
        FAQ__kav kav2 = null;
        FAQ__kav kav3 = null;
        FAQ__kav kavX = null;

        // Retrieve FAQ__kav records and categorize them based on their Id prefix
        for (FAQ__kav kav : [SELECT Id, UrlName FROM FAQ__kav]) {
            String articleIdPrefix = String.valueOf(kav.Id).substring(0, 3);
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

        // Prepare the base domain URL
        String domain = System.URL.getOrgDomainUrl().toExternalForm();
        domain = domain.replace('salesforce.com', 'salesforce-site.com');
        domain += '/kb/articles/';

        // Assert the generated URL for different article types
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

    /**
     * Tests the method that generates the URL for more articles.
     */
    @IsTest
    private static void checkMoreArticleTransformation() {
        String domain = System.URL.getOrgDomainUrl().toExternalForm();
        domain = domain.replace('salesforce.com', 'salesforce-site.com');
        domain += '/kb/pkb_Home?l=en_US&c=';

        String dcGroup = 'dcGroupId__c';
        String dataCategory = 'dataCategoryId__c';
        String expectedUrl = domain + 'dcGroupId%3AdataCategoryId';

        System.assertEquals(expectedUrl, TopFiveArticleController.getMoreArticlesUrl(dcGroup, dataCategory));
    }
}