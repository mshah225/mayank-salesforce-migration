@isTest
public class Test_AKBController 
{
    @testSetup static void setupData() 
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
            URLName = 'test-FAQ');
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
            URLName = 'testHowTo');
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
            URLName = 'testInfo');
        insert infoArticle;

        // publish the info
        infoArticle = [SELECT KnowledgeArticleId
                       FROM Informational__kav
                       WHERE Id = :infoArticle.id];
        KbManagement.PublishingService.publishArticle(infoArticle.KnowledgeArticleId, true);

        Profile p = [SELECT Id FROM Profile WHERE Name='ASU Community'];

        Contact testContact = ContactService.createTestContact();
        insert testContact;

        User testUser = UserService.createTestUser();
        testUser.ProfileId = p.Id;
        insert testUser;    
    }

    @isTest static void testAKBControllerFAQ() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'FAQ__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testUser)
        {
            AKBController akb = new AKBController();
            akb.getTitleKeyword();
            System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
        }
        Test.stopTest();
    }
    
    @isTest static void testAKBControllerInfo() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'Informational__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testUser)
        {
            AKBController akb = new AKBController();
            akb.getTitleKeyword();
            System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
        }
        Test.stopTest();
    }
    
    @isTest static void testAKBControllerHowTo() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'How_To__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testuser)
        {
            AKBController akb = new AKBController();
            akb.getTitleKeyword();
            System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
        }
        Test.stopTest();
    }

    @isTest static void testHelpfulYes() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'FAQ__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testuser)
        {
            AKBController akb = new AKBController();
            PageReference expected = new PageReference('/akb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id'));
            System.AssertEquals(expected.getUrl(), akb.helpfulYes().getUrl());

            articleTest = [SELECT KnowledgeArticleId 
                           FROM KnowledgeArticleVersion 
                           WHERE PublishStatus = 'Online' 
                           AND Language = 'en_US' 
                           AND ArticleType = 'How_To__kav' 
                           LIMIT 1];
            testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
            testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            akbPage = Page.akb;
            Test.setCurrentPage(akbPage);
            ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
            akb = new AKBController();
            expected = new PageReference('/akb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id'));
            System.AssertEquals(expected.getUrl(), akb.helpfulYes().getUrl());

            articleTest = [SELECT KnowledgeArticleId 
                           FROM KnowledgeArticleVersion 
                           WHERE PublishStatus = 'Online' 
                           AND Language = 'en_US' 
                           AND ArticleType = 'Informational__kav' 
                           LIMIT 1];
            testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
            testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            akbPage = Page.akb;
            Test.setCurrentPage(akbPage);
            ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
            akb = new AKBController();
            expected = new PageReference('/akb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id'));
            System.AssertEquals(expected.getUrl(), akb.helpfulYes().getUrl());
        }
        Test.stopTest();
    }

    @isTest static void testHelpfulNo() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'FAQ__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testuser)
        {
            AKBController akb = new AKBController();
            akb.feedbackHelpful.comments__c = 'test';
            PageReference expected = new PageReference('/akb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id'));
            System.AssertEquals(expected.getUrl(), akb.helpfulNo().getUrl());

            articleTest = [SELECT KnowledgeArticleId 
                           FROM KnowledgeArticleVersion 
                           WHERE PublishStatus = 'Online' 
                           AND Language = 'en_US' 
                           AND ArticleType = 'How_To__kav' 
                           LIMIT 1];
            testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
            testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            akbPage = Page.akb;
            Test.setCurrentPage(akbPage);
            ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
            akb = new AKBController();
            akb.feedbackHelpful.comments__c = 'test';
            expected = new PageReference('/akb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id'));
            System.AssertEquals(expected.getUrl(), akb.helpfulNo().getUrl());

            articleTest = [SELECT KnowledgeArticleId 
                           FROM KnowledgeArticleVersion 
                           WHERE PublishStatus = 'Online' 
                           AND Language = 'en_US' 
                           AND ArticleType = 'Informational__kav' 
                           LIMIT 1];
            testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
            testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            akbPage = Page.akb;
            Test.setCurrentPage(akbPage);
            ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
            akb = new AKBController();
            akb.feedbackHelpful.comments__c = 'test';
            expected = new PageReference('/akb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id'));
            System.AssertEquals(expected.getUrl(), akb.helpfulNo().getUrl());
        }
        Test.stopTest();
    }

    @isTest static void testFeedbackVisible() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'FAQ__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testUser)
        {
            AKBController akb = new AKBController();
            akb.getfeedbackVisible();
            akb.contactId = null;
            akb.getfeedbackVisible();
            System.assertEquals(true, akb.getfeedbackVisible());
        }
        Test.stopTest();    
    }

    @isTest static void testFeedbackNotVisible() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'FAQ__kav' 
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testUser)
        {
            AKBController akb = new AKBController();
            akb.feedbackHelpful.Article_Id__c = articleTest[0].Id;
            akb.feedbackHelpful.Contact__c = testContact.Id;
            akb.helpfulYes();
            System.AssertEquals(false, akb.getfeedbackVisible());
        }   
        Test.stopTest();
    }

    @isTest static void testChangeLinks() 
    {
        List<KnowledgeArticleVersion> articleTest = [SELECT KnowledgeArticleId 
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE PublishStatus = 'Online' 
                                                     AND Language = 'en_US' 
                                                     AND ArticleType = 'FAQ__kav' 
                                                     AND Title = 'testFAQ'
                                                     LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'test.user@test.example.com' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.akb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();
        System.runAs(testUser)
        {
            AKBController akb = new AKBController();
            akb.urlsJSON = '["test-FAQ"]';
            String fixedIdLink = '["/akb?id=' + articleTest[0].KnowledgeArticleId + '"]';
            akb.changeLink();
            akb.getContactId();
            System.AssertEquals(fixedIdLink, akb.fixedLinksJSON);
        }   
        Test.stopTest();
    }
}