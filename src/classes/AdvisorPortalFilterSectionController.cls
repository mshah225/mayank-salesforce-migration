public class AdvisorPortalFilterSectionController {
    private static Map<String, Set<Decimal>> outlookScoresByLabels = new Map<String, Set<Decimal>>{
        'very low' => new Set<Decimal>{0, 1, 2, 3},
        'low' => new Set<Decimal>{4, 5},
        'moderate' => new Set<Decimal>{6},
        'high' => new Set<Decimal>{7},
        'very high' => new Set<Decimal>{8, 9, 10}
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
    @AuraEnabled
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        Map<String, String> picklistValuesByLabel = new Map<String, String>();

        for (Schema.PicklistEntry picklistValue : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
            if (picklistValue.isActive()) {
                picklistValuesByLabel.put(picklistValue.getLabel(), picklistValue.getValue());
            }
        }

        return picklistValuesByLabel;
    }

    /**
     * Gets active Custom Metadata Case Status values to display on the filter section in the Advisor Portal.
     *
     * @return caseStatusValuesByLabel, a Map of Advisor_Portal_Case_Status__mdt record values by label.
     */
    @AuraEnabled
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
    @AuraEnabled
    public static Map<String, String> getCaseSubjectPicklistValues(List<Id> viewAsOptions) {
        Map<String, String> caseSubjectValuesByLabel = new Map<String, String>();

        for (AggregateResult result : [
            SELECT Subject
            FROM Case
            WHERE IsClosed = FALSE
            AND RecordTypeId = :IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach')
            AND Subject != NULL
            AND OwnerId IN :viewAsOptions
            GROUP BY Subject
            LIMIT 30000 
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
    @AuraEnabled
    public static Map<String, String> getCaseClassificationPicklistValues(List<Id> viewAsOptions) {
        Map<String, String> caseClassificationValuesByLabel = new Map<String, String>();

        for (AggregateResult result : [
            SELECT CC_Category__r.Name CategoryName
            FROM Case
            WHERE IsClosed = FALSE
            AND RecordTypeId = :IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach')
            AND CC_Category__c != NULL
            AND OwnerId IN :viewAsOptions
            GROUP BY CC_Category__r.Name
            LIMIT 30000
        ]) {
            if (result.get('CategoryName') != null) {
                caseClassificationValuesByLabel.put((String) result.get('CategoryName'), (String) result.get('CategoryName'));
            }
        }

        return caseClassificationValuesByLabel;
    }

    /**
     * Filters Contacts and Case wrappers on the Advisor Portal using the supplied view as options and filter.
     *
     * @param viewAsOptions, a List of User/Queue Ids to get related Contacts to use in search.
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return shortenedAdvisorPortalContactResults, a filtered List of AdvisorPortalContact records (3000 maximum contacts/case wrappers).
     */
    // Limits.getQueryRows() += 36000
    @AuraEnabled
    public static List<AdvisorPortalContact> getContactCaseWrappersWithLessQueries(List<Id> viewAsOptions, AdvisorPortalFilter filter){
        Set<Contact> allCaseContacts = new Set<Contact>();
        Set<Contact> filteredCaseContacts = new Set<Contact>();
        Set<Id> filteredContactIds = new Set<Id>();
        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();
        List<AdvisorPortalContact> shortenedAdvisorPortalContactResults = new List<AdvisorPortalContact>();
        Map<Id, List<Case>> casesByContactIds = new Map<Id, List<Case>>();
        
        // Query for cases owned by viewAsOptions and following cases-related filters
        List<Case> filteredCases = queryForCasesWithContactData(viewAsOptions, filter);

        for (Case eachCase : filteredCases) {
            allCaseContacts.add(eachCase.Contact);
        }

        // Filter contact list based on contact filter of filter string
        if (String.isNotBlank(filter.studentString)) {
            for (Contact eachContact : allCaseContacts) {
                if ( eachContact.Name == filter.studentString 
                  || eachContact.EmplId__c == filter.studentString 
                  || eachContact.ASURite_ID__c == filter.studentString) {
                    filteredContactIds.add(eachContact.Id);
                }
            }
        } else {
            for (Contact eachContact : allCaseContacts) {
                if (eachContact != null && eachContact.Id != null) {
                    filteredContactIds.add(eachContact.Id);
                }                
            }
        }

        // Filter based on Student Groups (LIMIT 2000 query, unavoidable)
        filteredContactIds = AdvisorPortalFilterHelper.filterStudentGroups(filter, filteredContactIds);

        // Filter based on Student Plans (LIMIT 2000 query, unavoidable)
        filteredContactIds = AdvisorPortalFilterHelper.filterStudentPlans(filter, filteredContactIds);
        
        // Filter based on Student Advisors (LIMIT 2000 query, unavoidable)
        filteredContactIds = AdvisorPortalFilterHelper.filterStudentAdvisors(filter, filteredContactIds);

        // Remove cases that don't match contact filters and generate list of filteredContacts
        for(Integer i=0; i<filteredCases.size(); i++) {
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
                casesByContactIds.put(eachCase.ContactId, new List<Case>{eachCase});
            } else {
                casesByContactIds.get(eachCase.ContactId).add(eachCase);
            }
        }



        // Add filtered Contact/Case records to wrapper.
        for (Contact contact : filteredCaseContacts) {
            // Skip contact if we filter by Case count, but there aren't any.
            if (!casesByContactIds.containsKey(contact.Id) && (filter.caseCount != null || filter.caseCount > 0)) {
                continue;
            }

            AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

            if (casesByContactIds.containsKey(contact.Id)) {
                // Skip Contact if we filter by Case count and it has less than we want.
                if ((filter.caseCount != null || filter.caseCount > 0) && casesByContactIds.get(contact.Id).size() < filter.caseCount) {
                    continue;
                }

                List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();

                for (Case caseResult : casesByContactIds.get(contact.Id)) {
                    caseWrappers.add(new AdvisorPortalCase(caseResult));
                }

                contactWrapper.addCases(caseWrappers);
                advisorPortalContactResults.add(contactWrapper);
            } else if (filter.allCasesState) {
                advisorPortalContactResults.add(contactWrapper);
            }
        }
        
        // Limit to the first 3000 results to prevent massive page slowdown
        for(Integer i=0; i<advisorPortalContactResults.size() && i<3000; i++) {
            shortenedAdvisorPortalContactResults.add(advisorPortalContactResults.get(i));
        }

        return shortenedAdvisorPortalContactResults;
    }

    // Limits.getQueryRows() += 30000
    private static List<Case> queryForCasesWithContactData(List<Id> viewAsOptions, AdvisorPortalFilter filter) {
        String queryString = '' +
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
                'OwnerId, ' +
                'ContactId, ' +
                'Id, ' +
                'Contact.Id, ' +
                'Contact.Name, ' +
                'Contact.EmplId__c, ' +
                'Contact.ASURite_Id__c, ' +
                'Contact.US_Citizen__c, ' +
                'Contact.Change_Date__c, ' +
                'Contact.Most_Recent_Outlook_Change_Direction__c, ' +
                'Contact.Curr_Cont_Prediction_Level__c ' +
            'FROM Case ' +
            'WHERE IsClosed = FALSE ' +
            'AND RecordTypeId = \'' + IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach') + '\'';

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
        
        queryString += ' AND OwnerId IN :viewAsOptions';

        if (filter.watchlistCasesState != null && filter.watchlistCasesState) {
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
            queryString += ' AND CreatedDate >= ' + Datetime.valueOf(filter.createdFromDate + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        if (!String.isBlank(filter.createdToDate)) {
            queryString += ' AND CreatedDate <= ' + Datetime.valueOf(filter.createdToDate + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
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

        queryString += ' ORDER BY Contact.Name ASC';
        queryString += ' LIMIT 30000';

        return Database.query(queryString);
    }
}