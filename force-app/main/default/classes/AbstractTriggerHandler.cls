public abstract class AbstractTriggerHandler {
    public AbstractTriggerHandler() {
        System.TriggerOperation triggerEvent = Trigger.operationType;
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

    public virtual void beforeInsert() {
    }
    public virtual void afterInsert() {
    }
    public virtual void beforeUpdate() {
    }
    public virtual void afterUpdate() {
    }
    public virtual void beforeDelete() {
    }
    public virtual void afterDelete() {
    }
    public virtual void afterUndelete() {
    }
}
