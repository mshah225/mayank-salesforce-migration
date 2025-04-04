@isTest
public class AKBControllerTest {
    public static User testUser;

    /**
     * Sets up test data including FAQ articles, terms, contacts, users, and live agent buttons.
     */
    static void setupData() {
        List<FAQ__kav> faqArticles = new List<FAQ__kav>();
        for (Integer i = 0; i < 30; i++) {
            FAQ__kav faqArticle = new FAQ__kav(
                Title = 'Testing FAQ Article' + i,
                Summary = 'Test FAQ From Apex' + i,
                Answer__c = 'TEST' + i,
                Language = 'en_US',
                IsVisibleInApp = true,
                IsVisibleInPkb = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                PublishStatus = 'Online',
                ValidationStatus = 'Published',
                RecordTypeId = Schema.SObjectType.FAQ__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId(),
                UrlName = 'akbController-Test-Article-' + i
            );
            faqArticles.add(faqArticle);
        }
        insert faqArticles;

        for (FAQ__kav faqArticle : faqArticles) {
            KbManagement.PublishingService.publishArticle(
                [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :faqArticle.Id].KnowledgeArticleId,
                true
            );
        }

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];

        Term__c termAC = new Term__c(
            Session_A_C_Start_Date__c = Date.today().addDays(365),
            Year__c = String.valueOf(Date.today().addDays(365).year())
        );
        insert termAC;

        Term__c termB = new Term__c(
            Session_B_Start_Date__c = Date.today().addDays(405),
            Year__c = String.valueOf(Date.today().addDays(405).year())
        );
        insert termB;

        Contact testContact = ContactService.createTestContact();
        insert testContact;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        testUser = (User) userCreator.create(1)[0];
        testUser.ProfileId = profile.Id;
        testUser.ContactId = testContact.Id;
        testUser.UserPermissionsKnowledgeUser = true;
        insert testUser;

        List<Live_Agent_Button__c> buttonsToInsert = new List<Live_Agent_Button__c>{
            new Live_Agent_Button__c(
                Name = 'Finances_Live_Chat',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat'
            ),
            new Live_Agent_Button__c(
                Name = 'ASU_Services_Live_Chat',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat'
            ),
            new Live_Agent_Button__c(
                Name = 'Technical_Support_Live_Chat',
                Chat_Endpoint__c = 'https://d.la4-c1cs-phx.salesforceliveagent.com/chat'
            )
        };
        insert buttonsToInsert;
    }

    /**
     * Tests the functionality of AKBController with FAQ articles.
     */
    @isTest
    static void testAKBControllerFAQ() {
        Test.startTest();
        setupData();

        FAQ__kav articleTest = [
            SELECT Title, KnowledgeArticleId
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND RecordType.Name = 'FAQ'
            LIMIT 1
        ];

        System.assertNotEquals(null, articleTest, 'Article test record is null');

        Test.setCurrentPage(Page.authkb);
        ApexPages.currentPage().getParameters().put('id', articleTest.KnowledgeArticleId);

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            String titleKeyword = akb.getTitleKeyword();
            System.assertEquals(articleTest.Title, titleKeyword);
            System.assertEquals(akb.article.KnowledgeArticleId, articleTest.KnowledgeArticleId);
        }
        Test.stopTest();
    }

    /**
     * Tests the functionality of the helpfulYes method in AKBController.
     */
    @isTest
    static void testHelpfulYes() {
        Test.startTest();
        setupData();

        FAQ__kav articleTest = [
            SELECT KnowledgeArticleId, ArticleNumber, Title, CreatedBy.Name, Functional_Group__c, RecordType.Name
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND RecordType.Name = 'FAQ'
            LIMIT 1
        ];

        System.assertNotEquals(null, articleTest, 'Article test record is null');

        Test.setCurrentPage(Page.authkb);
        ApexPages.currentPage().getParameters().put('id', articleTest.KnowledgeArticleId);

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            PageReference result = akb.helpfulYes();
            System.assertEquals('/authkb?Feedback=yes&id=' + articleTest.KnowledgeArticleId, result.getUrl());

            AKB_Article_Feedback__c feedback = [
                SELECT Article_Id__c, Helpful__c
                FROM AKB_Article_Feedback__c
                WHERE Contact__c = :testUser.ContactId AND Article_Id__c = :articleTest.KnowledgeArticleId
                LIMIT 1
            ];
            System.assertEquals(true, feedback.Helpful__c);
        }
        Test.stopTest();
    }

    /**
     * Tests the functionality of the helpfulNo method in AKBController.
     */
    @isTest
    static void testHelpfulNo() {
        Test.startTest();
        setupData();

        FAQ__kav articleTest = [
            SELECT KnowledgeArticleId, ArticleNumber, Title, CreatedBy.Name, Functional_Group__c, RecordType.Name
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND RecordType.Name = 'FAQ'
            LIMIT 1
        ];

        System.assertNotEquals(null, articleTest, 'Article test record is null');

        Test.setCurrentPage(Page.authkb);
        ApexPages.currentPage().getParameters().put('id', articleTest.KnowledgeArticleId);

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.feedbackHelpful.Comments__c = 'test';
            PageReference result = akb.helpfulNo();
            System.assertEquals('/authkb?Feedback=yes&id=' + articleTest.KnowledgeArticleId, result.getUrl());

            AKB_Article_Feedback__c feedback = [
                SELECT Article_Id__c, Helpful__c, Comments__c
                FROM AKB_Article_Feedback__c
                WHERE Contact__c = :testUser.ContactId AND Article_Id__c = :articleTest.KnowledgeArticleId
                LIMIT 1
            ];
            System.assertEquals(false, feedback.Helpful__c);
            System.assertEquals('test', feedback.Comments__c);
        }
        Test.stopTest();
    }

    /**
     * Tests the visibility of feedback in AKBController.
     */
    @isTest
    static void testFeedbackVisible() {
        Test.startTest();
        setupData();

        FAQ__kav articleTest = [
            SELECT KnowledgeArticleId
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND RecordType.Name = 'FAQ'
            LIMIT 1
        ];

        System.assertNotEquals(null, articleTest, 'Article test record is null');

        Test.setCurrentPage(Page.authkb);
        ApexPages.currentPage().getParameters().put('id', articleTest.KnowledgeArticleId);

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            Boolean isVisible = akb.getFeedbackVisible();
            System.assertEquals(true, isVisible);
        }
        Test.stopTest();
    }

    /**
     * Tests the non-visibility of feedback in AKBController.
     */
    @isTest
    static void testFeedbackNotVisible() {
        Test.startTest();
        setupData();

        FAQ__kav articleTest = [
            SELECT KnowledgeArticleId, ArticleNumber, Title, CreatedBy.Name, Functional_Group__c, RecordType.Name
            FROM FAQ__kav
            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND RecordType.Name = 'FAQ'
            LIMIT 1
        ];

        System.assertNotEquals(null, articleTest, 'Article test record is null');

        Test.setCurrentPage(Page.authkb);
        ApexPages.currentPage().getParameters().put('id', articleTest.KnowledgeArticleId);

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.feedbackHelpful.Article_Id__c = articleTest.KnowledgeArticleId;
            akb.feedbackHelpful.Contact__c = testUser.ContactId;
            akb.helpfulYes();
            Boolean isVisible = akb.getFeedbackVisible();
            System.assertEquals(false, isVisible);
        }
        Test.stopTest();
    }

    /**
     * Tests the functionality of the changeLinks method in AKBController.
     */
    @isTest
    static void testChangeLinks() {
        Test.startTest();
        setupData();

        FAQ__kav articleTest = [
            SELECT KnowledgeArticleId
            FROM FAQ__kav
            WHERE
                PublishStatus = 'Online'
                AND Language = 'en_US'
                AND RecordType.Name = 'FAQ'
                AND Title = 'Testing FAQ Article4'
            LIMIT 1
        ];

        System.assertNotEquals(null, articleTest, 'Article test record is null');

        Test.setCurrentPage(Page.authkb);
        ApexPages.currentPage().getParameters().put('id', articleTest.KnowledgeArticleId);

        System.runAs(testUser) {
            MyASUHelpController sc = new MyASUHelpController();
            AKBController akb = new AKBController(sc);
            akb.urlsJSON = '["akbController-Test-Article-4"]';
            akb.changeLink();
            String fixedIdLink = '["/authkb?id=' + articleTest.KnowledgeArticleId + '"]';
            System.assertEquals(fixedIdLink, akb.fixedLinksJSON);
        }
        Test.stopTest();
    }
}