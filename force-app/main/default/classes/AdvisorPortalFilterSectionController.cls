public class AdvisorPortalFilterSectionController {
    /**
     * Gets active picklist values for a provided Object and Field name.
     *
     * @param objectName, the name of the Object the picklist lives on.
     * @param fieldName, the name of the field to grab values from.
     *
     * @return picklistValuesByLabel, a Map of picklist values by their labels.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        return ObjectService.getPicklistChoicesMap(objectName, fieldName);
    }

    /**
     * Gets active picklist values for the Campus.
     * If filter is set, and indicates graduate students only, then only add graduate campuses.
     *
     * @return picklistValuesByLabel, a Map of picklist values by their labels.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCampusValues(String filterJSON) {
        Map<String, String> campusMap = new Map<String, String>();
        AdvisorPortalFilter filter = AdvisorPortalFilter.parse(filterJSON);

        if (filter != null) {
            List<Location__c> campusLocations = [
                SELECT Name, Graduate_Enabled__c, Location_Code__c
                FROM Location__c
                ORDER BY CreatedDate, Name
            ];

            if (filter.career == 'GRD') {
                // Load only some locations for graduate students
                for (Location__c campus : campusLocations)
                    if (campus.Graduate_Enabled__c)
                        campusMap.put(campus.Name, campus.Location_Code__c);
            } else {
                // Load all locations for undergraduate students
                for (Location__c campus : campusLocations)
                    campusMap.put(campus.Name, campus.Location_Code__c);
            }
        }
        return campusMap;
    }

    /**
     * Gets active Custom Metadata Case Status values to display on the filter section in the Advisor Portal.
     *
     * @return caseStatusValuesByLabel, a Map of Advisor_Portal_Case_Status__mdt record values by label.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCaseStatusSettings() {
        Map<String, String> caseStatusValuesByLabel = new Map<String, String>();

        for (Advisor_Portal_Case_Status__mdt statusSetting : [
            SELECT Label, Value__c
            FROM Advisor_Portal_Case_Status__mdt
            WHERE Active__c = TRUE
            ORDER BY Label ASC
        ]) {
            caseStatusValuesByLabel.put(statusSetting.Label, statusSetting.Value__c);
        }

        return caseStatusValuesByLabel;
    }

    /**
     * Gets Case Subject picklist values for the Subject filter when view options change.
     *
     * @param viewAsOptions, a List of User/Queue Ids to get related Contacts to use in search.
     * @return caseSubjectValuesByLabel, a Map of Case Subjects.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCaseSubjectPicklistValues(String filterJSON, List<Id> viewAsOptions) {
        Map<String, String> caseSubjectValuesByLabel = new Map<String, String>();
        List<String> recordTypeIds = new List<String>();
        AdvisorPortalFilter filter = AdvisorPortalFilter.parse(filterJSON);

        if (filter != null) {
            if (filter.career == 'GRD') {
                recordTypeIds.add(RecordIdHelper.getRecordTypeId('Case', 'ASU_Graduate_Advisor_Portal'));
            } else {
                recordTypeIds.add(RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'));
            }
        }

        for (AggregateResult result : [
            SELECT Subject
            FROM Case
            WHERE IsClosed = FALSE AND RecordTypeId IN :recordTypeIds AND Subject != NULL AND OwnerId IN :viewAsOptions
            GROUP BY Subject
            LIMIT 2000
        ]) {
            if (result.get('Subject') != null) {
                String label = (String) result.get('Subject');
                String value = EncodingUtil.base64Encode(Blob.valueOf(label));
                caseSubjectValuesByLabel.put(label, value);
            }
        }

        return caseSubjectValuesByLabel;
    }

    /**
     * Gets Case Category picklist values for the Category filter when view options change.
     *
     * @param viewAsOptions, a List of User/Queue Ids to get related Contacts to use in search.
     * @return caseClassificationValuesByLabel, a Map of Case Subjects.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCaseClassificationPicklistValues(String filterJSON, List<Id> viewAsOptions) {
        Map<String, String> caseClassificationValuesByLabel = new Map<String, String>();
        List<String> recordTypeIds = new List<String>();

        AdvisorPortalFilter filter = AdvisorPortalFilter.parse(filterJSON);

        if (filter != null) {
            if (filter.career == 'GRD') {
                recordTypeIds.add(RecordIdHelper.getRecordTypeId('Case', 'ASU_Graduate_Advisor_Portal'));
            } else {
                recordTypeIds.add(RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach'));
            }
        }

        for (AggregateResult result : [
            SELECT CC_Category__r.Name CategoryName
            FROM Case
            WHERE
                IsClosed = FALSE
                AND RecordTypeId IN :recordTypeIds
                AND CC_Category__c != NULL
                AND OwnerId IN :viewAsOptions
            GROUP BY CC_Category__r.Name
            LIMIT 2000
        ]) {
            if (result.get('CategoryName') != null) {
                String label = (String) result.get('CategoryName');
                String value = EncodingUtil.base64Encode(Blob.valueOf(label));
                caseClassificationValuesByLabel.put(label, value);
            }
        }

        return caseClassificationValuesByLabel;
    }

    /**
     * Gets active Academic Program values to display on the filter section in the Graduate Advisor Portal.
     *
     * @return a map of active program names to their program codes
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getAcademicProgramPicklistValues() {
        Map<String, String> labelToValueMap = new Map<String, String>();

        // Find programs where they have at least one active plan within them by
        // looking at all active plans and taking each unique program from there
        List<AggregateResult> activePlans = new List<AggregateResult>(
            [
                SELECT MAX(Program__r.Name), MAX(Program__r.Program_Code__c)
                FROM Plan__c
                WHERE
                    Plan_Status__c = TRUE
                    AND Program__r.Career__c = 'Graduate'
                    AND Program__r.Program_Code__c NOT IN ('GRPR', 'GCNV')
                GROUP BY Program__c
                HAVING MAX(Plan_Effective_Date__c) <= TODAY
                ORDER BY MAX(Program__r.Name) ASC
            ]
        );

        for (AggregateResult plan : activePlans) {
            labelToValueMap.put((String) plan.get('expr0'), (String) plan.get('expr1'));
        }

        return labelToValueMap;
    }

    /**
     * Gets active school/departments values for the School/Department filter
     * If filter is set, and indicates an academicProgram, only return schools under that program
     *
     * @return labelToValueMap, a Map of picklist values by their labels.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSchoolDepartmentPicklistVaues(String filterJSON) {
        Map<String, String> labelToValueMap = new Map<String, String>();

        // Find organizations that have active plans and which are active themselves
        // looking at all active plans and taking each unique organization from there

        DynamicSoqlBuilder soqlBuilder = new DynamicSoqlBuilder('Plan__c')
            .returnField('MAX(Organization__r.Name)')
            .returnField('MAX(Organization__r.Organization_Code__c)')
            .restrictEqual('Plan_Status__c', true)
            .restrictEqual('Program__r.Career__c', 'Graduate')
            .restrictNotIn('Program__r.Program_Code__c', new List<String>{ 'GRPR', 'GCNV' })
            .restrictEqual('Organization__r.Organization_Status__c', true)
            .setGroupBy('Organization__c')
            .addHaving('MAX(Plan_Effective_Date__c) <= TODAY')
            .addHaving('MAX(Organization__r.Effective_Date__c) <= TODAY')
            .setOrder('MAX(Organization__r.Organization_Code__c) ASC');

        AdvisorPortalFilter filter = AdvisorPortalFilter.parse(filterJSON);
        if (filter != null) {
            if (!String.isBlank(filter.academicProgram))
                soqlBuilder.restrictIn('Program__r.Program_Code__c', filter.getAcademicPrograms());
        }

        String queryString = soqlBuilder.toString();

        LogSuite.log('query', queryString);
        for (AggregateResult plan : Database.query(queryString)) {
            String label = (String) plan.get('expr1') + ' / ' + (String) plan.get('expr0');
            String value = (String) plan.get('expr1');
            labelToValueMap.put(label, value);
        }

        return labelToValueMap;
    }

    /**
     * Gets active academic plans for the Academic Plan filter
     * If filter is set, and indicates an academicProgram, only return plans under that program
     *                 , and indicates a schoolDepartment, only return plans under that department
     *                 , and indicates a degree level, only return plans for that level
     *
     * @return labelToValueMap, a Map of picklist values by their labels.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getAcademicPlanPicklistValues(String filterJSON) {
        Map<String, String> labelToValueMap = new Map<String, String>();

        DynamicSoqlBuilder soqlBuilder = new DynamicSoqlBuilder('Plan__c')
            .returnField('Name')
            .returnField('Plan_Code__c')
            .restrictEqual('Plan_Status__c', true)
            .restrictEqual('Program__r.Career__c', 'Graduate')
            .restrictNotIn('Program__r.Program_Code__c', new List<String>{ 'GRPR', 'GCNV' })
            .restrictLessThanOrEqual('Plan_Effective_Date__c', new DynamicSoqlBuilderRestriction.Keyword('TODAY'))
            .setOrder('Plan_Code__c ASC');

        AdvisorPortalFilter filter = AdvisorPortalFilter.parse(filterJSON);
        if (filter != null) {
            if (!String.isBlank(filter.degreeLevel)) {
                DynamicSoqlBuilderRestriction.OrRestriction degreeLevelRestrict = new DynamicSoqlBuilderRestriction.OrRestriction();
                List<String> requirements = new List<String>();
                List<String> degreeLevels = filter.getDegreeLevels();

                if (degreeLevels.contains('masters')) {
                    degreeLevelRestrict.add(
                        new DynamicSoqlBuilderRestriction.AndRestriction(
                            new List<DynamicSoqlBuilderRestriction>{
                                new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type__c', 'MAJ'),
                                new DynamicSoqlBuilderRestriction.EqualRestriction('Degree_Level__c', 'Masters')
                            }
                        )
                    );
                }
                if (degreeLevels.contains('doctorate')) {
                    degreeLevelRestrict.add(
                        new DynamicSoqlBuilderRestriction.AndRestriction(
                            new List<DynamicSoqlBuilderRestriction>{
                                new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type__c', 'MAJ'),
                                new DynamicSoqlBuilderRestriction.EqualRestriction('Degree_Level__c', 'Doctorate')
                            }
                        )
                    );
                }
                if (degreeLevels.contains('certificate')) {
                    degreeLevelRestrict.add(new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type__c', 'CER'));
                }
                if (degreeLevels.contains('non-degree')) {
                    degreeLevelRestrict.add(new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type__c', 'NDG'));
                }

                if (degreeLevelRestrict.isNotEmpty()) {
                    soqlBuilder.restrict(degreeLevelRestrict);
                }
            }

            if (!String.isBlank(filter.academicProgram))
                soqlBuilder.restrictIn('Program__r.Program_Code__c', filter.getAcademicPrograms());

            if (!String.isBlank(filter.schoolDepartment))
                soqlBuilder.restrictIn('Organization__r.Organization_Code__c', filter.getSchoolDepartments());
        }

        String queryString = soqlBuilder.toString();

        LogSuite.log('query', queryString);
        for (Plan__c plan : Database.query(queryString)) {
            labelToValueMap.put(plan.Plan_Code__c + ' / ' + plan.Name, plan.Plan_Code__c);
        }

        return labelToValueMap;
    }

    @AuraEnabled
    public static String getFilteredCases(List<Id> viewAsOptions, String filterJSON) {
        AdvisorPortalFilter filter = AdvisorPortalFilter.parse(filterJSON);

        List<AdvisorPortalContact> results = new List<AdvisorPortalContact>();
        if (filter.caseTypeState == 'AllCasesState') {
            results = new AdvisorPortalFilterQueryMaker(
                    viewAsOptions,
                    filter,
                    AdvisorPortalFilterQueryMaker.QueryWith.WITH_CONTACT
                )
                .query();
        } else {
            results = new AdvisorPortalFilterQueryMaker(
                    viewAsOptions,
                    filter,
                    AdvisorPortalFilterQueryMaker.QueryWith.WITH_CASE
                )
                .query();
        }

        return JSON.serialize(results);
    }

    public class AdvisorPortalException extends Exception {
    }
}
