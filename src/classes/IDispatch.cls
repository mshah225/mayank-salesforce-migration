public interface IDispatch {
    /**
     * IDispatch class is an interface to enforce dispatch code structure
     * Each method should include the business logic only (when to call
     * handler methods). Handler methods should represnet individual
     * business process steps.
     *
     * Think of a business process step as a "process" shape on a flowchart.
     * Think of business process login as a "decision" shape on a flowchart.
     */

    void beforeInsert();
    void beforeUpdate();
    void beforeDelete();
    void afterInsert();
    void afterUpdate();
    void afterDelete();
    void afterUndelete();
}
