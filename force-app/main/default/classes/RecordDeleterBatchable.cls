public class RecordDeleterBatchable implements Database.Batchable<String>, Database.Stateful {
    Id coordinatorId;
    String objectName;
    List<String> recordIds;
    List<RecordDeleter.DeleteStatus> reportLs;
    Boolean threwError;
    Datetime startTime;

    public RecordDeleterBatchable(Id coordinatorId, String objectName, List<String> recordIds) {
        this.coordinatorId = coordinatorId;
        this.objectName = objectName;
        this.recordIds = recordIds;
        this.reportLs = new List<RecordDeleter.DeleteStatus>();
        this.threwError = false;
    }

    public Iterable<String> start(Database.BatchableContext batchableContext) {
        // Record start time
        startTime = System.now();
        // Update coordinator
        update new Async_Job_Coordinator__c(Id = coordinatorId, Status__c = 'Running');
        // And return batch of ids to delete
        return recordIds;
    }

    public void execute(Database.BatchableContext batchableContext, List<String> scope) {
        try {
            // Delete
            RecordDeleter rd = new RecordDeleter(objectName, scope);
            List<RecordDeleter.DeleteStatus> statusLs = rd.deleteRecords();

            // Add this batch of results
            reportLs.addAll(statusLs);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('batchableContext.getJobId()', batchableContext.getJobId()));
            vars.add(
                ErrorLogger.convertStringToJSON('batchableContext.getChildJobId()', batchableContext.getChildJobId())
            );
            vars.add(ErrorLogger.convertStringToJSON('coordinatorId', coordinatorId));
            vars.add(ErrorLogger.convertStringToJSON('objectName', objectName));
            vars.add(ErrorLogger.convertListToJSON('scope', scope));
            ErrorLogger.log(ex, vars, false);

            for (String recordId : scope) {
                reportLs.add(new RecordDeleter.DeleteStatus(objectName, recordId, false, 'ERROR: ' + ex.getMessage()));
            }

            threwError = true;
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        try {
            Async_Job_Coordinator__c coordinator = new Async_Job_Coordinator__c(Id = coordinatorId);
            if (threwError) {
                coordinator.Status__c = 'Error';
            } else {
                coordinator.Status__c = 'Success';
            }
            update coordinator;

            saveReportMap();
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('batchableContext.getJobId()', batchableContext.getJobId()));
            vars.add(
                ErrorLogger.convertStringToJSON('batchableContext.getChildJobId()', batchableContext.getChildJobId())
            );
            vars.add(ErrorLogger.convertStringToJSON('coordinatorId', coordinatorId));
            vars.add(ErrorLogger.convertStringToJSON('objectName', objectName));
            ErrorLogger.log(ex, vars, false);

            Async_Job_Coordinator__c coordinator = new Async_Job_Coordinator__c(
                Id = coordinatorId,
                Status__c = 'Error'
            );
            update coordinator;
        }
    }

    private void saveReportMap() {
        if (reportLs.isEmpty())
            return;

        // Flatten results
        String flattenedReport = 'Record Id,Status,Error\n';
        while (!reportLs.isEmpty()) {
            RecordDeleter.DeleteStatus ds = reportLs[0];

            // Generate report line by line
            flattenedReport +=
                escapeCsvValue(ds.getRecordId()) +
                ',' +
                escapeCsvValue(ds.isSuccess() ? 'TRUE' : 'FALSE') +
                ',' +
                escapeCsvValue((ds.isSuccess() ? '' : ds.getErrorMessage())) +
                '\n';

            // Remove from map to reclaim heap space
            reportLs.remove(0);
        }

        // Create CSV
        ContentVersion cv = new ContentVersion(
            Title = objectName + ' Deletion Report at ' + startTime.format() + ' (' + coordinatorId + ')',
            PathOnClient = objectName + ' Deletion Report at ' + startTime.format() + ' (' + coordinatorId + ').csv',
            VersionData = Blob.valueOf(flattenedReport)
        );
        insert cv;

        cv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        // Associate with coordinator id
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = coordinatorId
        );
        insert cdl;
    }

    public static String escapeCsvValue(String input) {
        String output = input;
        if (input.contains('\n') || input.contains(',') || input.contains('"'))
            output = '"' + output.replaceAll('"', '""') + '"';
        return output;
    }
}
