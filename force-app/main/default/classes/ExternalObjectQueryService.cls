public virtual inherited sharing class ExternalObjectQueryService {
    static ExternalObjectQueryService instance = new ExternalObjectQueryService();

    public static List<SObject> getRecords(List<SObject> records) {
        return instance.recordTunnel(records);
    }

    protected virtual List<SObject> recordTunnel(List<SObject> records) {
        return records;
    }

    @TestVisible
    static void setMock(ExternalObjectQueryService mock) {
        instance = mock;
    }
}
