public class CaseService {
    /**
     * Returns the fields needed on the Service Center for a given case
     * @param The Case Id to look up
     * @return The Case Object
     */
    public static Case getCaseDetails(Id caseId) {
        Case requestedCase = [
            SELECT
                Id,
                CaseNumber,
                CC_Functional_Group__c,
                CC_Functional_Group__r.Name,
                Subject,
                Description,
                Feedback_Link__c,
                CreatedDate,
                Status,
                ClosedDate
            FROM Case
            WHERE Id = :caseId
        ];

        return requestedCase;
    }

    /**
     * Returns the email messages for the requested case
     * @param The Case Id to look up
     * @return The Case Objects Email Messages
     */
    public static EmailMessage[] getCaseEmailMessages(Date launchDate, Id caseId, List<String> contactEmails) {
        return [
            SELECT
                FromName,
                CreatedDate,
                MessageDate,
                HtmlBody,
                LastModifiedDate,
                Subject,
                TextBody,
                FromAddress,
                ToAddress,
                CCAddress
            FROM EmailMessage
            WHERE
                ParentId = :ApexPages.currentPage().getParameters().get('id')
                AND Status != '5'
                AND CreatedDate > :launchDate
                AND (ToAddress IN :contactEmails
                OR FromAddress IN :contactEmails)
            ORDER BY CreatedDate DESC
        ];
    }

    /**
     * Get these contact's open visible cases
     * @param A list of contacts
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleOpenCases(List<Contact> listOfContacts) {
        return getVisibleOpenCases(listOfContacts, 0);
    }

    /**
     * Get these contact's open visible cases
     * @param A list of contacts
     * @param An integer representing the amount of contacts to return
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleOpenCases(List<Contact> listOfContacts, Integer queryLimit) {
        List<Case> openCases = null;
        String caseFields = ObjectService.objectFieldsToString('Case');

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts) {
            contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try {
            String selectOpenVisibleCases =
                'SELECT ' +
                caseFields +
                ' ' +
                'FROM Case ' +
                'WHERE IsClosed = false ' +
                'AND Visible_by_Contact__c = true ' +
                'AND ContactId IN :contactIds ' +
                'ORDER BY CreatedDate DESC';

            if (queryLimit != 0) {
                selectOpenVisibleCases += ' LIMIT ' + queryLimit;
            }

            openCases = Database.query(selectOpenVisibleCases);
        } catch (Exception e) {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s open visible cases\n' +
                e.getStackTraceString()
            );
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : openCases) {
            if (conCaseMap.containsKey(caze.ContactId)) {
                conCaseMap.get(caze.ContactId).add(caze);
            } else {
                conCaseMap.put(caze.ContactId, new List<Case>{ caze });
            }
        }

        return conCaseMap;
    }

    /**
     * Get these contact's closed visible cases
     * @param A list of contacts
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleClosedCases(List<Contact> listOfContacts) {
        return getVisibleClosedCases(listOfContacts, 0);
    }

    /**
     * Get these contact's closed visible cases
     * @param A list of contacts
     * @param An integer representing the amount of contacts to return
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleClosedCases(List<Contact> listOfContacts, Integer queryLimit) {
        List<Case> closedCases = null;

        String caseFields = ObjectService.objectFieldsToString('Case');

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts) {
            contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try {
            String selectClosedVisibleCases =
                'SELECT ' +
                caseFields +
                ' ' +
                'FROM Case ' +
                'WHERE IsClosed = true ' +
                'AND Visible_by_Contact__c = true ' +
                'AND ContactId IN :contactIds ' +
                'ORDER BY ClosedDate DESC';

            if (queryLimit != 0) {
                selectClosedVisibleCases += ' LIMIT ' + queryLimit;
            }

            closedCases = Database.query(selectClosedVisibleCases);
        } catch (Exception e) {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s ' +
                    'closed visible cases\n' +
                    e.getStackTraceString()
            );
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : closedCases) {
            if (conCaseMap.containsKey(caze.ContactId)) {
                conCaseMap.get(caze.ContactId).add(caze);
            } else {
                conCaseMap.put(caze.ContactId, new List<Case>{ caze });
            }
        }

        return conCaseMap;
    }

    /**
     * Get all open cases for this contact
     * @param the contact Id
     * @return A list of all open cases for that contact
     */
    public static List<Case> getAllOpenCases(Id contactId) {
        List<Case> openCases = null;
        String caseFields = ObjectService.objectFieldsToString('Case');

        String selectOpenVisibleCases =
            'SELECT ' +
            caseFields +
            ' ' +
            'FROM Case ' +
            'WHERE IsClosed = false ' +
            'AND ContactId = :contactId ' +
            'ORDER BY CreatedDate DESC';

        openCases = Database.query(selectOpenVisibleCases);

        return openCases;
    }

    /**
     * Create a number of test cases. Usually for unit tests.
     * @param An integer describing the number of cases to create
     * @param The contact to associate the cases to
     * @return A list of cases
     */
    public static List<Case> createTestCases(Integer numberOfCases, Contact con) {
        List<Case> testCases = new List<Case>();

        for (Integer i = 0; i < numberOfCases; i++) {
            Case c = new Case();
            c.Subject = 'Test Case ' + i;
            c.Description = 'Auto generated test case';
            c.ContactId = con.Id;
            testCases.add(c);
        }

        return testCases;
    }

    public class CaseServiceException extends Exception {
    }

    /** After here is stuff used by the case dispatcher. Everything prior to this point
     * is old and we should try to remove references to them.
     */

    public static void processCaseAssociations(List<Case> newList) {
        Map<ID, Contact> relatedContactMap = new Map<ID, Contact>();
        Map<Id, Campaign> sourceMap = new Map<Id, Campaign>();
        Id recruitmentCaseRecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Admission_Services');

        Set<Id> caseContactIdSet = new Set<ID>();
        Set<Id> campaignIdSet = new Set<Id>();

        for (Case newCase : newList) {
            if (recruitmentCaseRecordTypeId != null && newCase.RecordTypeId == recruitmentCaseRecordTypeId) {
                campaignIdSet.add(newCase.Case_Source__c);
                caseContactIdSet.add(newCase.ContactId);
            }
        }

        if (!caseContactIdSet.isEmpty()) {
            LogSuite.log('query', 'Calling related contact map query');
            relatedContactMap = new Map<Id, Contact>(
                [
                    SELECT
                        Id,
                        (
                            SELECT
                                Id,
                                StageName,
                                Territory_Assignment_Last_Rule_Type__c,
                                OwnerId,
                                Owner.IsActive,
                                Enrollment_Coach__c,
                                Enrollment_Coach__r.IsActive,
                                CreatedDate,
                                IsClosed
                            FROM Opportunities__r
                            ORDER BY IsClosed ASC, CreatedDate DESC
                        )
                    FROM Contact
                    WHERE Id IN :caseContactIdSet
                ]
            );
        }

        if (!campaignIdSet.isEmpty()) {
            LogSuite.log('query', 'Calling source map query');
            sourceMap = new Map<Id, Campaign>(
                [
                    SELECT
                        Id,
                        Case_Assignment_Rule__r.Id,
                        Case_Assignment_Rule__r.Queue_ID__c,
                        Case_Assignment_Rule__r.CC_Category__c,
                        Case_Assignment_Rule__r.CC_Category__r.Name,
                        Case_Assignment_Rule__r.CC_Sub_Category__c,
                        Case_Assignment_Rule__r.CC_Sub_Category__r.Name,
                        Case_Assignment_Rule__r.Origin__c,
                        Case_Assignment_Rule__r.CC_Functional_Group__c,
                        Case_Assignment_Rule__r.CC_Functional_Group__r.Name,
                        Case_Assignment_Rule__r.Type_of_Additional_Assignment_Needed__c
                    FROM Campaign
                    WHERE Id IN :campaignIdSet
                ]
            );
        }

        List<Case_Assignment_Rule__c> defaultCarList = [
            SELECT
                Id,
                Queue_ID__c,
                Origin__c,
                CC_Category__c,
                CC_Sub_Category__c,
                CC_Functional_Group__c,
                Type_of_Additional_Assignment_Needed__c
            FROM Case_Assignment_Rule__c
            WHERE Email_Address__c = 'admissions@asu.edu'
        ];
        Case_Assignment_Rule__c defaultCar = defaultCarList.isEmpty() ? null : defaultCarList[0];

        for (Case newCase : newList) {
            if (newCase.Status == 'Processing') {
                List<String> subjectSplit = newCase.Subject.split('%');
                if (subjectSplit.size() >= 4) {
                    String emplid = '';
                    String first = '';
                    String last = '';

                    for (Integer x = 0; x < subjectSplit.size(); x++) {
                        List<String> tokenSplit = subjectSplit[x].split(':');
                        if (tokenSplit.size() >= 2 && tokenSplit[1] != '') {
                            if (tokenSplit[0] == 'ASURITE') {
                                emplid = tokenSplit[1];
                            } else if (tokenSplit[0] == 'First') {
                                first = tokenSplit[1];
                            } else if (tokenSplit[0] == 'Last') {
                                last = tokenSplit[1];
                            }
                        }
                    }

                    Contact conToCreate = new Contact();

                    if (emplid != null && emplid != '') {
                        LogSuite.log('query', 'Calling contact users query');
                        List<Contact> contactUsers = [SELECT Id FROM Contact WHERE EMPLID__c = :emplid LIMIT 1];
                        if (contactUsers != null && contactUsers.size() > 0) {
                            newCase.ContactId = contactUsers[0].Id;
                        } else {
                            conToCreate.EMPLID__c = emplid;
                        }
                    }

                    if (newCase.ContactId == null && first != null && first != '' && last != null && last != '') {
                        conToCreate.FirstName = first;
                        conToCreate.LastName = last;
                        insert conToCreate;
                        newCase.ContactId = conToCreate.Id;
                    }
                }
            }

            if (recruitmentCaseRecordTypeId != null && newCase.RecordTypeId == recruitmentCaseRecordTypeId) {
                Contact con = relatedContactMap.get(newCase.ContactId);
                Opportunity firstOpp = null;
                CaseAssignmentDeterminer assignmentDet = null;

                if (con != null) {
                    List<Opportunity> opList = con.Opportunities__r;
                    firstOpp = opList == null || opList.isEmpty() ? null : opList[0];
                }

                if (newCase.Associate_Case_to_Active_Opportunity__c == true && firstOpp != null) {
                    newCase.Opportunity__c = firstOpp.Id;
                }

                if (!UserInfo.getFirstName().equals('API') || UserInfo.getLastName().equals('ASU EMAIL SERVICE')) {
                    // If in a non API user context or are running as the email service
                    // then we should perform assignment by looking at fields on the case
                    assignmentDet = new CaseAssignmentDeterminer(firstOpp, newCase);
                } else {
                    // In API user context we should use the CAR of the case to determine
                    // how to perform assignment
                    if (sourceMap.containsKey(newCase.Case_Source__c)) {
                        Campaign source = sourceMap.get(newCase.Case_Source__c);
                        if (source.Case_Assignment_Rule__c != null) {
                            // If the case's source has a CAR, use that
                            assignmentDet = new CaseAssignmentDeterminer(firstOpp, source.Case_Assignment_Rule__r);
                        } else if (
                            firstOpp != null &&
                            firstOpp.Territory_Assignment_Last_Rule_Type__c != 'Default User' &&
                            firstOpp.Owner.IsActive == true
                        ) {
                            // Is the case's source has no CAR but the Opporunity has enough detail, use that
                            assignmentDet = new CaseAssignmentDeterminer(firstOpp);
                        } else {
                            // Lastly, fallback on using the default CAR
                            assignmentDet = new CaseAssignmentDeterminer(firstOpp, defaultCAR);
                        }
                    }
                }
                if (assignmentDet != null)
                    assignmentDet.setCaseFields(newCase);
            }
        }
    }

    public static void assignClassificationsAndRecordType(List<Case> newList, Map<Id, Case> oldMap) {
        Set<String> caseClassificationsToQuery = new Set<String>();
        List<CaseClassifier> casesToClassify = new List<CaseClassifier>();
        Set<Id> setOfCaseClassficationId = new Set<Id>();

        for (Case newCase : newList) {
            if (oldMap != null) {
                // If there was a previous state, make sure to handle the webform closing
                Case previousCaseState = oldMap.get(newCase.Id);
                CaseWebformCloser closer = new CaseWebformCloser(newCase, previousCaseState);
                closer.handleWebformCase();
            }

            CaseClassifier classifier = new CaseClassifier(newCase);
            if (classifier.hasInvalidCaseClassification()) {
                caseClassificationsToQuery.addAll(classifier.getMissingClassifications());
                casesToClassify.add(classifier);
            }

            setOfCaseClassficationId.add(newCase.CC_Functional_Group__c);
            setOfCaseClassficationId.add(newCase.CC_Category__c);
            setOfCaseClassficationId.add(newCase.CC_Sub_Category__c);
        }

        List<Case_Classification__c> classifications = [
            SELECT Name, Parent__r.Name, Parent__r.Parent__r.Name, RecordType.Name, Record_Types__c
            FROM Case_Classification__c
            WHERE (Name IN :caseClassificationsToQuery AND Active__c = TRUE) OR ID IN :setOfCaseClassficationId
        ];
        Map<String, Case_Classification__c> nameToClassification = new Map<String, Case_Classification__c>();
        Map<Id, String> mapCCIdToName = new Map<Id, String>();

        for (Case_Classification__c classification : classifications) {
            if (!setOfCaseClassficationId.contains(classification.Id)) {
                String classificationName = CaseClassifier.getClassificationUniqueName(
                    classification.Name,
                    classification.Parent__c == null ? '' : classification.Parent__r.Name,
                    (classification.Parent__c == null ||
                        classification.Parent__r.Parent__c == null)
                        ? ''
                        : classification.Parent__r.Parent__r.Name,
                    classification.RecordType.Name
                );
                nameToClassification.put(classificationName, classification);
            }
            mapCCIdToName.put(classification.Id, classification.Name);
        }

        for (CaseClassifier caseToClassify : casesToclassify) {
            caseToClassify.classifyCase(nameToClassification);
        }

        for (Case caseRecord : newList) {
            caseRecord.Functional_Group__c = mapCCIdToName.get(caseRecord.CC_Functional_Group__c);
            caseRecord.Category__c = mapCCIdToName.get(caseRecord.CC_Category__c);
            caseRecord.Sub_Category__c = mapCCIdToName.get(caseRecord.CC_Sub_Category__c);

            if (caseRecord.Original_Functional_Group__c == null) {
                caseRecord.Original_Functional_Group__c = caseRecord.Functional_Group__c;
                caseRecord.Original_Category__c = caseRecord.Category__c;
                caseRecord.Original_Sub_Category__c = caseRecord.Sub_Category__c;
            }

            assignRecordType(caseRecord, mapCCIdToName);
        }
    }

    public static void assignRecentGroupAndQueue(List<Case> newList, Map<Id, Case> oldMap) {
        List<Id> ownerIds = new List<Id>();
        for (Case newCase : newList) {
            if (!ownerIds.contains(newCase.OwnerId))
                ownerIds.add(newCase.OwnerId);
        }
        Map<Id, Group> groupNameMap = GroupService.mapGroupIdToName(ownerIds);

        for (Case newCase : newList) {
            Case oldCase = null;
            if (oldMap != null && newCase.Id != null)
                oldCase = oldMap.get(newCase.Id);

            if (groupNameMap.containsKey(newCase.OwnerId)) {
                newCase.Most_Recent_Queue__c = groupNameMap.get(newCase.OwnerId).Name;
            }

            if (
                newCase.Functional_Group__c != null &&
                newCase.Functional_Group__c != 'External Unit' &&
                (oldCase == null ||
                newCase.Functional_Group__c != oldCase.Functional_Group__c)
            ) {
                newCase.Most_Recent_Functional_Group__c = newCase.Functional_Group__c;
            }
        }
    }

    public static void forwardInsertedCaseEmail(List<Case> newList) {
        for (Case newCase : newList) {
            if (newCase.Status == 'Closed: Forwarded') {
                if (!CaseUtilities.emailForwarded) {
                    CaseUtilities.emailForwarded = true;
                    CaseUtilities.forwardCaseAttachments(
                        newCase.Id,
                        newCase.Forward_To_Email__c,
                        newCase.Forward_To_Email_Calculation__c
                    );
                }
            }
        }
    }

    private static void assignRecordType(Case caseRecord, Map<Id, String> mapCCIdToName) {
        if (mapCCIdToName.containsKey(caseRecord.CC_Functional_Group__c)) {
            if (mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Advisor Outreach')) {
                caseRecord.RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            } else if (mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Coach Outreach')) {
                caseRecord.RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach');
            } else if (
                (caseRecord.RecordTypeId == RecordIDHelper.getRecordTypeId('Case', 'ASU_Service') &&
                !mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Salesforce Support')) &&
                (mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('Admission Services') ||
                (mapCCIdToName.containsKey(caseRecord.CC_Category__c) &&
                mapCCIdToName.get(caseRecord.CC_Category__c).containsIgnoreCase('Recruitment')) ||
                (mapCCIdToName.containsKey(caseRecord.CC_Sub_Category__c) &&
                mapCCIdToName.get(caseRecord.CC_Sub_Category__c).containsIgnoreCase('Recruitment')))
            ) {
                caseRecord.RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Admission_Services');
            } else if (
                caseRecord.RecordTypeId == RecordIDHelper.getRecordTypeId('Case', 'ASU_Admission_Services') &&
                !mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('Admission Services') &&
                !mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('External Unit') &&
                (caseRecord.CC_Category__c == null ||
                (mapCCIdToName.containsKey(caseRecord.CC_Category__c) &&
                !mapCCIdToName.get(caseRecord.CC_Category__c).containsIgnoreCase('Recruitment'))) &&
                (caseRecord.CC_Sub_Category__c == null ||
                (mapCCIdToName.containsKey(caseRecord.CC_Sub_Category__c) &&
                !mapCCIdToName.get(caseRecord.CC_Sub_Category__c).containsIgnoreCase('Recruitment')))
            ) {
                caseRecord.RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Service');
            } else if (
                mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('Financial Aid') &&
                mapCCIdToName.containsKey(caseRecord.CC_Category__c) &&
                mapCCIdToName.get(caseRecord.CC_Category__c).equalsIgnoreCase('Outreach')
            ) {
                caseRecord.RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Student_Outreach');
            } else if (
                mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Graduate Advisor Portal')
            ) {
                caseRecord.RecordTypeId = RecordIDHelper.getRecordTypeId('Case', 'ASU_Graduate_Advisor_Portal');
            }
        }
    }

    public static void updateAccountIdFromContact(List<Case> updatedCases, Map<Id, Case> previousCasesMap) {
        Map<Id, Id> contactsToTrackMap = new Map<Id, Id>();
        Map<Id, Id> casesToUpdateMap = new Map<Id, Id>();

        for (Case updatedCase : updatedCases) {
            Case previousCase = previousCasesMap.get(updatedCase.Id);
            if (previousCase.ContactId != updatedCase.ContactId) {
                contactsToTrackMap.put(updatedCase.ContactId, updatedCase.Id);
            }
        }

        for (Contact contactToTrack : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactsToTrackMap.keySet()]) {
            casesToUpdateMap.put(contactsToTrackMap.get(contactToTrack.Id), contactToTrack.AccountId);
        }

        for (Case updatedCase : updatedCases) {
            if (casesToUpdateMap.keySet().contains(updatedCase.Id)) {
                updatedCase.AccountId = casesToUpdateMap.get(updatedCase.Id);
            }
        }
    }

    public class CaseAssignmentDeterminer {
        /**
         * Determine how to assign the case using details from opportunity
         */
        public CaseAssignmentDeterminer(Opportunity opp) {
            if (opp == null)
                return;

            ownerId = opp.OwnerId;
        }

        /**
         * Determine how to assign the case using details from the case and an opportunity
         */
        public CaseAssignmentDeterminer(Opportunity opp, Case newCase) {
            if (opp == null || newCase == null)
                return;

            if (
                newCase.Type_of_Additional_Assignment_Needed__c == 'Territory Manager' &&
                newCase.Associate_Case_to_Active_Opportunity__c == true
            ) {
                if (useOppForTerritoryManager(opp)) {
                    ownerId = opp.OwnerId;
                }
            } else if (
                newCase.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach' &&
                newCase.Associate_Case_to_Active_Opportunity__c == true
            ) {
                if (useOppForEnrollmentCoach(opp)) {
                    ownerId = opp.Enrollment_Coach__c;
                }
            }
        }

        /**
         * Determine how to assign the case using details from the case assignment rule and an opportunity
         */
        public CaseAssignmentDeterminer(Opportunity opp, Case_Assignment_Rule__c car) {
            if (opp == null || car == null)
                return;

            if (car.Type_of_Additional_Assignment_Needed__c == 'Territory Manager') {
                if (useOppForTerritoryManager(opp)) {
                    ownerId = opp.OwnerId;
                    typeOfAdditionalAssignment = 'Territory Manager';
                }
            } else if (car.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach') {
                if (useOppForEnrollmentCoach(opp)) {
                    ownerId = opp.Enrollment_Coach__c;
                    typeOfAdditionalAssignment = 'Enrollment Coach';
                }
            }

            setFieldsFromCar(car);
        }

        public void setCaseFields(Case newCase) {
            newCase.OwnerId = ownerId == null ? newCase.OwnerId : ownerId;
            newCase.Origin__c = origin == null ? newCase.Origin__c : origin;
            newCase.CC_Functional_Group__c = functionalGroup == null ? newCase.CC_Functional_Group__c : functionalGroup;
            newCase.CC_Category__c = category == null ? newCase.CC_Category__c : category;
            newCase.CC_Sub_Category__c = subCategory == null ? newCase.CC_Sub_Category__c : subCategory;
            newCase.Type_of_Additional_Assignment_Needed__c = typeOfAdditionalAssignment == null
                ? newCase.Type_of_Additional_Assignment_Needed__c
                : typeOfAdditionalAssignment;
        }

        private void setFieldsFromCar(Case_Assignment_Rule__c car) {
            if (ownerId == null && car.Queue_ID__c != null)
                ownerId = ID.valueOf(car.Queue_ID__c);
            if (car.Origin__c != null)
                origin = car.Origin__c;
            if (car.CC_Category__c != null)
                category = car.CC_Category__c;
            if (car.CC_Sub_Category__c != null)
                subCategory = car.CC_Sub_Category__c;
            if (car.CC_Functional_Group__c != null)
                functionalGroup = car.CC_Functional_Group__c;
        }

        private Boolean useOppForTerritoryManager(Opportunity opp) {
            return opp.Territory_Assignment_Last_Rule_Type__c != 'Default User' &&
                opp.Owner.IsActive == true &&
                opp.IsClosed == false;
        }
        private Boolean useOppForEnrollmentCoach(Opportunity opp) {
            return opp.Enrollment_Coach__c != null && opp.Enrollment_Coach__r.IsActive == true && opp.IsClosed == false;
        }

        public String ownerId = null;
        public String origin = null;
        public String functionalGroup = null;
        public String category = null;
        public String subCategory = null;
        public String typeOfAdditionalAssignment = null;
    }
}