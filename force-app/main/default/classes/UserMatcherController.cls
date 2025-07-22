public with sharing class UserMatcherController {
    /**
     * Launch an audit for users specified using identifiers and for the specified audit role
     */
    @AuraEnabled
    public static Id startAudit(List<String> identifiers, String auditRole) {
        // Create coordinator
        AsyncJobCoordinatorManager asyncManager = new AsyncJobCoordinatorManager();
        Id coordinatorId = asyncManager.getCoordinatorId();

        User_Audit_Log__c auditLog = new User_Audit_Log__c(
            Name = 'User Audit by ' + auditRole + ' at ' + System.now().format('YYYY-MM-dd HH:mm:ss zzz'),
            Async_Job_Coordinator__c = coordinatorId,
            Initial_Count__c = identifiers.size()
        );
        insert auditLog;

        List<String> nonEmptyIdentifiers = new List<String>();
        for (String id : identifiers)
            if (String.isNotBlank(id))
                nonEmptyIdentifiers.add(id);

        String batchJobId = Database.executeBatch(
            new UserMatcherBatch(coordinatorId, auditLog.Id, nonEmptyIdentifiers, auditRole)
        );

        // Update coordinator
        asyncManager.setQueuedJobId(batchJobId);

        return auditLog.Id;
    }

    /**
     * Get the current status of an audit job
     */
    @AuraEnabled
    public static AsyncJobCoordinatorManager.RunStatus checkStatus(String auditLogId) {
        if (auditLogId == null)
            return null;
        List<User_Audit_Log__c> logs = [
            SELECT Id, Async_Job_Coordinator__c
            FROM User_Audit_Log__c
            WHERE Id = :auditLogId
            LIMIT 1
        ];
        if (logs.isEmpty())
            throw new UserMatcherControllerException('Invalid audit log id');

        AsyncJobCoordinatorManager asyncManager = new AsyncJobCoordinatorManager(logs[0].Async_Job_Coordinator__c);
        return asyncManager.checkStatus();
    }

    /**
     * Get the download link for the audit log's CSV file
     */
    @AuraEnabled
    public static String getDownloadLink(String auditLogId) {
        try {
            if (auditLogId == null)
                return null;
            List<User_Audit_Log__c> logs = [
                SELECT Id, Async_Job_Coordinator__c
                FROM User_Audit_Log__c
                WHERE Id = :auditLogId
                LIMIT 1
            ];
            if (logs.isEmpty())
                throw new UserMatcherControllerException('Invalid audit log id');

            AsyncJobCoordinatorManager asyncManager = new AsyncJobCoordinatorManager(logs[0].Async_Job_Coordinator__c);
            return asyncManager.getDownloadURL();
        } catch (AsyncJobCoordinatorManager.IsRunningException ex) {
            throw new UserMatcherControllerException('Audit still running, cannot get download link');
        } catch (AsyncJobCoordinatorManager.HadErrorException ex) {
            throw new UserMatcherControllerException('Audit failed, review error logger cases for more detail');
        }
    }

    /**
     * Get the CSV contents for the audit log
     */
    @AuraEnabled
    public static String getFileContents(String auditLogId) {
        try {
            if (auditLogId == null)
                return null;
            List<User_Audit_Log__c> logs = [
                SELECT Id, Async_Job_Coordinator__c
                FROM User_Audit_Log__c
                WHERE Id = :auditLogId
                LIMIT 1
            ];
            if (logs.isEmpty())
                throw new UserMatcherControllerException('Invalid audit log id');

            AsyncJobCoordinatorManager asyncManager = new AsyncJobCoordinatorManager(logs[0].Async_Job_Coordinator__c);
            return asyncManager.getReport();
        } catch (AsyncJobCoordinatorManager.IsRunningException ex) {
            throw new UserMatcherControllerException('Audit still running, cannot get download link');
        } catch (AsyncJobCoordinatorManager.HadErrorException ex) {
            throw new UserMatcherControllerException('Audit failed, review error logger cases for more detail');
        }
    }

    /**
     * Get the custom metadata mapping for each field that the user search should include
     * This is used for the columns of the CSV
     */
    @AuraEnabled(cacheable=true)
    public static List<LabelValue> getUserSearchCustomMetadata() {
        List<User_Search_Setting__mdt> options = UserMatcherBatch.getUserSearchCustomMetadata();
        List<LabelValue> orderedPairs = new List<LabelValue>();
        for (User_Search_Setting__mdt opt : options) {
            orderedPairs.add(new LabelValue(opt.MasterLabel, opt.Field_Name__c));
        }
        return orderedPairs;
    }

    /**
     * Get all the options for roles
     */
    @AuraEnabled(cacheable=true)
    public static List<LabelValue> getUserSearchRoleCustomMetadata() {
        List<User_Search_Roles_Setting__mdt> options = UserMatcherBatch.getUserSearchRoleCustomMetadata();
        List<LabelValue> orderedPairs = new List<LabelValue>();
        for (User_Search_Roles_Setting__mdt opt : options) {
            orderedPairs.add(new LabelValue(opt.MasterLabel, opt.DeveloperName));
        }
        return orderedPairs;
    }

    public class UserMatcherControllerException extends Exception {
    }
}