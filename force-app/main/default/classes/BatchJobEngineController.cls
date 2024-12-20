public with sharing class BatchJobEngineController {
    /**
     * Gets details of the batch job by job ID
     * @param jobId - the ID of the batch job
     * @return List of AsyncApexJob records with job details
     */
    @AuraEnabled
    public static List<AsyncApexJob> getJobDetails(String jobId) {
        try {
            return [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                FROM AsyncApexJob
                WHERE Id = :jobId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Executes a batch class dynamically based on class name and chunk size
     * @param className - the name of the batch class to execute
     * @param chunkSize - the size of each batch chunk
     * @return the ID of the initiated batch job
     */
    @AuraEnabled
    public static String executeBatch(String className, Integer chunkSize) {
        try {
            Type batchInstance = Type.forName(className);
            Id batchJobId = Database.executeBatch((Database.Batchable<SObject>) batchInstance.newInstance(), chunkSize);
            return batchJobId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Retrieves all batch classes that end with 'Batch' to populate the combobox in LWC
     * @return List of batch class names ending in 'Batch'
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getAllBatchClassNames() {
        List<String> classNames = new List<String>();
        for (ApexClass apexClass : [SELECT Name FROM ApexClass WHERE Name LIKE '%Batch']) {
            classNames.add(apexClass.Name);
        }
        return classNames;
    }

    /**
     * Retrieves all enabled batch classes listed from the custom metadata settings
     * @return Boolean value representing the engine's access to the batch class
     */
    @AuraEnabled(cacheable=true)
    public static Boolean engineHasAccessToBatchClass(String className) {
        for (Batch_Job_Engine_Setting__mdt batchClass : [
            SELECT Id
            FROM Batch_Job_Engine_Setting__mdt
            WHERE Label = :className AND Engine_Has_Access_to_Batch_Class__c = TRUE
        ]) {
            return true;
        }

        return false;
    }
}