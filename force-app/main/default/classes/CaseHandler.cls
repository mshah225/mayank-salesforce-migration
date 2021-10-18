public without sharing class CaseHandler implements ITrigger {
    private Map<ID, Contact> relatedContactMap = new Map<ID, Contact>();
    private Map<Id, Campaign> sourceMap = new Map<Id, Campaign>();
    private Map<Id, Group> groupNameMap = new Map<Id, Group>();
    private List<RecordType> recruitmentCaseRT;
    private Savepoint sp;
    public Map<Id, String> mapCCIdToName;
    public final String RT_ADMIN_ONLY_ASU_ADVISOR_OUTREACH = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('(Admin Only) ASU Advisor Outreach')
        .getRecordTypeId();
    public final String RT_ASU_COACH_OUTREACH = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('ASU Coach Outreach')
        .getRecordTypeId();
    public final String RT_ASU_ADMISSION_SERVICE = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('ASU Admission Services')
        .getRecordTypeId();
    public final String RT_ASU_SERVICE = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('ASU Service')
        .getRecordTypeId();
    public final String RT_ASU_STUDENT_OUTREACH = Schema.SObjectType.Case.getRecordTypeInfosByName()
        .get('ASU Student Outreach')
        .getRecordTypeId();

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
        // Call the Group Service to map all the group names to their ids
        Set<String> caseClassificationsToQuery = new Set<String>();
        List<CaseClassifier> casesToClassify = new List<CaseClassifier>();
        Set<Id> setOfCaseClassficationId = new Set<Id>();

        if (Trigger.isInsert) {
            LogSuite.log('query', 'Calling recruitment case RT query');
            recruitmentCaseRT = new List<RecordType>(
                [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'ASU_Admission_Services']
            );
            if (recruitmentCaseRT.size() < 1) {
                return;
            }

            Set<Id> caseContactIdSet = new Set<ID>();
            Set<Id> campaignIdSet = new Set<Id>();

            for (Case newCase : (List<Case>) Trigger.new) {
                if (newCase.RecordTypeId == recruitmentCaseRT[0].Id) {
                    campaignIdSet.add(newCase.Case_Source__c);
                    caseContactIdSet.add(newCase.ContactId);
                }

                // Check each incoming case for valid classification fields.
                CaseClassifier classifier = new CaseClassifier(newCase);
                if (classifier.hasInvalidCaseClassification()) {
                    caseClassificationsToQuery.addAll(classifier.getMissingClassifications());
                    casesToClassify.add(classifier);
                }
                // populate CaseClassification Ids into list for a bulk query
                setOfCaseClassficationId.add(newCase.CC_Functional_Group__c);
                setOfCaseClassficationId.add(newCase.CC_Category__c);
                setOfCaseClassficationId.add(newCase.CC_Sub_Category__c);
            }

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

            if (campaignIdSet.size() > 0) {
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

            // SFE-11309 - Refactor, needs this query to be run atleast once
            List<Case_Classification__c> classifications = [
                SELECT Name, Parent__r.Name, Parent__r.Parent__r.Name, RecordType.Name, Record_Types__c
                FROM Case_Classification__c
                WHERE (Name IN :caseClassificationsToQuery AND Active__c = TRUE) OR ID IN :setOfCaseClassficationId
            ];
            Map<String, Case_Classification__c> nameToClassification = new Map<String, Case_Classification__c>();
            mapCCIdToName = new Map<Id, String>();
            for (Case_Classification__c classification : classifications) {
                // If check to sort based on if caseClassificationsToQuery or lstCaseClassfication
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

            // classification has been completed, so we can update the old values as per new values
            // SFE-11309; Update the Old CC fields as per new CC field values

            List<Id> ownerIdForCasesBeingInserted = new List<Id>();
            for (Case caseRecord : (List<Case>) Trigger.new) {
                caseRecord.Functional_Group__c = mapCCIdToName.get(caseRecord.CC_Functional_Group__c);
                caseRecord.Category__c = mapCCIdToName.get(caseRecord.CC_Category__c);
                caseRecord.Sub_Category__c = mapCCIdToName.get(caseRecord.CC_Sub_Category__c);
                if (caseRecord.Original_Functional_Group__c == null) {
                    caseRecord.Original_Functional_Group__c = caseRecord.Functional_Group__c;
                    caseRecord.Original_Category__c = caseRecord.Category__c;
                    caseRecord.Original_Sub_Category__c = caseRecord.Sub_Category__c;
                }
                assignRecordType(caseRecord);
                ownerIdForCasesBeingInserted.add(caseRecord.OwnerId);
            }
            groupNameMap = GroupService.mapGroupIdToName(ownerIdForCasesBeingInserted);
        } else if (Trigger.isUpdate) {
            for (Case newCase : (List<Case>) Trigger.new) {
                Case previousCaseState = (Case) Trigger.oldMap.get(newCase.Id);
                CaseWebformCloser closer = new CaseWebformCloser(newCase, previousCaseState);
                closer.handleWebformCase();
                // Check each incoming case for valid classification fields.
                CaseClassifier classifier = new CaseClassifier(newCase);
                if (classifier.hasInvalidCaseClassification()) {
                    caseClassificationsToQuery.addAll(classifier.getMissingClassifications());
                    casesToClassify.add(classifier);
                }
                // after classification has been done, populate CaseClassification Ids into list for a bulk query
                setOfCaseClassficationId.add(newCase.CC_Functional_Group__c);
                setOfCaseClassficationId.add(newCase.CC_Category__c);
                setOfCaseClassficationId.add(newCase.CC_Sub_Category__c);
            }

            // SFE-11309 - Refactor, needs this query to be run atleast once
            List<Case_Classification__c> classifications = [
                SELECT Name, Parent__r.Name, Parent__r.Parent__r.Name, RecordType.Name, Record_Types__c
                FROM Case_Classification__c
                WHERE (Name IN :caseClassificationsToQuery AND Active__c = TRUE) OR ID IN :setOfCaseClassficationId
            ];
            Map<String, Case_Classification__c> nameToClassification = new Map<String, Case_Classification__c>();
            mapCCIdToName = new Map<Id, String>();

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

            // classification has been completed, so we can update the old values as per new values
            // SFE-11309; Update the Old CC fields as per new CC field values
            // checks if CC exists and Name is not null
            //
            List<Id> ownerIdForCasesBeingUpdated = new List<Id>();
            for (Case caseRecord : (List<Case>) Trigger.new) {
                caseRecord.Functional_Group__c = mapCCIdToName.get(caseRecord.CC_Functional_Group__c);
                caseRecord.Category__c = mapCCIdToName.get(caseRecord.CC_Category__c);
                caseRecord.Sub_Category__c = mapCCIdToName.get(caseRecord.CC_Sub_Category__c);

                assignRecordType(caseRecord);
                ownerIdForCasesBeingUpdated.add(caseRecord.OwnerId);
            }
            groupNameMap = GroupService.mapGroupIdToName(ownerIdForCasesBeingUpdated);
        }
    }

    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
    }

    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {
        Case newCase = (Case) so;

        // Set system info field for Most Recent Queue
        if (groupNameMap.containsKey(newCase.OwnerId)) {
            newCase.Most_Recent_Queue__c = groupNameMap.get(newCase.OwnerId).Name;
        }
        // Set system info field for Most Recent Functional Group
        if (newCase.Functional_Group__c != 'External Unit' && newCase.Functional_Group__c != null) {
            newCase.Most_Recent_Functional_Group__c = newCase.Functional_Group__c;
        }

        //Support for Drupal Webforms
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

        if (recruitmentCaseRT.size() > 0 && newCase.RecordTypeId == recruitmentCaseRT[0].Id) {
            Contact con = relatedContactMap.get(newCase.ContactId);
            List<Opportunity> opList = new List<Opportunity>();
            Case_Assignment_Rule__c defaultCAR;
            boolean ownerSet = false;

            if (con != null) {
                opList = con.Opportunities__r;
            }

            // SFR-1109; moved boolean check here to correct bug on webform submissions
            if (newCase.Associate_Case_to_Active_Opportunity__c == true && opList != null && opList.size() > 0) {
                newCase.Opportunity__c = opList[0].Id;
            }

            // Special handling for API users below for webform integrations'
            if (!UserInfo.getFirstName().equals('API') || UserInfo.getLastName().equals('ASU EMAIL SERVICE')) {
                // SFR-1109; added opList check here to correct bug on webform submissions
                if (opList != null && opList.size() > 0) {
                    // Case "b"
                    if (
                        newCase.Type_of_Additional_Assignment_Needed__c == 'Territory Manager' &&
                        newCase.Associate_Case_to_Active_Opportunity__c == true
                    ) {
                        if (
                            opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' &&
                            opList[0].Owner.IsActive == true &&
                            opList[0].IsClosed == false
                        ) {
                            newCase.OwnerId = opList[0].OwnerId;
                            ownerSet = true;
                        }
                    } else if (
                        newCase.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach' &&
                        newCase.Associate_Case_to_Active_Opportunity__c == true
                    ) {
                        // Case "newCase"
                        if (
                            opList[0].Enrollment_Coach__c != null &&
                            opList[0].Enrollment_Coach__r.IsActive == true &&
                            opList[0].IsClosed == false
                        ) {
                            newCase.OwnerId = opList[0].Enrollment_Coach__c;
                            ownerSet = true;
                        }
                    }
                }
            } else {
                if (sourceMap.containsKey(newCase.Case_Source__c)) {
                    Campaign source = sourceMap.get(newCase.Case_Source__c);
                    // Did we find a related Case Assignment Rule?
                    if (source.Case_Assignment_Rule__c != null) {
                        if (opList != null && opList.size() > 0) {
                            // Case "b"
                            if (
                                source.Case_Assignment_Rule__r.Type_of_Additional_Assignment_Needed__c ==
                                'Territory Manager'
                            ) {
                                if (
                                    opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' &&
                                    opList[0].Owner.IsActive == true &&
                                    opList[0].IsClosed == false
                                ) {
                                    newCase.OwnerId = opList[0].OwnerId;
                                    newCase.Type_of_Additional_Assignment_Needed__c = 'Territory Manager';
                                    ownerSet = true;
                                }
                            } else if (
                                source.Case_Assignment_Rule__r.Type_of_Additional_Assignment_Needed__c ==
                                'Enrollment Coach'
                            ) {
                                if (
                                    opList[0].Enrollment_Coach__c != null &&
                                    opList[0].Enrollment_Coach__r.IsActive == true &&
                                    opList[0].IsClosed == false
                                ) {
                                    newCase.OwnerId = opList[0].Enrollment_Coach__c;
                                    newCase.Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach';
                                    ownerSet = true;
                                }
                            }
                        }

                        if (!ownerSet && source.Case_Assignment_Rule__r.Queue_ID__c != null) {
                            newCase.OwnerId = ID.valueOf(source.Case_Assignment_Rule__r.Queue_ID__c);
                        }
                        if (source.Case_Assignment_Rule__r.Origin__c != null) {
                            newCase.Origin__c = source.Case_Assignment_Rule__r.Origin__c;
                        }
                        if (source.Case_Assignment_Rule__r.CC_Category__c != null) {
                            newCase.CC_Category__c = source.Case_Assignment_Rule__r.CC_Category__c;
                        }
                        if (source.Case_Assignment_Rule__r.CC_Sub_Category__c != null) {
                            newCase.CC_Sub_Category__c = source.Case_Assignment_Rule__r.CC_Sub_Category__c;
                        }
                        if (source.Case_Assignment_Rule__r.CC_Functional_Group__c != null) {
                            newCase.CC_Functional_Group__c = source.Case_Assignment_Rule__r.CC_Functional_Group__c;
                        }
                    } else {
                        // No related Case Assignment Rule found; use the Territory Manager if found
                        if (
                            opList != null &&
                            opList.size() > 0 &&
                            opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' &&
                            opList[0].Owner.IsActive == true
                        ) {
                            newCase.OwnerId = opList[0].OwnerId;
                        } else {
                            // No valid Territory Manager found; use default Case Assignment Rule
                            if (defaultCAR == null) {
                                LogSuite.log('query', 'Calling default CAR query');
                                defaultCar = [
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
                                if (!(defaultCAR == null)) {
                                    if (opList != null && opList.size() > 0) {
                                        if (defaultCar.Type_of_Additional_Assignment_Needed__c == 'Territory Manager') {
                                            if (
                                                opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' &&
                                                opList[0].Owner.IsActive == true &&
                                                opList[0].IsClosed == false
                                            ) {
                                                newCase.OwnerId = opList[0].OwnerId;
                                                newCase.Type_of_Additional_Assignment_Needed__c = 'Territory Manager';
                                                ownerSet = true;
                                            }
                                        } else if (
                                            defaultCar.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach'
                                        ) {
                                            if (
                                                opList[0].Enrollment_Coach__c != null &&
                                                opList[0].Enrollment_Coach__r.IsActive == true &&
                                                opList[0].IsClosed == false
                                            ) {
                                                newCase.OwnerId = opList[0].Enrollment_Coach__c;
                                                newCase.Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach';
                                                ownerSet = true;
                                            }
                                        }
                                    }
                                    if (!ownerSet && defaultCar.Queue_ID__c != null) {
                                        newCase.OwnerId = ID.valueOf(defaultCar.Queue_ID__c);

                                        if (defaultCAR.Origin__c != null) {
                                            newCase.Origin__c = defaultCAR.Origin__c;
                                        }
                                        if (defaultCAR.CC_Category__c != null) {
                                            newCase.CC_Category__c = defaultCAR.CC_Category__c;
                                        }
                                        if (defaultCAR.CC_Sub_Category__c != null) {
                                            newCase.CC_Sub_Category__c = defaultCAR.CC_Sub_Category__c;
                                        }
                                        if (defaultCAR.CC_Functional_Group__c != null) {
                                            newCase.CC_Functional_Group__c = defaultCAR.CC_Functional_Group__c;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
        Case newCase = (Case) so;
        Case oldCase = (Case) oldSo;

        // Update the Most Recent Functional Group if the Functional Group has changed
        if (
            newCase.Functional_Group__c != oldCase.Functional_Group__c &&
            newCase.Functional_Group__c != 'External Unit'
        ) {
            newCase.Most_Recent_Functional_Group__c = newCase.Functional_Group__c;
        }

        // Update the Most Recent Queue field if the case owner is a Group
        if (groupNameMap.containsKey(newCase.OwnerId)) {
            newCase.Most_Recent_Queue__c = groupNameMap.get(newCase.OwnerId).Name;
        }
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so) {
    }

    /**
     * beforeFinally
     *
     * This method is called at the end of the execution of a BEFORE trigger. Use this to finalize
     * any bulk operations for a BEFORE trigger.
     */
    public void beforeFinally() {
    }

    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject newObject) {
        Case newCase = (Case) newObject;

        //Forward the email and attach any case attachments as well
        if (newCase.Status == 'Closed: Forwarded') {
            //Prevent recursive update and sending of mail
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

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        Case newCase = (Case) so;
        Case oldCase = (Case) oldSo;

        //Forward the email and attach any case attachments as well
        if (newCase.Status == 'Closed: Forwarded' && oldCase.Status != 'Closed: Forwarded') {
            //Prevent recursive update and sending of mail
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

    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so) {
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
    }

    /**
     * assignRecordType
     * @description: processes the case record and assigns a particular record type
     *               based on various conditions, called in bulkBefore and bulkAfter
     * @caseRecord: Input case record coming from before and after context
     */
    public void assignRecordType(Case caseRecord) {
        if (mapCCIdToName.containsKey(caseRecord.CC_Functional_Group__c)) {
            if (mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Advisor Outreach')) {
                caseRecord.RecordTypeId = RT_ADMIN_ONLY_ASU_ADVISOR_OUTREACH;
            } else if (mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Coach Outreach')) {
                caseRecord.RecordTypeId = RT_ASU_COACH_OUTREACH;
            } else if (
                (caseRecord.RecordTypeId == RT_ASU_SERVICE &&
                !mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('ASU Salesforce Support')) &&
                (mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('Admission Services') ||
                (mapCCIdToName.containsKey(caseRecord.CC_Category__c) &&
                mapCCIdToName.get(caseRecord.CC_Category__c).containsIgnoreCase('Recruitment')) ||
                (mapCCIdToName.containsKey(caseRecord.CC_Sub_Category__c) &&
                mapCCIdToName.get(caseRecord.CC_Sub_Category__c).containsIgnoreCase('Recruitment')))
            ) {
                caseRecord.RecordTypeId = RT_ASU_ADMISSION_SERVICE;
            } else if (
                caseRecord.RecordTypeId == RT_ASU_ADMISSION_SERVICE &&
                !mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('Admission Services') &&
                !mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('External Unit') &&
                (caseRecord.CC_Category__c == null ||
                (mapCCIdToName.containsKey(caseRecord.CC_Category__c) &&
                !mapCCIdToName.get(caseRecord.CC_Category__c).containsIgnoreCase('Recruitment'))) &&
                (caseRecord.CC_Sub_Category__c == null ||
                (mapCCIdToName.containsKey(caseRecord.CC_Sub_Category__c) &&
                !mapCCIdToName.get(caseRecord.CC_Sub_Category__c).containsIgnoreCase('Recruitment')))
            ) {
                caseRecord.RecordTypeId = RT_ASU_SERVICE;
            } else if (
                mapCCIdToName.get(caseRecord.CC_Functional_Group__c).equalsIgnoreCase('Financial Aid') &&
                mapCCIdToName.containsKey(caseRecord.CC_Category__c) &&
                mapCCIdToName.get(caseRecord.CC_Category__c).equalsIgnoreCase('Outreach')
            ) {
                caseRecord.RecordTypeId = RT_ASU_STUDENT_OUTREACH;
            }
        }
    }
}
