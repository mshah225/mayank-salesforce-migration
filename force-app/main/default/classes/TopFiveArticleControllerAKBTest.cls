@isTest
private class TopFiveArticleControllerAKBTest {
    private final static Map<String, Map<String, String>> dateCategoryGrpToLabelValueMp = new Map<String, Map<String, String>>{
        'Academics' => new Map<String, String>{
            'Classes' => 'My_ASU_Classes',
            'Programs and eAdvisor' => 'My_ASU_Programs_and',
            'Application Status' => 'My_ASU_Application'
        },
        'Campus_Services' => new Map<String, String>{ 'Devil2Devil' => 'My_ASU_Devil2Devil' },
        'Finances' => new Map<String, String>{
            'Account Charges' => 'My_ASU_Account_Charges',
            'Financial Aid and Scholarships' => 'My_ASU_Financial_Aid'
        }
    };

    @testSetup
    private static void setup() {
        List<FAQ__kav> faqArticles = new List<FAQ__kav>();
        Map<String, Map<String, String>> faqTitleToDcGrpAndVal = new Map<String, Map<String, String>>();

        // Create 5 artciles for each data category
        for (String dcGroupName : dateCategoryGrpToLabelValueMp.keySet()) {
            for (String dcName : dateCategoryGrpToLabelValueMp.get(dcGroupName).keySet()) {
                for (Integer i = 0; i < 5; i++) {
                    String dcVal = dateCategoryGrpToLabelValueMp.get(dcGroupName).get(dcName);
                    String uniqueURLName = 'Top5-Testing-FAQ-' + dcVal + '-' + i + '-' + System.currentTimeMillis();
                    uniqueURLName = uniqueURLName.replaceAll('[^a-zA-Z0-9-]', '');

                    FAQ__kav faqArticle = new FAQ__kav(
                        Title = dcVal + ' ' + i,
                        Summary = 'Test FAQ From Apex ' + i,
                        Answer__c = 'TEST ' + i,
                        Language = 'en_US',
                        IsVisibleInPKB = true,
                        IsVisibleInCsp = true,
                        IsVisibleInPrm = true,
                        URLName = uniqueURLName
                    );

                    faqArticles.add(faqArticle);

                    Map<String, String> dcGroupValMp = new Map<String, String>();
                    dcGroupValMp.put(dcGroupName, dcVal);
                    faqTitleToDcGrpAndVal.put(faqArticle.Title, dcGroupValMp);
                }
            }
        }
        insert faqArticles;
        faqArticles = [
            SELECT Id, Title, KnowledgeArticleId
            FROM FAQ__kav
            WHERE Id IN :new Map<Id, FAQ__kav>(faqArticles).keySet()
        ];

        // Publish each FAQ article
        for (FAQ__kav faqArticle : faqArticles) {
            KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
        }

        // Data Category selections for each FAQ article
        List<FAQ__DataCategorySelection> dcSelections = new List<FAQ__DataCategorySelection>();
        for (FAQ__kav faqArticle : faqArticles) {
            Map<String, String> dcGroupValMp = faqTitleToDcGrpAndVal.get(faqArticle.Title);

            String dcGroupName = new List<String>(dcGroupValMp.keySet())[0];
            String dcName = dcGroupValMp.get(dcGroupName);

            FAQ__DataCategorySelection faqDCS = new FAQ__DataCategorySelection(
                ParentId = faqArticle.Id,
                DataCategoryGroupName = dcGroupName,
                DataCategoryName = dcName
            );
            dcSelections.add(faqDCS);
            System.debug(faqDCS);
        }
        insert dcSelections;
    }

    @isTest
    private static void correctlyBuildsArticles() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        List<KnowledgeArticleVersion> expectedTop5Classes = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Academics__c AT My_ASU_Classes__c
        ];
        Assert.areEqual(
            5,
            expectedTop5Classes.size(),
            'Test setup expects only 5 My_ASU_Classes__c records to be created'
        );

        Test.startTest();
        RestContext.request.requestURI = System.URL.getOrgDomainUrl() + '/services/apexrest/TopFiveArticlesAKB';
        RestContext.request.httpMethod = 'POST';

        TopFiveArticleControllerAKB.getTopFiveArticles('Classes');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5Classes = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Test.stopTest();

        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );
        Assert.areEqual(expectedTop5Classes.size(), actualTop5Classes.size(), 'Returned wrong number of articles');
        for (KnowledgeArticleVersion kav : expectedTop5Classes) {
            TopFiveArticleControllerAKB.ArticleInfo matchedArticle = null;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5Classes)
                if (artInfo.id == kav.KnowledgeArticleId)
                    matchedArticle = artInfo;
            Assert.areNotEqual(null, matchedArticle, 'Missing expected article, id=' + kav.KnowledgeArticleId);
            Assert.areEqual(
                TopFiveArticleControllerAKB.getUrlPrefix() + '/authkb?id=' + kav.KnowledgeArticleId,
                matchedArticle.url,
                'Incorrectly generated URL'
            );
        }
    }

    @isTest
    private static void testGetByDataCategoryListName() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        List<KnowledgeArticleVersion> expectedTop5Classes = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Academics__c AT My_ASU_Classes__c
        ];
        List<KnowledgeArticleVersion> expectedTop5Programs = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Academics__c AT My_ASU_Programs_and__c
        ];
        List<KnowledgeArticleVersion> expectedTop5ApplStatus = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Academics__c AT My_ASU_Application__c
        ];
        List<KnowledgeArticleVersion> expectedTop5Devil2Devil = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Campus_Services__c AT My_ASU_Devil2Devil__c
        ];
        List<KnowledgeArticleVersion> expectedTop5AcctCharges = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Finances__c AT My_ASU_Account_Charges__c
        ];
        List<KnowledgeArticleVersion> expectedTop5FinAid = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Finances__c AT My_ASU_Financial_Aid__c
        ];

        Assert.areEqual(5, expectedTop5Classes.size(), 'Failed test prereq');
        Assert.areEqual(5, expectedTop5Programs.size(), 'Failed test prereq');
        Assert.areEqual(5, expectedTop5ApplStatus.size(), 'Failed test prereq');
        Assert.areEqual(5, expectedTop5Devil2Devil.size(), 'Failed test prereq');
        Assert.areEqual(5, expectedTop5AcctCharges.size(), 'Failed test prereq');
        Assert.areEqual(5, expectedTop5FinAid.size(), 'Failed test prereq');

        Test.startTest();
        RestContext.request.requestURI = System.URL.getOrgDomainUrl() + '/services/apexrest/TopFiveArticlesAKB';
        RestContext.request.httpMethod = 'POST';

        TopFiveArticleControllerAKB.getTopFiveArticles('Classes');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5Classes = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        TopFiveArticleControllerAKB.getTopFiveArticles('Programs and eAdvisor');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5Programs = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        TopFiveArticleControllerAKB.getTopFiveArticles('Application Status');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5ApplStatus = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        TopFiveArticleControllerAKB.getTopFiveArticles('Devil2Devil');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5Devil2Devil = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        TopFiveArticleControllerAKB.getTopFiveArticles('Account Charges');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5AcctCharges = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        TopFiveArticleControllerAKB.getTopFiveArticles('Financial Aid and Scholarships');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5FinAid = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );
        Test.stopTest();

        Assert.areEqual(expectedTop5Classes.size(), actualTop5Classes.size());
        for (KnowledgeArticleVersion kav : expectedTop5Classes) {
            Boolean found = false;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5Classes)
                if (artInfo.id == kav.KnowledgeArticleId)
                    found = true;
            Assert.isTrue(found, 'Missing expected article, id=' + kav.KnowledgeArticleId);
        }

        Assert.areEqual(expectedTop5Programs.size(), actualTop5Programs.size());
        for (KnowledgeArticleVersion kav : expectedTop5Programs) {
            Boolean found = false;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5Programs)
                if (artInfo.id == kav.KnowledgeArticleId)
                    found = true;
            Assert.isTrue(found, 'Missing expected article, id=' + kav.KnowledgeArticleId);
        }

        Assert.areEqual(expectedTop5ApplStatus.size(), actualTop5ApplStatus.size());
        for (KnowledgeArticleVersion kav : expectedTop5ApplStatus) {
            Boolean found = false;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5ApplStatus)
                if (artInfo.id == kav.KnowledgeArticleId)
                    found = true;
            Assert.isTrue(found, 'Missing expected article, id=' + kav.KnowledgeArticleId);
        }

        Assert.areEqual(expectedTop5Devil2Devil.size(), actualTop5Devil2Devil.size());
        for (KnowledgeArticleVersion kav : expectedTop5Devil2Devil) {
            Boolean found = false;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5Devil2Devil)
                if (artInfo.id == kav.KnowledgeArticleId)
                    found = true;
            Assert.isTrue(found, 'Missing expected article, id=' + kav.KnowledgeArticleId);
        }

        Assert.areEqual(expectedTop5AcctCharges.size(), actualTop5AcctCharges.size());
        for (KnowledgeArticleVersion kav : expectedTop5AcctCharges) {
            Boolean found = false;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5AcctCharges)
                if (artInfo.id == kav.KnowledgeArticleId)
                    found = true;
            Assert.isTrue(found, 'Missing expected article, id=' + kav.KnowledgeArticleId);
        }

        Assert.areEqual(expectedTop5FinAid.size(), actualTop5FinAid.size());
        for (KnowledgeArticleVersion kav : expectedTop5FinAid) {
            Boolean found = false;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5FinAid)
                if (artInfo.id == kav.KnowledgeArticleId)
                    found = true;
            Assert.isTrue(found, 'Missing expected article, id=' + kav.KnowledgeArticleId);
        }
    }

    @isTest
    private static void testGetByDataCategoryBackslash() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        List<KnowledgeArticleVersion> expectedTop5Classes = [
            SELECT Id, Title, KnowledgeArticleId
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online' AND language = 'en_US'
            WITH DATA CATEGORY Academics__c AT My_ASU_Classes__c
        ];
        Assert.areEqual(
            5,
            expectedTop5Classes.size(),
            'Test setup expects only 5 My_ASU_Classes__c records to be created'
        );

        Test.startTest();
        RestContext.request.requestURI = System.URL.getOrgDomainUrl() + '/services/apexrest/TopFiveArticlesAKB';
        RestContext.request.httpMethod = 'POST';
        TopFiveArticleControllerAKB.getTopFiveArticles('Academics__c\\My_ASU_Classes__c');
        List<TopFiveArticleControllerAKB.ArticleInfo> actualTop5Classes = (List<TopFiveArticleControllerAKB.ArticleInfo>) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            List<TopFiveArticleControllerAKB.ArticleInfo>.class
        );
        Test.stopTest();

        Assert.areEqual(200, RestContext.response.statusCode, 'Must return 200 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );
        Assert.areEqual(expectedTop5Classes.size(), actualTop5Classes.size(), 'Returned wrong number of articles');
        for (KnowledgeArticleVersion kav : expectedTop5Classes) {
            TopFiveArticleControllerAKB.ArticleInfo matchedArticle = null;
            for (TopFiveArticleControllerAKB.ArticleInfo artInfo : actualTop5Classes)
                if (artInfo.id == kav.KnowledgeArticleId)
                    matchedArticle = artInfo;
            Assert.areNotEqual(null, matchedArticle, 'Missing expected article, id=' + kav.KnowledgeArticleId);
            Assert.areEqual(
                TopFiveArticleControllerAKB.getUrlPrefix() + '/authkb?id=' + kav.KnowledgeArticleId,
                matchedArticle.url,
                'Incorrectly generated URL'
            );
        }
    }

    @isTest
    private static void testGetByDataCategoryInvalidDataCategory() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        RestContext.request.requestURI = System.URL.getOrgDomainUrl() + '/services/apexrest/TopFiveArticlesAKB';
        RestContext.request.httpMethod = 'POST';
        TopFiveArticleControllerAKB.getTopFiveArticles('Academics__c\\Classes');
        Test.stopTest();

        Assert.areEqual(500, RestContext.response.statusCode, 'Must return 500 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case];
        Assert.isTrue(!errorLoggerCase.isEmpty(), 'Expected error logger case to have been created');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('Academics__c\\Classes'),
            'Expected to error logger description to include request listName, but it instead said "' +
                errorLoggerCase[0].Description +
                '"'
        );
    }

    @isTest
    private static void testGetByDataCategoryIllegalCharacters() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        RestContext.request.requestURI = System.URL.getOrgDomainUrl() + '/services/apexrest/TopFiveArticlesAKB';
        RestContext.request.httpMethod = 'POST';
        TopFiveArticleControllerAKB.getTopFiveArticles('Herberger Institute__c\\Herberger_Institute__c');
        Test.stopTest();

        Assert.areEqual(500, RestContext.response.statusCode, 'Must return 500 status code');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            RestContext.response.headers.get('Content-Type'),
            'Must return application/json header'
        );

        List<Case> errorLoggerCase = [SELECT Id, Subject, Description FROM Case];
        Assert.isTrue(!errorLoggerCase.isEmpty(), 'Expected error logger case to have been created');
        Assert.isTrue(
            errorLoggerCase[0].Description.contains('Herberger Institute__c\\Herberger_Institute__c'),
            'Expected to error logger description to include request listName, but it instead said "' +
                errorLoggerCase[0].Description +
                '"'
        );
    }
}
