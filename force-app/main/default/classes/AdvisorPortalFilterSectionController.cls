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
        Map<String, String> picklistValuesByLabel = new Map<String, String>();

        for (
            Schema.PicklistEntry picklistValue : Schema.getGlobalDescribe()
                .get(objectName)
                .getDescribe()
                .fields.getMap()
                .get(fieldName)
                .getDescribe()
                .getPicklistValues()
        ) {
            if (picklistValue.isActive()) {
                picklistValuesByLabel.put(picklistValue.getLabel(), picklistValue.getValue());
            }
        }

        return picklistValuesByLabel;
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
            LIMIT 10000
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
            LIMIT 10000
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
                HAVING MAX(Plan_Effective_Date__c) < TODAY
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
            ' AND Program__r.Career__c = \'Graduate\'';

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
            results = getContactCaseWrappersWithLessQueries(viewAsOptions, filter);
        }

        return JSON.serialize(results);
    }

    /**
     * Filters Contacts and Case wrappers on the Advisor Portal using the supplied view as options and filter.
     *
     * @param viewAsOptions, a List of User/Queue Ids to use in search.
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return shortenedAdvisorPortalContactResults, a filtered List of AdvisorPortalContact records (3000 maximum contacts/case wrappers).
     */
    public static List<AdvisorPortalContact> getContactCaseWrappersWithLessQueries(
        List<Id> viewAsOptions,
        AdvisorPortalFilter filter
    ) {
        Set<Contact> allCaseContacts = new Set<Contact>();
        Set<Contact> filteredCaseContacts = new Set<Contact>();
        Set<Id> filteredContactIds = new Set<Id>();
        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();
        Map<Id, List<Case>> casesByContactIds = new Map<Id, List<Case>>();
        Integer contactsLeft = 3000; // max number of contacts returned

        // Query for cases owned by viewAsOptions and following cases-related filters (and some contact related ones)
        List<Case> filteredCases = queryForCasesWithContactData(viewAsOptions, filter, false);

        for (Case eachCase : filteredCases) {
            allCaseContacts.add(eachCase.Contact);
        }

        for (Contact eachContact : allCaseContacts) {
            if (eachContact != null && eachContact.Id != null) {
                filteredContactIds.add(eachContact.Id);
            }
        }

        // Filter based on Student Groups
        filteredContactIds = filterStudentGroups(filter, filteredContactIds);

        // Filter based on Student Plans
        filteredContactIds = filterStudentPlans(filter, filteredContactIds);

        // Filter on special populations if possible
        // note, these are all aditive, so we should UNION the results of all the special population filters
        if (filter.career == 'GRD') {
            if (!String.isBlank(filter.specialPopulation)) {
                Set<Id> filteredContactIds1 = getMatchesForSpecialPopulationDualOrAppliedToGrad(
                    filter,
                    filteredContactIds
                );
                Set<Id> filteredContactIds2 = getMatchesForSpecialPopulationFormatStudents(filter, filteredContactIds);
                Set<Id> filteredContactIds3 = getMatchesForSpecialPopulationProvisionalAdmits(
                    filter,
                    filteredContactIds
                );
                Set<Id> filteredContactIds4 = getMatchesForSpecialPopulationRegistrationHold(
                    filter,
                    filteredContactIds
                );
                Set<Id> filteredContactIds5 = getMatchesForSpecialPopulationStudentGroups(filter, filteredContactIds);

                filteredContactIds.clear();
                filteredContactIds.addAll(filteredContactIds1);
                filteredContactIds.addAll(filteredContactIds2);
                filteredContactIds.addAll(filteredContactIds3);
                filteredContactIds.addAll(filteredContactIds4);
                filteredContactIds.addAll(filteredContactIds5);
            }
        }

        // Remove cases that don't match contact filters and generate list of filteredCaseContacts
        for (Integer i = 0; i < filteredCases.size(); i++) {
            Case eachCase = filteredCases.get(i);
            if (filteredContactIds.contains(eachCase.ContactId)) {
                filteredCaseContacts.add(eachCase.Contact);
            } else {
                filteredCases.remove(i);
                i--;
            }
        }

        // Add mapping of contactId to case list
        for (Case eachCase : filteredCases) {
            if (!casesByContactIds.containsKey(eachCase.ContactId)) {
                casesByContactIds.put(eachCase.ContactId, new List<Case>{ eachCase });
            } else {
                casesByContactIds.get(eachCase.ContactId).add(eachCase);
            }
        }

        // Add filtered Contact/Case records to wrapper.
        for (Contact contact : filteredCaseContacts) {
            if (contactsLeft <= 0) {
                break;
            }

            // Skip contact if we filter by Case count, but there aren't any.
            if (
                !casesByContactIds.containsKey(contact.Id) &&
                !String.isBlank(filter.caseCount) &&
                Integer.valueOf(filter.caseCount) > 0
            ) {
                continue;
            }

            AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

            if (casesByContactIds.containsKey(contact.Id)) {
                // Skip Contact if we filter by Case count and it has less than we want.
                if (
                    !String.isBlank(filter.caseCount) &&
                    casesByContactIds.get(contact.Id).size() != Integer.valueOf(filter.caseCount)
                ) {
                    continue;
                }

                List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();

                for (Case caseResult : casesByContactIds.get(contact.Id)) {
                    caseWrappers.add(new AdvisorPortalCase(caseResult));
                }

                contactWrapper.addCases(caseWrappers);
                advisorPortalContactResults.add(contactWrapper);
                contactsLeft--;
            }
        }

        return advisorPortalContactResults;
    }

    /**
     * Query for our cases and apply as many filters as possible
     * Depending on searchByContactInsteadOfOwner, use idList as either a list of OwnerId's or Contacts
     *
     * @param idList, a List of User/Queue OR Contact Ids to get cases by
     * @param filter, the AdvisorPortalFilter to use.
     * @param searchByContactInsteadOfOwner, if idList is a list of contact id's
     *
     * @return Database.query(queryString), the result of that query
     */
    private static List<Case> queryForCasesWithContactData(
        List<Id> idList,
        AdvisorPortalFilter filter,
        Boolean searchByContactInsteadOfOwner
    ) {
        String queryString =
            '' +
            'SELECT Priority, ' +
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
            'OwnerId, ' +
            'ContactId, ' +
            'Id, ' +
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
            'WHERE IsClosed = FALSE ' +
            'AND RecordTypeId = \'' +
            RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach') +
            '\'';

        if (!String.isBlank(filter.caseCategory)) {
            List<String> categories = filter.caseCategory.split(';');
            queryString += ' AND CC_Category__r.Name IN :categories';
        }

        if (!String.isBlank(filter.caseSubject)) {
            List<String> subjects = filter.caseSubject.split(';');
            queryString += ' AND Subject IN :subjects';
        }

        if (!String.isBlank(filter.caseStatus)) {
            List<String> statuses = filter.caseStatus.split(';');
            queryString += ' AND Status IN :statuses';
        }

        if (searchByContactInsteadOfOwner) {
            queryString += ' AND ContactId IN :idList';
        } else {
            queryString += ' AND OwnerId IN :idList';
        }

        if (!String.isBlank(filter.caseTypeState) && filter.caseTypeState == 'WatchlistCasesState') {
            queryString += ' AND CC_Category__r.Name = \'Watchlist\' AND CC_Category__r.Parent__r.Name = \'ASU Advisor Outreach\'';
        }

        if (!String.isBlank(filter.outlookScore)) {
            List<Decimal> scores = new List<Decimal>();

            for (String s : filter.outlookScore.split(';')) {
                if (outlookScoresByLabels.containsKey(s)) {
                    scores.addAll(outlookScoresByLabels.get(s));
                }
            }

            queryString += ' AND Curr_Cont_Prediction_Level__c IN :scores';
        }

        if (!String.isBlank(filter.outlookChange)) {
            List<Decimal> changeDirections = new List<Decimal>();

            for (String s : filter.outlookChange.split(';')) {
                if (outlookChangeByLabels.containsKey(s)) {
                    changeDirections.add(outlookChangeByLabels.get(s));
                }
            }

            queryString += ' AND Most_Recent_Outlook_Change_Direction__c IN :changeDirections';
        }

        if (!String.isBlank(filter.createdFromDate)) {
            queryString +=
                ' AND CreatedDate >= ' +
                Datetime.valueOf(filter.createdFromDate + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        if (!String.isBlank(filter.createdToDate)) {
            queryString +=
                ' AND CreatedDate <= ' +
                Datetime.valueOf(filter.createdToDate + ' 23:59:59').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        if (!String.isBlank(filter.followUpFromDate)) {
            queryString += ' AND Followup_Date__c >= ' + filter.followUpFromDate;
        }

        if (!String.isBlank(filter.followUpToDate)) {
            queryString += ' AND Followup_Date__c <= ' + filter.followUpToDate;
        }

        if (!String.isBlank(filter.persistenceFromDate)) {
            queryString += ' AND Change_Date__c >= ' + filter.persistenceFromDate;
        }

        if (!String.isBlank(filter.persistenceToDate)) {
            queryString += ' AND Change_Date__c <= ' + filter.persistenceToDate;
        }

        if (!String.isBlank(filter.studentString)) {
            queryString += ' AND ( Contact.Preferred_Full_Name__c = \'' + filter.studentString;
            queryString += '\' OR Contact.Name = \'' + filter.studentString;
            queryString += '\' OR Contact.EmplId__c = \'' + filter.studentString;
            queryString += '\' OR Contact.ASURite_ID__c = \'' + filter.studentString;
            queryString += '\') ';
        }

        queryString += ' ORDER BY Contact.LastName, Contact.Preferred_First_Name__c ASC';
        queryString += ' LIMIT 30000';

        return Database.query(queryString);
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
        List<Contact> contacts = getAllContacts(viewAsOptions, filter);
        return getContactCaseWrappersFor(contacts, filter);
    }

    // Get all students for viewAsOptions, following a filter
    private static List<Contact> getAllContacts(List<Id> viewAsOptions, AdvisorPortalFilter filter) {
        Set<Contact> contacts = new Set<Contact>();
        Set<Id> contactIds = new Set<Id>();
        List<Success_Student__c> listOfStudents;

        // Find all relevant contacts
        if (String.isNotBlank(filter.studentString)) {
            listOfStudents = [
                SELECT
                    Student__c,
                    Student__r.Id,
                    Student__r.Name,
                    Student__r.FirstName,
                    Student__r.Preferred_Full_Name__c,
                    Student__r.Preferred_First_Name__c,
                    Student__r.LastName,
                    Student__r.EmplId__c,
                    Student__r.ASURITE_Id__c,
                    Student__r.US_Citizen__c,
                    Student__r.Change_Date__c,
                    Student__r.Most_Recent_Outlook_Change_Direction__c,
                    Student__r.Curr_Cont_Prediction_Level__c
                FROM Success_Student__c
                WHERE
                    Success_Pod__r.OwnerId IN :viewAsOptions
                    AND Is_Active__c = TRUE
                    AND (Student__r.Preferred_Full_Name__c = :filter.studentString
                    OR Student__r.Name = :filter.studentString
                    OR Student__r.EmplId__c = :filter.studentString
                    OR Student__r.ASURite_ID__c = :filter.studentString)
                ORDER BY Student__r.LastName, Student__r.Preferred_First_Name__c ASC
                LIMIT 10000
            ];
        } else {
            listOfStudents = [
                SELECT
                    Student__c,
                    Student__r.Id,
                    Student__r.Name,
                    Student__r.FirstName,
                    Student__r.Preferred_Full_Name__c,
                    Student__r.Preferred_First_Name__c,
                    Student__r.LastName,
                    Student__r.EmplId__c,
                    Student__r.ASURITE_Id__c,
                    Student__r.US_Citizen__c,
                    Student__r.Change_Date__c,
                    Student__r.Most_Recent_Outlook_Change_Direction__c,
                    Student__r.Curr_Cont_Prediction_Level__c
                FROM Success_Student__c
                WHERE Success_Pod__r.OwnerId IN :viewAsOptions AND Is_Active__c = TRUE
                ORDER BY Student__r.LastName, Student__r.Preferred_First_Name__c ASC
                LIMIT 10000
            ];
        }

        for (Success_Student__c student : listOfStudents) {
            contactIds.add(student.Student__r.Id);
            contacts.add(student.Student__r);
        }

        contactIds = filterStudentGroups(filter, contactIds);

        contactIds = filterStudentPlans(filter, contactIds);

        // Filter on special populations if possible
        // note, these are all aditive, so we should UNION the results of all the special population filters
        if (filter.career == 'GRD') {
            if (!String.isBlank(filter.specialPopulation)) {
                Set<Id> filteredContactIds1 = getMatchesForSpecialPopulationDualOrAppliedToGrad(filter, contactIds);
                Set<Id> filteredContactIds2 = getMatchesForSpecialPopulationFormatStudents(filter, contactIds);
                Set<Id> filteredContactIds3 = getMatchesForSpecialPopulationProvisionalAdmits(filter, contactIds);
                Set<Id> filteredContactIds4 = getMatchesForSpecialPopulationRegistrationHold(filter, contactIds);
                Set<Id> filteredContactIds5 = getMatchesForSpecialPopulationStudentGroups(filter, contactIds);

                contactIds.clear();
                contactIds.addAll(filteredContactIds1);
                contactIds.addAll(filteredContactIds2);
                contactIds.addAll(filteredContactIds3);
                contactIds.addAll(filteredContactIds4);
                contactIds.addAll(filteredContactIds5);
            }
        }

        for (Contact c : contacts) {
            if (!contactIds.contains(c.Id)) {
                contacts.remove(c);
            }
        }

        return new List<Contact>(contacts);
    }

    // Get all open case for a list of students, following a filter
    private static List<AdvisorPortalContact> getContactCaseWrappersFor(
        List<Contact> contacts,
        AdvisorPortalFilter filter
    ) {
        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();
        List<Id> contactIds = new List<Id>();
        Map<Id, List<Case>> casesByContactIds = new Map<Id, List<Case>>();
        Integer contactsLeft = 3000; // max number of contacts returned

        for (Contact c : contacts) {
            contactIds.add(c.Id);
        }

        // Query for cases owned by viewAsOptions and following cases-related filters (and some contact filters)
        List<Case> filteredCases = queryForCasesWithContactData(contactIds, filter, true);

        // Add mapping of contactId to case list
        for (Case eachCase : filteredCases) {
            if (!casesByContactIds.containsKey(eachCase.ContactId)) {
                casesByContactIds.put(eachCase.ContactId, new List<Case>{ eachCase });
            } else {
                casesByContactIds.get(eachCase.ContactId).add(eachCase);
            }
        }

        // Add filtered Contact/Case records to wrapper.
        for (Contact contact : contacts) {
            if (contactsLeft <= 0) {
                break;
            }

            // Skip contact if we filter by Case count, but there aren't any.
            if (
                !casesByContactIds.containsKey(contact.Id) &&
                !String.isBlank(filter.caseCount) &&
                Integer.valueOf(filter.caseCount) > 0
            ) {
                continue;
            }

            AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

            if (casesByContactIds.containsKey(contact.Id)) {
                // Skip Contact if we filter by Case count and it has less than we want.
                if (
                    !String.isBlank(filter.caseCount) &&
                    casesByContactIds.get(contact.Id).size() != Integer.valueOf(filter.caseCount)
                ) {
                    continue;
                }

                List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();

                for (Case caseResult : casesByContactIds.get(contact.Id)) {
                    caseWrappers.add(new AdvisorPortalCase(caseResult));
                }

                contactWrapper.addCases(caseWrappers);
                advisorPortalContactResults.add(contactWrapper);
                contactsLeft--;
            } else {
                contactWrapper.addCases(new List<AdvisorPortalCase>());
                advisorPortalContactResults.add(contactWrapper);
                contactsLeft--;
            }
        }

        return advisorPortalContactResults;
    }

    /**
     * Queries for Contact Ids based on the provided filter on Student_Group__c.
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    @TestVisible
    private static Set<Id> filterStudentGroups(AdvisorPortalFilter filter, Set<Id> contactIds) {
        Boolean useQueryString = false;
        Set<Id> filteredContactIds = new Set<Id>();
        String queryString =
            'SELECT SG_Contact__c' +
            ' FROM Student_Group__c' +
            ' WHERE SG_Contact__c IN :contactIds' +
            ' AND SG_Status__c = TRUE';

        if (filter.career != null) {
            // if statement for using either undergrad filtering
            // if grad filtering, there still might be some of student group filters to apply
            // (for special populations), but they happen in a different place since they
            // need to be applied as a UNION rather than an INTERSECTION
            if (filter.career != 'GRD') {
                if (!String.isBlank(filter.studentGroupCode)) {
                    useQueryString = true;
                    queryString += ' AND SG_PeopleSoft_Code__c = :filter.studentGroupCode';
                }
            }

            queryString += ' AND SG_Effective_Date__c < TODAY';
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
     * Queries for Contact Ids based on the provided filter on Student_Plan__c.
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    @TestVisible
    private static Set<Id> filterStudentPlans(AdvisorPortalFilter filter, Set<Id> contactIds) {
        Boolean useQueryString = false;
        Set<Id> filteredContactIds = new Set<Id>();
        String queryString = 'SELECT Contact__c FROM Student_Program_Plan__c WHERE Contact__c IN :contactIds';

        if (filter.career != null) {
            // if statement for using either grad level or undergrad level filtering
            useQueryString = true;
            if (filter.career == 'GRD') {
                // Use grad portal filtering capabilities
                queryString += ' AND Career__c = \'Graduate\'';

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
                    queryString += ' AND Program_Code__c IN :academicPrograms';
                }

                if (!String.isBlank(filter.academicPlan)) {
                    List<String> academicPlans = filter.academicPlan.split(';');
                    queryString += ' AND Plan_Code__c IN :academicPlans';
                }

                if (!String.isBlank(filter.admitTermFrom)) {
                    queryString += ' AND (Admit_Term__r.PeopleSoft_Code__c >= \'' + filter.admitTermFrom + '\'';
                    queryString += ' OR Requirement_Term__c >= \'' + filter.admitTermFrom + '\')';
                }

                if (!String.isBlank(filter.admitTermTo)) {
                    queryString += ' AND (Admit_Term__r.PeopleSoft_Code__c <= \'' + filter.admitTermTo + '\'';
                    queryString += ' OR Requirement_Term__c <= \'' + filter.admitTermTo + '\')';
                }
            } else {
                // use undergrad portal filtering capabilties
                queryString += ' AND Career__c != \'Graduate\'';

                if (!String.isBlank(filter.academicLevel)) {
                    List<String> academicLevels = filter.academicLevel.split(';');
                    queryString += ' AND Cohort__c IN :academicLevels';
                }

                if (!String.isBlank(filter.major)) {
                    queryString +=
                        ' AND  Plan_Type_Text__c = \'MAJ\' AND ( Plan_Description__c LIKE \'%' +
                        filter.major +
                        '%\' OR Plan_Code__c LIKE \'%' +
                        filter.major +
                        '%\' )';
                }
            }

            // ... and for filters that both grad and undergrad use
            if (!String.isBlank(filter.campus)) {
                List<String> campuses = filter.campus.split(';');
                queryString += ' AND Campus__r.Location_Code__c IN :campuses';
            }

            if (!String.isBlank(filter.residency)) {
                List<String> residencies = filter.residency.split(';');
                queryString += ' AND Residency__c IN :residencies';
            }
        }

        queryString += ' GROUP BY Contact__c LIMIT 4000';
        // make query to filter - or return intial set of contactIds if no filtering is needed
        if (useQueryString) {
            for (AggregateResult studentPlanResult : Database.query(queryString)) {
                filteredContactIds.add((Id) studentPlanResult.get('Contact__c'));
            }
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
    private static Set<Id> getMatchesForSpecialPopulationStudentGroups(AdvisorPortalFilter filter, Set<Id> contactIds) {
        Set<Id> filteredContactIds = new Set<Id>();
        String queryString =
            'SELECT SG_Contact__c' +
            ' FROM Student_Group__c' +
            ' WHERE SG_Contact__c IN :contactIds' +
            ' AND SG_Status__c = TRUE';

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

                        queryString += ' AND SG_Effective_Date__c < TODAY';
                        queryString += ' AND SG_Status__c = TRUE';
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
        Set<Id> contactIds
    ) {
        Set<Id> filteredContactIds = new Set<Id>();

        List<String> dualEnrollmentCareers = new List<String>{ 'Graduate', 'Law' };
        List<String> appliedToGraduateCodes = new List<String>{ 'AG', 'AP', 'GD', 'IR', 'PN' };

        // Query for both applied to graduate and dual enrollment
        List<Student_Program_Plan__c> potentialMatches = [
            SELECT Contact__c, Program_Code__c
            FROM Student_Program_Plan__c
            WHERE
                Contact__c IN :contactIds
                AND (Career__c IN :dualEnrollmentCareers
                OR (Career__c = 'Graduate'
                AND Status__c = 'Active in Program'
                AND Degree_Chkout_Stat_Code__c IN :appliedToGraduateCodes))
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
        Set<Id> contactIds
    ) {
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

    /**
     * Queries for Contact Ids based on the provided filter's special populations.  This handles all the one's that can be done simply
     * looking at the student's Service_Indicator__c
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    private static Set<Id> getMatchesForSpecialPopulationProvisionalAdmits(
        AdvisorPortalFilter filter,
        Set<Id> contactIds
    ) {
        Set<Id> filteredContactIds = new Set<Id>();

        if (filter.career != null) {
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    List<String> specialPopulations = filter.specialPopulation.split(';');
                    if (specialPopulations.contains('provivisional admits, not met yet')) {
                        List<AggregateResult> serviceIndicators = new List<AggregateResult>(
                            [
                                SELECT SI_Contact__c
                                FROM Service_Indicator__c
                                WHERE
                                    SI_Contact__c IN :contactIds
                                    AND SI_Code__c = 'AD4'
                                    AND SI_Reason__c = 'PROV'
                                    AND SI_Positive_Service_Indicator__c = TRUE
                                GROUP BY SI_Contact__c
                                LIMIT 2000
                            ]
                        );

                        for (AggregateResult serviceIndicator : serviceIndicators) {
                            filteredContactIds.add((Id) serviceIndicator.get('SI_Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }

    /**
     * Queries for Contact Ids based on the provided filter's special populations.  This handles all the one's that need to query
     * both Service_Indicator__c and Student_Program_Plan__c
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    private static Set<Id> getMatchesForSpecialPopulationRegistrationHold(
        AdvisorPortalFilter filter,
        Set<Id> contactIds
    ) {
        Set<Id> filteredContactIds = new Set<Id>();

        if (filter.career != null) {
            if (filter.career == 'GRD') {
                if (!String.isBlank(filter.specialPopulation)) {
                    List<String> specialPopulations = filter.specialPopulation.split(';');
                    if (specialPopulations.contains('active students with registation hold')) {
                        String currentPSCode = getCurrentPeoplesoftTermCode();
                        List<AggregateResult> serviceIndicators = new List<AggregateResult>(
                            [
                                SELECT SI_Contact__c
                                FROM Service_Indicator__c
                                WHERE
                                    SI_Contact__c IN :contactIds
                                    AND Enrollment_Impact__c = TRUE
                                    AND SI_Positive_Service_Indicator__c = FALSE
                                    AND SI_Start_Term__r.PeopleSoft_Code__c >= :currentPSCode
                                    AND SI_End_Term__r.PeopleSoft_Code__c <= :currentPSCode
                                GROUP BY SI_Contact__c
                                LIMIT 2000
                            ]
                        );
                        for (AggregateResult serviceIndicator : serviceIndicators) {
                            filteredContactIds.add((Id) serviceIndicator.get('SI_Contact__c'));
                        }

                        List<AggregateResult> ensureStudentIsActive = [
                            SELECT Contact__c
                            FROM Student_Program_Plan__c
                            WHERE
                                Contact__c IN :filteredContactIds
                                AND Career__c = 'Graduate'
                                AND Status__c = 'Active in Program'
                                AND Effective_Date__c <= TODAY
                            GROUP BY Contact__c
                            LIMIT 2000
                        ];
                        filteredContactIds.clear();
                        for (AggregateResult studentIsActiveCheck : ensureStudentIsActive) {
                            filteredContactIds.add((Id) studentIsActiveCheck.get('Contact__c'));
                        }
                    }
                }
            }
        }

        return filteredContactIds;
    }

    private static String getCurrentPeoplesoftTermCode() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        return currentTermData.CurrTerm__c;
    }
}
