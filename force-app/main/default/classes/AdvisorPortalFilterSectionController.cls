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
        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);

        if (filter != null) {
            List<Location__c> campusLocations = [
                SELECT Name, Graduate_Enabled__c, Location_Code__c
                FROM Location__c
                ORDER BY CreatedDate, Name
            ];

            if (filter.career != null && filter.career == 'GRD') {
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
        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);

        if (filter != null) {
            if (filter.career != null && filter.career == 'GRD') {
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
        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);

        Boolean gradMode = filter != null && filter.career == 'GRD';

        if (gradMode) {
            /**
             * In grad mode, we show all possible categories, these are all under the 'ASU Graduate Advisor Portal' functional group
             * specifically, we are leaving out the "Watchlist" category because that is handled by the "Watchlist Cases" toggle
             */
            String categoryRecordType = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category');
            for (Case_Classification__c category : [
                SELECT Id, Name
                FROM Case_Classification__c
                WHERE
                    Parent__r.Name = 'ASU Graduate Advisor Portal'
                    AND RecordTypeId = :categoryRecordType
                    AND Name != 'Watchlist'
                    AND Active__c = TRUE
                    AND Visible__c = TRUE
            ]) {
                String label = category.Name;
                String value = EncodingUtil.base64Encode(Blob.valueOf(label));
                caseClassificationValuesByLabel.put(label, value);
            }
        } else {
            /**
             * In undergrad mode, we limit to only case categories that are on at least one case
             */
            String undergradRecordType = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            for (AggregateResult result : [
                SELECT CC_Category__r.Name CategoryName
                FROM Case
                WHERE
                    IsClosed = FALSE
                    AND RecordTypeId = :undergradRecordType
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
        }

        return caseClassificationValuesByLabel;
    }

    /**
     * Gets Case Sub-Category picklist values for the Subcategory filter when category selections change.
     *
     * @param filterJSON JSON serialized filter state (to allow us to only return the subcategories for the selected cateogries)
     * @param viewAsOptions, a List of User/Queue Ids to limit cases owned by.
     * @return caseSubClassificationValuesByLabel, a Map of Case Subclassifications.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCaseSubClassificationPicklistValues(
        String filterJSON,
        List<Id> viewAsOptions
    ) {
        Map<String, String> caseSubClassificationValuesByLabel = new Map<String, String>();
        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);

        Boolean gradMode = filter != null && filter.career == 'GRD';

        if (gradMode) {
            /**
             * In grad mode, we show all possible subcategories, these are all under the 'ASU Graduate Advisor Portal' functional group
             * except those under the Watchlist category
             * also if, category is set in filter, limit to only subcategories in that category
             */
            String subcategoryRecordType = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category');

            DynamicSoqlBuilder soqlBuilder = new DynamicSoqlBuilder('Case_Classification__c')
                .returnField('Id')
                .returnField('Name')
                .restrictEqual('Parent__r.Parent__r.Name', 'ASU Graduate Advisor Portal')
                .restrictNotEqual('Parent__r.Name', 'Watchlist')
                .restrictEqual('Active__c', true)
                .restrictEqual('Visible__c', true)
                .restrictEqual('RecordTypeId', subcategoryRecordType);

            // Additionally filter on parent__r.name if category is set
            if (filter != null)
                if (String.isNotBlank(filter.caseCategory)) {
                    soqlBuilder.restrictIn('Parent__r.Name', filter.getCaseCategories());
                }

            String queryString = soqlBuilder.toString();

            LogSuite.log('query', queryString);
            for (Case_Classification__c category : Database.query(queryString)) {
                String label = category.Name;
                String value = EncodingUtil.base64Encode(Blob.valueOf(label));
                caseSubClassificationValuesByLabel.put(label, value);
            }
        } else {
            /**
             * In undergrad mode, we limit to only case subcategories that are on at least one case
             */
            String ugradAdvisorCasesRecType = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

            DynamicSoqlBuilder soqlBuilder = new DynamicSoqlBuilder('Case')
                .returnField('CC_Sub_Category__r.Name SubCategoryName')
                .restrictNotEqual('CC_Sub_Category__c', new DynamicSoqlBuilderRestriction.Keyword('NULL'))
                .restrictEqual('IsClosed', false)
                .restrictEqual('RecordTypeId', ugradAdvisorCasesRecType)
                .restrictIn('OwnerId', viewAsOptions)
                .setGroupBy('CC_Sub_Category__r.Name')
                .setLimit(2000);

            // Additionally filter on category, if set
            if (filter != null)
                if (String.isNotBlank(filter.caseCategory)) {
                    soqlBuilder.restrictIn('CC_Category__r.Name', filter.getCaseCategories());
                }

            String queryString = soqlBuilder.toString();

            LogSuite.log('query', queryString);
            for (AggregateResult plan : Database.query(queryString)) {
                String label = (String) plan.get('SubCategoryName');
                String value = EncodingUtil.base64Encode(Blob.valueOf(label));
                caseSubClassificationValuesByLabel.put(label, value);
            }
        }

        return caseSubClassificationValuesByLabel;
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

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);
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

        DynamicSoqlBuilder soqlBuilder = new DynamicSoqlBuilder(Schema.SObjectType.Plan__c)
            .returnField(Schema.SObjectType.Plan__c.fields.Name)
            .returnField(Schema.SObjectType.Plan__c.fields.Plan_Code__c)
            .restrictEqual(Schema.SObjectType.Plan__c.fields.Plan_Status__c, true)
            .restrictEqual('Program__r.Career__c', 'Graduate')
            .restrictNotIn('Program__r.Program_Code__c', new List<String>{ 'GRPR', 'GCNV' })
            // No GERT plans
            .restrict(
                new DynamicSoqlBuilderRestriction.NotRestriction(
                    new DynamicSoqlBuilderRestriction.AndRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.LikeRestriction('Program__r.Program_Code__c', 'GR%'),
                            new DynamicSoqlBuilderRestriction.EqualRestriction(
                                Schema.SObjectType.Plan__c.fields.Plan_Type__c.getName(),
                                'CER'
                            ),
                            new DynamicSoqlBuilderRestriction.OrRestriction(
                                new List<DynamicSoqlBuilderRestriction>{
                                    new DynamicSoqlBuilderRestriction.LikeRestriction(
                                        Schema.SObjectType.Plan__c.fields.Plan_Code__c.getName(),
                                        '%GERT'
                                    ),
                                    new DynamicSoqlBuilderRestriction.LikeRestriction(
                                        Schema.SObjectType.Plan__c.fields.Name.getName(),
                                        'UG-%'
                                    )
                                }
                            )
                        }
                    )
                )
            )
            // Only active plans
            .restrictLessThanOrEqual(
                Schema.SObjectType.Plan__c.fields.Plan_Effective_Date__c,
                new DynamicSoqlBuilderRestriction.Keyword('TODAY')
            )
            .setOrder('Plan_Code__c ASC');

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);
        if (filter != null) {
            if (String.isNotBlank(filter.degreeLevel)) {
                DynamicSoqlBuilderRestriction.OrRestriction degreeLevelRestrict = new DynamicSoqlBuilderRestriction.OrRestriction();
                List<String> requirements = new List<String>();
                List<String> degreeLevels = filter.getDegreeLevels();

                if (degreeLevels.contains('masters')) {
                    degreeLevelRestrict.add(
                        new DynamicSoqlBuilderRestriction.AndRestriction(
                            new List<DynamicSoqlBuilderRestriction>{
                                new DynamicSoqlBuilderRestriction.EqualRestriction(
                                    Schema.SObjectType.Plan__c.fields.Plan_Type__c.getName(),
                                    'MAJ'
                                ),
                                new DynamicSoqlBuilderRestriction.EqualRestriction(
                                    Schema.SObjectType.Plan__c.fields.Degree_Level__c.getName(),
                                    'Masters'
                                )
                            }
                        )
                    );
                }
                if (degreeLevels.contains('doctorate')) {
                    degreeLevelRestrict.add(
                        new DynamicSoqlBuilderRestriction.AndRestriction(
                            new List<DynamicSoqlBuilderRestriction>{
                                new DynamicSoqlBuilderRestriction.EqualRestriction(
                                    Schema.SObjectType.Plan__c.fields.Plan_Type__c.getName(),
                                    'MAJ'
                                ),
                                new DynamicSoqlBuilderRestriction.EqualRestriction(
                                    Schema.SObjectType.Plan__c.fields.Degree_Level__c.getName(),
                                    'Doctorate'
                                )
                            }
                        )
                    );
                }
                if (degreeLevels.contains('certificate')) {
                    degreeLevelRestrict.add(
                        new DynamicSoqlBuilderRestriction.EqualRestriction(
                            Schema.SObjectType.Plan__c.fields.Plan_Type__c.getName(),
                            'CER'
                        )
                    );
                }
                if (degreeLevels.contains('non-degree')) {
                    degreeLevelRestrict.add(
                        new DynamicSoqlBuilderRestriction.EqualRestriction(
                            Schema.SObjectType.Plan__c.fields.Plan_Type__c.getName(),
                            'NDG'
                        )
                    );
                }

                if (degreeLevelRestrict.isNotEmpty()) {
                    soqlBuilder.restrict(degreeLevelRestrict);
                }
            }

            if (String.isNotBlank(filter.academicProgram))
                soqlBuilder.restrictIn('Program__r.Program_Code__c', filter.getAcademicPrograms());

            if (String.isNotBlank(filter.schoolDepartment))
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
        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterJSON);

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
