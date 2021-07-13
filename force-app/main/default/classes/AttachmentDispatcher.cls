public with sharing class AttachmentDispatcher implements IDispatch {
    private static final boolean debug = false; // Toggle debug error reporting
    private static Map<Id, Attachment> newAttachments; // trigger.new
    private static Map<Id, Attachment> oldAttachments; // trigger.oldMap
    private static Map<Id, Case> casesToUpdate; // Map of cases that need to be updated based on business logic

    public AttachmentDispatcher(Map<Id, Attachment> newMap, Map<Id, Attachment> oldMap) {
        newAttachments = newMap;
        oldAttachments = oldMap;
    }

    /**
     * Method containing business logic to process after insert triggers
     * <p>
     * SFE-5455: Number_Of_Files__c on cases needs to be updated when
     * attachments are inserted
     */
    public void afterInsert() {
        casesToUpdate = AttachmentService.getCasesFromAttachments(newAttachments.values());

        if (casesToUpdate != null && !casesToUpdate.isEmpty()) {
            casesToUpdate = AttachmentService.setCaseNumberOfFiles(casesToUpdate);
            update casesToUpdate.values();
        }
    }

    /**
     * method containing business logic to process after undeleting records
     * <p>
     * Undeleting records is the same as re-inserting them into the database.
     * Because of this, we simply re-call the insert handlers
     */
    public void afterUndelete() {
        beforeInsert();
        afterInsert();
    }

    /**
     * Method containing business logic to process after delete triggers
     * <p>
     * SFE-5455: Number_Of_Files__c on cases needs to be updated when
     * attachments are deleted
     */
    public void afterDelete() {
        casesToUpdate = AttachmentService.getCasesFromAttachments(oldAttachments.values());

        if (casesToUpdate != null && !casesToUpdate.isEmpty()) {
            casesToUpdate = AttachmentService.setCaseNumberOfFiles(casesToUpdate);
            update casesToUpdate.values();
        }
    }

    //Required by Dispatcher Interface
    public void afterUpdate() {
    }
    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
}
