public without sharing class ContactUploadBatch implements Database.batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id attachmentId;
    private Id subscriptionId;
    private String subscriberStatus;
    private String contactUploadId;
    private Map<Integer, String> columnMap;
    private Boolean headerRow;

    public ContactUploadBatch(Id attachmentId, Id subscriptionId, String subscriberStatus) {
        this.attachmentId = attachmentId;
        this.subscriptionId = subscriptionId;
        this.subscriberStatus = subscriberStatus;
    }

    public Iterable<String> start(Database.BatchableContext batchableContext) {
        if (attachmentId == null) {
            return null;
        }
        headerRow = true;
        ContactUploadFileReader uploadReader = new ContactUploadFileReader(attachmentId);
        contactUploadId = uploadReader.contactCSV.ParentId;
        updateUploadStatus('Processing');
        return uploadReader.fileIterator;
    }

    public void execute(Database.BatchableContext batchableContext, List<String> scope) {
        List<List<String>> csvLines = recreateRowsFromIteration(scope);

        List<Contact_Upload_Detail__c> detailsToProcess = new List<Contact_Upload_Detail__c>();
        List<Contact_Upload_Detail__c> detailsInError = new List<Contact_Upload_Detail__c>();
        ContactUploadDetailService detailCreator = new ContactUploadDetailService(contactUploadId, columnMap);
        detailCreator.setSubscriptionId(subscriptionId);
        detailCreator.setSubscriberStatus(subscriberStatus);
        for (List<String> lineValues : csvLines) {
            Contact_Upload_Detail__c detailFromLine = detailCreator.createAndValidateRow(lineValues);
            if (detailFromLine.Status__c != 'Error') {
                detailsToProcess.add(detailFromLine);
            } else {
                detailsInError.add(detailFromLine);
            }
        }
        ContactUploadSearcher searcher = new ContactUploadSearcher(detailsToProcess);
        searcher.searchAndCreateContacts();
        detailCreator.createSubscriberStatusMap(detailsToProcess);
        List<Subscriber__c> subscriberList = new List<Subscriber__c>();
        for (Contact_Upload_Detail__c uploadDetail : detailsToProcess) {
            Subscriber__c subToAdd = detailCreator.createSubscriberForUploadDetail(uploadDetail);
            if (subtoAdd != null) {
                subscriberList.add(subToAdd);
            } else {
                uploadDetail.Status__c = 'Error';
                uploadDetail.Processing_Notes__c += 'Failed to create subscriber record. ';
            }
        }

        if (subscriberList.size() > 0) {
            Database.upsert(subscriberList, Subscriber__c.Unique_Key__c, false);
        }

        Map<String, Id> uniqueKeyToSubscriberId = new Map<String, Id>();
        for (Subscriber__c upsertedSubscriber : subscriberList) {
            uniqueKeyToSubscriberId.put(upsertedSubscriber.Unique_Key__c, upsertedSubscriber.Id);
        }

        for (Contact_Upload_Detail__c uploadDetail : detailsToProcess) {
            if (uploadDetail.Status__c != 'Error') {
                String uniqueKey =
                    String.valueOf(uploadDetail.Subscription__c).left(15) +
                    '.' +
                    String.valueOf(uploadDetail.Contact__c).left(15);
                Id subscriberId = uniqueKeyToSubscriberId.get(uniqueKey);
                if (subscriberId == null) {
                    uploadDetail.Status__c = 'Error';
                    uploadDetail.Processing_Notes__c += ' Failed to create subscriber record. ';
                } else {
                    uploadDetail.Subscriber__c = uniqueKeyToSubscriberId.get(uniqueKey);
                }
            }
        }

        detailsToProcess.addAll(detailsInError);
        if (detailsToProcess.size() > 0) {
            Database.insert(detailsToProcess, false);
        }
    }

    private List<List<String>> recreateRowsFromIteration(List<String> csvContacts) {
        String csvFile = '';
        List<List<String>> csvColumnData = new List<List<String>>();
        for (String row : csvContacts) {
            if (headerRow) {
                createHeaderMappings(row);
                headerRow = false;
                continue;
            }
            csvColumnData.addAll(CsvReader.readCsvFile(row));
        }
        return csvColumnData;
    }

    private void createHeaderMappings(String row) {
        List<List<String>> csvLines = CsvReader.readCsvFile(row);
        columnMap = new Map<Integer, String>();
        if (!csvLines.isEmpty()) {
            Integer columnIndex = 0;
            for (String s : csvLines[0]) {
                columnMap.put(columnIndex, s);
                columnIndex++;
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        if (hasSuccessfulRecords() && noErroredRecords()) {
            updateUploadStatus('Complete with no errors');
        } else {
            updateUploadStatus('Complete with errors');
        }
    }

    private Boolean hasSuccessfulRecords() {
        List<Contact_Upload_Detail__c> successfulDetails = [
            SELECT Id
            FROM Contact_Upload_Detail__c
            WHERE Contact_Upload__c = :contactUploadId AND Status__c = 'Success'
            LIMIT 1
        ];

        return !successfulDetails.isEmpty();
    }

    @TestVisible
    private Boolean noErroredRecords() {
        List<Contact_Upload_Detail__c> erroredDetails = [
            SELECT Id
            FROM Contact_Upload_Detail__c
            WHERE Contact_Upload__c = :contactUploadId AND Status__c = 'Error'
            LIMIT 1
        ];

        return erroredDetails.isEmpty();
    }

    private void updateUploadStatus(String status) {
        Contact_Upload__c cu = new Contact_Upload__c(Id = contactUploadId, Status__c = status);
        update cu;
    }
}