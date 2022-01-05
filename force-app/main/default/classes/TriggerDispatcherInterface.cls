public interface TriggerDispatcherInterface {
    void beforeInsert();
    void beforeUpdate();
    void beforeDelete();
    void afterInsert();
    void afterUpdate();
    void afterDelete();
    void afterUndelete();
}
