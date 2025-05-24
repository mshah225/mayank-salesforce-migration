public with sharing class ViewAsController {
    private transient Map<String, Cookie> cookieMap; // Stores the web page cookies
    private transient Cookie viewAsCookie; // Stores the cookie containing the vieweing user id

    /*
     * Cannot define getter of transient property
     *
     * <p>
     * Gets the pages current cookies
     * </p>
     */
    private Map<String, Cookie> getCookieMap() {
        cookieMap = ApexPages.currentPage().getCookies();

        return cookieMap;
    }

    /*
     * Keeps track of the view as id(user selected in view as component).
     *
     * <p>
     * Setter creates a cookie to store user id. Cookie
     * expires after each session.
     * </p>
     */
    public String viewAsId {
        get;
        set {
            viewAsId = value;
            viewAsCookie = new Cookie('viewAsId', viewAsId, null, -1, false); // setting max age to -1 creates a session cookie
            getCookieMap().put('viewAsId', viewAsCookie);
            ApexPages.currentPage().setCookies(cookieMap.values());
        }
    }

    /*
     * Contains list owner ids selected by user in viewas component search box
     */
    public String viewAsIdListString { get; set; }

    public String viewAsRecordTypeId { get; set; }
    public List<SelectOption> viewAsRecordTypeIdOptions { get; set; }

    /*
     * Initialize component with current user's Id
     */
    public ViewAsController() {
        if (getCookieMap() != null) {
            if (cookieMap.containsKey('viewAsId')) {
                viewAsId = cookieMap.get('viewAsId').getValue();
            }
        }

        if (viewAsId == null || viewAsId == '') {
            viewAsId = UserInfo.getUserId();
        }

        // Apply view as id and load record type options
        viewAsRecordTypeIdOptions = new List<SelectOption>();
        changeViewAsId();
    }

    public void changeViewAsId() {
        List<String> SUCCESS_RES_COACH_RTIDS = new List<String>{
            RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Coach'),
            RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Career_Coach'),
            RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Financial_Intake'),
            RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Reentry')
        };

        Map<String, RecordType> recordTypeMp = new Map<String, RecordType>();

        // Generate list of resource record type name -> id for this user
        List<Success_Resource__c> resources = [
            SELECT Id, RecordTypeId, RecordType.Id, RecordType.Name, RecordType.DeveloperName
            FROM Success_Resource__c
            WHERE Resource__c = :viewAsId AND RecordTypeId IN :SUCCESS_RES_COACH_RTIDS
        ];
        for (Success_Resource__c resource : resources) {
            recordTypeMp.put(resource.RecordType.DeveloperName, resource.RecordType);
        }

        // Populate options in dropdown
        viewAsRecordTypeIdOptions.clear();
        for (String devName : recordTypeMp.keySet()) {
            RecordType rt = recordTypeMp.get(devName);
            viewAsRecordTypeIdOptions.add(new SelectOption(rt.Id, rt.Name));
        }

        // Select default
        // Reentry > Career_Coach > Financial_Intake > Coach
        if (recordTypeMp.containsKey('Reentry'))
            viewAsRecordTypeId = recordTypeMp.get('Reentry').Id;
        else if (recordTypeMp.containsKey('Career_Coach'))
            viewAsRecordTypeId = recordTypeMp.get('Career_Coach').Id;
        else if (recordTypeMp.containsKey('Financial_Intake'))
            viewAsRecordTypeId = recordTypeMp.get('Financial_Intake').Id;
        else if (recordTypeMp.containsKey('Coach'))
            viewAsRecordTypeId = recordTypeMp.get('Coach').Id;
        else
            viewAsRecordTypeId = null;
    }
}