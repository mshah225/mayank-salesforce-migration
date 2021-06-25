public without sharing class OpportunityHandler implements ITrigger {
    private Map<Id, Id> oppToContactMap = new Map<Id, Id>();
    private Map<Id, Id> leadToContactMap = new Map<Id, Id>();
    private static Map<Id, Account> accountMap;
    private List<Id> planIds = new List<Id>();
    private Map<Id, Id> programColleges = new Map<Id, Id>();
    private static Set<Id> accountIds;

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
        accountIds = new Set<Id>();
        accountMap = new Map<Id, Account>();

        if (Trigger.isInsert || Trigger.isUpdate) {
            //Get all accounts attached to the opportunity
            Boolean missingContact = false;
            Boolean changedPlan = false;

            for (Integer x = 0; x < Trigger.new.size(); x++) {
                Opportunity o = (Opportunity) Trigger.new.get(x);

                if (o.AccountId != null) {
                    accountIds.add(o.AccountId);
                }

                if (o.Contact__c == null) {
                    missingContact = true;
                }

                Id oldAdmittedPlan = null;
                Id oldAcademicPlan = null;

                if (Trigger.isUpdate) {
                    Opportunity oldOpp = (Opportunity) Trigger.old.get(x);
                    oldAdmittedPlan = oldOpp.Admitted_Plan__c;
                    oldAcademicPlan = oldOpp.Academic_Plan__c;
                }

                if (o.Academic_Plan__c != oldAcademicPlan || o.Admitted_Plan__c != oldAdmittedPlan) {
                    changedPlan = true;
                    if (o.Academic_Plan__c != oldAcademicPlan) {
                        planIds.add(o.Academic_Plan__c);
                    }

                    if (o.Admitted_Plan__c != oldAdmittedPlan) {
                        planIds.add(o.Admitted_Plan__c);
                    }
                }
            }

            if (missingContact && accountIds.size() > 0) {
                //Get all Contacts linked to the Opportunities via the Accounts
                accountMap = new Map<Id, Account>([SELECT Id, Contact__c FROM Account WHERE Id IN :accountIds]);
            }

            if (changedPlan) {
                List<Plan__c> programs = [SELECT Id, Program__c FROM Plan__c WHERE Id IN :planIds];
                for (Integer x = 0; x < programs.size(); x++) {
                    Plan__c c = programs.get(x);
                    programColleges.put(c.Id, c.Program__c);
                }

                //For each of the new opportunities, if we have changed the academic or admitted plans,
                //update the college on the opportunity to point to the plan's college
                for (Integer x = 0; x < Trigger.new.size(); x++) {
                    Opportunity newOpp = (Opportunity) Trigger.new.get(x);

                    Id oldAdmittedPlan = null;
                    Id oldAcademicPlan = null;
                    if (Trigger.isUpdate) {
                        Opportunity oldOpp = (Opportunity) Trigger.old.get(x);
                        oldAdmittedPlan = oldOpp.Admitted_Plan__c;
                        oldAcademicPlan = oldOpp.Academic_Plan__c;
                    }

                    if (newOpp.Academic_Plan__c != oldAcademicPlan || newOpp.Admitted_Plan__c != oldAdmittedPlan) {
                        if (newOpp.Admitted_Plan__c != null) {
                            newOpp.College__c = programColleges.get(newOpp.Admitted_Plan__c);
                        } else if (newOpp.Academic_Plan__c != null) {
                            newOpp.College__c = programColleges.get(newOpp.Academic_Plan__c);
                        }
                    }
                }
            }
        }
    }

    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> afterAccountIds = new Set<Id>();
            for (SObject so : Trigger.new) {
                Opportunity o = (Opportunity) so;
                if (o.AccountId != null) {
                    afterAccountIds.add(o.AccountId);
                }
            }

            //If the accounts on the Opportunity have changed since we last queried them, get them again
            if (afterAccountIds.size() > 0 && (accountMap == null || !accountIds.containsAll(afterAccountIds))) {
                accountMap = new Map<Id, Account>([SELECT Id, Contact__c FROM Account WHERE Id IN :afterAccountIds]);
            }

            for (SObject so : Trigger.new) {
                Opportunity o = (Opportunity) so;
                if (o.converted_lead_id__c != null && o.AccountId != null) {
                    leadToContactMap.put(ID.valueOf(o.converted_lead_id__c), accountMap.get(o.AccountId).contact__c);
                }
            }
        }
    }

    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {
        Opportunity o = (Opportunity) so;

        o.Opportunity_Assignment_Number_Rand__c = OpportunityService.generateOpportunityAssignmentNumber();

        // Populate the contact reference on the Opportunity if there is none set
        if (o.Contact__c == null && accountMap.size() > 0) {
            // We should always have an account for an Opportunity
            Account oppsAccount = accountMap.get(o.AccountId);
            o.Contact__c = oppsAccount.Contact__c;
        }
    }

    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
        Opportunity o = (Opportunity) so;

        if (oppToContactMap.containsKey(o.Id)) {
            o.contact__c = oppToContactMap.get(o.Id);
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
    public void afterInsert(SObject so) {
    }

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
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
        if (Trigger.isAfter && Trigger.isInsert) {
            cleanUpLeadInterests(Trigger.new);
        }
    }

    private void cleanUpLeadInterests(List<Opportunity> opportunityList) {
        if (opportunityList.size() == 0) {
            return;
        }

        Set<Id> contactIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();

        for (Opportunity o : opportunityList) {
            if (o.converted_lead_id__c != null) {
                leadIds.add(ID.valueOf(o.converted_lead_id__c));
            }
        }

        if (leadIds.size() > 0) {
            List<Lead_Interest__c> leadInterestList = new List<Lead_Interest__c>(
                [SELECT Id, Status__c, leads__c FROM Lead_Interest__c WHERE leads__c IN :leadIds]
            );

            for (Lead_Interest__c li : leadInterestList) {
                if (leadToContactMap.containsKey(li.leads__c)) {
                    li.Contact__c = leadToContactMap.get(li.leads__c);
                }
            }

            if (leadInterestList.size() > 0) {
                update leadInterestList;
            }
        }

        return;
    }
}
