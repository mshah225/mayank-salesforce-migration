public class CsvManager {
    private String csvFile;
    private Integer currentBatchSize;
    private Integer jobSize;
    private String header;
    private BulkApiManager bulkManager;

    public CsvManager(String header, Integer jobSize, ObjectScrambleService.objectTypes objectType) {
        this.header = header;
        this.jobSize = jobSize;
        if (
            objectType == ObjectScrambleService.objectTypes.CONVERTED_LEAD ||
            objectType == ObjectScrambleService.objectTypes.DELETED_SILVERPOP
        ) {
            bulkManager = new BulkApiManager(objectType.name(), 'delete');
        } else {
            bulkManager = new BulkApiManager(objectType.name(), 'update');
        }
        currentBatchSize = 0;
        csvFile = header;
    }

    public void addRow(String rowToAdd) {
        if (currentBatchSize >= jobSize) {
            sendBatchAndRefreshCsv();
        }

        csvFile += rowToAdd;
        currentBatchSize += 1;
    }

    public void closeJob() {
        sendBatchAndRefreshCsv();
        bulkManager.closeJob();
    }

    public String getCsvFile() {
        return csvFile;
    }

    public Integer getCurrentBatchSize() {
        return currentBatchSize;
    }

    private void sendBatchAndRefreshCsv() {
        bulkManager.sendBatch(csvFile);
        csvFile = header;
        currentBatchSize = 0;
    }
}
