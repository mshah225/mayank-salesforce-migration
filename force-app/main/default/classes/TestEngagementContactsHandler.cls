public without sharing class TestEngagementContactsHandler implements ITrigger {
    Map<ID, Test_Engagement_Contacts__c> relatedEngagementMap = new Map<ID, Test_Engagement_Contacts__c>();
    Savepoint sp;

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
        try {
            et4ae5.triggerUtility.automate('Test_Engagement_Contacts__c');
        } catch (Exception shouldOnlyBeInTests) {
            if (
                !Test.isRunningTest() &&
                shouldOnlyBeInTests.getTypeName() == 'et4ae5.MCBaseException.InvalidParameterException'
            ) {
                throw shouldOnlyBeInTests;
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
        Test_Engagement_Contacts__c e = (Test_Engagement_Contacts__c) so;
        TestEmailSendHelper esh = new TestEmailSendHelper();
        esh.SendIt(e.Id);
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
    }
}
