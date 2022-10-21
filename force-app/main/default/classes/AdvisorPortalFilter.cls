public class AdvisorPortalFilter {
    // Static variables to describe state of the world
    public static final String mostRecentVersion = 'v2';
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
    public String version {
        get {
            // Since we must support saving filters in the advisor portal, we must have some versioning in case we ever drastically change this class
            // Default to the most recent version
            return version == null ? mostRecentVersion : version;
        }
        set;
    }

    // Some fields that are always set
    public String caseTypeState; // "AllCasesState" | "ProactiveCasesState" | "WatchlistCasesState"
    public String career; // "GRD" | "UGRD"

    // -----  Used in which mode?  ---------------------  UGRAD  ------  GRAD  ------ -- v1 -- v2 --
    public String studentString; //.....................  ugrad  ......  grad  ...... ..  y ..  y ..
    public String campus; //............................  ugrad  ......  grad  ...... ..  y ..  y ..
    public String academicLevel; //.....................  ugrad  .................... ..  y ..  y ..
    public String studentGroupCode; //..................  ugrad  .................... ..  y ..  y ..
    public String major; //.............................  ugrad  .................... ..  y ..  y ..
    public String degreeLevel; //......................................  grad  ...... ..  y ..  y ..
    public String academicProgram; //..................................  grad  ...... ..  y ..  y ..
    public String schoolDepartment; //.................................  grad  ...... ..  y ..  y ..
    public String academicPlan; //.....................................  grad  ...... ..  y ..  y ..
    public String admitTermFrom; //....................................  grad  ...... ..  y ..  y ..
    public String admitTermTo; //......................................  grad  ...... ..  y ..  y ..
    public String residency; //.........................  ugrad........  grad  ...... ..  y ..  y ..
    public String caseStatus; //........................  ugrad........  grad  ...... ..  y ..  y ..
    public String caseCategory; //......................  ugrad........  grad  ...... ..  y ..  y ..
    public String caseSubject; //.......................  ugrad  .................... ..  y ..  y ..
    public String specialPopulation; //................................  grad  ...... ..  y ..  y ..
    public String outlookScore; //......................  ugrad  .................... ..  y ..  y ..
    public String outlookChange; //.....................  ugrad  .................... ..  y ..  y ..
    public String caseCount; //.........................  ugrad........  grad  ...... ..  y ..  y ..
    public String createdFromDate; //...................  ugrad........  grad  ...... ..  y ..  y ..
    public String createdToDate; //.....................  ugrad........  grad  ...... ..  y ..  y ..
    public String followUpFromDate; //..................  ugrad........  grad  ...... ..  y ..  y ..
    public String followUpToDate; //....................  ugrad........  grad  ...... ..  y ..  y ..
    public String persistenceFromDate; //...............  ugrad  .................... ..  y ..  y ..
    public String persistenceToDate; //.................  ugrad  .................... ..  y ..  y ..

    public AdvisorPortalFilter() {
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
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.campus))
            val = this.campus;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('campus')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getAcademicLevels() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.academicLevel))
            val = this.academicLevel;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('academicLevel')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

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
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.degreeLevel))
            val = this.degreeLevel;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('degreeLevel')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getAcademicPrograms() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.academicProgram))
            val = this.academicProgram;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('academicProgram')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getSchoolDepartments() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.schoolDepartment))
            val = this.schoolDepartment;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('schoolDepartment')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getAcademicPlans() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.academicPlan))
            val = this.academicPlan;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('academicPlan')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

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
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.residency))
            val = this.residency;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('residency')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getCaseStatuses() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseStatus))
            val = this.caseStatus;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('caseStatus')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getCaseCategories() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseCategory))
            val = this.caseCategory;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('caseCategory')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getCaseSubjects() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.caseSubject))
            val = this.caseSubject;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('caseSubject')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<String> getSpecialPopulations() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.specialPopulation))
            val = this.specialPopulation;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('specialPopulation')) {
                val_arr = decodeBase64ElementsOfArray(val_arr);
            }
        }

        return val_arr;
    }
    public List<Decimal> getOutlookScores() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr_str = null;
        List<Decimal> val_arr_dec = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.outlookScore))
            val = this.outlookScore;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr_str = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('outlookScore')) {
                val_arr_str = decodeBase64ElementsOfArray(val_arr_str);
            }

            // Convert labels to corresponding values
            val_arr_dec = new List<Decimal>();
            for (String elem : val_arr_str) {
                if (outlookScoresByLabels.containsKey(elem)) {
                    val_arr_dec.addAll(outlookScoresByLabels.get(elem));
                }
            }
        }

        return val_arr_dec;
    }
    public List<Decimal> getOutlookChanges() {
        RuleSet ruleSet = new RuleSet(version);
        String val = null;
        List<String> val_arr_str = null;
        List<Decimal> val_arr_dec = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.outlookChange))
            val = this.outlookChange;

        if (val != null) {
            // Split using array delimiter
            List<String> val_split = val.split(ruleSet.arrayDelim);
            val_arr_str = val_split;

            // Decode each element of the array if they are base64 encoded
            if (ruleSet.arrayElemsAreBase64Encoded.contains('outlookChange')) {
                val_arr_str = decodeBase64ElementsOfArray(val_arr_str);
            }
            // Convert labels to corresponding values
            val_arr_dec = new List<Decimal>();
            for (String elem : val_arr_str) {
                if (outlookChangeByLabels.containsKey(elem)) {
                    val_arr_dec.add(outlookChangeByLabels.get(elem));
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
    public String getCreatedFromDate() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.createdFromDate))
            val = this.createdFromDate;

        if (val != null) {
            // from date is at beginning of that date
            val = Datetime.valueOf(val + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        return val;
    }
    public String getCreatedToDate() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.createdToDate))
            val = this.createdToDate;

        if (val != null) {
            // to date is at end of that date
            val = Datetime.valueOf(val + ' 23:59:59').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        return val;
    }
    public String getFollowUpFromDate() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.followUpFromDate))
            val = this.followUpFromDate;

        return val;
    }
    public String getFollowUpToDate() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.followUpToDate))
            val = this.followUpToDate;

        return val;
    }
    public String getPersistenceFromDate() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.persistenceFromDate))
            val = this.persistenceFromDate;

        return val;
    }
    public String getPersistenceToDate() {
        String val = null;

        // Determine if the value is set at all and extract it if it is
        if (!String.isBlank(this.persistenceToDate))
            val = this.persistenceToDate;

        return val;
    }

    /**
     * Upgrades a filter from whichever version it currently is, to the format of the most recent version
     * This is important since we allow advisors to save filters, and if they save using an old format and we
     * later change the format, we need to be able to update there filter to the newest formats.
     */
    public void upgradeToMostRecentVersion() {
        RuleSet mostRecentVerRS = new RuleSet(mostRecentVersion);
        RuleSet curVerRS = new RuleSet(version);

        // Convert format for all arrays (that is all we need to do, since everything else is currently identical from rule set to rule set)
        campus = convStrArrFromRSToRS(campus, 'campus', curVerRS, mostRecentVerRS);
        academicLevel = convStrArrFromRSToRS(academicLevel, 'academicLevel', curVerRS, mostRecentVerRS);
        degreeLevel = convStrArrFromRSToRS(degreeLevel, 'degreeLevel', curVerRS, mostRecentVerRS);
        academicProgram = convStrArrFromRSToRS(academicProgram, 'academicProgram', curVerRS, mostRecentVerRS);
        schoolDepartment = convStrArrFromRSToRS(schoolDepartment, 'schoolDepartment', curVerRS, mostRecentVerRS);
        academicPlan = convStrArrFromRSToRS(academicPlan, 'academicPlan', curVerRS, mostRecentVerRS);
        residency = convStrArrFromRSToRS(residency, 'residency', curVerRS, mostRecentVerRS);
        caseStatus = convStrArrFromRSToRS(caseStatus, 'caseStatus', curVerRS, mostRecentVerRS);
        caseCategory = convStrArrFromRSToRS(caseCategory, 'caseCategory', curVerRS, mostRecentVerRS);
        caseSubject = convStrArrFromRSToRS(caseSubject, 'caseSubject', curVerRS, mostRecentVerRS);
        specialPopulation = convStrArrFromRSToRS(specialPopulation, 'specialPopulation', curVerRS, mostRecentVerRS);
        outlookScore = convStrArrFromRSToRS(outlookScore, 'outlookScore', curVerRS, mostRecentVerRS);
        outlookChange = convStrArrFromRSToRS(outlookChange, 'outlookChange', curVerRS, mostRecentVerRS);

        version = mostRecentVersion;
    }

    /**
     * Take the string representation of an array under one rule set and convert it to the string represenation in another rule set
     *
     * @param fieldValueString The array-representing-string to convert, it should follow the rules of fromRs
     * @param fieldName The field the string is for
     * @param fromRs The Rule Set the current string follows
     * @param toRs The Rule Set the resultant string should follow
     *
     * @return A new array-representing-string that follows the rules of toRS
     */
    public static String convStrArrFromRSToRS(String fieldValueString, String fieldName, RuleSet fromRs, RuleSet toRs) {
        if (fieldValueString == null)
            return null;
        return convArrToStrUsingRS(convStrToArrUsingRS(fieldValueString, fieldName, fromRs), fieldName, toRs);
    }

    /**
     * Breaks up a string that represents an array into the corresponding array. Follows a ruleset
     * to determine delimiter and if it needs to decode each element from base64
     *
     * @param fieldValueString The string to extract the array from
     * @param fieldName The field that this string corresponds to
     * @param rs The ruleset to convert using
     *
     * @return The array the string represented
     */
    @TestVisible
    private static List<String> convStrToArrUsingRS(String fieldValueString, String fieldName, RuleSet rs) {
        if (fieldValueString == null)
            return null;

        List<String> newValues = fieldValueString.split(rs.arrayDelim); //split using delimiter

        // Convert from base64 if needed
        if (rs.arrayElemsAreBase64Encoded.contains(fieldName)) {
            newValues = decodeBase64ElementsOfArray(newValues);
        }

        return newValues;
    }

    /**
     * Converts an array of values to the string representation for a specific ruleset (following if that ruleset
     * requires base64 encoding and using that ruleset's delimiter)
     *
     * @param fieldValues The array to convert
     * @param fieldName The field that this array corresponds to
     * @param rs The ruleset to convert using
     *
     * @return A string representing that array for this ruleset
     */
    @TestVisible
    private static String convArrToStrUsingRS(List<String> fieldValues, String fieldName, RuleSet rs) {
        if (fieldValues == null)
            return null;

        List<String> newValues = new List<String>(fieldValues);
        // Convert to base64 if needed
        if (rs.arrayElemsAreBase64Encoded.contains(fieldName)) {
            newValues = encodeBase64ElementsOfArray(newValues);
        }
        return String.join(newValues, rs.arrayDelim); // create with current array delimiter;
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

    /*
     * Rule sets describe how to handle each version of the filter
     * Such as which delimiter was used for arrays
     *   and which values are base64 encoded
     */
    public class RuleSet {
        String version;
        List<String> arrayElemsAreBase64Encoded = new List<String>();
        String arrayDelim;
        Map<String, Map<String, Object>> filterNameToLabelToValueMap = new Map<String, Map<String, Object>>();

        public RuleSet(String version) {
            this.version = version;

            if (version == 'v1') {
                arrayDelim = ';';
            } else if (version == 'v2') {
                arrayDelim = ';';
                arrayElemsAreBase64Encoded.add('caseSubject');
                arrayElemsAreBase64Encoded.add('caseCategory');
            }
        }
    }
}