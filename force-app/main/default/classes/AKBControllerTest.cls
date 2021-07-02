@isTest
public class AKBControllerTest {
    public static User testUser;

    static void setupData() {
        for (Integer i = 0; i < 30; i++) {
            FAQ__kav faqArticle = new FAQ__kav(
                Title = 'Testing FAQ Article' + i,
                Summary = 'Test FAQ From Apex' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                IsVisibleInPKB = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                URLName = 'akbController-Test-Article-' + i
            );

            insert faqArticle;

            // Publish the FAQ Articles
            faqArticle = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :faqArticle.id];

            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
        }

        Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];

        Term__c termAC = new Term__c();
        Date dTac = Date.today().adddays(365);
        Date dTb = Date.today().adddays(405);
        termAC.Session_A_C_Start_Date__c = date.newinstance(dTac.year(), dTac.month(), dTac.day());
        String ACYear = String.valueOf(dTac.year());
        termAC.Year__c = ACYear;

        insert termAC;

        Term__c termB = new Term__c();
        termB.Session_B_Start_Date__c = date.newinstance(dTb.year(), dTb.month(), dTb.day());
        String BYear = String.valueOf(dTb.year());
        termB.Year__c = BYear;

        insert termB;

        Service_Center_Maintenance__c scm = new Service_Center_Maintenance__c(
            Name = 'The Test Message',
            Displayed__c = true,
            Message__c = 'There is maintenance'
        );
        insert scm;

        Contact testContact = ContactService.createTestContact();

        insert testContact;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        testUser = (User) userCreator.create(1)[0];
        testUser.ProfileId = p.Id;
        testUser.ContactId = testContact.Id;

        insert testUser;

        List<Live_Agent_Button__c> buttonsToInsert = new List<Live_Agent_Button__c>();
        buttonsToInsert.add(new Live_Agent_Button__c(Name = 'Finances_Live_Chat'));
        buttonsToInsert.add(new Live_Agent_Button__c(Name = 'ASU_Services_Live_Chat'));
        buttonsToInsert.add(new Live_Agent_Button__c(Name = 'Technical_Support_Live_Chat'));

        insert buttonsToInsert;
    }

    @isTest
    static void testAKBControllerFAQ() {
        setupData();
        List<KnowledgeArticleVersion> articleTest = [
            SELECT KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
            LIMIT 1
        ];

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.authkb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);

        Test.startTest();

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.getTitleKeyword();
            System.AssertEquals(akb.article.KnowledgeArticleId, articleTest[0].KnowledgeArticleId);
        }

        Test.stopTest();
    }

    @isTest
    static void testHelpfulYes() {
        setupData();
        List<KnowledgeArticleVersion> articleTest = [
            SELECT KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
            LIMIT 1
        ];

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.authkb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);

        Test.startTest();

        System.runAs(testuser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            PageReference expected = new PageReference(
                '/authkb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id')
            );
            System.AssertEquals(expected.getUrl(), akb.helpfulYes().getUrl());

            articleTest = [
                SELECT KnowledgeArticleId
                FROM KnowledgeArticleVersion
                WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
                LIMIT 1
            ];

            testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            akbPage = Page.authkb;
            Test.setCurrentPage(akbPage);
            ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
            akb = new AKBController(sc);
            expected = new PageReference(
                '/authkb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id')
            );
            System.AssertEquals(expected.getUrl(), akb.helpfulYes().getUrl());
        }

        Test.stopTest();
    }

    @isTest
    static void testHelpfulNo() {
        setupData();
        List<KnowledgeArticleVersion> articleTest = [
            SELECT KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
            LIMIT 1
        ];

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.authkb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);

        Test.startTest();

        System.runAs(testuser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.feedbackHelpful.comments__c = 'test';
            PageReference expected = new PageReference(
                '/authkb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id')
            );
            System.AssertEquals(expected.getUrl(), akb.helpfulNo().getUrl());

            articleTest = [
                SELECT KnowledgeArticleId
                FROM KnowledgeArticleVersion
                WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
                LIMIT 1
            ];

            testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            akbPage = Page.authkb;
            Test.setCurrentPage(akbPage);
            ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
            akb = new AKBController(sc);
            akb.feedbackHelpful.comments__c = 'test';
            expected = new PageReference(
                '/authkb?Feedback=yes&id=' + ApexPages.currentPage().getParameters().get('id')
            );
            System.AssertEquals(expected.getUrl(), akb.helpfulNo().getUrl());
        }

        Test.stopTest();
    }

    @isTest
    static void testFeedbackVisible() {
        setupData();
        List<KnowledgeArticleVersion> articleTest = [
            SELECT KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
            LIMIT 1
        ];

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.authkb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);

        Test.startTest();

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.getfeedbackVisible();
            akb.userContact = testContact;
            System.assertEquals(true, akb.getfeedbackVisible());
        }

        Test.stopTest();
    }

    @isTest
    static void testFeedbackNotVisible() {
        setupData();
        List<KnowledgeArticleVersion> articleTest = [
            SELECT KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND ArticleType = 'FAQ__kav'
            LIMIT 1
        ];

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.authkb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);

        Test.startTest();

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.feedbackHelpful.Article_Id__c = articleTest[0].Id;
            akb.feedbackHelpful.Contact__c = testContact.Id;
            akb.helpfulYes();
            System.AssertEquals(false, akb.getfeedbackVisible());
        }

        Test.stopTest();
    }

    @isTest
    static void testChangeLinks() {
        setupData();
        List<KnowledgeArticleVersion> articleTest = [
            SELECT KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE
                PublishStatus = 'Online'
                AND Language = 'en_US'
                AND ArticleType = 'FAQ__kav'
                AND Title = 'Testing FAQ Article4'
            LIMIT 1
        ];

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        PageReference akbPage = Page.authkb;
        Test.setCurrentPage(akbPage);
        ApexPages.currentPage().getParameters().put('id', articleTest[0].KnowledgeArticleId);
        Test.startTest();

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.urlsJSON = '["akbController-Test-Article-4"]';
            String fixedIdLink = '["/authkb?id=' + articleTest[0].KnowledgeArticleId + '"]';
            akb.changeLink();
            System.AssertEquals(fixedIdLink, akb.fixedLinksJSON);
        }

        Test.stopTest();
    }
}
