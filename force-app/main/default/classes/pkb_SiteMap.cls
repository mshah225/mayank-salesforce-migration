/**
 * This class manages the site map for the knowledge base, including available article types and languages,
 * and provides methods to retrieve documentation and site map lists.
 */
public with sharing class pkb_SiteMap {
    /**
     * List of all available article types in the organization.
     */
    public List<String> availableArticleTypes { get; private set; }

    /**
     * List of all available languages.
     */
    public List<String> availableLanguages { get; private set; }

    public static final Integer MAX_ARTICLES = 5;
    public static String DEFAULT_PUBLISH_STATUS = 'online';

    public String lang { get; set; }
    public Integer offset { get; set; }

    /**
     * Constructor for pkb_SiteMap.
     * Initializes available article types and languages, and sets the offset and language parameters.
     */
    public pkb_SiteMap() {
        init();
        this.offset = 0;
        String tmpOffset = ApexPages.currentPage().getParameters().get('offset');
        if (String.isNotBlank(tmpOffset) && tmpOffset.isNumeric()) {
            tmpOffset = String.escapeSingleQuotes(tmpOffset);
            this.offset = Integer.valueOf(tmpOffset);
        }
        this.lang = String.valueOf(ApexPages.currentPage().getParameters().get('lang'));
        if (String.isNotBlank(this.lang)) {
            this.lang = String.escapeSingleQuotes(this.lang);
        } else {
            this.lang = availableLanguages.get(0);
        }
    }

    /**
     * Populates available articles and languages using the schema of the FAQ__kav object.
     */
    private void init() {
        availableArticleTypes = new List<String>();

        for (
            Schema.RecordTypeInfo recordTypeInfo : Schema.getGlobalDescribe()
                .get('FAQ__kav')
                .getDescribe()
                .getRecordTypeInfos()
        ) {
            availableArticleTypes.add(recordTypeInfo.getName());
        }

        availableLanguages = new List<String>();
        for (Schema.PicklistEntry a : FAQ__kav.Language.getDescribe().getPickListValues()) {
            availableLanguages.add(a.getValue());
        }
    }

    /**
     * Property to return the proper Sites URL, used to build the full URL later.
     */
    public String siteUrl {
        get {
            String surl = Site.getCustomWebAddress();
            if (!String.isNotBlank(surl)) {
                surl = Site.getCurrentSiteUrl();
                String pref = Site.getPrefix();
                if (pref != null && String.isNotBlank(pref))
                    surl = surl.removeEndIgnoreCase(Site.getPrefix() + '/');
                else
                    surl = surl.removeEndIgnoreCase('/');
            }
            return surl;
        }
        set;
    }

    /**
     * Retrieves a list of documentation articles.
     *
     * @return A list of KAWrapper objects representing the documentation articles.
     */
    public List<KAWrapper> getDocumentationList() {
        List<KAWrapper> results = new List<KAWrapper>();
        Integer offs = this.offset;
        String qry =
            'SELECT Id, KnowledgeArticleId, LastPublishedDate, Title, UrlName, LastModifiedDate ' +
            'FROM FAQ__kav ' +
            'WHERE PublishStatus = \'' +
            DEFAULT_PUBLISH_STATUS +
            '\' ' +
            'AND IsVisibleInPkb = true ' +
            'AND Language =\'' +
            this.lang +
            '\' ' +
            'ORDER BY LastPublishedDate DESC ' +
            'LIMIT :MAX_ARTICLES ' +
            'OFFSET :offs';

        for (SObject iK : Database.query(qry)) {
            results.add(new KAWrapper(iK));
        }
        return results;
    }

    /**
     * Retrieves a list of site maps for all available languages.
     *
     * @return A list of SMWrapper objects representing the site maps.
     */
    public List<SMWrapper> getSiteMapsList() {
        List<SMWrapper> results = new List<SMWrapper>();
        List<SMWrapper> tmp;
        for (String l : availableLanguages) {
            tmp = getSiteMapsList(l);
            if (!tmp.isEmpty())
                results.addAll(tmp);
        }
        return results;
    }

    /**
     * Retrieves a list of site maps for a specific language.
     *
     * @param lang The language for which to retrieve the site maps.
     * @return A list of SMWrapper objects representing the site maps.
     */
    public List<SMWrapper> getSiteMapsList(String lang) {
        List<SMWrapper> results = new List<SMWrapper>();
        String q =
            'SELECT COUNT() ' +
            'FROM FAQ__kav ' +
            'WHERE PublishStatus = \'' +
            DEFAULT_PUBLISH_STATUS +
            '\' ' +
            'AND IsVisibleInPkb = true ' +
            'AND Language =\'' +
            lang +
            '\' ' +
            'LIMIT ' +
            Limits.getLimitQueryRows();
        Integer max = Database.countQuery(q);
        Long l = Math.mod(max, MAX_ARTICLES);
        Double numPages = Math.floor(max / MAX_ARTICLES);
        if (l > 0) {
            numPages = numPages + 1;
        }

        for (Integer i = 0; i < numPages; i++) {
            results.add(new SMWrapper(lang, (i * MAX_ARTICLES)));
        }
        return results;
    }

    /**
     * Wrapper class for knowledge article records.
     */
    public with sharing class KAWrapper {
        public Id id { get; set; } // This is the ID of the FAQ__ka record, not the KAV record
        public Id knowledgearticleid { get; set; }
        public String lastpublisheddate { get; set; }
        public String aType { get; set; }
        public String urlName { get; set; }

        /**
         * Constructor for KAWrapper.
         *
         * @param ka The knowledge article record to wrap.
         */
        public KAWrapper(SObject ka) {
            this.knowledgearticleid = String.valueOf(ka.get('Id'));
            Datetime aux;
            if (!Test.isRunningTest()) {
                aux = Datetime.valueOf(ka.get('LastModifiedDate'));
            } else {
                aux = Datetime.now();
            }

            this.lastpublisheddate = aux.format('yyyy-MM-dd');

            Schema.SObjectType token = this.knowledgearticleid.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            this.aType = dr.getName().replace('__kav', '');

            this.urlName = String.valueOf(ka.get('UrlName'));
        }
    }

    /**
     * Wrapper class for site map records.
     */
    public with sharing class SMWrapper {
        public Integer offset { get; set; }
        public String lastModDate { get; set; }
        public String lang { get; set; }

        /**
         * Constructor for SMWrapper.
         *
         * @param l The language for the site map.
         * @param o The offset for the site map.
         */
        public SMWrapper(String l, Integer o) {
            this.offset = o;
            Datetime aux = Datetime.now();
            this.lastModDate = aux.format('yyyy-MM-dd');
            this.lang = l;
        }
    }
}