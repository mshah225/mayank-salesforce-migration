public without sharing class CaseHandler
implements ITrigger {

    Map<ID, Contact> relatedContactMap = new Map<ID, Contact>();
    Map<Id, Campaign> sourceMap = new Map<Id, Campaign>();
    List<RecordType> recruitmentCaseRT;
    Set<Id> groupIds;
    Savepoint sp;

    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore()
    {
        if (Trigger.isUpdate)
        {
            Map<Id, String> groupNameMap = GroupService.mapGroupIdToName();

            for (Case caze : (List<Case>) Trigger.new)
            {
                if (groupNameMap.containsKey(caze.OwnerId))
                {
                    caze.Most_Recent_Queue__c = groupNameMap.get(caze.OwnerId);
                }
            }
        }

        if (!Trigger.isInsert)
        {
            return;
        }

        recruitmentCaseRT = new List<RecordType>([SELECT Id FROM RecordType WHERE SobjectType='Case' AND DeveloperName = 'ASU_Admission_Services']);
        if (recruitmentCaseRT.size() < 1)
        return;

        Set<Id> caseContactIdSet = new Set<ID>();
        Set<Id> campaignIdSet = new Set<Id>();

        for (Case c: (List<Case>)Trigger.new)
        {
            if (c.RecordTypeId == recruitmentCaseRT[0].Id)
            {
                campaignIdSet.add(c.Case_Source__c);
                // Case "a"
                // SFR-1109; removed boolean check here to correct bug on webform submissions
                //if (c.Associate_Case_to_Active_Opportunity__c == true) {
                caseContactIdSet.add(c.ContactId);
                //}

            }
        }

        relatedContactMap = new Map<Id, Contact>([SELECT Id, (Select Id, StageName, Territory_Assignment_Last_Rule_Type__c, OwnerId, Owner.IsActive, Enrollment_Coach__c, Enrollment_Coach__r.IsActive, CreatedDate, IsClosed FROM Opportunities__r ORDER BY IsClosed ASC, CreatedDate DESC) FROM Contact WHERE Id in :caseContactIdSet]);
        if (campaignIdSet.size() > 0) {
            sourceMap = new Map<Id, Campaign>([SELECT Id, Case_Assignment_Rule__r.Id, Case_Assignment_Rule__r.Queue_ID__c, Case_Assignment_Rule__r.Category__c, Case_Assignment_Rule__r.Sub_Category__c, Case_Assignment_Rule__r.Origin__c, Case_Assignment_Rule__r.Functional_Group__c, Case_Assignment_Rule__r.Type_of_Additional_Assignment_Needed__c FROM Campaign WHERE Id IN :campaignIdSet]);
        }

    }

    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {}

        /**
        * beforeInsert
        *
        * This method is called iteratively for each record to be inserted during a BEFORE
        * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
        */
        public void beforeInsert(SObject so) {
            Case c = (Case)so;

            if (recruitmentCaseRT.size() > 0 && c.RecordTypeId == recruitmentCaseRT[0].Id) {
                Contact con = relatedContactMap.get(c.ContactId);
                List<Opportunity> opList = new List<Opportunity>();
                Case_Assignment_Rule__c defaultCAR;
                boolean ownerSet = false;

                if (con != null)
                opList = con.Opportunities__r;

                system.debug('GRF c: ' + c);
                system.debug('GRF opList: ' + opList);

                // SFR-1109; moved boolean check here to correct bug on webform submissions
                if (c.Associate_Case_to_Active_Opportunity__c == true && opList != null && opList.size() > 0)
                c.Opportunity__c = opList[0].Id;

                // Special handling for API users below for webform integrations'
                system.debug('GRF Username: ' + UserInfo.getFirstName());
                system.debug('GRF sourceMap: ' + sourceMap);
                if (!UserInfo.getFirstName().equals('API') || UserInfo.getLastName().equals('ASU EMAIL SERVICE')) {
                    // SFR-1109; added opList check here to correct bug on webform submissions
                    if (opList != null && opList.size() > 0) {
                        // Case "b"
                        if (c.Type_of_Additional_Assignment_Needed__c == 'Territory Manager' && c.Associate_Case_to_Active_Opportunity__c == true) {
                            if (opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' && opList[0].Owner.IsActive == true && opList[0].IsClosed == false) {
                                c.OwnerId = opList[0].OwnerId;
                                ownerSet = true;
                            }
                        }
                        // Case "c"
                        else if (c.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach' && c.Associate_Case_to_Active_Opportunity__c == true) {
                            if (opList[0].Enrollment_Coach__c != null && opList[0].Enrollment_Coach__r.IsActive == true && opList[0].IsClosed == false) {
                                c.OwnerId = opList[0].Enrollment_Coach__c;
                                ownerSet = true;
                            }
                        }
                    }
                }
                // Case for API users (webforms)
                else {
                    if (sourceMap.containsKey(c.Case_Source__c)) {
                        Campaign source = sourceMap.get(c.Case_Source__c);
                        // Did we find a related Case Assignment Rule?
                        if (source.Case_Assignment_Rule__c != null) {

                            // SFE-690 Apply TM/EC logic to API users as well as non-API users
                            if (opList != null && opList.size() > 0) {
                                // Case "b"
                                if (source.Case_Assignment_Rule__r.Type_of_Additional_Assignment_Needed__c == 'Territory Manager') {
                                    if (opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' && opList[0].Owner.IsActive == true && opList[0].IsClosed == false) {
                                        c.OwnerId = opList[0].OwnerId;
                                        c.Type_of_Additional_Assignment_Needed__c = 'Territory Manager';
                                        ownerSet = true;
                                    }
                                }
                                // Case "c"
                                else if (source.Case_Assignment_Rule__r.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach') {
                                    if (opList[0].Enrollment_Coach__c != null && opList[0].Enrollment_Coach__r.IsActive == true && opList[0].IsClosed == false) {
                                        c.OwnerId = opList[0].Enrollment_Coach__c;
                                        c.Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach';
                                        ownerSet = true;
                                    }
                                }
                            }

                            if (!ownerSet && source.Case_Assignment_Rule__r.Queue_ID__c != null)
                            c.OwnerId = ID.valueOf(source.Case_Assignment_Rule__r.Queue_ID__c);
                            if (source.Case_Assignment_Rule__r.Origin__c != null)
                            c.Origin__c = source.Case_Assignment_Rule__r.Origin__c;
                            if (source.Case_Assignment_Rule__r.Category__c != null)
                            c.Category__c = source.Case_Assignment_Rule__r.Category__c;
                            if (source.Case_Assignment_Rule__r.Sub_Category__c != null)
                            c.Sub_Category__c = source.Case_Assignment_Rule__r.Sub_Category__c;
                            if (source.Case_Assignment_Rule__r.Functional_Group__c != null)
                            c.Functional_Group__c =source.Case_Assignment_Rule__r.Functional_Group__c;
                        }
                        else {
                            // No related Case Assignment Rule found; use the Territory Manager if found
                            if (opList != null && opList.size() > 0 && opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' && opList[0].Owner.IsActive == true)
                            c.OwnerId = opList[0].OwnerId;
                            else {
                                // No valid Territory Manager found; use default Case Assignment Rule
                                if (defaultCAR == null) {
                                    defaultCar = [SELECT Id, Queue_ID__c, Origin__c, Category__c, Sub_Category__c, Functional_Group__c, Type_of_Additional_Assignment_Needed__c FROM Case_Assignment_Rule__c WHERE Email_Address__c = 'admissions@asu.edu'];
                                    if (!(defaultCAR == null)) {

                                        // SFE-690 Apply TM/EC logic to API users as well as non-API users
                                        if (opList != null && opList.size() > 0) {
                                            // Case "b"
                                            if (defaultCar.Type_of_Additional_Assignment_Needed__c == 'Territory Manager') {
                                                if (opList[0].Territory_Assignment_Last_Rule_Type__c != 'Default User' && opList[0].Owner.IsActive == true && opList[0].IsClosed == false) {
                                                    c.OwnerId = opList[0].OwnerId;
                                                    c.Type_of_Additional_Assignment_Needed__c = 'Territory Manager';
                                                    ownerSet = true;
                                                }
                                            }
                                            // Case "c"
                                            else if (defaultCar.Type_of_Additional_Assignment_Needed__c == 'Enrollment Coach') {
                                                if (opList[0].Enrollment_Coach__c != null && opList[0].Enrollment_Coach__r.IsActive == true && opList[0].IsClosed == false) {
                                                    c.OwnerId = opList[0].Enrollment_Coach__c;
                                                    c.Type_of_Additional_Assignment_Needed__c = 'Enrollment Coach';
                                                    ownerSet = true;
                                                }
                                            }
                                        }
                                        if (!ownerSet && defaultCar.Queue_ID__c != null)
                                        c.OwnerId = ID.valueOf(defaultCar.Queue_ID__c);

                                        if (defaultCAR.Origin__c != null)
                                        c.Origin__c = defaultCAR.Origin__c;
                                        if (defaultCAR.Category__c != null)
                                        c.Category__c = defaultCAR.Category__c;
                                        if (defaultCAR.Sub_Category__c != null)
                                        c.Sub_Category__c = defaultCAR.Sub_Category__c;
                                        if (defaultCAR.Functional_Group__c != null)
                                        c.Functional_Group__c = defaultCAR.Functional_Group__c;
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
        public void beforeUpdate(SObject oldSo, SObject so)
        {
            Case oldCase = (Case) oldSo;
            Case newCase = (Case) so;

            if (newCase.Functional_Group__c != oldCase.Functional_Group__c && oldCase.Functional_Group__c != 'External Unit')
            {
                newCase.Most_Recent_Functional_Group__c = oldCase.Functional_Group__c;
            }
        }

        /**
        * beforeDelete
        *
        * This method is called iteratively for each record to be deleted during a BEFORE
        * trigger.
        */
        public void beforeDelete(SObject so){}

            /**
            * beforeFinally
            *
            * This method is called at the end of the execution of a BEFORE trigger. Use this to finalize
            * any bulk operations for a BEFORE trigger.
            */
            public void beforeFinally(){}

                /**
                * afterInsert
                *
                * This method is called iteratively for each record inserted during an AFTER
                * trigger. Always put field validation in the 'After' methods in case another trigger
                * has modified any values. The record is 'read only' by this point.
                */
                public void afterInsert(SObject so) {}

                    /**
                    * afterUpdate
                    *
                    * This method is called iteratively for each record updated during an AFTER
                    * trigger.
                    */
                    public void afterUpdate(SObject oldSo, SObject so) {
                        Case c = (Case)so;
                        Case oldc = (Case)oldSo;

                        //Forward the email and attach any case attachments as well
                        if (c.Status == 'Closed: Forwarded' && oldC.Status != 'Closed: Forwarded'){
                            //Prevent recursive update and sending of mail
                            if(!CaseUtilities.emailForwarded){
                                CaseUtilities.emailForwarded = true;
                                CaseUtilities.forwardCaseAttachments(c.Id, c.Forward_To_Email__c , c.Forward_To_Email_Calculation__c);
                            }
                        }
                    }

                    /**
                    * afterDelete
                    *
                    * This method is called iteratively for each record deleted during an AFTER
                    * trigger.
                    */
                    public void afterDelete(SObject so){}

                        /**
                        * andFinally
                        *
                        * This method is called once all records have been processed by the trigger. Use this
                        * method to accomplish any final operations such as creation or updates of other records.
                        */
                        public void andFinally() {

                        }

                    }
