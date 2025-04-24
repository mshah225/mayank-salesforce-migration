/**
 * An instance of this class is a specific set of filters you should apply on the advisor portal when retrieving cases/contacts
 *
 * We support version-ing, since these filters can be saved. Before returning a saved filter, we always run upgradeToMostRecentVersion
 * to update it to the most recent version though, so when using a filter to filter cases/contacts you can always be sure that it is
 * of the most recent version.
 *
 * Also, because of versioning (and because we want to use JSON.deserialize), all fields should be strings (as this gives us maximum flexibility
 * to avoid having deserialization fail on old versions).
 *
 * There are several functions that you should use when using the filter to filter cases/contacts
 * 1. shouldUse returns a boolean indicating if you SHOULD apply a filter or not, this allows us to avoid applying empty filters
 *    or applying GRAD filters when in UGRAD mode
 * 2. The getter functions return the filter value in the form that you can use in SOQL. For example Outlook Scores are decimals
 *    the outlookScore field is a String, but getOutlookScores will return a List<Decimal> after parsing that string.
 *    You'll always want to use the getters because they get you the correct object type and also do things like base64 decode strings before returning
 *    Also, they will return null if that filter is empty.
 */

public class AdvisorPortalFilter {
    // Static variables to describe state of the world
    public static final String mostRecentVersion = 'v3';
    private static final Map<String, Set<Decimal>> outlookScoresByLabels = new Map<String, Set<Decimal>>{
        'very low' => new Set<Decimal>{ 0, 1, 2, 3 },
        'low' => new Set<Decimal>{ 4, 5 },
        'moderate' => new Set<Decimal>{ 6 },
        'high' => new Set<Decimal>{ 7 },
        'very high' => new Set<Decimal>{ 8, 9, 10 }
    };
    private static final Map<String, Decimal> outlookChangeByLabels = new Map<String, Decimal>{
        'up' => 1,
        'down' => 0,
        'no change' => -1
    };

    // Control variables
    @AuraEnabled
    public String version {
        get {
            // Since we must support saving filters in the advisor portal, we must have some versioning in case we ever change this class
            // Default to the most recent version
            return version == null ? mostRecentVersion : version;
        }
        set;
    }

    // Some fields that are always set
    @AuraEnabled
    public String caseTypeState; // "AllCasesState" | "ProactiveCasesState" | "WatchlistCasesState"
    @AuraEnabled
    public String career; // "GRD" | "UGRD"
    @AuraEnabled
    public String ownerIds;

    // -----  Used in which mode?  ---------------------  UGRAD  ------  GRAD  ------ -- v1 -- v2 --
    @AuraEnabled
    public String studentString; //.....................  ugrad  ......  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String campus; //............................  ugrad  ......  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String academicLevel; //.....................  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String studentGroupCode; //..................  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String major; //.............................  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String degreeLevel; //......................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String academicProgram; //..................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String schoolDepartment; //.................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String academicPlan; //.....................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String admitTermFrom; //....................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String admitTermTo; //......................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String residency; //.........................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String caseStatus; //........................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String caseCategory; //......................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String caseSubCategory; //..................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String caseSubject; //.......................  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String specialPopulation; //................................  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String outlookScore; //......................  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String outlookChange; //.....................  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String caseCount; //.........................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String createdFromDate; //...................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String createdToDate; //.....................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String followUpFromDate; //..................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String followUpToDate; //....................  ugrad........  grad  ...... ..  y ..  y ..
    @AuraEnabled
    public String persistenceFromDate; //...............  ugrad  .................... ..  y ..  y ..
    @AuraEnabled
    public String persistenceToDate; //.................  ugrad  .................... ..  y ..  y ..

    public AdvisorPortalFilter() {
    }

    /**
     * Attempts to deserailize a String into an Advisor Portal Filter.
     * If the string is null, empty string, or empty object (`{}`), then returns null
     * as this is a non-filter
     */
    public static AdvisorPortalFilter deserialize(String serialized) {
        AdvisorPortalFilter filter = null;
        if (serialized != null && serialized != '' && serialized != '{}') {
            filter = (AdvisorPortalFilter) JSON.deserialize(serialized, AdvisorPortalFilter.class);
        }
        return filter;
    }

    /**
     * Checks if a specific filter should be used or not.  Returns false when either the filter is unset or when the that filter is inactive due to grad/ugrad mode
     *
     * @param filterName Name of the filter to determine if it should be used or not
     *
     * @return True if that filter is set and matches the current grad/ugrad mode
     */
    public Boolean shouldUse(String filterName) {
        Boolean useThisFilter = true;

        // career should NEVER be null
        if (career == null)
            return false;

        /** Check if this filter is used with this career (some filters are only allowed for GRD or UGRD and not the other) */
        if (career == 'GRD') {
            useThisFilter &= new List<String>{
                    'studentString',
                    'campus',
                    'degreeLevel',
                    'academicProgram',
                    'schoolDepartment',
                    'academicPlan',
                    'admitTermFrom',
                    'admitTermTo',
                    'residency',
                    'caseStatus',
                    'caseCategory',
                    'caseSubCategory',
                    'specialPopulation',
                    'caseCount',
                    'createdFromDate',
                    'createdToDate',
                    'followUpFromDate',
                    'followUpToDate'
                }
                .contains(filterName);
        } else {
            useThisFilter &= new List<String>{
                    'studentString',
                    'campus',
                    'academicLevel',
                    'studentGroupCode',
                    'major',
                    'residency',
                    'caseStatus',
                    'caseCategory',
                    'caseSubject',
                    'outlookScore',
                    'outlookChange',
                    'caseCount',
                    'createdFromDate',
                    'createdToDate',
                    'followUpFromDate',
                    'followUpToDate',
                    'persistenceFromDate',
                    'persistenceToDate'
                }
                .contains(filterName);
        }

        /** Check if filter is actually set */
        if (filterName == 'studentString')
            useThisFilter &= getStudentString() != null;
        else if (filterName == 'campus')
            useThisFilter &= getCampuses() != null;
        else if (filterName == 'academicLevel')
            useThisFilter &= getAcademicLevels() != null;
        else if (filterName == 'studentGroupCode')
            useThisFilter &= getStudentGroupCode() != null;
        else if (filterName == 'major')
            useThisFilter &= getMajor() != null;
        else if (filterName == 'degreeLevel')
            useThisFilter &= getDegreeLevels() != null;
        else if (filterName == 'academicProgram')
            useThisFilter &= getAcademicPrograms() != null;
        else if (filterName == 'schoolDepartment')
            useThisFilter &= getSchoolDepartments() != null;
        else if (filterName == 'academicPlan')
            useThisFilter &= getAcademicPlans() != null;
        else if (filterName == 'admitTermFrom')
            useThisFilter &= getAdmitTermFrom() != null;
        else if (filterName == 'admitTermTo')
            useThisFilter &= getAdmitTermTo() != null;
        else if (filterName == 'residency')
            useThisFilter &= getResidencies() != null;
        else if (filterName == 'caseStatus')
            useThisFilter &= getCaseStatuses() != null;
        else if (filterName == 'caseCategory')
            useThisFilter &= getCaseCategories() != null;
        else if (filterName == 'caseSubCategory')
            useThisFilter &= getCaseSubCategories() != null;
        else if (filterName == 'caseSubject')
            useThisFilter &= getCaseSubjects() != null;
        else if (filterName == 'specialPopulation')
            useThisFilter &= getSpecialPopulations() != null;
        else if (filterName == 'outlookScore')
            useThisFilter &= getOutlookScores() != null;
        else if (filterName == 'outlookChange')
            useThisFilter &= getOutlookChanges() != null;
        else if (filterName == 'caseCount')
            useThisFilter &= getCaseCount() != null;
        else if (filterName == 'createdFromDate')
            useThisFilter &= getCreatedFromDate() != null;
        else if (filterName == 'createdToDate')
            useThisFilter &= getCreatedToDate() != null;
        else if (filterName == 'followUpFromDate')
            useThisFilter &= getFollowUpFromDate() != null;
        else if (filterName == 'followUpToDate')
            useThisFilter &= getFollowUpToDate() != null;
        else if (filterName == 'persistenceFromDate')
            useThisFilter &= getPersistenceFromDate() != null;
        else if (filterName == 'persistenceToDate')
            useThisFilter &= getPersistenceToDate() != null;

        return useThisFilter;
    }

    /*
     * Getters and Setters for all attributes that may or may not be set
     */
    public List<String> getOwnerIds() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.ownerIds))
            val = this.ownerIds;

        if (val != null)
            val_arr = val.split(';');

        if (val_arr == null)
            val_arr = new List<String>();

        return val_arr;
    }
    public String getCaseTypeState() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseTypeState))
            val = this.caseTypeState;

        return val;
    }
    public String getCareer() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.career))
            val = this.career;

        return val;
    }
    public String getStudentString() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.studentString))
            val = this.studentString;

        return val;
    }
    public List<String> getCampuses() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.campus))
            val = this.campus;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<String> getAcademicLevels() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.academicLevel))
            val = this.academicLevel;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public String getStudentGroupCode() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.studentGroupCode))
            val = this.studentGroupCode;

        return val;
    }
    public String getMajor() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.major))
            val = this.major;

        return val;
    }
    public List<String> getDegreeLevels() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.degreeLevel))
            val = this.degreeLevel;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<String> getAcademicPrograms() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.academicProgram))
            val = this.academicProgram;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<String> getSchoolDepartments() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.schoolDepartment))
            val = this.schoolDepartment;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<String> getAcademicPlans() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.academicPlan))
            val = this.academicPlan;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public String getAdmitTermFrom() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.admitTermFrom))
            val = this.admitTermFrom;

        return val;
    }
    public String getAdmitTermTo() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.admitTermTo))
            val = this.admitTermTo;

        return val;
    }
    public List<String> getResidencies() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.residency))
            val = this.residency;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<String> getCaseStatuses() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseStatus))
            val = this.caseStatus;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<String> getCaseCategories() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseCategory))
            val = this.caseCategory;

        if (val != null)
            val_arr = decodeBase64ElementsOfArray(val.split(';'));

        return val_arr;
    }
    public List<String> getCaseSubCategories() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseSubCategory))
            val = this.caseSubCategory;

        if (val != null)
            val_arr = decodeBase64ElementsOfArray(val.split(';'));

        return val_arr;
    }
    public List<String> getCaseSubjects() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseSubject))
            val = this.caseSubject;

        if (val != null)
            val_arr = decodeBase64ElementsOfArray(val.split(';'));

        return val_arr;
    }
    public List<String> getSpecialPopulations() {
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.specialPopulation))
            val = this.specialPopulation;

        if (val != null)
            val_arr = val.split(';');

        return val_arr;
    }
    public List<Decimal> getOutlookScores() {
        String val = null;
        List<String> val_arr_str = null;
        List<Decimal> val_arr_dec = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.outlookScore))
            val = this.outlookScore;

        if (val != null) {
            // Split using array delimiter
            val_arr_str = val.split(';');

            // Convert labels to corresponding values
            val_arr_dec = new List<Decimal>();
            for (String elem : val_arr_str) {
                if (outlookScoresByLabels.containsKey(elem)) {
                    val_arr_dec.addAll(outlookScoresByLabels.get(elem));
                } else {
                    throw new AdvisorPortalFilterValueException(
                        'Found value "' + elem + '" in outlook score filter - this is an invalid value'
                    );
                }
            }
        }

        return val_arr_dec;
    }
    public List<Decimal> getOutlookChanges() {
        String val = null;
        List<String> val_arr_str = null;
        List<Decimal> val_arr_dec = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.outlookChange))
            val = this.outlookChange;

        if (val != null) {
            // Split using array delimiter
            val_arr_str = val.split(';');

            // Convert labels to corresponding values
            val_arr_dec = new List<Decimal>();
            for (String elem : val_arr_str) {
                if (outlookChangeByLabels.containsKey(elem)) {
                    val_arr_dec.add(outlookChangeByLabels.get(elem));
                } else {
                    throw new AdvisorPortalFilterValueException(
                        'Found value "' + elem + '" in outlook change filter - this is an invalid value'
                    );
                }
            }
        }

        return val_arr_dec;
    }
    public Integer getCaseCount() {
        String val = null;
        Integer val_int = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseCount))
            val = this.caseCount;

        if (val != null) {
            if (Integer.valueOf(val) > 0) {
                // value must be at least 1
                val_int = Integer.valueOf(val);
            }
        }

        return val_int;
    }
    public Datetime getCreatedFromDate() {
        String val = null;
        Datetime val_dt = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.createdFromDate))
            val = this.createdFromDate;

        if (val != null) {
            // from date is at beginning of that date
            val_dt = Datetime.valueOf(val + ' 00:00:00');
        }

        return val_dt;
    }
    public Datetime getCreatedToDate() {
        String val = null;
        Datetime val_dt = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.createdToDate))
            val = this.createdToDate;

        if (val != null) {
            // to date is at end of that date
            val_dt = Datetime.valueOf(val + ' 23:59:59');
        }

        return val_dt;
    }
    public Date getFollowUpFromDate() {
        String val = null;
        Date val_date = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.followUpFromDate))
            val = this.followUpFromDate;

        if (val != null) {
            // to date is at end of that date
            val_date = Date.valueOf(val);
        }

        return val_date;
    }
    public Date getFollowUpToDate() {
        String val = null;
        Date val_date = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.followUpToDate))
            val = this.followUpToDate;

        if (val != null) {
            // to date is at end of that date
            val_date = Date.valueOf(val);
        }

        return val_date;
    }
    public Date getPersistenceFromDate() {
        String val = null;
        Date val_date = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.persistenceFromDate))
            val = this.persistenceFromDate;

        if (val != null) {
            // to date is at end of that date
            val_date = Date.valueOf(val);
        }

        return val_date;
    }
    public Date getPersistenceToDate() {
        String val = null;
        Date val_date = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.persistenceToDate))
            val = this.persistenceToDate;

        if (val != null) {
            // to date is at end of that date
            val_date = Date.valueOf(val);
        }

        return val_date;
    }

    /**
     * Upgrades a filter from whichever version it currently is, to the format of the most recent version
     * This is important since we allow advisors to save filters, and if they save using an old format and we
     * later change the format, we need to be able to update there filter to the newest formats.
     */
    public void upgradeToMostRecentVersion() {
        List<String> upgradePath = new List<String>();
        upgradePath.add(version);

        if (version == 'v1') {
            // from v1 -> v2 we began base64 encoding subject, category, and subcategory
            version = 'v2';
            upgradePath.add('v2');

            // Convert fields
            if (String.isNotBlank(caseSubject))
                caseSubject = String.join(encodeBase64ElementsOfArray(caseSubject.split(';')), ';');
            if (String.isNotBlank(caseCategory))
                caseCategory = String.join(encodeBase64ElementsOfArray(caseCategory.split(';')), ';');
            if (String.isNotBlank(caseSubCategory))
                caseSubCategory = String.join(encodeBase64ElementsOfArray(caseSubCategory.split(';')), ';');
        }

        if (version == 'v2') {
            // from v2 -> v3 we added ownerIds field (default it to current user if empty)
            upgradePath.add('v3');
            version = 'v3';

            if (String.isBlank(ownerIds))
                ownerIds = UserInfo.getUserId();
        }

        if (version != mostRecentVersion) {
            throw new AdvisorPortalFilterUpgradeException(
                'Failed to upgrade filter to most recent version. Upgrade path was: ' + String.join(upgradePath, ' -> ')
            );
        }
    }

    /**
     * Get the advisor portal as a serialized JSON string
     */
    override public String toString() {
        Map<String, String> jsonMp = new Map<String, String>();

        if (String.isNotBlank(version))
            jsonMp.put('version', version);
        if (String.isNotBlank(caseTypeState))
            jsonMp.put('caseTypeState', caseTypeState);
        if (String.isNotBlank(career))
            jsonMp.put('career', career);
        if (String.isNotBlank(ownerIds))
            jsonMp.put('ownerIds', ownerIds);
        if (String.isNotBlank(studentString))
            jsonMp.put('studentString', studentString);
        if (String.isNotBlank(campus))
            jsonMp.put('campus', campus);
        if (String.isNotBlank(academicLevel))
            jsonMp.put('academicLevel', academicLevel);
        if (String.isNotBlank(studentGroupCode))
            jsonMp.put('studentGroupCode', studentGroupCode);
        if (String.isNotBlank(major))
            jsonMp.put('major', major);
        if (String.isNotBlank(degreeLevel))
            jsonMp.put('degreeLevel', degreeLevel);
        if (String.isNotBlank(academicProgram))
            jsonMp.put('academicProgram', academicProgram);
        if (String.isNotBlank(schoolDepartment))
            jsonMp.put('schoolDepartment', schoolDepartment);
        if (String.isNotBlank(academicPlan))
            jsonMp.put('academicPlan', academicPlan);
        if (String.isNotBlank(admitTermFrom))
            jsonMp.put('admitTermFrom', admitTermFrom);
        if (String.isNotBlank(admitTermTo))
            jsonMp.put('admitTermTo', admitTermTo);
        if (String.isNotBlank(residency))
            jsonMp.put('residency', residency);
        if (String.isNotBlank(caseStatus))
            jsonMp.put('caseStatus', caseStatus);
        if (String.isNotBlank(caseCategory))
            jsonMp.put('caseCategory', caseCategory);
        if (String.isNotBlank(caseSubCategory))
            jsonMp.put('caseSubCategory', caseSubCategory);
        if (String.isNotBlank(caseSubject))
            jsonMp.put('caseSubject', caseSubject);
        if (String.isNotBlank(specialPopulation))
            jsonMp.put('specialPopulation', specialPopulation);
        if (String.isNotBlank(outlookScore))
            jsonMp.put('outlookScore', outlookScore);
        if (String.isNotBlank(outlookChange))
            jsonMp.put('outlookChange', outlookChange);
        if (String.isNotBlank(caseCount))
            jsonMp.put('caseCount', caseCount);
        if (String.isNotBlank(createdFromDate))
            jsonMp.put('createdFromDate', createdFromDate);
        if (String.isNotBlank(createdToDate))
            jsonMp.put('createdToDate', createdToDate);
        if (String.isNotBlank(followUpFromDate))
            jsonMp.put('followUpFromDate', followUpFromDate);
        if (String.isNotBlank(followUpToDate))
            jsonMp.put('followUpToDate', followUpToDate);
        if (String.isNotBlank(persistenceFromDate))
            jsonMp.put('persistenceFromDate', persistenceFromDate);
        if (String.isNotBlank(persistenceToDate))
            jsonMp.put('persistenceToDate', persistenceToDate);

        return JSON.serialize(jsonMp);
    }

    /**
     * Assumes each element of orgArr is base64 encoded.
     * Decodes each value and returns an array with the decoded values.
     *
     * @param orgArr An array of base64 encoded values
     * @return An array where each element corresponds to the similar element in the original array, but each element has been base64 decoded
     */
    @TestVisible
    private static List<String> decodeBase64ElementsOfArray(List<String> orgArr) {
        // return null if orgArr is null
        if (orgArr == null)
            return null;

        // decode each element one by one
        List<String> newArr = new List<String>();
        for (String elem : orgArr)
            newArr.add(EncodingUtil.base64Decode(elem).toString());
        return newArr;
    }
    /**
     * Encodes each value in an array
     *
     * @param orgArr An array of values
     * @return An array where each element corresponds to the similar element in the original array, but each element has been base64 encoded
     */
    @TestVisible
    private static List<String> encodeBase64ElementsOfArray(List<String> orgArr) {
        // return null if orgArr is null
        if (orgArr == null)
            return null;

        // encode each element one by one
        List<String> newArr = new List<String>();
        for (String elem : orgArr)
            newArr.add(EncodingUtil.base64Encode(Blob.valueOf(elem)));
        return newArr;
    }

    public class AdvisorPortalFilterUpgradeException extends Exception {
    }
    public class AdvisorPortalFilterValueException extends Exception {
    }
}