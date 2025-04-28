/**
 * Unit tests for pkb_Controller and pkb_SettingsController.
 */
@IsTest
private class pkb_ControllerTest {
    static String siteName = 'PKB_TEST_' + String.valueOf(Crypto.getRandomInteger());
    static String publishStatus = 'Online';
    static String lang = 'en_US';
    static PKB__c pkb;
    static SObject kavObj;
    static String objType;
    static PKB_Featured__c featured;
    static PKB_Featured__c keyword;
    static List<PKB_Article_Feedback_Deflection__c> pafds;

    /**
     * Custom exception class for test purposes.
     */
    class TestException extends Exception {
    }

    /**
     * Tests the pkb_Controller class.
     */
    @IsTest
    private static void testController() {
        setupData();
        setupSettingsData();
        Id kaId = (Id) kavObj.get('KnowledgeArticleId');
        Id kavId = (Id) kavObj.get('Id');
        String articleNumber = (String) kavObj.get('ArticleNumber');
        String catString;

        Test.startTest();
        if (kavObj == null) {
            return;
        }

        List<String> searchResults = new List<String>{ keyword.Id, kavId };
        Test.setFixedSearchResults(searchResults);

        pkb_Controller refCon = new pkb_Controller();
        pkb_Controller pkbCon;
        PageReference p;

        p = new PageReference('/');
        Test.setCurrentPage(p);
        pkbCon = new pkb_Controller(new ApexPages.StandardController(new FAQ__ka()));
        System.assertNotEquals(pkbCon.publishStatus, null);

        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'foor');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.categoryParam, catString);
        Test.setCurrentPage(p);
        pkbCon = new pkb_Controller(new ApexPages.StandardController(new FAQ__ka()));
        pkbCon.prepareSearchRSS();

        p = new PageReference('/?id=' + kaId);
        Test.setCurrentPage(p);
        pkbCon = new pkb_Controller(new ApexPages.StandardController(new FAQ__ka(Id = kaId)));

        System.assertNotEquals(pkbCon.pageTitle, null);
        System.assertNotEquals(pkbCon.selectedLanguageURL, null);
        pkbCon.selectedCategory = 'foo';
        System.assertNotEquals(pkbCon.selectedCategoryLabel, null);
        pkbCon.selectedCategory = '';
        System.assert(!pkbCon.caseCreateError);
        System.assert(!pkbCon.caseCreated);
        System.assert(!pkbCon.feedbackRecorded);
        System.assertNotEquals(pkbCon.languageOptions, null);
        System.assertEquals(pkbCon.currPage, 1);
        pkbCon.nextPage();
        pkbCon.prevPage();
        System.assertEquals(pkbCon.currPage, 1);

        pkbCon.deferred();
        pafds = [
            SELECT Id, Session_ID__c
            FROM PKB_Article_Feedback_Deflection__c
            WHERE Article_Number__c = :articleNumber
        ];
        System.assert(pafds.size() == 1);

        pafds = [
            SELECT Id, Session_ID__c
            FROM PKB_Article_Feedback_Deflection__c
            WHERE Session_ID__c = :pkbCon.sessionId
        ];
        System.assert(pafds.size() == 1);

        p = new PageReference('/');
        p.getParameters().put('id', kaId);
        p.getParameters().put(refCon.contactUsParam, refCon.contactUsValue);
        Test.setCurrentPage(p);
        pkbCon = new pkb_Controller(new ApexPages.StandardController(new FAQ__ka(Id = kaId)));

        pkbCon.feedbackComments = 'some comments';
        pkbCon.recordArticleFeedback();
        pafds = [SELECT Id FROM PKB_Article_Feedback_Deflection__c WHERE Article_Number__c = :articleNumber];
        System.assert(pafds.size() == 2);

        pkbCon.contactUsDeferral();
        pafds = [SELECT Id FROM PKB_Article_Feedback_Deflection__c WHERE Article_Number__c = :articleNumber];
        System.assert(pafds.size() == 3);

        pkbCon.theCud.firstName = 'Foo';
        pkbCon.theCud.lastName = 'Bar';
        pkbCon.theCud.email = '';
        pkbCon.createCase();
        System.assert(pkbCon.caseCreateError);

        String validType = 'foo';
        if (!refCon.caseTypeOptions.isEmpty()) {
            for (SelectOption so : refCon.caseTypeOptions) {
                if (!isBlank(so.getValue())) {
                    validType = so.getValue();
                    break;
                }
            }
        }

        pkbCon.theCud.firstName = 'Foo';
        pkbCon.theCud.lastName = 'Bar';
        pkbCon.theCud.email = 'foo';
        pkbCon.theCud.reqType = validType;
        pkbCon.createCase();
        System.assert(pkbCon.caseCreateError);

        pkbCon.theCud.email = siteName + '@bar.com';
        pkbCon.createCase();
        System.assert(!pkbCon.caseCreateError);

        pkb.Create_Contact_and_Account__c = true;
        update pkb;
        pkbCon.createCase();

        pkbCon.siteAdmin = new User(FirstName = 'Test', LastName = 'Admin', Email = 'TestAdmin@foo.com');
        pkbCon.createCase();
        pkbCon.theCase = pkbCon.theCase.clone(false);
        pkbCon.theCud.firstName = '';
        pkbCon.theCud.lastName = '';
        pkbCon.theCud.email = null;
        pkbCon.insertRecords();
        System.assert(pkbCon.caseCreateError);

        pkb = PKB__c.getInstance(siteName);
        System.assert(pkb.Create_Contact_and_Account__c);

        pkbCon.theCase = pkbCon.theCase.clone(false);
        pkbCon.theCud.firstName = 'Foo';
        pkbCon.theCud.lastName = 'Bar';
        pkbCon.theCud.email = siteName + '@bar.com';
        pkbCon.theCud.reqType = validType;
        pkbCon.createCase();
        pkbCon.theCase.AccountId = '0013010101jQrdW'; // fake account number
        Test.stopTest();
        pkbCon.insertRecords();

        TestException e = new TestException('Test Exception!!');
        pkb_Controller.debugException(e);
        pkbCon.notifyAdmin(null, e, 'some message here');

        pkbCon.selectedCategory = null;
        System.assertEquals(pkbCon.buildCategorySosl(), null);
        pkbCon.selectedCategory = 'foo_t:bar';
        System.assertNotEquals(pkbCon.buildCategorySosl(), null);

        pkb_Controller.initFromListOfArticleIds(null, lang);
        pkb_Controller.initFromListOfArticleIds(new List<String>(), lang);
        pkb_Controller.initFromListOfArticleIds(new List<String>{ kaId }, lang);

        pkb_Controller.initFromListOfKAVIds(null, lang);
        pkb_Controller.initFromListOfKAVIds(new List<String>(), lang);
        pkb_Controller.initFromListOfKAVIds(new List<String>{ kavId }, lang);

        User u = pkb_Controller.getSiteAdmin();
    }

    /**
     * Tests the pkb_SettingsController class.
     */
    @IsTest
    private static void testSettingsController() {
        Test.startTest();
        setupSettingsData();
        Test.stopTest();
        pkb_SettingsController refCon = new pkb_SettingsController();
        pkb_SettingsController pkbsc;
        PageReference p;

        p = new PageReference('/?' + refCon.createSettingsParam + '=' + refCon.createSettingsValue);
        Test.setCurrentPage(p);
        pkbsc = new pkb_SettingsController(new ApexPages.StandardController(new PKB__c()));
        System.assert(pkbsc.creatingSettings);

        p = new PageReference('/?id=' + pkb.Id);
        Test.setCurrentPage(p);
        pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));
        System.assert(!pkbsc.creatingSettings);

        System.assert(!pkbsc.settingsOptions.isEmpty());

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);
        System.assert(pkbsc.settingsPicked);
        System.assert(pkbsc.settingsExist);

        pkb_ka__c test_pkb_ka = new pkb_ka__c();
        test_pkb_ka.Name = 'test_pkb_ka';
        test_pkb_ka.apiName__c = 'Test_API_Name_1';
        test_pkb_ka.layout__c = 'Test_Layout_1';
        test_pkb_ka.pkb__c = pkb.Id;
        insert test_pkb_ka;

        pkbsc.kaTypes =
            '[    {        "Id": "' +
            test_pkb_ka.Id +
            '",        "apiName__c": "Test_API_Name_1_changed",        "layout__c": "Test_Layout_1_changed"    },    {        "apiName__c": "Test_API_Name_2",        "layout__c": "Test_Layout_2"    }]        ';

        pkb_SettingsController.isRunningTest = true;
        p = pkbsc.saveSettings();
        System.assert(p.getUrl().contains(pkb.Id));

        List<pkb_ka__c> insertedRecords = [
            SELECT Id, Name, apiName__c, layout__c, pkb__c
            FROM pkb_ka__c
            WHERE pkb__c = :pkb.Id
        ];
        System.assertEquals(2, insertedRecords.size(), 'Expected two pkb_ka__c records to be inserted');
        System.assertEquals('Test_API_Name_1_changed', insertedRecords[0].apiName__c);
        System.assertEquals('Test_Layout_1_changed', insertedRecords[0].layout__c);
        System.assertEquals('Test_API_Name_2', insertedRecords[1].apiName__c);
        System.assertEquals('Test_Layout_2', insertedRecords[1].layout__c);
    }

    /**
     * Tests the CTI keywords in pkb_SettingsController.
     */
    @IsTest
    private static void testSettings_CTI_keywords() {
        Test.startTest();
        setupSettingsData();
        Test.stopTest();

        pkb_SettingsController refCon = new pkb_SettingsController();
        pkb_SettingsController pkbsc;
        PageReference p;

        p = new PageReference('/?id=' + pkb.Id);
        Test.setCurrentPage(p);
        pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));

        pkb.CTI_configuration__c = '';
        pkb.Add_Case_Id__c = false;

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);

        PKB__c updatedElm = null;
        Map<String, PKB__c> settingsMap = PKB__c.getAll();
        if (settingsMap.containsKey(pkb.Name)) {
            updatedElm = settingsMap.get(pkb.Name);
        }
        System.assertEquals(updatedElm.Add_Case_Id__c, pkb.Add_Case_Id__c);

        pkb.CTI_configuration__c = '[[[[[p]43';
        pkb.Add_Case_Id__c = true;

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);

        updatedElm = null;
        settingsMap = PKB__c.getAll();
        if (settingsMap.containsKey(pkb.Name)) {
            updatedElm = settingsMap.get(pkb.Name);
        }
        System.assertEquals(updatedElm.Add_Case_Id__c, false);

        pkb.CTI_configuration__c = '[P]3[CN]';
        pkb.Add_Case_Id__c = true;

        p = pkbsc.saveSettings();
        System.assertEquals(p, null);

        updatedElm = null;
        settingsMap = PKB__c.getAll();
        if (settingsMap.containsKey(pkb.Name)) {
            updatedElm = settingsMap.get(pkb.Name);
        }
        System.assertEquals(updatedElm.Add_Case_Id__c, false);
    }

    /**
     * Tests the search string functionality in pkb_Controller.
     */
    @IsTest
    private static void test_searchString() {
        Test.startTest();
        setupData();
        setupSettingsData();
        Test.stopTest();

        Id kaId = (Id) kavObj.get('KnowledgeArticleId');
        Id kavId = (Id) kavObj.get('Id');
        String catString;
        pkb_Controller refCon = new pkb_Controller();
        pkb_Controller pkbCon;
        PageReference p;

        p = new PageReference('/');
        Test.setCurrentPage(p);
        pkbCon = new pkb_Controller(new ApexPages.StandardController(new FAQ__ka()));
        System.assertNotEquals(pkbCon.publishStatus, null);

        p = new PageReference('/');
        p.getParameters().put(refCon.queryParam, 'fr');
        p.getParameters().put(refCon.languageParam, lang);
        p.getParameters().put(refCon.categoryParam, catString);
        Test.setCurrentPage(p);
        pkbCon = new pkb_Controller(new ApexPages.StandardController(new FAQ__ka()));
        System.assertEquals(pkbCon.enteredSearchQuery, pkbCon.searchPrompt);
    }

    /**
     * Sets up custom settings data for testing.
     */
    static void setupSettingsData() {
        pkb = new PKB__c();
        pkb.Name = siteName;
        pkb.Category_Group_1__c = '1';
        pkb.Category_Group_2__c = '2';
        pkb.Category_Group_3__c = '3';
        pkb.Root_Category_1__c = '1';
        pkb.Root_Category_2__c = '2';
        pkb.Root_Category_3__c = '3';
        pkb.Create_Contact_and_Account__c = false;
        pkb.Display_Article_Summary__c = true;
        pkb.Multi_Language_Enabled__c = true;
        pkb.Popular_Articles_Size__c = 2;
        pkb.Related_Articles_Size__c = 2;
        pkb.Results_Page_Size__c = 2;
        insert pkb;
    }

    /**
     * Sets up test data for knowledge articles.
     */
    static void setupData() {
        List<String> kavNames = new List<String>(pkb_Controller.kavNames);
        if (kavNames.isEmpty()) {
            return;
        }

        pkb_Controller.DEFAULT_PUBLISH_STATUS = publishStatus;
        pkb_Controller.DEFAULT_SITE_NAME = siteName;

        for (Integer i = 0; i < 15; i++) {
            objType = kavNames.get(0);
            kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
            kavObj.put('Title', 'SAMPLE foo title!!! ' + i);
            kavObj.put('UrlName', 'url-foo-foo-' + i);
            kavObj.put('Summary', 'This is a summary!!! for the test article ' + i);
            kavObj.put('Functional_Group__c', 'Test');
            kavObj.put('Language', lang);

            insert kavObj;

            String q =
                'SELECT ' +
                pkb_Controller.join(pkb_Controller.kavFields, ',') +
                ' ' +
                'FROM FAQ__kav ' +
                'WHERE Id = \'' +
                kavObj.get('Id') +
                '\'';
            FAQ__kav testFAQ = Database.query(q);

            KbManagement.PublishingService.publishArticle(testFAQ.KnowledgeArticleId, true);
        }

        featured = new PKB_Featured__c(
            Article_Number__c = '000000011',
            Is_Keyword_Article__c = false,
            PKB_Name__c = siteName
        );
        insert featured;

        keyword = new PKB_Featured__c(
            Article_Number__c = '000000333',
            Is_Keyword_Article__c = true,
            Keyword__c = 'foo',
            PKB_Name__c = siteName
        );
        insert keyword;
    }

    /**
     * Checks if the given string is null or empty.
     * @param s The string to check.
     * @return True if the string is null or empty, false otherwise.
     */
    static Boolean isBlank(String s) {
        return (s == null || s == '');
    }
}