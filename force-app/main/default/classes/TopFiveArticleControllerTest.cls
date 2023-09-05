@isTest(SeeAllData=true)
public with sharing class TopFiveArticleControllerTest {
    private static Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox == true ? true : false;
    private static String sandboxInstance = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
    private static String sandboxName = UserInfo.getUserName().substringAfterLast('.');

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
        if (isSandbox) {
            domain = 'http://' + sandboxName + '-asu' + '.' + sandboxInstance + '.force.com/kb/articles/';
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
        if (isSandbox) {
            domain = 'http://' + sandboxName + '-asu' + '.' + sandboxInstance + '.force.com/kb/pkb_Home?l=en_US&c=';
        } else {
            domain = 'https://asu.secure.force.com/kb/pkb_Home?l=en_US&c=';
        }

        String dcGroup = 'dcGroupId__c';
        String dataCategory = 'dataCatagoryId__c';
        String expectedUrl = domain + 'dcGroupId%3AdataCatagoryId';

        System.assertEquals(expectedUrl, TopFiveArticleController.getMoreArticlesUrl(dcGroup, dataCategory));
    }
}