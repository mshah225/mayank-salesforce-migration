public without sharing class LeadHandler implements ITrigger {
    private static LeadStatus convertedStatus;
    private List<Lead> leadsToConvert = new List<Lead>();
    public static boolean ranLeadConversion = false;

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
    }

    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
        if (convertedStatus == null) {
            // Grab the status for converted Leads
            List<LeadStatus> statusList = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];

            if (statusList.size() > 0) {
                convertedStatus = statusList[0];
            }
        }
        if (Trigger.IsInsert) {
            List<Id> leadIdList = new List<Id>();
            for (sObject s : Trigger.New) {
                Lead l = (Lead) s;
                leadIdList.add(l.Id);
            }
            System.debug(leadIdList);
            setHashId(leadIDList);
        }
    }

    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {
        Lead newLead = (Lead) so;
        newLead.Lead_Assignment_Number__c = OpportunityService.generateOpportunityAssignmentNumber();
    }

    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
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
    public void afterInsert(SObject so) {
        Lead l = (Lead) so;

        if (l.Convert_Perform_Conversion__c) {
            leadsToConvert.add(l);
        }
    }

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        Lead l = (Lead) so;
        Lead oldL = (Lead) oldSo;

        if (l.Convert_Perform_Conversion__c && oldL.Convert_Perform_Conversion__c == false) {
            leadsToConvert.add(l);
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
        if (Trigger.isAfter && !ranLeadConversion) {
            ranLeadConversion = true;
            convertLeads();
            ranLeadConversion = false;
        }
    }

    private void convertLeads() {
        if (leadsToConvert.size() == 0) {
            return;
        }

        /*
         * Primary lead conversion logic
         */
        List<Database.LeadConvertResult> leadConversionResults = new List<Database.LeadConvertResult>();
        Set<Id> leadsNeedingPreviousEducation = new Set<Id>();
        Integer count = 0;

        Map<Integer, List<Database.LeadConvert>> leadConvertBatchMap = LeadService.generateLeadConvertBatches(
            leadsToConvert,
            convertedStatus.MasterLabel
        );

        for (List<Database.LeadConvert> lcBatch : leadConvertBatchMap.values()) {
            List<Database.LeadConvertResult> lcResultList = Database.convertLead(lcBatch, false);
            leadConversionResults.addAll(lcResultList);
        }

        Set<Id> convertedLeadIds = new Set<Id>();
        List<String> vars = new List<String>();
        for (Database.LeadConvertResult lcr : leadConversionResults) {
            try {
                if (lcr.isSuccess()) {
                    convertedLeadIds.add(lcr.getLeadId());
                } else
                    throw new LeadConversionException('Failed Lead Conversion');
            } catch (Exception e) {
                vars.add(ErrorLogger.convertIdToJSON('Lead Id', lcr.getLeadId()));
            }
        }
        if (vars != null && vars.size() > 0) {
            Exception e = new LeadConversionException('Failed Lead Conversion');
            ErrorLogger.log(e, vars, false);
        }

        // Map convert lead data to associated opportunities, if any
        if (convertedLeadIds.size() > 0) {
            List<Opportunity> oppsToUpdate = OpportunityService.mapLeadDataToOpportunity(convertedLeadIds);
            update oppsToUpdate;

            /*
             * Create necessary records and perform data processing as a result of lead conversion
             */
            for (Lead l : leadsToConvert) {
                // If Leads has Last Institution Attended populated, add to the List that
                // needs a Previous Education entry added
                if (l.Last_Institution_Attended__c != null) {
                    leadsNeedingPreviousEducation.add(l.Id);
                }
            }

            if (leadsNeedingPreviousEducation.size() > 0) {
                List<Previous_Education__c> previousEducationList = LeadService.createConvertedPreviousEducation(
                    leadsNeedingPreviousEducation
                );
                insert previousEducationList;
            }
        }
    }

    @future
    static void setHashId(List<Id> LeadIdList) {
        List<Lead> leadList = new List<Lead>();
        for (Id i : leadIdList) {
            Lead c = new Lead(Id = i, HashLeadID__c = Hasher.hashId(i));
            leadList.add(c);
        }
        update leadList;
    }

    class LeadConversionException extends Exception {
    }
}
