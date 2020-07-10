public class AdvisorPortalFilterSectionController {
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
            AND ContactId IN :AdvisorPortalController.getSuccessStudentContactIdsForViewOptions(viewAsOptions)
            GROUP BY Subject
            LIMIT 50000
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
            AND ContactId IN :AdvisorPortalController.getSuccessStudentContactIdsForViewOptions(viewAsOptions)
            GROUP BY CC_Category__r.Name
            LIMIT 50000
        ]) {
            if (result.get('CategoryName') != null) {
                caseClassificationValuesByLabel.put((String) result.get('CategoryName'), (String) result.get('CategoryName'));
            }
        }

        return caseClassificationValuesByLabel;
    }

    /**
     * Filters Contacts on the Advisor Portal using the supplied view as options and filter.
     *
     * @param viewAsOptions, a List of User/Queue Ids to get related Contacts to use in search.
     * @param filter, the AdvisorPortalFilter to use.
     *
     * @return advisorPortalContactResults, a filtered List of AdvisorPortalContact records.
     */
    @AuraEnabled
    public static List<AdvisorPortalContact> filterContacts(List<Id> viewAsOptions, AdvisorPortalFilter filter) {
        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();
        Map<Id, List<Case>> casesByContactIds = new Map<Id, List<Case>>();
        Set<Id> filteredContactIds = AdvisorPortalController.getSuccessStudentContactIdsForViewOptions(viewAsOptions);
        filteredContactIds = AdvisorPortalFilterHelper.filterContacts(filter, filteredContactIds);
        filteredContactIds = AdvisorPortalFilterHelper.filterStudentGroups(filter, filteredContactIds);
        filteredContactIds = AdvisorPortalFilterHelper.filterStudentPlans(filter, filteredContactIds);
        filteredContactIds = AdvisorPortalFilterHelper.filterStudentAdvisors(filter, filteredContactIds);
        
        /**
         * Filter on Case fields.
         */
        for (Case caseResult : AdvisorPortalFilterHelper.filterCases(filter, filteredContactIds)) {
            if (!casesByContactIds.containsKey(caseResult.ContactId)) {
                casesByContactIds.put(caseResult.ContactId, new List<Case>{caseResult});
            } else {
                casesByContactIds.get(caseResult.ContactId).add(caseResult);
            }
        }
        
        List<Contact> contactsFromFilteredIds = [
            SELECT Name,
                EMPLID__c,
                ASURite_ID__c,
                US_Citizen__c,
                Change_Date__c,
                Most_Recent_Outlook_Change_Direction__c,
                Curr_Cont_Prediction_Level__c
            FROM Contact
            WHERE Id IN :filteredContactIds
            ORDER BY Name
            LIMIT 2000
        ];

        // Add filtered Contact/Case records to wrapper.
        for (Contact contact : contactsFromFilteredIds) {

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

        return advisorPortalContactResults;
    }
}