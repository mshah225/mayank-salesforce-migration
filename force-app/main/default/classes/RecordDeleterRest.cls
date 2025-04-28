@RestResource(urlMapping='/RecordDeleter')
global with sharing class RecordDeleterRest {
    public static Boolean hasAccess() {
        return RecordDeleter.currentUserHasAccess();
    }

    @HttpPost
    global static void deleteRecords(List<String> recordIds) {
        RestResponse res = RestContext.response;

        try {
            if (!hasAccess())
                throw new RecordDeleterRestPermissionException(
                    'Current user (id=' + UserInfo.getUserId() + ') does not have permission to use RecordDeleter'
                );
            if (recordIds == null || recordIds.isEmpty())
                throw new RecordDeleterRestInvalidIdException('No records passed for deletion');

            String objectName;
            for (String recordId : recordIds) {
                String eachObjectName = RecordIdHelper.findObjectNameFromRecordIdPrefix(recordId);

                // Ids that don't map to any object type
                if (eachObjectName == 'Error')
                    throw new RecordDeleterRestInvalidIdException(
                        'Could not determine object type of record id=' + recordId
                    );

                // Record first object name
                if (objectName == null)
                    objectName = eachObjectName;

                // Compare all types to first type to ensure all are same
                if (objectName != null && eachObjectName != objectName)
                    throw new RecordDeleterRestInvalidIdException(
                        'Mixed object types - record id=' +
                            recordId +
                            ' is of type ' +
                            eachObjectName +
                            ' but expected type ' +
                            objectName
                    );
            }

            RecordDeleter rd = new RecordDeleter(objectName, recordIds);
            List<RecordDeleter.DeleteStatus> statuses = rd.deleteRecords();
            List<DeleteStatus> responseStatuses = new List<DeleteStatus>();

            for (RecordDeleter.DeleteStatus ds : statuses) {
                responseStatuses.add(new DeleteStatus(ds));
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseStatuses));
        } catch (RecordDeleterRestPermissionException e) {
            res.statusCode = 403;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(e)));
        } catch (RecordDeleterRestInvalidIdException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(e)));
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(e)));
        }
    }

    public class RecordDeleterRestPermissionException extends Exception {
    }
    public class RecordDeleterRestInvalidIdException extends Exception {
    }

    public class DeleteStatus {
        public String recordId;
        public Boolean success;
        public String errorMsg;

        public DeleteStatus(RecordDeleter.DeleteStatus ds) {
            this.recordId = ds.recordId;
            this.success = ds.success;
            this.errorMsg = ds.errorMsg;
        }
    }

    global class ErrorResponse {
        public String error;

        public ErrorResponse(Exception e) {
            error = e.getMessage();
        }
    }
}
