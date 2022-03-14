public class AttachmentDispatcher implements TriggerDispatcherInterface {
    private List<Attachment> newList;
    private Map<Id, Attachment> newMap;
    private List<Attachment> oldList;
    private Map<Id, Attachment> oldMap;

    public AttachmentDispatcher(
        List<Attachment> newList,
        Map<Id, Attachment> newMap,
        List<Attachment> oldList,
        Map<Id, Attachment> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }

    public void beforeInsert() {
    }
    public void beforeUpdate() {
    }
    public void beforeDelete() {
    }
    public void afterInsert() {
        AttachmentService.getCasesFromAttachments(newList);
    }
    public void afterUpdate() {
    }
    public void afterDelete() {
        AttachmentService.getCasesFromAttachments(oldList);
    }
    public void afterUndelete() {
        AttachmentService.getCasesFromAttachments(newList);
    }
}
