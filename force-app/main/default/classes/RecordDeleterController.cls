public with sharing class RecordDeleterController {
    @AuraEnabled(cacheable=true)
    public static Boolean hasAccess() {
        return RecordDeleter.currentUserHasAccess();
    }

    @AuraEnabled(cacheable=true)
    public static String getObjectName(String prefix) {
        try {
            if (!hasAccess())
                throw new RecordDeleterControllerPermissionException(
                    'Current user (id=' + UserInfo.getUserId() + ') does not have permission to use the RecordDeleter'
                );

            String objectName = RecordIdHelper.findObjectNameFromRecordIdPrefix(prefix);
            if (objectName == 'Error')
                throw new RecordDeleterControllerInvalidIdException(
                    'Could not determine object type using prefix=' + prefix
                );
            return objectName;
        } catch (RecordDeleterControllerPermissionException e) {
            throw e;
        } catch (RecordDeleterControllerInvalidIdException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id performMassDelete(List<String> recordIds) {
        try {
            if (!hasAccess())
                throw new RecordDeleterControllerPermissionException(
                    'Current user (id=' + UserInfo.getUserId() + ') does not have permission to use the RecordDeleter'
                );

            if (recordIds == null || recordIds.isEmpty())
                throw new RecordDeleterControllerInvalidIdException('No records queued for deletion');

            String objectName = null;

            for (String recordId : recordIds) {
                String eachObjectName = RecordIdHelper.findObjectNameFromRecordIdPrefix(recordId);

                // Ids that don't map to any object type
                if (eachObjectName == 'Error')
                    throw new RecordDeleterControllerInvalidIdException(
                        'Could not determine object type of record id=' + recordId
                    );

                // Record first object name
                if (objectName == null)
                    objectName = eachObjectName;

                // Compare all types to first type to ensure all are same
                if (objectName != null && eachObjectName != objectName)
                    throw new RecordDeleterControllerInvalidIdException(
                        'Mixed object types - record id=' +
                            recordId +
                            ' is of type ' +
                            eachObjectName +
                            ' but expected type ' +
                            objectName
                    );
            }

            // Create coordinator
            Async_Job_Coordinator__c coordinator = new Async_Job_Coordinator__c(Status__c = 'Preparing');
            insert coordinator;

            // Queue job
            Id batchProcessId = Database.executeBatch(
                new RecordDeleterBatchable(coordinator.Id, objectName, recordIds),
                50
            );

            // Update coordinator
            coordinator.Job_Id__c = batchProcessId;
            coordinator.Status__c = 'Queued';
            update coordinator;

            return coordinator.Id;
        } catch (RecordDeleterControllerPermissionException e) {
            throw e;
        } catch (RecordDeleterControllerInvalidIdException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static RunStatus checkStatus(String coordinatorId) {
        try {
            if (!hasAccess())
                throw new RecordDeleterControllerPermissionException(
                    'Current user (id=' + UserInfo.getUserId() + ') does not have permission to use the RecordDeleter'
                );

            RunStatus rs = new RunStatus();

            if (coordinatorId == null)
                return null;

            List<Async_Job_Coordinator__c> coordinator = [
                SELECT Id, Status__c, Job_Id__c
                FROM Async_Job_Coordinator__c
                WHERE Id = :coordinatorId
                LIMIT 1
            ];

            if (coordinator.isEmpty())
                throw new RecordDeleterControllerInvalidCoordinatorIdException(
                    'Could not find job using coordinator id=' + coordinatorId
                );

            rs.done = new List<String>{ 'Success', 'Error' }.contains(coordinator[0].Status__c);

            if (rs.done) {
                rs.percent = 1;
            } else {
                AsyncApexJob asyncJob = [
                    SELECT Id, Status, TotalJobItems, JobItemsProcessed
                    FROM AsyncApexJob
                    WHERE Id = :coordinator[0].Job_Id__c
                ];
                if (asyncJob.TotalJobItems != 0)
                    rs.percent = Decimal.valueOf(asyncJob.JobItemsProcessed) / Decimal.valueOf(asyncJob.TotalJobItems);
            }

            return rs;
        } catch (RecordDeleterControllerPermissionException e) {
            throw e;
        } catch (RecordDeleterControllerInvalidCoordinatorIdException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getResults(String coordinatorId) {
        try {
            if (!hasAccess())
                throw new RecordDeleterControllerPermissionException(
                    'Current user (id=' + UserInfo.getUserId() + ') does not have permission to use the RecordDeleter'
                );

            if (coordinatorId == null)
                return null;

            List<Async_Job_Coordinator__c> coordinator = [
                SELECT Id, Status__c, Job_Id__c
                FROM Async_Job_Coordinator__c
                WHERE Id = :coordinatorId
                LIMIT 1
            ];

            if (coordinator.isEmpty())
                throw new RecordDeleterControllerInvalidCoordinatorIdException(
                    'Could not find job using coordinator id=' + coordinatorId
                );

            if (!new List<String>{ 'Success', 'Error' }.contains(coordinator[0].Status__c))
                throw new RecordDeleterControllerNoReportException(
                    'Job (id=' + coordinatorId + ') is still running cannot download report'
                );

            List<ContentDocumentLink> cdl = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :coordinatorId
                LIMIT 1
            ];

            if (cdl.isEmpty())
                throw new RecordDeleterControllerNoReportException(
                    'Could not find job report for job id=' + coordinatorId
                );

            List<ContentVersion> cv = [
                SELECT VersionData
                FROM ContentVersion
                WHERE ContentDocumentId = :cdl[0].ContentDocumentId AND PathOnClient LIKE '%.csv'
                LIMIT 1
            ];

            if (cv.isEmpty())
                throw new RecordDeleterControllerNoReportException(
                    'Could not find job report for job id=' + coordinatorId
                );

            return cv[0].VersionData.toString();
        } catch (RecordDeleterControllerPermissionException e) {
            throw e;
        } catch (RecordDeleterControllerInvalidCoordinatorIdException e) {
            throw e;
        } catch (RecordDeleterControllerNoReportException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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

    public class RecordDeleterControllerPermissionException extends Exception {
    }
    public class RecordDeleterControllerInvalidIdException extends Exception {
    }
    public class RecordDeleterControllerInvalidCoordinatorIdException extends Exception {
    }
    public class RecordDeleterControllerNoReportException extends Exception {
    }
}
