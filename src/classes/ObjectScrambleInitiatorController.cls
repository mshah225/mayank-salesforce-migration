public class ObjectScrambleInitiatorController {
    public String response { get; set; }

    public ObjectScrambleInitiatorController() {
        if (jobIsRunning()) {
            response = 'Error: Job Currently Running Already.';
        }
    }

    public void verifyNoProcessRunningAndStart() {
        if (jobIsRunning()) {
            response = startBulkApiProcess();
        } else {
            response = 'Error: Job Currently Running Already.';
        }
    }

    private Boolean jobIsRunning() {
        Id apexClassId = [SELECT Id FROM ApexClass WHERE Name = 'ObjectScrambleBatch' LIMIT 1].Id;
        List<AsyncApexJob> currentJobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE
                ApexClassId = :apexClassId
                AND (Status = 'Processing'
                OR Status = 'Holding'
                OR Status = 'Preparing'
                OR Status = 'Queued')
        ];

        return !currentJobs.isEmpty();
    }

    private String startBulkApiProcess() {
        ObjectScrambleBatch contactBatch = new ObjectScrambleBatch(ObjectScrambleService.objectTypes.CONTACT);
        Id contactBatchJobId = Database.executeBatch(contactBatch, 2000);

        ObjectScrambleBatch userBatch = new ObjectScrambleBatch(ObjectScrambleService.objectTypes.USER);
        Id userBatchJobId = Database.executeBatch(userBatch, 2000);

        ObjectScrambleBatch leadBatch = new ObjectScrambleBatch(ObjectScrambleService.objectTypes.LEAD);
        Id leadBatchJobId = Database.executeBatch(leadBatch, 2000);

        return 'Job Ids - Contact: ' + contactBatchJobId + ' Lead: ' + userBatchJobId + ' User: ' + userBatchJobId;
    }
}
