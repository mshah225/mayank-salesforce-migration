/*
* Test class : ContentDocumentLinkTriggerTest
*/

public class ContentDocumentLinkDispatcher implements TriggerDispatcherInterface {
    private List<ContentDocumentLink> newList;
    private Map<Id, ContentDocumentLink> newMap;
    private List<ContentDocumentLink> oldList;
    private Map<Id, ContentDocumentLink> oldMap;
    
    public ContentDocumentLinkDispatcher(
        List<ContentDocumentLink> newList,
        Map<Id, ContentDocumentLink> newMap,
        List<ContentDocumentLink> oldList,
        Map<Id, ContentDocumentLink> oldMap
    ) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }
    
    public void beforeInsert() {}
    public void beforeUpdate() {}
    public void beforeDelete() {}
    
    public void afterInsert() {
        FileService.updateCasesFromFiles(newList);
    }
    
    public void afterUpdate() {
        FileService.updateCasesFromFiles(newList);
    }
    
    public void afterDelete() {
        FileService.updateCasesFromFiles(oldList);
    }
    
    public void afterUndelete() {
        FileService.updateCasesFromFiles(newList);
    }
}