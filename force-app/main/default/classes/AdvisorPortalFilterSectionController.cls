public class AdvisorPortalFilterSectionController {
    private static Map<String, Set<Decimal>> outlookScoresByLabels = new Map<String, Set<Decimal>>{
        'very low' => new Set<Decimal>{ 0, 1, 2, 3 },
        'low' => new Set<Decimal>{ 4, 5 },
        'moderate' => new Set<Decimal>{ 6 },
        'high' => new Set<Decimal>{ 7 },
        'very high' => new Set<Decimal>{ 8, 9, 10 }
    };

    private static Map<String, Decimal> outlookChangeByLabels = new Map<String, Decimal>{
        'up' => 1,
        'down' => 0,
        'no change' => -1
    };

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
        if (filterJSON != null && filterJSON != '' && filterJSON != '{}') {
            AdvisorPortalFilter filter = (AdvisorPortalFilter) JSON.deserialize(filterJSON, AdvisorPortalFilter.class);

            List<Location__c> campusLocations = [
                SELECT Name, Graduate_Enabled__c, Location_Code__c
                FROM Location__c
                ORDER BY CreatedDate, Name
            ];

            if (filter != null && filter.career != null && filter.career == 'GRD') {
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
    public static Map<String, String> getCaseSubjectPicklistValues(List<Id> viewAsOptions) {
        Map<String, String> caseSubjectValuesByLabel = new Map<String, String>();

        Id recordType = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        for (AggregateResult result : [
            SELECT Subject
            FROM Case
            WHERE IsClosed = FALSE AND RecordTypeId = :recordType AND Subject != NULL AND OwnerId IN :viewAsOptions
            GROUP BY Subject
            LIMIT 2000
        ]) {
            if (result.get('Subject') != null) {
                caseSubjectValuesByLabel.put((String) result.get('Subject'), (String) result.get('Subject'));
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
    public static Map<String, String> getCaseClassificationPicklistValues(List<Id> viewAsOptions) {
        Map<String, String> caseClassificationValuesByLabel = new Map<String, String>();

        Id recordType = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');

        for (AggregateResult result : [
            SELECT CC_Category__r.Name CategoryName
            FROM Case
            WHERE
                IsClosed = FALSE
                AND RecordTypeId = :recordType
                AND CC_Category__c != NULL
                AND OwnerId IN :viewAsOptions
            GROUP BY CC_Category__r.Name
            LIMIT 2000
        ]) {
            if (result.get('CategoryName') != null) {
                caseClassificationValuesByLabel.put(
                    (String) result.get('CategoryName'),
                    (String) result.get('CategoryName')
                );
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
        String queryString =
            'SELECT Name, Plan_Code__c' +
            ' FROM Plan__c' +
            ' WHERE Plan_Status__c = TRUE' +
            ' AND Plan_Effective_Date__c <= TODAY' +
            ' AND Program__r.Career__c = \'Graduate\'' +
            ' AND Program__r.Program_Code__c NOT IN (\'GRPR\', \'GCNV\')';

        if (filterJSON != null && filterJSON != '' && filterJSON != '{}') {
            AdvisorPortalFilter filter = (AdvisorPortalFilter) JSON.deserialize(filterJSON, AdvisorPortalFilter.class);

            if (!String.isBlank(filter.degreeLevel)) {
                List<String> degreeLevels = filter.degreeLevel.split(';');
                Set<String> planTypesSet = new Set<String>();

                if (degreeLevels.contains('masters')) {
                    planTypesSet.add('MAJ');
                }
                if (degreeLevels.contains('doctorate')) {
                    planTypesSet.add('MAJ');
                }
                if (degreeLevels.contains('certificate')) {
                    planTypesSet.add('CER');
                }
                if (degreeLevels.contains('non-degree')) {
                    planTypesSet.add('NDG');
                }

                if (!planTypesSet.isEmpty()) {
                    List<String> planTypesList = new List<String>(planTypesSet);
                    queryString += ' AND Plan_Type__c IN :planTypesList';
                }
            }

            if (!String.isBlank(filter.academicProgram)) {
                List<String> academicPrograms = filter.academicProgram.split(';');
                queryString += ' AND Program__r.Program_Code__c IN :academicPrograms';
            }

            if (!String.isBlank(filter.schoolDepartment)) {
                List<String> schoolDepartments = filter.schoolDepartment.split(';');
                queryString += ' AND Program__r.Academic_Group__r.Academic_Group_Code__c IN :schoolDepartments';
            }
        }

        queryString += ' ORDER BY Plan_Code__c ASC';

        for (Plan__c plan : Database.query(queryString)) {
            labelToValueMap.put(plan.Plan_Code__c + ' / ' + plan.Name, plan.Plan_Code__c);
        }

        return labelToValueMap;
    }

    @AuraEnabled
    public static String getFilteredCases(List<Id> viewAsOptions, String filterJSON) {
        AdvisorPortalFilter filter = (AdvisorPortalFilter) JSON.deserialize(filterJSON, AdvisorPortalFilter.class);

        List<AdvisorPortalContact> results = new List<AdvisorPortalContact>();
        if (filter.caseTypeState == 'AllCasesState') {
            results = getAllContactsAndRespectiveCases(viewAsOptions, filter);
        } else {
            results = getCasesAndRespectiveContacts(viewAsOptions, filter);
        }

        return JSON.serialize(results);
    }

    /**
     * Query for our cases and apply as many filters as possible
     * Depending on searchByContactInsteadOfOwner, use idList as either a list of OwnerId's or Contacts
     *
     * @param viewAsOptions, a List of User/Queue OR Contact Ids to get cases by
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return shortenedAdvisorPortalContactResults, a filtered List of AdvisorPortalContact records (3000 maximum contacts/case wrappers).
     */
    private static List<AdvisorPortalContact> getCasesAndRespectiveContacts(
        List<Id> viewAsOptions,
        AdvisorPortalFilter filter
    ) {
        // These filters are done as separate queries due to their wide variety, and them needing to be UNIONed togther
        // (Salesforce not nice with OR in semi-joins)
        Set<Id> possibleContactIds = filterSpecialPopulations(filter, viewAsOptions, null);

        // Generate query string
        String caseQueryString = generateCaseSearchString(filter, viewAsOptions, possibleContactIds);

        // Get all possible results
        List<Case> allCases = Database.query(caseQueryString);

        Set<Id> contactIds = new Set<Id>();
        Map<Id, List<Case>> contactIdToCasesMap = new Map<Id, List<Case>>();
        for (Case c : allCases) {
            Id contactId = c.ContactId;
            contactIds.add(contactId);
            if (!contactIdToCasesMap.containsKey(contactId))
                contactIdToCasesMap.put(contactId, new List<Case>());
            contactIdToCasesMap.get(contactId).add(c);
        }

        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();
        Integer contactsLeft = 3000; // max number of contacts returned

        for (Id contactId : contactIdToCasesMap.keySet()) {
            if (!contactIds.contains(contactId))
                continue;
            if (contactsLeft <= 0)
                break;

            // Skip contact if we filter by Case count, but there aren't correct amount
            if (
                !String.isBlank(filter.caseCount) &&
                Integer.valueOf(filter.caseCount) > 0 &&
                contactIdToCasesMap.get(contactId).size() != Integer.valueOf(filter.caseCount)
            )
                continue;

            // Create the corresponding contact object from the contact of this case
            Contact contact = contactIdToCasesMap.get(contactId)[0].Contact;

            AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

            // Mark if in grad or ugrad mode
            if (filter.career == 'GRD') {
                contactWrapper.isGradStudent = true;
            } else {
                contactWrapper.isGradStudent = false;
            }

            List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();
            for (Case c : contactIdToCasesMap.get(contact.Id)) {
                caseWrappers.add(new AdvisorPortalCase(c));
            }
            if (!caseWrappers.isEmpty()) {
                contactWrapper.addCases(caseWrappers);
            }
            advisorPortalContactResults.add(contactWrapper);
            contactsLeft--;
        }

        return advisorPortalContactResults;
    }

    /**
     * Filters Contacts and Case wrappers on the Advisor Portal using the supplied view as options and filter.
     * Return a list for allContacts instead of just contacts with cases.
     *
     * @param viewAsOptions, a List of User/Queue Ids to get related Contacts to use in search.
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return shortenedAdvisorPortalContactResults, a filtered List of AdvisorPortalContact records (3000 maximum contacts/case wrappers).
     */
    public static List<AdvisorPortalContact> getAllContactsAndRespectiveCases(
        List<Id> viewAsOptions,
        AdvisorPortalFilter filter
    ) {
        // The query already has 2 semi-joins, so we need to do this separately
        Set<Id> possibleContactIds = filterStudentGroups(filter, viewAsOptions, null);

        // These filters are done as separate queries due to their wide variety, and them needing to be UNIONed togther
        // (Salesforce not nice with OR in semi-joins)
        possibleContactIds = filterSpecialPopulations(filter, viewAsOptions, possibleContactIds);

        // Generate query string
        String studentQueryString = generateStudentSearchString(filter, viewAsOptions, possibleContactIds);

        // Get all possible results
        List<Contact> allContacts = Database.query(studentQueryString);

        Set<Id> contactIds = new Set<Id>();
        for (Contact c : allContacts) {
            contactIds.add(c.Id);
        }

        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();
        Integer contactsLeft = 3000; // max number of contacts returned

        for (Contact contact : allContacts) {
            if (!contactIds.contains(contact.Id))
                continue;
            if (contactsLeft <= 0)
                break;

            // Skip contact if we filter by Case count, but there aren't correct amount
            if (
                !String.isBlank(filter.caseCount) &&
                Integer.valueOf(filter.caseCount) > 0 &&
                contact.cases.size() != Integer.valueOf(filter.caseCount)
            )
                continue;

            AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

            // Mark if in grad or ugrad mode
            if (filter.career == 'GRD') {
                contactWrapper.isGradStudent = true;
            } else {
                contactWrapper.isGradStudent = false;
            }

            List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();
            for (Case c : contact.cases) {
                caseWrappers.add(new AdvisorPortalCase(c));
            }
            if (!caseWrappers.isEmpty()) {
                contactWrapper.addCases(caseWrappers);
            }
            advisorPortalContactResults.add(contactWrapper);
            contactsLeft--;
        }

        return advisorPortalContactResults;
    }

    /**
     * Queries for Contact Ids based on the provided filter on Student_Group__c.
     * We have to do this separately sometimes since you are limited to 2 Semi-joins per query
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    @TestVisible
    private static Set<Id> filterStudentGroups(AdvisorPortalFilter filter, List<Id> ownerIds, Set<Id> contactIds) {
        if (contactIds == null)
            return getContactsFromStudentGroups(filter, ownerIds);

        Boolean useQueryString = false;
        Set<Id> filteredContactIds = new Set<Id>();
        String queryString = 'SELECT SG_Contact__c FROM Student_Group__c WHERE SG_Contact__c IN :contactIds';

        if (filter.career != null) {
            // if statement for using either undergrad filtering
            // if grad filtering, there still might be some of student group filters to apply
            // (for special populations), but they happen in a different place since they
            // need to be applied as a UNION rather than an INTERSECTION
            if (filter.career != 'GRD') {
                if (!String.isBlank(filter.studentGroupCode)) {
                    useQueryString = true;
                    queryString += ' AND SG_PeopleSoft_Code__c = \'' + filter.studentGroupCode + '\'';
                }
            }

            queryString += ' AND SG_Effective_Date__c <= TODAY';
            queryString += ' AND SG_Status__c = TRUE';
            queryString += ' GROUP BY SG_Contact__c LIMIT 4000';
        }
        // make query to filter - or return intial set of contactIds if no filtering is needed
        if (useQueryString) {
            for (AggregateResult studentPlanResult : Database.query(queryString)) {
                filteredContactIds.add((Id) studentPlanResult.get('SG_Contact__c'));
            }
            return filteredContactIds;
        } else {
            return contactIds;
        }
    }

    /**
     * Get contacts from student groups
     */
    private static Set<Id> getContactsFromStudentGroups(AdvisorPortalFilter filter, List<Id> ownerIds) {
        if (filter.career != 'GRD' && !String.isBlank(filter.studentGroupCode)) {
            Set<Id> contactIds = new Set<Id>();

            String queryString =
                'SELECT SG_Contact__c FROM Student_Group__c WHERE' +
                ' SG_PeopleSoft_Code__c = \'' +
                filter.studentGroupCode +
                '\'' +
                ' AND SG_Contact__c IN (' +
                generateSuccessStudentFilterString(ownerIds) +
                ')' +
                ' AND SG_Effective_Date__c <= TODAY' +
                ' AND SG_Status__c = TRUE' +
                ' GROUP BY SG_Contact__c LIMIT 4000';

            for (AggregateResult studentPlanResult : Database.query(queryString)) {
                contactIds.add((Id) studentPlanResult.get('SG_Contact__c'));
            }

            return contactIds;
        } else {
            return null;
        }
    }

    /**
     * Get all contacts that match the specific special populations
     */
    private static Set<Id> filterSpecialPopulations(AdvisorPortalFilter filter, List<Id> ownerIds, Set<Id> contactIds) {
        Boolean didFiltering = false;
        Set<Id> filteredContactIds = new Set<Id>();
        // note, these are all aditive, so we should UNION the results of all the special population filters
        if (filter.career == 'GRD') {
            if (!String.isBlank(filter.specialPopulation)) {
                didFiltering = true;

                Set<Id> filteredContactIds1 = getMatchesForSpecialPopulationDualOrAppliedToGrad(
                    filter,
                    ownerIds,
                    contactIds
                );
                Set<Id> filteredContactIds2 = getMatchesForSpecialPopulationFormatStudents(
                    filter,
                    ownerIds,
                    contactIds
                );
                Set<Id> filteredContactIds3 = getMatchesForSpecialPopulationProvisionalAdmitsAndRegistrationHold(
                    filter,
                    ownerIds,
                    contactIds
                );
                Set<Id> filteredContactIds4 = getMatchesForSpecialPopulationStudentGroups(filter, ownerIds, contactIds);

                filteredContactIds.addAll(filteredContactIds1);
                filteredContactIds.addAll(filteredContactIds2);
                filteredContactIds.addAll(filteredContactIds3);
                filteredContactIds.addAll(filteredContactIds4);
            }
        }

        if (didFiltering) {
            return filteredContactIds;
        } else {
            return contactIds;
        }
    }

    /**
     * Queries for Contact Ids based on the provided filter's special populations.  This handles all the one's that can be done simply
     * looking at the student's groups
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    private static Set<Id> getMatchesForSpecialPopulationStudentGroups(
        AdvisorPortalFilter filter,
        List<Id> ownerIds,
        Set<Id> contactIds
    ) {
        if (contactIds == null)
            return getContactsForSpecialPopulationStudentGroups(filter, ownerIds);

        Set<Id> filteredContactIds = new Set<Id>();

        String queryString =
            'SELECT SG_Contact__c' +
            ' FROM Student_Group__c' +
            ' WHERE SG_Contact__c IN :contactIds' +
            ' AND SG_Status__c = TRUE' +
            ' AND SG_Effective_Date__c <= TODAY';

        if (filter.career != null) {
            // if statement for using either grad level or undergrad level filtering
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    Set<String> acceptablePeoplesoftCodesSet = new Set<String>();
                    List<String> specialPopulations = filter.specialPopulation.split(';');
                    if (specialPopulations.contains('accelerated 4+1 degrees')) {
                        acceptablePeoplesoftCodesSet.add('GRAH'); // Active undergrad, 4 + 1 applicant
                        acceptablePeoplesoftCodesSet.add('GRAI'); // When matriculated as a student
                        acceptablePeoplesoftCodesSet.add('ADIP'); // International Accelerated (IADP) students
                    }
                    if (specialPopulations.contains('veterans')) {
                        acceptablePeoplesoftCodesSet.add('SR1B');
                        acceptablePeoplesoftCodesSet.add('SR1D');
                    }
                    if (specialPopulations.contains('mayo students')) {
                        acceptablePeoplesoftCodesSet.add('SRKY');
                    }
                    if (specialPopulations.contains('cintana students')) {
                        acceptablePeoplesoftCodesSet.add('ADAD'); // Cintana Students
                        acceptablePeoplesoftCodesSet.add('ADAM'); // hs dual enrollment students
                        acceptablePeoplesoftCodesSet.add('SRSA'); // teach for america students
                    }

                    if (!acceptablePeoplesoftCodesSet.isEmpty()) {
                        List<String> acceptablePeoplesoftCodesList = new List<String>(acceptablePeoplesoftCodesSet);
                        queryString += ' AND SG_PeopleSoft_Code__c IN :acceptablePeoplesoftCodesList';

                        queryString += ' GROUP BY SG_Contact__c LIMIT 2000';

                        for (AggregateResult studentPlanResult : Database.query(queryString)) {
                            filteredContactIds.add((Id) studentPlanResult.get('SG_Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }
    private static Set<Id> getContactsForSpecialPopulationStudentGroups(AdvisorPortalFilter filter, List<Id> ownerIds) {
        Set<Id> filteredContactIds = new Set<Id>();

        String queryString =
            'SELECT SG_Contact__c' +
            ' FROM Student_Group__c' +
            ' WHERE SG_Contact__c IN (' +
            generateSuccessStudentFilterString(ownerIds) +
            ')' +
            ' AND SG_Status__c = TRUE' +
            ' AND SG_Effective_Date__c <= TODAY';

        if (filter.career != null) {
            // if statement for using either grad level or undergrad level filtering
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    Set<String> acceptablePeoplesoftCodesSet = new Set<String>();
                    List<String> specialPopulations = filter.specialPopulation.split(';');
                    if (specialPopulations.contains('accelerated 4+1 degrees')) {
                        acceptablePeoplesoftCodesSet.add('GRAH'); // Active undergrad, 4 + 1 applicant
                        acceptablePeoplesoftCodesSet.add('GRAI'); // When matriculated as a student
                        acceptablePeoplesoftCodesSet.add('ADIP'); // International Accelerated (IADP) students
                    }
                    if (specialPopulations.contains('veterans')) {
                        acceptablePeoplesoftCodesSet.add('SR1B');
                        acceptablePeoplesoftCodesSet.add('SR1D');
                    }
                    if (specialPopulations.contains('mayo students')) {
                        acceptablePeoplesoftCodesSet.add('SRKY');
                    }
                    if (specialPopulations.contains('cintana students')) {
                        acceptablePeoplesoftCodesSet.add('ADAD'); // Cintana Students
                        acceptablePeoplesoftCodesSet.add('ADAM'); // hs dual enrollment students
                        acceptablePeoplesoftCodesSet.add('SRSA'); // teach for america students
                    }

                    if (!acceptablePeoplesoftCodesSet.isEmpty()) {
                        List<String> acceptablePeoplesoftCodesList = new List<String>(acceptablePeoplesoftCodesSet);
                        queryString += ' AND SG_PeopleSoft_Code__c IN :acceptablePeoplesoftCodesList';

                        queryString += ' GROUP BY SG_Contact__c LIMIT 2000';

                        for (AggregateResult studentPlanResult : Database.query(queryString)) {
                            filteredContactIds.add((Id) studentPlanResult.get('SG_Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }

    /**
     * Queries for Contact Ids based on the provided filter's special populations.  This handles all the one's that can be done simply
     * looking at the student's Student_Program_Plan__c
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    private static Set<Id> getMatchesForSpecialPopulationDualOrAppliedToGrad(
        AdvisorPortalFilter filter,
        List<Id> ownerIds,
        Set<Id> contactIds
    ) {
        if (contactIds == null)
            return getContactsForSpecialPopulationDualOrAppliedToGrad(filter, ownerIds);

        Set<Id> filteredContactIds = new Set<Id>();

        List<String> dualEnrollmentCareers = new List<String>{ 'Graduate', 'Law' };
        List<String> appliedToGraduateCodes = new List<String>{ 'AG', 'AP', 'GD', 'IR', 'PN' };

        // Query for both applied to graduate and dual enrollment
        List<Student_Program_Plan__c> potentialMatches = [
            SELECT Contact__c, Career__c, Status__c, Degree_Chkout_Stat_Code__c
            FROM Student_Program_Plan__c
            WHERE
                Contact__c IN :contactIds
                AND (Career__c IN :dualEnrollmentCareers
                OR (Career__c = 'Graduate'
                AND Degree_Chkout_Stat_Code__c IN :appliedToGraduateCodes))
                AND Status__c = 'Active in Program'
                AND Effective_Date__c <= TODAY
            ORDER BY Contact__c, Effective_Date__c, Plan_Sequence__c DESC NULLS LAST
            LIMIT 2000
        ];

        Id prevContactId = null;
        Id currContactId = null;
        Integer numberOfPlans = 0;
        for (Student_Program_Plan__c programPlan : potentialMatches) {
            prevContactId = currContactId;
            currContactId = programPlan.Contact__c;

            // first program plan for this contact, reset counter
            if (prevContactId != currContactId) {
                numberOfPlans = 0;
            }

            if (filter.career != null) {
                if (filter.career == 'GRD') {
                    if (!String.isBlank(filter.specialPopulation)) {
                        List<String> specialPopulations = filter.specialPopulation.split(';');
                        if (specialPopulations.contains('applied to graduate')) {
                            // this is a match for the applied to graduate filter
                            if (
                                programPlan.Career__c == 'Graduate' &&
                                programPlan.Status__c == 'Active in Program' &&
                                appliedToGraduateCodes.contains(programPlan.Degree_Chkout_Stat_Code__c)
                            ) {
                                filteredContactIds.add(currContactId);
                            }
                        }

                        if (specialPopulations.contains('concurrent enrollment')) {
                            // this is a match for the dual enrollment filter
                            if (dualEnrollmentCareers.contains(programPlan.Career__c)) {
                                numberOfPlans++;

                                if (numberOfPlans > 1) {
                                    filteredContactIds.add(currContactId);
                                }
                            }
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }
    private static Set<Id> getContactsForSpecialPopulationDualOrAppliedToGrad(
        AdvisorPortalFilter filter,
        List<Id> ownerIds
    ) {
        Set<Id> filteredContactIds = new Set<Id>();

        List<String> dualEnrollmentCareers = new List<String>{ 'Graduate', 'Law' };
        List<String> appliedToGraduateCodes = new List<String>{ 'AG', 'AP', 'GD', 'IR', 'PN' };

        // Query for both applied to graduate and dual enrollment
        String queryString =
            'SELECT Contact__c, Career__c, Status__c, Degree_Chkout_Stat_Code__c' +
            ' FROM Student_Program_Plan__c WHERE' +
            ' Contact__c IN (' +
            generateSuccessStudentFilterString(ownerIds) +
            ')' +
            ' AND (Career__c IN :dualEnrollmentCareers' +
            ' OR (Career__c = \'Graduate\'' +
            ' AND Degree_Chkout_Stat_Code__c IN :appliedToGraduateCodes))' +
            ' AND Status__c = \'Active in Program\'' +
            ' AND Effective_Date__c <= TODAY' +
            ' ORDER BY Contact__c, Effective_Date__c, Plan_Sequence__c DESC NULLS LAST' +
            ' LIMIT 2000';

        List<Student_Program_Plan__c> potentialMatches = Database.query(queryString);

        Id prevContactId = null;
        Id currContactId = null;
        Integer numberOfPlans = 0;
        for (Student_Program_Plan__c programPlan : potentialMatches) {
            prevContactId = currContactId;
            currContactId = programPlan.Contact__c;

            // first program plan for this contact, reset counter
            if (prevContactId != currContactId) {
                numberOfPlans = 0;
            }

            if (filter.career != null) {
                if (filter.career == 'GRD') {
                    if (!String.isBlank(filter.specialPopulation)) {
                        List<String> specialPopulations = filter.specialPopulation.split(';');
                        if (specialPopulations.contains('applied to graduate')) {
                            // this is a match for the applied to graduate filter
                            if (
                                programPlan.Career__c == 'Graduate' &&
                                programPlan.Status__c == 'Active in Program' &&
                                appliedToGraduateCodes.contains(programPlan.Degree_Chkout_Stat_Code__c)
                            ) {
                                filteredContactIds.add(currContactId);
                            }
                        }

                        if (specialPopulations.contains('concurrent enrollment')) {
                            // this is a match for the dual enrollment filter
                            if (dualEnrollmentCareers.contains(programPlan.Career__c)) {
                                numberOfPlans++;

                                if (numberOfPlans > 1) {
                                    filteredContactIds.add(currContactId);
                                }
                            }
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }

    /**
     * Queries for Contact Ids based on the provided filter's special populations.  This handles all the one's that can be done simply
     * looking at the student's Student_Milestone__c
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    private static Set<Id> getMatchesForSpecialPopulationFormatStudents(
        AdvisorPortalFilter filter,
        List<Id> ownerIds,
        Set<Id> contactIds
    ) {
        if (contactIds == null)
            return getContactsForSpecialPopulationFormatStudents(filter, ownerIds);

        Set<Id> filteredContactIds = new Set<Id>();

        if (filter.career != null) {
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    List<String> specialPopulations = filter.specialPopulation.split(';');
                    if (specialPopulations.contains('format students')) {
                        String currentPSCode = getCurrentPeoplesoftTermCode();
                        List<AggregateResult> mileStoneStudents = new List<AggregateResult>(
                            [
                                SELECT Contact__c
                                FROM Student_Milestone__c
                                WHERE
                                    Contact__c IN :contactIds
                                    AND Milestone__c = 'GRFORMAT'
                                    AND Effdt__c <= TODAY
                                    AND Term_Required__r.PeopleSoft_Code__c >= :currentPSCode
                                GROUP BY Contact__c
                                LIMIT 2000
                            ]
                        );

                        for (AggregateResult studentMilestone : mileStoneStudents) {
                            filteredContactIds.add((Id) studentMilestone.get('Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }
    private static Set<Id> getContactsForSpecialPopulationFormatStudents(
        AdvisorPortalFilter filter,
        List<Id> ownerIds
    ) {
        Set<Id> filteredContactIds = new Set<Id>();

        if (filter.career != null) {
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    List<String> specialPopulations = filter.specialPopulation.split(';');
                    if (specialPopulations.contains('format students')) {
                        String currentPSCode = getCurrentPeoplesoftTermCode();

                        String queryString =
                            'SELECT Contact__c FROM Student_Milestone__c WHERE' +
                            ' Contact__c IN (' +
                            generateSuccessStudentFilterString(ownerIds) +
                            ')' +
                            ' AND Milestone__c = \'GRFORMAT\'' +
                            ' AND Effdt__c <= TODAY' +
                            ' AND Term_Required__r.PeopleSoft_Code__c >= \'' +
                            currentPSCode +
                            '\'' +
                            ' GROUP BY Contact__c' +
                            ' LIMIT 2000';

                        List<AggregateResult> mileStoneStudents = (List<AggregateResult>) Database.query(queryString);

                        for (AggregateResult studentMilestone : mileStoneStudents) {
                            filteredContactIds.add((Id) studentMilestone.get('Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }

    /**
     * Queries for Contact Ids based on the provided filter's special populations.  This handles all the one's that can be done simply
     * looking at the student's Service_Indicator__c
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    private static Set<Id> getMatchesForSpecialPopulationProvisionalAdmitsAndRegistrationHold(
        AdvisorPortalFilter filter,
        List<Id> ownerIds,
        Set<Id> contactIds
    ) {
        if (contactIds == null)
            return getContactsForSpecialPopulationProvisionalAdmitsAndRegistrationHold(filter, ownerIds);

        Set<Id> filteredContactIds = new Set<Id>();

        if (filter.career != null) {
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    List<String> specialPopulations = filter.specialPopulation.split(';');

                    Boolean makeQuery = false;
                    String currentPSCode = getCurrentPeoplesoftTermCode();

                    String queryString = 'SELECT SI_Contact__c FROM Service_Indicator__c';
                    queryString += ' WHERE SI_Contact__c IN :contactIds';
                    queryString += ' AND SI_Start_Term__r.PeopleSoft_Code__c <= :currentPSCode';
                    queryString += ' AND SI_End_Term__r.PeopleSoft_Code__c >= :currentPSCode';

                    List<String> extraWhereClauseComponents = new List<String>();

                    if (specialPopulations.contains('provivisional admits, not met yet')) {
                        makeQuery = true;
                        extraWhereClauseComponents.add(
                            '(SI_Code__c = \'AD4\' AND SI_Reason__c = \'PROV\' AND SI_Positive_Service_Indicator__c = TRUE)'
                        );
                    }
                    if (specialPopulations.contains('active students with registation hold')) {
                        makeQuery = true;
                        extraWhereClauseComponents.add(
                            '(Enrollment_Impact__c = TRUE AND SI_Positive_Service_Indicator__c = FALSE)'
                        );
                    }

                    queryString += ' AND (' + String.join(extraWhereClauseComponents, ' OR ') + ')';

                    queryString += ' GROUP BY SI_Contact__c';
                    queryString += ' LIMIT 2000';

                    if (makeQuery) {
                        for (AggregateResult serviceIndicator : Database.query(queryString)) {
                            filteredContactIds.add((Id) serviceIndicator.get('SI_Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }
    private static Set<Id> getContactsForSpecialPopulationProvisionalAdmitsAndRegistrationHold(
        AdvisorPortalFilter filter,
        List<Id> ownerIds
    ) {
        Set<Id> filteredContactIds = new Set<Id>();

        if (filter.career != null) {
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    List<String> specialPopulations = filter.specialPopulation.split(';');

                    Boolean makeQuery = false;
                    String currentPSCode = getCurrentPeoplesoftTermCode();

                    String queryString = 'SELECT SI_Contact__c FROM Service_Indicator__c';
                    queryString += ' WHERE SI_Contact__c IN (' + generateSuccessStudentFilterString(ownerIds) + ')';
                    queryString += ' AND SI_Start_Term__r.PeopleSoft_Code__c <= :currentPSCode';
                    queryString += ' AND SI_End_Term__r.PeopleSoft_Code__c >= :currentPSCode';

                    List<String> extraWhereClauseComponents = new List<String>();

                    if (specialPopulations.contains('provivisional admits, not met yet')) {
                        makeQuery = true;
                        extraWhereClauseComponents.add(
                            '(SI_Code__c = \'AD4\' AND SI_Reason__c = \'PROV\' AND SI_Positive_Service_Indicator__c = TRUE)'
                        );
                    }
                    if (specialPopulations.contains('active students with registation hold')) {
                        makeQuery = true;
                        extraWhereClauseComponents.add(
                            '(Enrollment_Impact__c = TRUE AND SI_Positive_Service_Indicator__c = FALSE)'
                        );
                    }

                    queryString += ' AND (' + String.join(extraWhereClauseComponents, ' OR ') + ')';

                    queryString += ' GROUP BY SI_Contact__c';
                    queryString += ' LIMIT 2000';

                    if (makeQuery) {
                        for (AggregateResult serviceIndicator : Database.query(queryString)) {
                            filteredContactIds.add((Id) serviceIndicator.get('SI_Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }

    /**
     * Get query to search for cases, and grab student data with it
     * This should be used for seaching caseTypeState="ProactiveCasesState"|"WatchlistCasesState"
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param ownerIds, a Set of Owner Ids to use in the query.
     * @param contactIds, a Set of contact Id's to limit the results to
     *
     * @return Query String for mostly filtered results
     */
    private static String generateCaseSearchString(AdvisorPortalFilter filter, List<Id> ownerIds, Set<Id> contactIds) {
        String queryString =
            'SELECT Id, ' +
            'CaseNumber, ' +
            'Subject, ' +
            'Status, ' +
            'Followup_Date__c, ' +
            'Owner.Name, ' +
            'CreatedDate, ' +
            'CC_Category__r.Name, ' +
            'CC_Category__r.Parent__r.Name, ' +
            'RecordType.Name, ' +
            'Change_Date__c, ' +
            'Curr_Cont_Prediction_Level__c, ' +
            'Most_Recent_Outlook_Change_Direction__c, ' +
            'Most_Recent_Queue__c, ' +
            'Priority, ' +
            'OwnerId, ' +
            'ContactId, ' +
            'Contact.Id, ' +
            'Contact.Name, ' +
            'Contact.FirstName, ' +
            'Contact.Preferred_Full_Name__c, ' +
            'Contact.Preferred_First_Name__c, ' +
            'Contact.LastName, ' +
            'Contact.EmplId__c, ' +
            'Contact.ASURite_Id__c, ' +
            'Contact.US_Citizen__c, ' +
            'Contact.Change_Date__c, ' +
            'Contact.Most_Recent_Outlook_Change_Direction__c, ' +
            'Contact.Curr_Cont_Prediction_Level__c ' +
            'FROM Case ' +
            'WHERE';

        List<String> andStatements = new List<String>();

        andStatements.add('IsClosed = FALSE');
        andStatements.add('RecordTypeId = \'' + RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach') + '\'');

        if (!String.isBlank(filter.caseCategory)) {
            List<String> categories = filter.caseCategory.split(';');
            andStatements.add('CC_Category__r.Name IN ' + getSoqlListString(categories));
        }

        if (!String.isBlank(filter.caseSubject)) {
            List<String> subjects = filter.caseSubject.split(';');
            andStatements.add('Subject IN ' + getSoqlListString(subjects));
        }

        if (!String.isBlank(filter.caseStatus)) {
            List<String> statuses = filter.caseStatus.split(';');
            andStatements.add('Status IN ' + getSoqlListString(statuses));
        }

        andStatements.add('OwnerId IN ' + getSoqlListString(ownerIds));

        if (!String.isBlank(filter.caseTypeState) && filter.caseTypeState == 'WatchlistCasesState') {
            andStatements.add(
                'CC_Category__r.Name = \'Watchlist\' AND CC_Category__r.Parent__r.Name = \'ASU Advisor Outreach\''
            );
        }

        if (!String.isBlank(filter.outlookScore)) {
            List<Decimal> scores = new List<Decimal>();

            for (String s : filter.outlookScore.split(';')) {
                if (outlookScoresByLabels.containsKey(s)) {
                    scores.addAll(outlookScoresByLabels.get(s));
                }
            }

            andStatements.add('Curr_Cont_Prediction_Level__c IN ' + getSoqlListString(scores));
        }

        if (!String.isBlank(filter.outlookChange)) {
            List<Decimal> changeDirections = new List<Decimal>();

            for (String s : filter.outlookChange.split(';')) {
                if (outlookChangeByLabels.containsKey(s)) {
                    changeDirections.add(outlookChangeByLabels.get(s));
                }
            }

            andStatements.add('Most_Recent_Outlook_Change_Direction__c IN ' + getSoqlListString(changeDirections));
        }

        if (!String.isBlank(filter.createdFromDate)) {
            andStatements.add(
                'CreatedDate >= ' +
                Datetime.valueOf(filter.createdFromDate + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ')
            );
        }

        if (!String.isBlank(filter.createdToDate)) {
            andStatements.add(
                'CreatedDate <= ' +
                Datetime.valueOf(filter.createdToDate + ' 23:59:59').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ')
            );
        }

        if (!String.isBlank(filter.followUpFromDate)) {
            andStatements.add('Followup_Date__c >= ' + filter.followUpFromDate);
        }

        if (!String.isBlank(filter.followUpToDate)) {
            andStatements.add('Followup_Date__c <= ' + filter.followUpToDate);
        }

        if (!String.isBlank(filter.persistenceFromDate)) {
            andStatements.add('Change_Date__c >= ' + filter.persistenceFromDate);
        }

        if (!String.isBlank(filter.persistenceToDate)) {
            andStatements.add('Change_Date__c <= ' + filter.persistenceToDate);
        }

        if (!String.isBlank(filter.studentString)) {
            String nameQuery =
                '(' +
                'Contact.Preferred_Full_Name__c = \'' +
                filter.studentString +
                '\' OR Contact.Name = \'' +
                filter.studentString +
                '\' OR Contact.EmplId__c = \'' +
                filter.studentString +
                '\' OR Contact.ASURite_ID__c = \'' +
                filter.studentString +
                '\') ';

            andStatements.add(nameQuery);
        }

        String filterByStudentProgramPlanString = generateStudentProgramPlanFilterString(filter);
        if (filterByStudentProgramPlanString != null)
            andStatements.add('ContactId IN (' + filterByStudentProgramPlanString + ')');

        String filterByStudentGroupString = generateStudentGroupFilterString(filter);
        if (filterByStudentGroupString != null)
            andStatements.add('ContactId IN (' + filterByStudentGroupString + ')');

        if (contactIds != null)
            andStatements.add('ContactId IN ' + getSoqlListString(new List<Id>(contactIds)));

        queryString += ' ' + String.join(andStatements, ' AND ');
        queryString += ' ORDER BY Contact.LastName, Contact.Preferred_First_Name__c ASC';
        queryString += ' LIMIT 30000';

        return queryString;
    }

    /**
     * Get query to search for students, and grab case data with it
     * This should be used for seaching caseTypeState="AllCasesState"
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param ownerIds, a Set of Owner Ids to use in the query.
     *
     * @return Query String for mostly filtered results
     */

    private static String generateStudentSearchString(
        AdvisorPortalFilter filter,
        List<Id> ownerIds,
        Set<Id> contactIds
    ) {
        String queryString =
            'SELECT Id, Name, ' +
            '(SELECT Id, CaseNumber, Subject, Status, Followup_Date__c, OwnerId, Owner.Name, ' +
            'CreatedDate, CC_Category__r.Name, CC_Category__r.Parent__r.Name, RecordType.Name, ' +
            'Change_Date__c, Curr_Cont_Prediction_Level__c, ' +
            'Most_Recent_Outlook_Change_Direction__c, Most_Recent_Queue__c, Priority FROM Cases)' +
            ' FROM Contact WHERE';

        List<String> andStatements = new List<String>();

        andStatements.add('Id IN (' + generateSuccessStudentFilterString(ownerIds) + ')');

        if (!String.isBlank(filter.outlookScore)) {
            List<Decimal> scores = new List<Decimal>();

            for (String s : filter.outlookScore.split(';')) {
                if (outlookScoresByLabels.containsKey(s)) {
                    scores.addAll(outlookScoresByLabels.get(s));
                }
            }

            andStatements.add('Curr_Cont_Prediction_Level__c IN ' + getSoqlListString(scores));
        }

        if (!String.isBlank(filter.outlookChange)) {
            List<Decimal> changeDirections = new List<Decimal>();

            for (String s : filter.outlookChange.split(';')) {
                if (outlookChangeByLabels.containsKey(s)) {
                    changeDirections.add(outlookChangeByLabels.get(s));
                }
            }

            andStatements.add('Most_Recent_Outlook_Change_Direction__c IN ' + getSoqlListString(changeDirections));
        }

        if (!String.isBlank(filter.persistenceFromDate)) {
            andStatements.add('Change_Date__c >= ' + filter.persistenceFromDate);
        }

        if (!String.isBlank(filter.persistenceToDate)) {
            andStatements.add('Change_Date__c <= ' + filter.persistenceToDate);
        }

        if (!String.isBlank(filter.studentString)) {
            String nameQuery =
                '(' +
                'Preferred_Full_Name__c = \'' +
                filter.studentString +
                '\' OR Name = \'' +
                filter.studentString +
                '\' OR EmplId__c = \'' +
                filter.studentString +
                '\' OR ASURite_ID__c = \'' +
                filter.studentString +
                '\') ';

            andStatements.add(nameQuery);
        }

        String filterByStudentProgramPlanString = generateStudentProgramPlanFilterString(filter);

        if (filterByStudentProgramPlanString != null)
            andStatements.add('Id IN (' + filterByStudentProgramPlanString + ')');

        // contactIds should be the valid student groups, since we are limited to 2 Semi-joins and can't do it using semi-join in this case
        // if Salesforce ever increases that limit, then we can do semi-join here rather than passing in the possible ids
        if (contactIds != null)
            andStatements.add('Id IN ' + getSoqlListString(new List<Id>(contactIds)));

        queryString += ' ' + String.join(andStatements, ' AND ');

        queryString += ' ORDER BY LastName, Preferred_First_Name__c ASC';

        return queryString;
    }

    /**
     * Get the query to filter by student group
     *
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return Query string for student groups, or null if it shouldn't be used
     */
    private static String generateStudentGroupFilterString(AdvisorPortalFilter filter) {
        String queryString = null;
        if (!String.isBlank(filter.studentGroupCode)) {
            queryString =
                'SELECT SG_Contact__c FROM Student_Group__c WHERE' +
                ' SG_Effective_Date__c <= TODAY' +
                ' AND SG_Status__c = TRUE' +
                ' AND SG_PeopleSoft_Code__c = \'' +
                filter.studentGroupCode +
                '\'';
        }
        return queryString;
    }

    /**
     * Get the query to filter by student program plans
     *
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return Query string for student program plans, or null if it shouldn't be used
     */
    private static String generateStudentProgramPlanFilterString(AdvisorPortalFilter filter) {
        String queryString = 'SELECT Contact__c FROM Student_Program_Plan__c WHERE';

        if (filter.career == 'GRD') {
            queryString += ' Career__c = \'Graduate\'';
        } else {
            queryString += ' Career__c != \'Graduate\'';
        }

        if (!String.isBlank(filter.degreeLevel)) {
            List<String> degreeLevels = filter.degreeLevel.split(';');
            List<String> degreeLevelQueryComponents = new List<String>();

            if (degreeLevels.contains('masters')) {
                degreeLevelQueryComponents.add('(Plan_Type_Text__c = \'MAJ\' AND Education_Level__c=\'17\')');
            }
            if (degreeLevels.contains('doctorate')) {
                degreeLevelQueryComponents.add('(Plan_Type_Text__c = \'MAJ\' AND Education_Level__c=\'21\')');
            }
            if (degreeLevels.contains('certificate')) {
                degreeLevelQueryComponents.add('(Plan_Type_Text__c = \'CER\')');
            }
            if (degreeLevels.contains('non-degree')) {
                degreeLevelQueryComponents.add('(Plan_Type_Text__c = \'NDG\')');
            }

            if (!degreeLevelQueryComponents.isEmpty()) {
                queryString += ' AND (' + String.join(degreeLevelQueryComponents, ' OR ') + ')';
            }
        }

        if (!String.isBlank(filter.academicProgram)) {
            List<String> academicPrograms = filter.academicProgram.split(';');
            queryString += ' AND Program_Code__c IN ' + getSoqlListString(academicPrograms);
        }

        if (!String.isBlank(filter.academicPlan)) {
            List<String> academicPlans = filter.academicPlan.split(';');
            queryString += ' AND Plan_Code__c IN ' + getSoqlListString(academicPlans);
        }

        if (!String.isBlank(filter.admitTermFrom)) {
            queryString += ' AND (Admit_Term__r.PeopleSoft_Code__c >= \'' + filter.admitTermFrom + '\'';
            queryString += ' OR Requirement_Term__c >= \'' + filter.admitTermFrom + '\')';
        }

        if (!String.isBlank(filter.admitTermTo)) {
            queryString += ' AND (Admit_Term__r.PeopleSoft_Code__c <= \'' + filter.admitTermTo + '\'';
            queryString += ' OR Requirement_Term__c <= \'' + filter.admitTermTo + '\')';
        }

        if (!String.isBlank(filter.academicLevel)) {
            List<String> academicLevels = filter.academicLevel.split(';');
            queryString += ' AND Cohort__c IN ' + getSoqlListString(academicLevels);
        }

        if (!String.isBlank(filter.major)) {
            queryString +=
                ' AND  Plan_Type_Text__c = \'MAJ\' AND ( Plan_Description__c LIKE \'%' +
                filter.major +
                '%\' OR Plan_Code__c LIKE \'%' +
                filter.major +
                '%\' )';
        }

        if (!String.isBlank(filter.campus)) {
            List<String> campuses = filter.campus.split(';');
            queryString += ' AND Campus__r.Location_Code__c IN ' + getSoqlListString(campuses);
        }

        if (!String.isBlank(filter.residency)) {
            List<String> residencies = filter.residency.split(';');
            queryString += ' AND Residency__c IN ' + getSoqlListString(residencies);
        }

        return queryString;
    }

    private static String generateSuccessStudentFilterString(List<Id> ownerIds) {
        return 'SELECT Student__c FROM Success_Student__c WHERE Success_Pod__r.OwnerId IN ' +
            getSoqlListString(ownerIds) +
            ' AND Is_Active__c = TRUE';
    }

    private static String getSoqlListString(List<String> values) {
        List<String> quoted = new List<String>();
        for (String v : values)
            quoted.add('\'' + v + '\'');
        return '(' + String.join(quoted, ', ') + ')';
    }

    private static String getSoqlListString(List<Id> values) {
        List<String> quoted = new List<String>();
        for (Id v : values)
            quoted.add('\'' + v + '\'');
        return '(' + String.join(quoted, ', ') + ')';
    }

    private static String getSoqlListString(List<Decimal> values) {
        List<String> quoted = new List<String>();
        for (Decimal v : values)
            quoted.add(v.toPlainString());
        return '(' + String.join(quoted, ', ') + ')';
    }

    private static String getCurrentPeoplesoftTermCode() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        return currentTermData.CurrTerm__c;
    }
}
