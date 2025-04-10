/**
 * Controller class for managing PKB (Public Knowledge Base) functionalities.
 */
public without sharing class pkb_Controller {
    /* ***** SEARCH DEFAULTS ***** */
    private final static String SEARCH_PROMPT = System.Label.PKB2_Search_Prompt;
    private final static String CONTACT_US_PROMPT = System.Label.PKB2_Contact_Us_Prompt;
    private final static String CONTACT_US_BUTTON_PROMPT = System.Label.PKB2_Ask_Button;
    private final static String SEARCH_BUTTON_PROMPT = System.Label.PKB2_Search_Button;
    private final static Integer CASE_SUBJECT_LENGTH = 250;

    // Public to allow setting during unit tests
    public static String DEFAULT_PUBLISH_STATUS = 'online';
    public static String DEFAULT_SITE_NAME = Site.getName();

    /**
     * Retrieves the search prompt based on the contact us flag.
     * @return Search or Contact Us prompt.
     */
    public String searchPrompt {
        get {
            return (displayContactUs ? CONTACT_US_PROMPT : SEARCH_PROMPT);
        }
    }

    /**
     * Retrieves the button prompt based on the contact us flag.
     * @return Search or Contact Us button prompt.
     */
    public String buttonPrompt {
        get {
            return (displayContactUs ? CONTACT_US_BUTTON_PROMPT : SEARCH_BUTTON_PROMPT);
        }
    }

    /* ***** URL PARAM CONSTANTS AND GETTERS ***** */
    public final static String QUERY_PARAM = 'q';
    public final static String LANGUAGE_PARAM = 'l';
    public final static String CATEGORY_PARAM = 'c';
    public final static String SESSION_PARAM = 's';
    public final static String FEEDBACK_PARAM = 'f';
    public final static String CONTACT_US_PARAM = 'cu';
    public final static String FEEDBACK_SOURCE_PARAM = 'fs';
    public final static String PAGE_NUM_PARAM = 'pn';

    public String queryParam {
        get {
            return QUERY_PARAM;
        }
    }
    public String languageParam {
        get {
            return LANGUAGE_PARAM;
        }
    }
    public String categoryParam {
        get {
            return CATEGORY_PARAM;
        }
    }
    public String sessionParam {
        get {
            return SESSION_PARAM;
        }
    }
    public String feedbackParam {
        get {
            return FEEDBACK_PARAM;
        }
    }
    public String feedbackSourceParam {
        get {
            return FEEDBACK_SOURCE_PARAM;
        }
    }
    public String contactUsParam {
        get {
            return CONTACT_US_PARAM;
        }
    }
    public String pageNumParam {
        get {
            return PAGE_NUM_PARAM;
        }
    }

    /* ***** KAV EXTENSION ***** */
    private final static String KAV_EXTENSION = '__kav';
    public String kavExtension {
        get {
            return KAV_EXTENSION;
        }
    }

    // Value for the contact us param
    private final static String CONTACT_US_VALUE = '1';
    public String contactUsValue {
        get {
            return CONTACT_US_VALUE;
        }
    }

    // Values for the feedback params
    private final static String FEEDBACK_SHOW_YESNO = 'yesno';
    private final static String FEEDBACK_SHOW_DIALOG = 'dialog';
    public String feedbackShowYesNo {
        get {
            return FEEDBACK_SHOW_YESNO;
        }
    }
    public String feedbackShowDialog {
        get {
            return FEEDBACK_SHOW_DIALOG;
        }
    }

    // Feedback source param values
    private final static String FEEDBACK_CONTACT_US = 'ContactUs';
    private final static String FEEDBACK_SEARCH = 'Search';
    private final static String FEEDBACK_RELATED = 'RelatedArticle';
    public String feedbackContactUs {
        get {
            return FEEDBACK_CONTACT_US;
        }
    }
    public String feedbackSearch {
        get {
            return FEEDBACK_SEARCH;
        }
    }
    public String feedbackRelated {
        get {
            return FEEDBACK_RELATED;
        }
    }

    /* ***** STANDARD CONTROLLER AND RECORD PROPERTIES ***** */
    public ApexPages.StandardController theSC { get; set; }
    public FAQ__ka theArticle { get; set; }
    public FAQ__kav theAV { get; set; }
    public KnowledgeArticleWrapper theKad { get; set; }
    public List<KnowledgeArticleWrapper> rssKads { get; set; }
    public List<KnowledgeArticleWrapper> featuredKads { get; set; }
    public List<KnowledgeArticleWrapper> recommendedKads { get; set; }
    public String publishStatus {
        get {
            return DEFAULT_PUBLISH_STATUS;
        }
    }

    public Boolean facebook {
        get {
            return Site.getTemplate().getUrl().endsWith('pkb_Template_fb');
        }
    }

    public pkb_Controller() {
    }

    /**
     * Constructor that initializes the controller with a standard controller.
     * @param sc StandardController instance.
     */
    public pkb_Controller(ApexPages.StandardController sc) {
        theArticle = (FAQ__ka) sc.getRecord();
        String q = ApexPages.currentPage().getParameters().get(QUERY_PARAM);
        String l = ApexPages.currentPage().getParameters().get(LANGUAGE_PARAM);
        String c = ApexPages.currentPage().getParameters().get(CATEGORY_PARAM);
        String fs = ApexPages.currentPage().getParameters().get(FEEDBACK_SOURCE_PARAM);
        if (!isBlank(l))
            selectedLanguage = String.escapeSingleQuotes(l);
        if (!isBlank(c))
            selectedCategory = String.escapeSingleQuotes(c);
        if (!isBlank(fs))
            feedbackSource = fs;

        Cookie sessionCookie = ApexPages.currentPage().getCookies().get('PKB2SessionId');
        if (sessionCookie == null) {
            sessionId = randomUUID();
            sessionCookie = new Cookie('PKB2SessionId', sessionId, '/', -1, false);
            ApexPages.currentPage().setCookies(new List<Cookie>{ sessionCookie });
        } else {
            sessionId = sessionCookie.getValue();
        }
        enteredSearchQuery = searchPrompt;
        if (!isBlank(q) && q.length() > 2) {
            urlSearchQuery = q;
            enteredSearchQuery = q;
        } else {
            String errorMsg = System.Label.PKB2_js_search_string_length;
            errorMsg = errorMsg.replace('NNN', '3');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
        }

        if (!viewingArticle) {
            buildFeaturedKads();
        }

        theKad = new KnowledgeArticleWrapper();
        if (viewingArticle) {
            theKad = new KnowledgeArticleWrapper(theArticle.Id, selectedLanguage);
            theAV = theKad.theAV;
            List<PKB_Article_Feedback_Deflection__c> afds = [
                SELECT Id
                FROM PKB_Article_Feedback_Deflection__c
                WHERE Session_ID__c = :sessionId AND Article_Number__c = :theKad.articleNumber
            ];
            feedbackRecorded = !afds.isEmpty();
        }

        if (searchExecuted) {
            buildRecommendedKads();
        }
    }

    /**
     * Generates a random UUID.
     * @return A random UUID string.
     */
    public String randomUUID() {
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue = '';
        Integer nextByte = 0;
        for (Integer i = 0; i < 16; i++) {
            if (i == 4 || i == 6 || i == 8 || i == 10) {
                returnValue += '-';
            }
            nextByte = (Math.round(Math.random() * 255) - 128) & 255;
            if (i == 6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if (i == 8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            returnValue += charAt(kHexChars, nextByte >> 4);
            returnValue += charAt(kHexChars, nextByte & 15);
        }
        return returnValue;
    }

    /**
     * Retrieves a character at a specified index from a string.
     * @param str The string to retrieve the character from.
     * @param index The index of the character to retrieve.
     * @return The character at the specified index.
     */
    private String charAt(String str, Integer index) {
        if (str == null)
            return null;
        if (str.length() <= 0)
            return str;
        if (index < 0 || index >= str.length())
            return null;
        return str.substring(index, index + 1);
    }

    /* ***** SOSL QUERY TO ENABLE SEARCH RSS ***** */
    /**
     * Prepares the RSS feed for a single search query (via SOSL).
     */
    public void prepareSearchRSS() {
        if (viewingArticle)
            return;

        String catQ = 'WITH DATA CATEGORY ';
        rssKads = new List<KnowledgeArticleWrapper>();
        String escapedQ = String.escapeSingleQuotes(urlSearchQuery);
        if (isBlank(escapedQ) || urlSearchQuery.length() < 2)
            return;

        if (!isBlank(selectedCategory))
            catQ += buildCategorySosl();

        String q = '';
        q +=
            'FIND \'' +
            escapedQ +
            '*\' IN ALL FIELDS RETURNING FAQ__kav(' +
            join(kavFields, ',') +
            ' where PublishStatus = :publishStatus and Language = :selectedLanguage order by LastPublishedDate desc limit 20) ';
        if (!isBlank(selectedCategory))
            q += catQ;

        List<List<SObject>> searchList = Search.query(q);
        List<FAQ__kav> kavs = (List<FAQ__kav>) searchList[0];

        for (FAQ__kav k : kavs) {
            rssKads.add(new KnowledgeArticleWrapper(k));
        }
    }

    /**
     * Builds the category SOSL query.
     * @return The SOSL query string for categories.
     */
    public String buildCategorySosl() {
        if (isBlank(selectedCategory))
            return null;

        List<String> selectedCategorySOSL = new List<String>();
        List<String> selectedCategoryTokens = selectedCategory.split(',');
        List<String> temp;
        for (String s : selectedCategoryTokens) {
            temp = s.trim().split(':');
            temp[0] = temp[0] + '__c';
            temp[1] = temp[1] + '__c';
            selectedCategorySOSL.add(join(temp, ' ABOVE_OR_BELOW '));
        }
        return (join(selectedCategorySOSL, ' AND '));
    }

    public Boolean foundRecommended { get; set; }

    /**
     * Builds the recommended Knowledge Article Wrappers.
     */
    public void buildRecommendedKads() {
        if (viewingArticle && !displayContactUs)
            return;

        List<PKB_Featured__c> pkbfs;
        Set<String> anums = new Set<String>();
        String escapedQ = String.escapeSingleQuotes(urlSearchQuery);
        String orQuery = buildOrQuery(escapedQ);

        String q = '';
        q += 'FIND \'' + orQuery + '\' IN ALL FIELDS RETURNING ';
        q += 'PKB_Featured__c(Keyword__c, Article_Number__c where Is_Keyword_Article__c = true';
        if (isSite)
            q += ' and PKB_Name__c = :siteName';
        q += ' ORDER BY Order__c ASC NULLS last)';

        List<List<SObject>> searchList = Search.query(q);
        pkbfs = (List<PKB_Featured__c>) searchList[0];

        for (PKB_Featured__c p : pkbfs) {
            anums.add(p.Article_Number__c);
        }

        if (anums.isEmpty())
            return;

        recommendedKads = initFromListOfArticleNumbers(new List<String>(anums), selectedLanguage);
        foundRecommended = !recommendedKads.isEmpty();
    }

    /**
     * Builds the OR query for SOSL.
     * @param keywords The keywords to build the query from.
     * @return The OR query string.
     */
    public static String buildOrQuery(String keywords) {
        if (isBlank(keywords))
            return null;

        String temp;
        List<String> tokens = String.escapeSingleQuotes(keywords).replaceAll('[!.,?<>;:{}@#$%^&*()]', '').split(' ');
        List<String> newTokens = new List<String>();

        for (String s : tokens) {
            temp = s.trim();
            if (!excludedSoslWords.contains(temp))
                newTokens.add(temp + '*');
        }
        tokens = newTokens;

        if (tokens.isEmpty())
            return null;
        else if (tokens.size() == 1)
            return tokens[0];
        else
            return join(tokens, ' OR ');
    }

    /* ***** GENERAL DISPLAY AND PROCESSING CONDITIONALS ***** */
    public Boolean viewingArticle {
        get {
            return (!isBlank(theArticle.Id));
        }
    }
    public Boolean searchExecuted {
        get {
            return (!isBlank(allSearchParams) && enteredSearchQuery != searchPrompt);
        }
    }
    public Boolean displaySearchResultsLink {
        get {
            return (!isBlank(allSearchParams));
        }
    }
    public Boolean isSite {
        get {
            return !isBlank(Site.getName());
        }
    }

    /* ***** HANDLE TO CURRENT INSTANCE OF CONTROLLER ***** */
    public pkb_Controller pkbCon {
        get {
            return this;
        }
    }

    /* ***** SEARCH RELATED PROPERTIES AND METHODS ***** */
    public String selectedCategory { get; set; }
    public String urlSearchQuery { get; set; }
    public String feedbackSource { get; set; }
    public String enteredSearchQuery {
        get {
            if (enteredSearchQuery == null)
                enteredSearchQuery = searchPrompt;
            return enteredSearchQuery;
        }
        set;
    }

    /**
     * Retrieves all search parameters formatted as a URL string.
     * @return URL-formatted search parameters.
     */
    public String allSearchParams {
        get {
            String s;
            List<String> keyValues = new List<String>();
            if (!isBlank(urlSearchQuery))
                keyValues.add(QUERY_PARAM + '=' + EncodingUtil.urlEncode(urlSearchQuery, 'UTF-8'));
            if (!isBlank(selectedLanguage))
                keyValues.add(LANGUAGE_PARAM + '=' + EncodingUtil.urlEncode(selectedLanguage, 'UTF-8'));
            if (!isBlank(selectedCategory))
                keyValues.add(CATEGORY_PARAM + '=' + EncodingUtil.urlEncode(selectedCategory, 'UTF-8'));
            if (displayContactUs)
                keyValues.add(CONTACT_US_PARAM + '=' + CONTACT_US_VALUE);
            s = join(keyValues, '&');
            return s;
        }
    }

    /**
     * Retrieves the page title based on whether an article is being viewed.
     * @return The page title.
     */
    public String pageTitle {
        get {
            if (viewingArticle)
                return theKad.title;
            else
                return 'Home';
        }
    }

    /**
     * Retrieves the site base title.
     * @return The site base title.
     */
    public String siteBaseTitle {
        get {
            String s = siteName;
            if (isBlank(s))
                s = 'Public Knowledge Base';
            return s;
        }
    }

    /**
     * Retrieves the selected language URL.
     * @return The selected language URL.
     */
    public String selectedLanguageURL {
        get {
            return '/' + (multiLanguage ? selectedLanguage + '/' : '');
        }
    }

    /**
     * Retrieves the selected category label.
     * @return The selected category label.
     */
    public String selectedCategoryLabel {
        get {
            return selectedCategory.replace(',', ', ').replace(':', ': ').replace('_', ' ');
        }
    }

    /**
     * Retrieves the selected language.
     * @return The selected language.
     */
    public String selectedLanguage {
        get {
            if (isBlank(selectedLanguage))
                selectedLanguage = pkb_SettingsController.DEFAULT_LANGUAGE;
            return selectedLanguage;
        }
        set;
    }

    /**
     * Builds the featured Knowledge Article Wrappers.
     */
    public void buildFeaturedKads() {
        Set<String> anums = new Set<String>();
        List<PKB_Featured__c> pkbfs = [
            SELECT Id, Article_Number__c, LastModifiedDate
            FROM PKB_Featured__c
            WHERE
                Is_Keyword_Article__c = FALSE
                AND PKB_Name__c = :siteName
                AND (Expiration__c >= :Date.today()
                OR Expiration__c = NULL)
            ORDER BY Order__c DESC NULLS LAST, LastModifiedDate DESC
        ];

        for (PKB_Featured__c p : pkbfs) {
            anums.add(p.Article_Number__c);
        }
        featuredKads = initFromListOfArticleNumbers(new List<String>(anums), selectedLanguage);
    }

    /* ***** NARROW SEARCH DISPLAY CONDITIONALS ***** */
    public Boolean displayCategory1 {
        get {
            return (!isBlank(categoryGroup1) && !isBlank(rootCategory1));
        }
    }
    public Boolean displayCategory2 {
        get {
            return (!isBlank(categoryGroup2) && !isBlank(rootCategory2));
        }
    }
    public Boolean displayCategory3 {
        get {
            return (!isBlank(categoryGroup3) && !isBlank(rootCategory3));
        }
    }
    public Boolean displayNarrow {
        get {
            return (displayCategory1 || displayCategory2 || displayCategory3);
        }
    }

    /* ***** FEEDBACK AND CASE DEFERRAL CONDITIONALS AND PROCESSING ***** */
    public String sessionId { get; set; }
    public String feedbackComments { get; set; }
    public String createCaseErrorMsg { get; set; }
    public Boolean caseCreateError {
        get {
            if (caseCreateError == null)
                caseCreateError = false;
            return caseCreateError;
        }
        set;
    }
    public Boolean caseCreated {
        get {
            if (caseCreated == null)
                caseCreated = false;
            return caseCreated;
        }
        set;
    }
    public Boolean feedbackRecorded {
        get {
            if (feedbackRecorded == null)
                feedbackRecorded = false;
            return feedbackRecorded;
        }
        set;
    }

    /**
     * Defers the creation of a case.
     */
    public void deferred() {
        createDeferral(true);
        feedbackRecorded = true;
    }

    /**
     * Records the article feedback.
     */
    public void recordArticleFeedback() {
        if (!isBlank(feedbackComments)) {
            createDeferral(false);
            feedbackRecorded = true;
        }
    }

    /**
     * Creates a deferral record.
     * @param isDeferred Indicates if the record is deferred.
     */
    public void createDeferral(Boolean isDeferred) {
        String fs = (feedbackSourceOptions.contains(feedbackSource) ? feedbackSource : null);

        PKB_Article_Feedback_Deflection__c afd = new PKB_Article_Feedback_Deflection__c(
            Article_ID__c = theKad.id,
            Article_Number__c = theKad.articleNumber,
            Article_Title__c = theKad.title,
            Type__c = theKad.articleTypeLabel,
            Feedback_Source__c = fs,
            Comments__c = feedbackComments,
            Session_ID__c = sessionId,
            Deflection__c = isDeferred,
            Keyword_Searched__c = urlSearchQuery
        );

        List<FAQ__ka> authorNameList = [SELECT CreatedBy.Name FROM FAQ__ka WHERE Id = :theKad.id];

        if (authorNameList.size() > 0) {
            afd.Article_Author__c = authorNameList[0].CreatedBy.Name;
        }

        if (theKad.articleTypeName != null) {
            if (theKad.articleTypeName.equals('FAQ__kav')) {
                afd.Functional_Group__c = theKad.faq.Functional_Group__c;
            }
        }

        insert afd;
    }

    /**
     * Retrieves the functional group of the article.
     * @return The functional group.
     */
    public String getFuncGroup() {
        String funcGroup;
        if (theKad.articleTypeName.equals('FAQ__kav')) {
            funcGroup = theKad.faq.Functional_Group__c;
            return funcGroup;
        }

        return funcGroup;
    }

    /**
     * Retrieves the article type.
     * @return The article type.
     */
    public String getArtType() {
        String artType = theKad.articleTypeLabel;
        return artType;
    }

    /**
     * Retrieves the name of the creator of the article.
     * @return The creator's name.
     */
    public String getCreatedByName() {
        String createdByName = [SELECT CreatedBy.Name FROM FAQ__ka WHERE Id = :theKad.id].CreatedBy.Name;
        return createdByName;
    }

    public Set<String> feedbackSourceOptions {
        get {
            if (feedbackSourceOptions == null)
                feedbackSourceOptions = getActivePicklistOptions(
                        'PKB_Article_Feedback_Deflection__c',
                        'Feedback_Source__c'
                    )
                    .keySet();
            return feedbackSourceOptions;
        }
        set;
    }

    /* ***** CONTACT US CONDITIONALS AND PROCESSING ***** */
    public Boolean displayContactUs {
        get {
            return (ApexPages.currentPage().getParameters().get(CONTACT_US_PARAM) == CONTACT_US_VALUE);
        }
    }
    public ContactUsWrapper theCud {
        get {
            if (theCud == null) {
                theCud = new ContactUsWrapper();
            }
            return theCud;
        }
        set;
    }

    public Case theCase { get; set; }

    /**
     * Handles contact us deferral and redirects to the current site URL.
     * @return PageReference instance for redirection.
     */
    public PageReference contactUsDeferral() {
        feedbackComments = urlSearchQuery;
        feedbackSource = 'ContactUs';
        deferred();
        PageReference p = new PageReference(currentSiteUrl);
        p.setRedirect(true);
        return p;
    }

    /**
     * Creates a case with the provided data.
     */
    public void createCase() {
        createCaseErrorMsg = null;
        caseCreateError = false;

        if (isBlank(theCud.firstName) || isBlank(theCud.lastName) || isBlank(theCud.email) || isBlank(theCud.reqType)) {
            createCaseErrorMsg = System.Label.PKB2_All_Fields_Required;
            caseCreateError = true;
            return;
        }

        if (!isEmail(theCud.email)) {
            createCaseErrorMsg = System.Label.PKB2_Email_Invalid;
            caseCreateError = true;
            return;
        }

        String d = '';
        d += '\n' + System.Label.PKB2_First_Name + ': ' + theCud.firstName;
        d += '\n' + System.Label.PKB2_Last_Name + ': ' + theCud.lastName;
        d += '\n' + System.Label.PKB2_Email + ': ' + theCud.email;
        d += '\n' + System.Label.PKB2_Request_Type + ': ' + theCud.reqType + '\n';
        d += '\n' + System.Label.PKB2_Search_Button + ':\n' + urlSearchQuery;

        theCud.query = urlSearchQuery;
        String subject = '<no search provided>';
        if (!isBlank(urlSearchQuery))
            subject = (urlSearchQuery.length() < CASE_SUBJECT_LENGTH
                ? urlSearchQuery
                : urlSearchQuery.substring(0, CASE_SUBJECT_LENGTH));

        theCase = new Case();
        theCase.Subject = subject;
        theCase.Type = theCud.reqType;
        theCase.Origin = defaultCaseOrigin;
        if (caseOrigins.containsKey('Web'))
            theCase.Origin = 'Web';
        theCase.Description = d;
        theCase.Customer_emoticon_value__c = theCud.User_Experience;
        theCase.pkbgeolocalization__Latitude__s = theCud.location_Latitude;
        theCase.pkbgeolocalization__Longitude__s = theCud.location_Longitude;
        insertRecords();
    }

    /**
     * Inserts records into the database.
     */
    public void insertRecords() {
        createCaseErrorMsg = null;
        caseCreateError = false;
        System.Savepoint sp = Database.setSavepoint();
        if (createAcctCon) {
            try {
                Account a;
                Contact c;
                List<Contact> cons = [
                    SELECT Id, Account.Id
                    FROM Contact
                    WHERE Email = :theCud.email AND Email != NULL
                    LIMIT 2
                ];

                if (!cons.isEmpty()) {
                    a = cons[0].Account;
                    c = cons[0];
                } else {
                    a = new Account(Name = theCud.lastName + ', ' + theCud.firstName);
                    insert a;
                    c = new Contact(
                        AccountId = a.Id,
                        FirstName = theCud.firstName,
                        LastName = theCud.lastName,
                        Email = theCud.email
                    );
                    insert c;
                }

                theCase.AccountId = a.Id;
                theCase.ContactId = c.Id;
                relateContactToFeedback(sessionId, c.Id);
            } catch (System.DmlException de) {
                setErrorAndRollback(sp);
                notifyAdminAndChangeSettings(de, null);
            } catch (Exception e) {
                setErrorAndRollback(sp);
                notifyAdminAndChangeSettings(null, e);
            }
        }
        try {
            insert theCase;
            caseCreated = true;
        } catch (DmlException de) {
            setErrorAndRollback(sp);
            notifyAdmin(de, null, System.Label.PKB2_Case_Error_Admin_Notification);
        } catch (Exception e) {
            setErrorAndRollback(sp);
            notifyAdmin(null, e, System.Label.PKB2_Case_Error_Admin_Notification);
        }
    }

    /**
     * Relates the contact to the article feedback.
     * @param sessionId The session ID.
     * @param contactId The contact ID.
     */
    public void relateContactToFeedback(String sessionId, Id contactId) {
        List<PKB_Article_Feedback_Deflection__c> articleFeedbacks = [
            SELECT Id
            FROM PKB_Article_Feedback_Deflection__c
            WHERE Session_ID__c = :sessionId AND Contact__c = NULL
        ];
        if (!articleFeedbacks.isEmpty()) {
            for (PKB_Article_Feedback_Deflection__c articleFeedback : articleFeedbacks) {
                articleFeedback.Contact__c = contactId;
            }
            update articleFeedbacks;
        }
    }

    /**
     * Sets the error message and rolls back the transaction to the provided savepoint.
     * @param sp The savepoint to rollback to.
     */
    public void setErrorAndRollback(System.Savepoint sp) {
        createCaseErrorMsg = System.Label.PKB2_Case_Submit_Error;
        caseCreateError = true;
        Database.rollback(sp);
    }

    /**
     * Notifies the admin and changes settings in case of an error.
     * @param de The DML exception.
     * @param e The general exception.
     */
    public void notifyAdminAndChangeSettings(System.DmlException de, Exception e) {
        notifyAdmin(de, e, System.Label.PKB2_Error_Admin_Notification_Email);
        kbSettings.Create_Contact_and_Account__c = false;
        update kbSettings;
    }

    /**
     * Sends an email to the admin with the error details.
     * @param de The DML exception.
     * @param e The general exception.
     * @param introMessage The introductory message for the email.
     */
    public void notifyAdmin(System.DmlException de, Exception e, String introMessage) {
        String body;
        Messaging.SingleEmailMessage msg;

        String debug;

        if (de != null) {
            debug = debugDmlException(de);
        } else if (e != null) {
            debug = debugException(e);
        }

        if (siteAdmin != null) {
            msg = new Messaging.SingleEmailMessage();
            msg.setSubject('Public Knowledge Base 2 - Package Exception Notification');
            msg.setToAddresses(new List<String>{ siteAdmin.Email });

            body = introMessage;
            body += '\n\nAPEX TRANSACTION DEBUG INFORMATION:\n' + debug;
            body += '\n\nSUBMITTED CASE INFORMATION:';
            body += '\n\nSubject: ' + theCase.Subject;
            body += '\n\nCase Type: ' + theCase.Type;
            body += '\n\nCase Origin: ' + theCase.Origin;
            body += '\n\nDescription: ' + theCase.Description;
            body += '\n\n';
            msg.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ msg });
        }
    }

    /**
     * Provides detailed debug information for a DML exception.
     * @param de The DML exception.
     * @return A string containing debug information.
     */
    public static String debugDmlException(System.DmlException de) {
        String s = '';
        s += 'Cause: ' + de.getCause();
        s += '\nLineNumber: ' + de.getLineNumber();
        s += '\nMessage: ' + de.getMessage();
        s += '\nStackTraceString: ' + de.getStackTraceString();
        s += '\nTypeName: ' + de.getTypeName();
        s += '\nDmlFieldNames: ' + de.getDmlFieldNames(0);
        s += '\nDmlFields: ' + de.getDmlFields(0);
        s += '\nDmlIndex: ' + de.getDmlIndex(0);
        s += '\nDmlMessage: ' + de.getDmlMessage(0);
        s += '\nDmlStatusCode: ' + de.getDmlStatusCode(0);
        s += '\nDmlType: ' + de.getDmlType(0);
        s += '\nNumDml: ' + de.getNumDml();
        return s;
    }

    /**
     * Provides detailed debug information for a general exception.
     * @param e The general exception.
     * @return A string containing debug information.
     */
    public static String debugException(Exception e) {
        String s = '';
        s += 'Cause: ' + e.getCause();
        s += '\nLineNumber: ' + e.getLineNumber();
        s += '\nMessage: ' + e.getMessage();
        s += '\nStackTraceString: ' + e.getStackTraceString();
        s += '\nTypeName: ' + e.getTypeName();
        return s;
    }

    /**
     * Retrieves the default case origin.
     * @return The default case origin.
     */
    public String defaultCaseOrigin {
        get {
            if (defaultCaseOrigin == null)
                defaultCaseOrigin = getPicklistDefault('Case', 'Origin');
            return defaultCaseOrigin;
        }
        set;
    }

    /**
     * Retrieves the active picklist options for case origins.
     * @return A map of case origin picklist options.
     */
    public Map<String, String> caseOrigins {
        get {
            if (caseOrigins == null)
                caseOrigins = getActivePicklistOptions('Case', 'Origin');
            return caseOrigins;
        }
        set;
    }

    /**
     * Retrieves the select options for case types.
     * @return A list of select options for case types.
     */
    public List<SelectOption> caseTypeOptions {
        get {
            if (caseTypeOptions == null) {
                List<SelectOption> opts = new List<SelectOption>();
                Map<String, String> optionsMap = getActivePicklistOptions('Case', 'Type');
                for (String s : optionsMap.keySet()) {
                    opts.add(new SelectOption(s, optionsMap.get(s)));
                }
                caseTypeOptions = new List<SelectOption>();
                caseTypeOptions.add(new SelectOption('', '--' + System.Label.PKB2_None + '--'));
                caseTypeOptions.addAll(sortOptionList(opts));
            }
            return caseTypeOptions;
        }
        set;
    }

    /* ***** SITE-SPECIFIC VALUES THAT CAN BE OVERRIDDEN IF NOT VIEWING IN A SITE ***** */

    /**
     * Retrieves the current site URL.
     * @return The current site URL.
     */
    public String currentSiteUrl {
        get {
            if (currentSiteUrl == null) {
                currentSiteUrl = Site.getBaseUrl();
                if (!isSite) {
                    if (Site.getTemplate().getUrl().endsWith('pkb_Template_fb'))
                        currentSiteUrl = Page.pkb_Home_fb.getUrl();
                    else
                        currentSiteUrl = Page.pkb_Home.getUrl();
                }
            }
            return currentSiteUrl;
        }
        set;
    }

    /**
     * Retrieves the site name.
     * @return The site name.
     */
    public String siteName {
        get {
            return DEFAULT_SITE_NAME;
        }
    }

    /* ***** CUSTOM SETTINGS ***** */

    /**
     * Retrieves the PKB settings.
     * @return The PKB settings.
     */
    private PKB__c kbSettings {
        get {
            return PKB__c.getValues(siteName);
        }
    }

    /**
     * Checks if the article summary should be displayed.
     * @return True if the article summary should be displayed, false otherwise.
     */
    public Boolean showArticleSummary {
        get {
            return (kbSettings == null
                ? pkb_SettingsController.DEFAULT_DISPLAY_SUMMARY
                : kbSettings.Display_Article_Summary__c);
        }
    }

    /**
     * Retrieves the number of popular articles.
     * @return The number of popular articles.
     */
    public Integer popularArticles {
        get {
            return (kbSettings == null
                ? pkb_SettingsController.DEFAULT_POPULAR_SIZE
                : Integer.valueOf(kbSettings.Popular_Articles_Size__c));
        }
    }

    /**
     * Retrieves the number of related articles.
     * @return The number of related articles.
     */
    public Integer relatedArticles {
        get {
            return (kbSettings == null
                ? pkb_SettingsController.DEFAULT_RELATED_SIZE
                : Integer.valueOf(kbSettings.Related_Articles_Size__c));
        }
    }

    /**
     * Retrieves the number of articles per page.
     * @return The number of articles per page.
     */
    public Integer articlesPerPage {
        get {
            return (kbSettings == null
                ? pkb_SettingsController.DEFAULT_RESULTS_SIZE
                : Integer.valueOf(kbSettings.Results_Page_Size__c));
        }
    }

    /**
     * Checks if multi-language support is enabled.
     * @return True if multi-language support is enabled, false otherwise.
     */
    public Boolean multiLanguage {
        get {
            return (kbSettings == null
                ? pkb_SettingsController.DEFAULT_MULTI_LANGUAGE
                : kbSettings.Multi_Language_Enabled__c);
        }
    }

    /**
     * Checks if account and contact creation is enabled.
     * @return True if account and contact creation is enabled, false otherwise.
     */
    public Boolean createAcctCon {
        get {
            return (kbSettings == null
                ? pkb_SettingsController.DEFAULT_CREATE_ACCOUNT_CONTACT
                : kbSettings.Create_Contact_and_Account__c);
        }
    }

    /**
     * Retrieves the available languages.
     * @return The available languages.
     */
    public String availableLanguages {
        get {
            return (kbSettings == null ? pkb_SettingsController.DEFAULT_LANGUAGE : kbSettings.Selected_Languages__c);
        }
    }

    /**
     * Retrieves the first category group.
     * @return The first category group.
     */
    public String categoryGroup1 {
        get {
            return (kbSettings == null ? null : kbSettings.Category_Group_1__c);
        }
    }

    /**
     * Retrieves the second category group.
     * @return The second category group.
     */
    public String categoryGroup2 {
        get {
            return (kbSettings == null ? null : kbSettings.Category_Group_2__c);
        }
    }

    /**
     * Retrieves the third category group.
     * @return The third category group.
     */
    public String categoryGroup3 {
        get {
            return (kbSettings == null ? null : kbSettings.Category_Group_3__c);
        }
    }

    /**
     * Retrieves the label for the first category group.
     * @return The label for the first category group.
     */
    public String categoryLabel1 {
        get {
            return (kbSettings == null ? null : System.Label.PKB2_Category_Group_Label_1);
        }
    }

    /**
     * Retrieves the label for the second category group.
     * @return The label for the second category group.
     */
    public String categoryLabel2 {
        get {
            return (kbSettings == null ? null : System.Label.PKB2_Category_Group_Label_2);
        }
    }

    /**
     * Retrieves the label for the third category group.
     * @return The label for the third category group.
     */
    public String categoryLabel3 {
        get {
            return (kbSettings == null ? null : System.Label.PKB2_Category_Group_Label_3);
        }
    }

    /**
     * Retrieves the root category for the first category group.
     * @return The root category for the first category group.
     */
    public String rootCategory1 {
        get {
            return (kbSettings == null ? null : kbSettings.Root_Category_1__c);
        }
    }

    /**
     * Retrieves the root category for the second category group.
     * @return The root category for the second category group.
     */
    public String rootCategory2 {
        get {
            return (kbSettings == null ? null : kbSettings.Root_Category_2__c);
        }
    }

    /**
     * Retrieves the root category for the third category group.
     * @return The root category for the third category group.
     */
    public String rootCategory3 {
        get {
            return (kbSettings == null ? null : kbSettings.Root_Category_3__c);
        }
    }

    /**
     * Retrieves the Facebook App ID.
     * @return The Facebook App ID.
     */
    public String fbAppId {
        get {
            return (kbSettings == null ? null : kbSettings.FBAppId__c);
        }
    }

    /* ***** SEARCH RESULTS PAGINATION NAVIGATION ***** */

    /**
     * Retrieves the current page number.
     * @return The current page number.
     */
    public Integer currPage {
        get {
            if (currPage == null) {
                currPage = 1;
                String p = ApexPages.currentPage().getParameters().get(PAGE_NUM_PARAM);
                if (!isBlank(p))
                    currPage = Integer.valueOf(p);
            }
            return currPage;
        }
        set;
    }

    /**
     * Increments the current page number.
     */
    public void nextPage() {
        currPage++;
    }

    /**
     * Decrements the current page number.
     */
    public void prevPage() {
        currPage--;
    }

    /* ***** RETRIEVE LANGUAGE LABELS AND VALUES AND CONSTRUCT SELECT OPTIONS ***** */

    /**
     * Retrieves the set of available languages.
     * @return The set of available languages.
     */
    public Set<String> availableLanguagesSet {
        get {
            if (availableLanguagesSet == null) {
                availableLanguagesSet = new Set<String>();
                List<String> langs = (isBlank(availableLanguages)
                    ? new List<String>{ pkb_SettingsController.DEFAULT_LANGUAGE }
                    : availableLanguages.split(';'));
                for (String s : langs)
                    availableLanguagesSet.add(s);
            }
            return availableLanguagesSet;
        }
        set;
    }

    /**
     * Retrieves the select options for languages.
     * @return A list of select options for languages.
     */
    public List<SelectOption> languageOptions {
        get {
            if (languageOptions == null) {
                languageOptions = new List<SelectOption>();
                for (SelectOption so : allLanguageOptions) {
                    if (availableLanguagesSet.contains(so.getValue())) {
                        languageOptions.add(so);
                    }
                }
                languageOptions = sortOptionList(languageOptions);
            }
            return languageOptions;
        }
        set;
    }

    /**
     * Retrieves all language options.
     * @return A list of all language options.
     */
    public static List<SelectOption> allLanguageOptions {
        get {
            if (allLanguageOptions == null) {
                Map<String, String> optionsMap = getActivePicklistOptions('User', 'LanguageLocaleKey');
                allLanguageOptions = new List<SelectOption>();
                for (String s : optionsMap.keySet()) {
                    allLanguageOptions.add(new SelectOption(s, optionsMap.get(s)));
                }
                allLanguageOptions = sortOptionList(allLanguageOptions);
            }
            return allLanguageOptions;
        }
        set;
    }

    /* ***** DYNAMIC RETRIEVAL OF ARTICLE TYPES VIA DESCRIBES AND OBJECT ID PREFIXES ***** */

    /**
     * Retrieves the set of KAV object names.
     * @return The set of KAV object names.
     */
    public static Set<String> kavNames {
        get {
            if (kavNames == null) {
                kavNames = new Set<String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                for (String s : gd.keySet()) {
                    if (s.contains(KAV_EXTENSION)) {
                        if (s == 'FAQ__kav') {
                            kavNames.add(s);
                        }
                    }
                }
            }
            return kavNames;
        }
        set;
    }

    /**
     * Retrieves the map of KAV object prefix to their describe results.
     * @return The map of KAV object prefix to describe results.
     */
    public static Map<String, Schema.DescribeSObjectResult> kavObjPrefixMap {
        get {
            if (kavObjPrefixMap == null) {
                kavObjPrefixMap = new Map<String, Schema.DescribeSObjectResult>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Schema.DescribeSObjectResult sor;
                for (String s : kavNames) {
                    sor = gd.get(s).getDescribe();
                    kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
                }
            }
            return kavObjPrefixMap;
        }
        set;
    }

    /**
     * Retrieves the describe result for a KAV object by its ID.
     * @param i The ID of the KAV object.
     * @return The describe result.
     */
    public static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
        if (isBlank(i) || i.length() < 15)
            return null;
        return kavObjPrefixMap.get(i.substring(0, 3).toLowerCase());
    }

    /* ***** CONTACT US FORM WRAPPER CLASS ***** */

    /**
     * Wrapper class for Contact Us form data.
     */
    public class ContactUsWrapper {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String reqType { get; set; }
        public String query { get; set; }
        public Decimal location_Latitude { get; set; }
        public Decimal location_Longitude { get; set; }
        public String User_Experience { get; set; }

        public ContactUsWrapper() {
        }
    }

    /**
     * Wrapper class for Knowledge Articles.
     */
    public class KnowledgeArticleWrapper {
        public String id { get; set; }
        public String title { get; set; }
        public String summary { get; set; }
        public String urlName { get; set; }
        public String articleTypeName { get; set; }
        public String articleTypeLabel { get; set; }
        public DateTime lastModifiedDate { get; set; }
        public DateTime firstPublishedDate { get; set; }
        public DateTime lastPublishedDate { get; set; }
        public String articleNumber { get; set; }
        public String articleAuthor { get; set; }
        public FAQ__kav theAV { get; set; }
        public FAQ__kav faq { get; set; }

        public KnowledgeArticleWrapper() {
        }

        /**
         * Initializes the Knowledge Article Wrapper with a FAQ__kav record.
         * @param kav The FAQ__kav record.
         */
        public KnowledgeArticleWrapper(FAQ__kav kav) {
            init(kav);
        }

        /**
         * Initializes the Knowledge Article Wrapper with an ID and language.
         * @param i The ID of the article.
         * @param lang The language of the article.
         */
        public KnowledgeArticleWrapper(Id i, String lang) {
            String q = '';
            String pub = pkb_Controller.DEFAULT_PUBLISH_STATUS;
            q += 'SELECT ' + join(kavFields, ',') + ' FROM FAQ__kav';
            q += ' WHERE PublishStatus = :pub AND Language = :lang AND KnowledgeArticleId = :i LIMIT 1';
            FAQ__kav kav = (FAQ__kav) Database.query(q);
            init(kav);
        }

        /**
         * Initializes the wrapper with a FAQ__kav record.
         * @param kav The FAQ__kav record.
         */
        public void init(FAQ__kav kav) {
            this.theAV = kav;
            id = this.theAV.KnowledgeArticleId;
            title = this.theAV.Title;
            summary = this.theAV.Summary;
            urlName = this.theAV.UrlName;
            articleTypeName = getKAVDescribeById(id).getLocalName();
            articleTypeLabel = getKAVDescribeById(id).getLabel();
            // articleTypeLabel = 'FOUND!';
            lastModifiedDate = this.theAV.LastModifiedDate;
            firstPublishedDate = this.theAV.FirstPublishedDate;
            lastPublishedDate = this.theAV.LastPublishedDate;
            articleNumber = this.theAV.ArticleNumber;

            if (articleTypeName.equals('FAQ__kav')) {
                faq = [
                    SELECT Functional_Group__c
                    FROM FAQ__kav
                    WHERE PublishStatus = 'Online' AND KnowledgeArticleId = :id
                ];
            }
        }
    }

    /**
     * Retrieves the excluded SOSL words.
     * @return The set of excluded SOSL words.
     */
    public static Set<String> excludedSoslWords {
        get {
            if (excludedSoslWords == null) {
                excludedSoslWords = new Set<String>{ 'and', 'or', 'the', 'a' };
            }
            return excludedSoslWords;
        }
        private set;
    }

    /**
     * Retrieves the fields of FAQ__kav to be used in queries.
     * @return The set of FAQ__kav fields.
     */
    public static Set<String> kavFields {
        get {
            if (kavFields == null) {
                kavFields = new Set<String>{
                    'Id',
                    'Title',
                    'Summary',
                    'UrlName',
                    'ArticleNumber',
                    'LastModifiedDate',
                    'FirstPublishedDate',
                    'LastPublishedDate',
                    'Language',
                    'PublishStatus',
                    'KnowledgeArticleId'
                };
            }
            return kavFields;
        }
        private set;
    }

    /* ***** STATIC INITIALIZERS AND FACTORIES FOR KnowledgeArticleWrapper ***** */

    /**
     * Initializes a list of Knowledge Article Wrappers from a list of article numbers.
     * @param anums The list of article numbers.
     * @param lang The language of the articles.
     * @return The list of Knowledge Article Wrappers.
     */
    public static List<KnowledgeArticleWrapper> initFromListOfArticleNumbers(List<String> anums, String lang) {
        List<KnowledgeArticleWrapper> articleWrapperList = new List<KnowledgeArticleWrapper>();
        if (anums == null || anums.isEmpty())
            return articleWrapperList;

        String q = '';
        q += 'SELECT ' + join(kavFields, ',') + ' FROM FAQ__kav';
        q +=
            ' WHERE PublishStatus = \'' +
            pkb_Controller.DEFAULT_PUBLISH_STATUS +
            '\' AND Language = \'' +
            lang +
            '\' AND ArticleNumber IN :anums ORDER BY LastPublishedDate DESC';

        List<FAQ__kav> kavs = (List<FAQ__kav>) Database.query(q);
        for (FAQ__kav kav : kavs) {
            articleWrapperList.add(new KnowledgeArticleWrapper(kav));
        }
        return articleWrapperList;
    }

    /**
     * Initializes a list of Knowledge Article Wrappers from a list of article IDs.
     * @param aids The list of article IDs.
     * @param lang The language of the articles.
     * @return The list of Knowledge Article Wrappers.
     */
    public static List<KnowledgeArticleWrapper> initFromListOfArticleIds(List<String> aids, String lang) {
        List<KnowledgeArticleWrapper> articleWrapperList = new List<KnowledgeArticleWrapper>();
        if (aids == null || aids.isEmpty())
            return articleWrapperList;

        String q = '';
        q += 'SELECT ' + join(kavFields, ',') + ' FROM FAQ__kav';
        q +=
            ' WHERE PublishStatus = \'' +
            pkb_Controller.DEFAULT_PUBLISH_STATUS +
            '\' AND Language = \'' +
            lang +
            '\' AND KnowledgeArticleId IN :aids ORDER BY LastPublishedDate DESC';

        List<FAQ__kav> kavs = (List<FAQ__kav>) Database.query(q);
        return initFromListOfKAVs(kavs);
    }

    /**
     * Initializes a list of Knowledge Article Wrappers from a list of KAV IDs.
     * @param kids The list of KAV IDs.
     * @param lang The language of the articles.
     * @return The list of Knowledge Article Wrappers.
     */
    public static List<KnowledgeArticleWrapper> initFromListOfKAVIds(List<String> kids, String lang) {
        List<KnowledgeArticleWrapper> articleWrapperList = new List<KnowledgeArticleWrapper>();
        if (kids == null || kids.isEmpty())
            return articleWrapperList;

        String q = '';
        q += 'SELECT ' + join(kavFields, ',') + ' FROM FAQ__kav';
        q +=
            ' WHERE PublishStatus = \'' +
            pkb_Controller.DEFAULT_PUBLISH_STATUS +
            '\' AND Language = \'' +
            lang +
            '\' AND Id IN :kids ORDER BY LastPublishedDate DESC';

        List<FAQ__kav> kavs = (List<FAQ__kav>) Database.query(q);
        return initFromListOfKAVs(kavs);
    }

    /**
     * Initializes a list of Knowledge Article Wrappers from a list of FAQ__kav records.
     * @param kavs The list of FAQ__kav records.
     * @return The list of Knowledge Article Wrappers.
     */
    public static List<KnowledgeArticleWrapper> initFromListOfKAVs(List<FAQ__kav> kavs) {
        List<KnowledgeArticleWrapper> articleWrapperList = new List<KnowledgeArticleWrapper>();
        if (kavs == null || kavs.isEmpty())
            return articleWrapperList;

        for (FAQ__kav kav : kavs) {
            articleWrapperList.add(new KnowledgeArticleWrapper(kav));
        }
        return articleWrapperList;
    }

    /* ***** GENERAL UTILITY METHODS ***** */

    /**
     * Checks if a string is blank.
     * @param s The string to check.
     * @return True if the string is blank, false otherwise.
     */
    public static Boolean isBlank(String s) {
        return (s == null || s == '');
    }

    /**
     * Joins a list of strings with a separator.
     * @param strings The list of strings.
     * @param c The separator.
     * @return The joined string.
     */
    public static String join(List<String> strings, String c) {
        if (strings == null || strings.isEmpty())
            return null;

        String sep = (isBlank(c) ? ',' : c);
        Integer i, size;
        String s = strings[0];
        size = strings.size();

        for (i = 1; i < size; i++) {
            s += (sep + strings[i]);
        }
        return s;
    }

    /**
     * Joins a set of strings with a separator.
     * @param strings The set of strings.
     * @param c The separator.
     * @return The joined string.
     */
    public static String join(Set<String> strings, String c) {
        return join(new List<String>(strings), c);
    }

    /**
     * Retrieves the default value of a picklist field.
     * @param so The sObject type.
     * @param field The field name.
     * @return The default value of the picklist field.
     */
    public static String getPicklistDefault(String so, String field) {
        String defVal = null;
        for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
            if (ple.isDefaultValue()) {
                defVal = ple.getValue();
                break;
            }
        }
        return defVal;
    }

    /**
     * Retrieves the active picklist options for a field.
     * @param so The sObject type.
     * @param field The field name.
     * @return A map of picklist options.
     */
    public static Map<String, String> getActivePicklistOptions(String so, String field) {
        Map<String, String> options = new Map<String, String>();
        for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
            options.put(ple.getValue(), ple.getLabel());
        }
        return options;
    }

    /**
     * Retrieves the active picklist entries for a field.
     * @param so The sObject type.
     * @param field The field name.
     * @return A list of picklist entries.
     */
    public static List<Schema.PicklistEntry> getActivePicklistEntries(String so, String field) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();
        if (!gd.containsKey(so))
            return ples;

        Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
        Map<String, Schema.SObjectField> sofs = sor.fields.getMap();
        if (!sofs.containsKey(field))
            return ples;

        Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();
        if (dfr.getType() != Schema.DisplayType.Picklist)
            return ples;

        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            if (ple.isActive()) {
                ples.add(ple);
            }
        }
        return ples;
    }

    /**
     * Checks if a string is a valid email address.
     * @param s The string to check.
     * @return True if the string is a valid email address, false otherwise.
     */
    public static Boolean isEmail(String s) {
        if (isBlank(s))
            return false;

        String p = '\\w+([-+.\']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*';
        Pattern pat = Pattern.compile(p);
        Matcher mat = pat.matcher(s);

        return mat.matches();
    }

    /**
     * Retrieves the site admin user.
     * @return The site admin user.
     */
    public User siteAdmin {
        get {
            if (siteAdmin == null)
                siteAdmin = getSiteAdmin();
            return siteAdmin;
        }
        set;
    }

    /**
     * Retrieves the site admin user.
     * @return The site admin user.
     */
    public static User getSiteAdmin() {
        List<Site> sites = [
            SELECT Id, Name, Admin.Id, Admin.FirstName, Admin.LastName, Admin.Name, Admin.Email
            FROM Site
            WHERE Name = :DEFAULT_SITE_NAME
        ];
        User u = (!sites.isEmpty() && sites[0].Admin != null ? sites[0].Admin : null);
        return u;
    }

    /**
     * Sorts a list of SelectOption by their label alphabetically using quicksort algorithm.
     * @param listToSort The list of SelectOption to be sorted.
     * @return The sorted list of SelectOption.
     */
    public static List<SelectOption> sortOptionList(List<SelectOption> listToSort) {
        if (listToSort == null || listToSort.size() <= 1) {
            return listToSort;
        }

        List<SelectOption> less = new List<SelectOption>();
        List<SelectOption> greater = new List<SelectOption>();
        Integer pivot = listToSort.size() / 2;

        SelectOption pivotValue = listToSort[pivot];
        listToSort.remove(pivot);

        for (SelectOption x : listToSort) {
            if (x.getLabel() <= pivotValue.getLabel()) {
                less.add(x);
            } else if (x.getLabel() > pivotValue.getLabel()) {
                greater.add(x);
            }
        }

        List<SelectOption> returnList = new List<SelectOption>();
        returnList.addAll(sortOptionList(less));
        returnList.add(pivotValue);
        returnList.addAll(sortOptionList(greater));

        return returnList;
    }
}