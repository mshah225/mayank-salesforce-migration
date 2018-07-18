public abstract class AbstractTriggerHandler {
    
    public AbstractTriggerHandler(System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
        
            when BEFORE_INSERT {
                beforeInsert();
            }
            when AFTER_INSERT {
                afterInsert();
            }
            when BEFORE_UPDATE {
                beforeUpdate();
            }
            when AFTER_UPDATE {
                afterUpdate();
            }
            when BEFORE_DELETE {
                beforeDelete();
            }
            when AFTER_DELETE {
                afterDelete();
            }
            when AFTER_UNDELETE {
                afterUndelete();   
            }
        }
    }
    
    public void beforeInsert() {}
    
    public void afterInsert() {}
    
    public void beforeUpdate() {}
    
    public void afterUpdate() {}
    
    public void beforeDelete() {}
    
    public void afterDelete() {}
    
    public void afterUndelete() {}
}
