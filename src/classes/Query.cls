public virtual inherited sharing class Query {
    public static List<SObject> records(List<SObject> records) {
        return instance.passThrough(records);
    }

    static Query instance = new Query();
    @TestVisible
    static void setMock(Query mock) {
        instance = mock;
    }

    protected virtual List<SObject> passThrough(List<SObject> records) {
        return records;
    }
}
