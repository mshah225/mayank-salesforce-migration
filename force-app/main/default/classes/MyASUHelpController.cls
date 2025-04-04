public with sharing class MyASUHelpController {
    public String siteTitleName { get; set; }
    public String siteTitleUrl { get; set; }
    private static final Date EMAILVISIBILITYDATE = Date.newInstance(2015, 4, 6);
    private Id caseId;
    private Date today;
    private Term__c termcAC;
    private Term__c termcB;
    public AlertHandler alertHandler { get; set; } // Use the custom alerting component
    private MyASUHelpViewAsService viewAsService;
    public List<Opportunity> oppList;
    public Boolean viewingAs { get; set; }
    public Case suggestAnArticle { get; set; }
    public String suggestedArticleDescription { get; set; }
    public Case newCase { get; set; }

    public Contact userContact;
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emplId { get; set; }
    public String masqScopeIdCookie { get; set; }
    public String stopViewAsUrl { get; set; }
    public String viewAsUrl { get; set; }
    public String asurite { get; set; }
    public String userAsurite;

    public String functionalGroup { get; set; }
    public Boolean isSearchingWithFunctionalGroup { get; set; }
    public List<FAQ__kav> allFinancialArticles;
    public List<FAQ__kav> topThreeFinancialArticles;
    public List<FAQ__kav> allTechnicalArticles;
    public List<FAQ__kav> topThreeTechnicalArticles;
    public List<FAQ__kav> allHousingArticles;
    public List<FAQ__kav> topThreeHousingArticles;
    public String viewAllArticlesUrl;
    public String viewAllFinanceArticlesUrl;
    public String viewAllTechnicalArticlesUrl;
    public String viewAllHousingArticlesUrl;

    public String orgId { get; set; }
    public String chatEndpoint { get; set; }
    public String scriptEndpointUrl { get; set; }
    public String deploymentId { get; set; }
    public List<Live_Agent_Button_Setting__mdt> livechatButtons { get; set; }
    @TestVisible
    private static List<Live_Agent_Button_Setting__mdt> TEST_BUTTONS;

    public MyASUHelpController() {
        setSiteTitleInformation();
        instantiateControllerVariables();
        setLiveAgentSettings();

        checkForViewAs();
        popUserContact();
        popTerms();

        checkForFunctionalGroup();
        setAllFinancialArticles();
        setAllTechnicalArticles();
        setAllHousingArticles();
        setViewAllArticlesLinks();
    }

    private void setSiteTitleInformation() {
        siteTitleName = 'My ASU';
        siteTitleUrl = System.Label.MyASU_Help_Base_URL + '/myasu/student';
    }

    private void instantiateControllerVariables() {
        suggestAnArticle = new Case();
        newCase = new Case();
        viewingAs = false;
        functionalGroup = null;
        isSearchingWithFunctionalGroup = false;
        alertHandler = new AlertHandler();
        loadStudentSCAlerts(); // Do before standard alerts to appear above standard alerts
        alertHandler.loadStandardAlertsFromMap(ApexPages.currentPage().getParameters());
    }

    private void loadStudentSCAlerts() {
        // Only loaded on studentSC page
        if (ApexPages.currentPage().getUrl().toLowerCase().contains(Page.studentSC.getUrl().toLowerCase())) {
            List<ASU_Alert_Messages__mdt> alertMessages;

            if (CustomMetadataHelper.isNotTest()) {
                alertMessages = [
                    SELECT Display_Message__c, Url__c, Priority__c, Type__c, Title__c, Start_Time__c, End_Time__c
                    FROM ASU_Alert_Messages__mdt
                    WHERE Is_Active__c = TRUE
                    ORDER BY Priority__c
                ];
            } else {
                alertMessages = (List<ASU_Alert_Messages__mdt>) CustomMetadataHelper.getFakeRecords(
                    'ASU_Alert_Messages__mdt$$ASUHelpTab$$Active'
                );
            }

            processAlerts(alertMessages);
        }
    }

    private void processAlerts(List<ASU_Alert_Messages__mdt> alertMessages) {
        for (ASU_Alert_Messages__mdt message : alertMessages) {
            // If has not started yet or if has already ended - then skip
            // this cannot be part of the SOQL query due to SF not supporting OR disjunctions for custom metadata
            if (message.Start_Time__c != null && message.Start_Time__c > System.now())
                continue;
            if (message.End_Time__c != null && message.End_Time__c < System.now())
                continue;

            // Setup required fields
            String alertType = customAlert.WARNING;
            String alertTitle = message.Title__c != null ? message.Title__c : ' ';
            String alertMessage = message.Display_Message__c;
            String alertUrl = message.Url__c;

            // Set the message type
            if (message.Type__c != null) {
                if (message.Type__c.equalsIgnoreCase(customAlert.FATAL))
                    alertType = customAlert.FATAL;
                else if (message.Type__c.equalsIgnoreCase(customAlert.INFO))
                    alertType = customAlert.INFO;
                else if (message.Type__c.equalsIgnoreCase(customAlert.WARNING))
                    alertType = customAlert.WARNING;
                else if (message.Type__c.equalsIgnoreCase(customAlert.CONFIRM))
                    alertType = customAlert.CONFIRM;
            }

            // Add the alert to the list
            alertHandler.newAlert(alertType, alertTitle, alertMessage, alertUrl);
        }
    }

    private void setLiveAgentSettings() {
        // Get all chat buttons
        livechatButtons = [
            SELECT
                Label,
                DeveloperName,
                Chat_Button_Id__c,
                Chat_Deployment__c,
                Chat_Endpoint__c,
                Org_Id__c,
                Chatbot_URL__c,
                Order__c
            FROM Live_Agent_Button_Setting__mdt
            WHERE Show_on_Help_Tab__c = TRUE
            ORDER BY Order__c ASC
        ];

        // Test override
        if (Test.isRunningTest() && TEST_BUTTONS != null)
            livechatButtons = TEST_BUTTONS;

        // Handle when all are disabled
        if (livechatButtons.isEmpty()) {
            orgId = '';
            chatEndpoint = '';
            scriptEndpointUrl = '';
            deploymentId = '';
            return;
        }

        // Get common scripts/metadata
        orgId = livechatButtons[0].Org_Id__c;
        chatEndpoint = livechatButtons[0].Chat_Endpoint__c;
        scriptEndpointUrl = chatEndpoint.replace('https://d', 'https://c').replace('/chat', '');
        deploymentId = livechatButtons[0].Chat_Deployment__c;
    }

    public void checkForViewAs() {
        if (
            ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != null &&
            ApexPages.currentPage().getParameters().get('masqScopeIdCookie') != ''
        ) {
            masqScopeIdCookie = ApexPages.currentPage().getParameters().get('masqScopeIdCookie');
            userAsurite = [SELECT ASURite_Id__c FROM User WHERE Id = :UserInfo.getUserId()].ASURite_Id__c;

            viewAsService = new MyASUHelpViewAsService(masqScopeIdCookie, userAsurite);
        } else {
            viewingAs = false;
        }
    }

    public void checkForFunctionalGroup() {
        if (ApexPages.currentPage().getParameters().get('category') != null) {
            String functionalGroupKey = ApexPages.currentPage().getParameters().get('category');
            if (functionalGroupKey.equals('finance')) {
                functionalGroup = 'Financial Aid';
            } else if (functionalGroupKey.equals('technical')) {
                functionalGroup = '%Technical Resources%';
            } else if (functionalGroupKey.equals('housing')) {
                functionalGroup = 'Housing';
            }

            if (functionalGroup != null) {
                isSearchingWithFunctionalGroup = true;
            }
        }
    }

    public void popUserContact() {
        if (viewAsService != null && viewAsService.hasViewAsRights) {
            userContact = viewAsService.getContact(viewAsService.getResponseValueFromMap('effectiveAsurite'));
            stopViewAsUrl = viewAsService.getResponseValueFromMap('stopViewAsUrl');
            viewAsUrl = viewAsService.getResponseValueFromMap('viewAsUrl');
            viewingAs = true;
        } else {
            userContact = ContactService.getLoggedInContact();
        }
        firstName = userContact.FirstName;
        lastName = userContact.LastName;
        emplId = userContact.EMPLID__c;
        asurite = userContact.ASURite_ID__c;
    }

    public void popTerms() {
        today = date.today();

        termcAC = [
            SELECT Session_A_C_Start_Date__c
            FROM Term__c
            WHERE session_A_C_Start_Date__c > :System.today()
            LIMIT 1
        ];

        termcB = [SELECT Session_B_Start_Date__c FROM Term__c WHERE session_B_Start_Date__c > :System.today() LIMIT 1];

        oppList = [
            SELECT Career__c, Term__c, StageName, Admitted_Session__c
            FROM Opportunity
            WHERE Contact__c = :userContact.Id
        ];
    }

    private void setAllFinancialArticles() {
        allFinancialArticles = [
            SELECT Id, Functional_Group__c, KnowledgeArticleId, Title, UrlName
            FROM FAQ__kav
            WHERE IsDeleted = FALSE AND PublishStatus = 'Online' AND Functional_Group__c = 'Financial Aid'
            ORDER BY ArticleTotalViewCount DESC
            LIMIT 200
        ];
        topThreeFinancialArticles = new List<FAQ__kav>();

        if (allFinancialArticles != null && !allFinancialArticles.isEmpty()) {
            if (allFinancialArticles[0].Id != null) {
                topThreeFinancialArticles.add(allFinancialArticles[0]);
            }
            if (allFinancialArticles[1].Id != null) {
                topThreeFinancialArticles.add(allFinancialArticles[1]);
            }
            if (allFinancialArticles[2].Id != null) {
                topThreeFinancialArticles.add(allFinancialArticles[2]);
            }
        }
    }

    public List<FAQ__kav> getAllFinancialArticles() {
        return allFinancialArticles;
    }

    public List<FAQ__kav> getTopThreeFinancialArticles() {
        return topThreeFinancialArticles;
    }

    private void setAllTechnicalArticles() {
        allTechnicalArticles = [
            SELECT Id, Functional_Group__c, KnowledgeArticleId, Title, UrlName
            FROM FAQ__kav
            WHERE IsDeleted = FALSE AND PublishStatus = 'Online' AND Functional_Group__c LIKE '%Technical Resources%'
            ORDER BY ArticleTotalViewCount DESC
            LIMIT 200
        ];
        topThreeTechnicalArticles = new List<FAQ__kav>();

        if (allTechnicalArticles != null && !allTechnicalArticles.isEmpty()) {
            if (allTechnicalArticles[0].Id != null) {
                topThreeTechnicalArticles.add(allTechnicalArticles[0]);
            }
            if (allTechnicalArticles[1].Id != null) {
                topThreeTechnicalArticles.add(allTechnicalArticles[1]);
            }
            if (allTechnicalArticles[2].Id != null) {
                topThreeTechnicalArticles.add(allTechnicalArticles[2]);
            }
        }
    }

    public List<FAQ__kav> getAllTechnicalArticles() {
        return allTechnicalArticles;
    }

    public List<FAQ__kav> getTopThreeTechnicalArticles() {
        return topThreeTechnicalArticles;
    }

    private void setAllHousingArticles() {
        allHousingArticles = [
            SELECT Id, Functional_Group__c, KnowledgeArticleId, Title, UrlName
            FROM FAQ__kav
            WHERE IsDeleted = FALSE AND PublishStatus = 'Online' AND Functional_Group__c = 'Housing'
            ORDER BY ArticleTotalViewCount DESC
            LIMIT 200
        ];
        topThreeHousingArticles = new List<FAQ__kav>();

        if (allHousingArticles != null && !allHousingArticles.isEmpty()) {
            if (allHousingArticles[0].Id != null) {
                topThreeHousingArticles.add(allHousingArticles[0]);
            }
            if (allHousingArticles[1].Id != null) {
                topThreeHousingArticles.add(allHousingArticles[1]);
            }
            if (allHousingArticles[2].Id != null) {
                topThreeHousingArticles.add(allHousingArticles[2]);
            }
        }
    }

    public List<FAQ__kav> getAllHousingArticles() {
        return allHousingArticles;
    }

    public List<FAQ__kav> getTopThreeHousingArticles() {
        return topThreeHousingArticles;
    }

    public String getViewAllArticlesLink() {
        return viewAllArticlesUrl;
    }

    private void setViewAllArticlesLinks() {
        viewAllArticlesUrl = '/viewAllArticles';
        viewAllFinanceArticlesUrl = viewAllArticlesUrl + '?category=finance';
        viewAllTechnicalArticlesUrl = viewAllArticlesUrl + '?category=technical';
        viewAllHousingArticlesUrl = viewAllArticlesUrl + '?category=housing';
    }

    public String getViewAllFinancialArticlesLink() {
        return viewAllFinanceArticlesUrl;
    }

    public String getViewAllTechnicalArticlesLink() {
        return viewAllTechnicalArticlesUrl;
    }

    public String getViewAllHousingArticlesLink() {
        return viewAllHousingArticlesUrl;
    }

    public PageReference suggestAnArticleSubmit() {
        if (viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);
            return go;
        }

        suggestAnArticle.Subject = 'Suggest An Article';
        if (suggestedArticleDescription != null) {
            suggestAnArticle.Description = suggestedArticleDescription;
        }
        suggestAnArticle.ContactId = userContact.Id;

        List<Case_Classification__c> funcGroupList;
        funcGroupList = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordType.Name = 'Functional Group' AND Active__c = TRUE AND Name = 'Student Success Innovations'
            LIMIT 1
        ];
        if (!funcGroupList.isEmpty() && funcGroupList[0].Id != null) {
            suggestAnArticle.CC_Functional_Group__c = funcGroupList[0].Id;
        }

        List<Case_Classification__c> catList;
        catList = [
            SELECT Id
            FROM Case_Classification__c
            WHERE
                RecordType.Name = 'Category'
                AND Active__c = TRUE
                AND Name = 'Knowledge'
                AND Parent__c = :suggestAnArticle.CC_Functional_Group__c
            LIMIT 1
        ];
        if (!catList.isEmpty() && catList[0].Id != null) {
            suggestAnArticle.CC_Category__c = catList[0].Id;
        }

        suggestAnArticle.Origin__c = 'My ASU';
        suggestAnArticle.Visible_by_Contact__c = false;
        suggestAnArticle.OwnerId = [
            SELECT Id
            FROM Group
            WHERE Name = 'Student Success Innovations (Case)' AND Type = 'Queue'
        ]
        .Id;

        insert suggestAnArticle;

        return redirectWithParams(ApexPages.currentPage(), 'Suggest', 'yes');
    }

    public String getSource() {
        String source = ApexPages.currentPage().getParameters().get('source');

        if (source == null) {
            source = 'studentSC';
        } else if (source.equals('viewAllCases')) {
            source = 'viewAllCases?source=studentSC';
        }

        return source;
    }

    public Boolean getNormalPhone() {
        return (userContact.CAP__c == null) ? true : false;
    }

    public Boolean getRoverPhone() {
        return (userContact.CAP__c != null) ? true : false;
    }

    public Boolean getHelpBox() {
        if ((oppList == null && userContact != null) || (oppList.size() == 0 && userContact != null)) {
            return true;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'A/C') && today < date.valueOf(termcAC.Session_A_C_Start_Date__c)
        ) {
            return false;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'B') && today < date.valueOf(termcB.Session_B_Start_Date__c)
        ) {
            return false;
        } else if (
            oppList[0].StageName != 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            (userContact.Affiliation_Student__c == 'Current' ||
            userContact.Affiliation_Alumni__c == 'Current' ||
            userContact.Affiliation_Courtesy_Affiliate__c == 'Current' ||
            userContact.Affiliation_Employee__c == 'Current') &&
            today < date.valueOf(termcB.Session_B_Start_Date__c)
        ) {
            return false;
        } else {
            return true;
        }
    }

    public List<Case> getMyCases() {
        List<Contact> contacts = new List<Contact>{ userContact };
        Map<Id, List<Case>> openCaseMap;
        if (viewAsService != null) {
            openCaseMap = viewAsService.getOpenCases(contacts, 5);
        } else {
            openCaseMap = CaseService.getVisibleOpenCases(contacts, 5);
        }

        return (openCaseMap.get(userContact.Id) == null) ? new List<Case>() : openCaseMap.get(userContact.Id);
    }

    public List<Case> getClosedCases() {
        List<Case> closedCases = new List<Case>();
        List<Contact> contacts = new List<Contact>{ userContact };
        Map<Id, List<Case>> closedCaseMap;

        if (viewAsService != null) {
            closedCaseMap = viewAsService.getClosedCases(contacts, 5);
        } else {
            closedCaseMap = CaseService.getVisibleClosedCases(contacts, 5);
        }

        return (closedCaseMap.get(userContact.Id) == null) ? new List<Case>() : closedCaseMap.get(userContact.Id);
    }

    public Boolean getMyCasesBox() {
        if ((oppList == null && userContact != null) || (oppList.size() == 0 && userContact != null)) {
            return true;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'A/C') && today < date.valueOf(termcAC.Session_A_C_Start_Date__c)
        ) {
            return false;
        } else if (
            (oppList[0].StageName == 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            oppList[0].Admitted_Session__c == 'B') && today < date.valueOf(termcB.Session_B_Start_Date__c)
        ) {
            return false;
        } else if (
            oppList[0].StageName != 'Enrolled' &&
            oppList[0].Career__c == 'Undergraduate' &&
            (userContact.Affiliation_Student__c == 'Current' ||
            userContact.Affiliation_Alumni__c == 'Current' ||
            userContact.Affiliation_Courtesy_Affiliate__c == 'Current' ||
            userContact.Affiliation_Employee__c == 'Current') &&
            today < date.valueOf(termcB.Session_B_Start_Date__c)
        ) {
            return false;
        } else {
            return true;
        }
    }

    public PageReference redirectWithParams(PageReference page, String param, String value) {
        PageReference redirect = page;
        redirect.getParameters().put(param, value);
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference viewCase() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        String current = ApexPages.currentPage().getUrl();
        current = current.split('apex/')[1];
        PageReference viewCasePage = new PageReference('/viewcase');
        viewCasePage.getParameters().put('id', caseId);
        viewCasePage.getParameters().put('source', current);

        if (viewingAs) {
            viewCasePage.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
        }

        return viewCasePage;
    }

    public PageReference submitCase() {
        Boolean isCaseCreated = true;
        PageReference confirmPage;
        if (viewingAs) {
            PageReference go = new PageReference(ApexPages.currentPage().getUrl());
            go.getParameters().put('masqScopeIdCookie', masqScopeIdCookie);
            go.setRedirect(true);
            return go;
        }

        Case createdCase = MyASUHelpEmailService.submitCase(newCase, userContact);

        if (createdCase.Id != null) {
            ApexPages.currentPage().getParameters().put('caseId', newCase.Id);
            confirmPage = viewCase();
            confirmPage.setRedirect(true);
            return confirmPage;
        } else {
            return null;
        }
    }
}