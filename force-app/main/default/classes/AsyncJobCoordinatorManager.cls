/**
 * Manager class for working with a single Async_Job_Coordinator__c
 *
 * This class provides a wrapper when using the Async_Job_Coordinator__c class to track an batch job's progress
 *
 * -- Setup --
 * If you already have a Async_Job_Coordinator__c, you should pass the id in the contructor
 * otherwise we will create a new Async_Job_Coordinator__c and insert it automatically
 *
 * When creating a new Async_Job_Coordinator__c, it will start in the "Preparing" state
 *
 * After creating a new Async_Job_Coordinator__c, you can then call `setQueuedJobId()` to set the batch job id
 * and move the Async_Job_Coordinator__c into the "Queued" state.
 *
 * -- Tracking state --
 * You can then call `setRunning()`, `setSuccess()`, `setError()` while running your batch job to move the
 * Async_Job_Coordinator__c to the proper state. These are usually called from the batch job.
 *
 *  -- Checking state --
 * To query the record you can call `checkStatus()` to check the current state of the job, if it has finished and what percentage of batches
 * it has completed.
 *
 * Once it has complete, you can call `getReport()` and `getDownloadURL()` to get the contents of the report CSV and CSV download url.
 *
 * These are usually called from the LWC controller to check if the job is done yet
 */

public with sharing class AsyncJobCoordinatorManager {
    // Coordinator object to track state in DB
    Async_Job_Coordinator__c coordinator;
    // When complete - get report file
    Id contentDocumentId;
    ContentVersion contentVersion;

    public AsyncJobCoordinatorManager() {
        coordinator = new Async_Job_Coordinator__c(Status__c = 'Preparing');
        insert coordinator;
    }
    public AsyncJobCoordinatorManager(Id coordinatorId) {
        List<Async_Job_Coordinator__c> coordinatorLs = [
            SELECT Id, Status__c, Job_Id__c
            FROM Async_Job_Coordinator__c
            WHERE Id = :coordinatorId
            LIMIT 1
        ];

        if (coordinatorLs.isEmpty()) {
            throw new InvalidCoordinatorIdException('Coordinator Id ' + coordinatorId + ' not found');
        }
        coordinator = coordinatorLs[0];
    }

    /**
     * Get coordinator id
     */
    public Id getCoordinatorId() {
        return coordinator.Id;
    }

    /**
     * Set an async job to the "Queued" state - this should be called after a batch job has been enququed
     * @param batchProcessId The batch job id
     */
    public void setQueuedJobId(Id batchProcessId) {
        coordinator.Job_Id__c = batchProcessId;
        coordinator.Status__c = 'Queued';
        update coordinator;
    }

    /**
     * Set an async job to the "Running" state - this should be called from the batch job in the start method
     */
    public void setRunning() {
        coordinator.Status__c = 'Running';
        update coordinator;
    }

    /**
     * Set an async job to the "Success" state - this should be called from the batch job finish method if
     * the job ran without errors
     */
    public void setSuccess() {
        coordinator.Status__c = 'Success';
        update coordinator;
    }

    /**
     * Set an async job to the "Error" state - this should be called from the batch job finish method if
     * the job had any errors
     */
    public void setError() {
        coordinator.Status__c = 'Error';
        update coordinator;
    }

    /**
     * Check the current status of an async job, check if it is complete and, if not, what
     * percentage complete it is
     */
    public RunStatus checkStatus() {
        RunStatus rs = new RunStatus();

        rs.done = new List<String>{ 'Success', 'Error' }.contains(coordinator.Status__c);

        if (rs.done) {
            rs.percent = 1;
        } else {
            AsyncApexJob asyncJob = [
                SELECT Id, Status, TotalJobItems, JobItemsProcessed
                FROM AsyncApexJob
                WHERE Id = :coordinator.Job_Id__c
            ];
            if (asyncJob.TotalJobItems != 0)
                rs.percent = Decimal.valueOf(asyncJob.JobItemsProcessed) / Decimal.valueOf(asyncJob.TotalJobItems);
        }

        return rs;
    }

    /**
     * Get the Report CSV from this async job
     *
     * Most async jobs build some sort of report file, often in the form of a CSV
     * This method returns the String contents of that file
     */
    public String getReport() {
        if (coordinator.Status__c == 'Error')
            throw new HadErrorException();
        if (coordinator.Status__c != 'Success')
            throw new IsRunningException();

        populateDocument();

        return contentVersion.VersionData.toString();
    }

    /**
     * Get the download URL for the report file
     */
    public String getDownloadURL() {
        if (coordinator.Status__c == 'Error')
            throw new HadErrorException();
        if (coordinator.Status__c != 'Success')
            throw new IsRunningException();

        populateDocument();

        return '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
    }

    /**
     * Get the report document at the end of the job
     */
    private void populateDocument() {
        // Get content document
        if (contentDocumentId == null) {
            List<ContentDocumentLink> cdl = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :coordinator.Id
                LIMIT 1
            ];

            if (cdl.isEmpty())
                throw new NoReportException('Could not find job report for job id=' + coordinator.Id);

            contentDocumentId = cdl[0].ContentDocumentId;
        }

        // Get most recent version of document
        if (contentVersion == null && contentDocumentId != null) {
            List<ContentVersion> cv = [
                SELECT VersionData
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocumentId AND PathOnClient LIKE '%.csv'
                LIMIT 1
            ];

            if (cv.isEmpty())
                throw new NoReportException('Could not find job report for job id=' + coordinator.Id);

            contentVersion = cv[0];
        }
    }

    public class RunStatus {
        @AuraEnabled
        public Boolean done = false;
        @AuraEnabled
        public Decimal percent = 0.0;
    }

    public class ResultItem {
        @AuraEnabled
        public String csvData;
        @AuraEnabled
        public String errorMessage;
    }

    public class HadErrorException extends Exception {
    }
    public class IsRunningException extends Exception {
    }
    public class InvalidCoordinatorIdException extends Exception {
    }
    public class NoReportException extends Exception {
    }
}