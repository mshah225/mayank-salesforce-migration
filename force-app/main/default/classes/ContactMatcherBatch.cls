public without sharing class ContactMatcherBatch implements Database.batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id attachmentId;
    private Id subscriptionId;
    private String contactUploadId;
    private Map<Integer, String> columnMap;
    private Boolean headerRow;
    private String updatedCSVBody = '';

    public ContactMatcherBatch(Id attachmentId, Id subscriptionId) {
        this.attachmentId = attachmentId;
        this.subscriptionId = subscriptionId;
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
        List<Contact_Upload_Detail__c> allDetailsFromLines = new List<Contact_Upload_Detail__c>();
        ContactUploadDetailService detailCreator = new ContactUploadDetailService(contactUploadId, columnMap);
        detailCreator.setSubscriptionId(subscriptionId);
        for (List<String> lineValues : csvLines) {
            Contact_Upload_Detail__c detailFromLine = detailCreator.createAndValidateRowForMatcher(lineValues);
            if (detailFromLine.Status__c != 'Error') {
                detailsToProcess.add(detailFromLine);
            } else {
                detailsInError.add(detailFromLine);
            }
            allDetailsFromLines.add(detailFromLine);
        }
        ContactUploadSearcher searcher = new ContactUploadSearcher(detailsToProcess);
        searcher.searchContactsToMatch();
        addContactIdToCSV(scope, allDetailsFromLines);
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
        createNewAttachment();
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

    private void addContactIdToCSV(List<String> tableOfContacts, List<Contact_Upload_Detail__c> contactDetails) {
        Integer contactDetailRow = 0;
        if (String.isEmpty(updatedCSVBody)) {
            createHeaderForContactMatcher();
            tableOfContacts.remove(0);
        }
        for (String row : tableOfContacts) {
            if (contactDetails[contactDetailRow].Contact__c == null) {
                updatedCSVBody += row + ', \r';
            } else {
                updatedCSVBody += row + ',' + contactDetails[contactDetailRow].Contact__c + '\r';
            }
            contactDetailRow++;
        }
    }

    private void createHeaderForContactMatcher() {
        for (String headerColumnName : columnMap.values()) {
            updatedCSVBody += headerColumnName + ',';
        }
        updatedCSVBody += 'Contact Id\r';
    }

    private void createNewAttachment() {
        Attachment updatedAttachment = [
            SELECT Name, ParentId, Body, Description
            FROM Attachment
            WHERE Id = :attachmentId
            LIMIT 1
        ];
        updatedAttachment.Body = Blob.valueOf(updatedCSVBody);
        updatedAttachment.Id = null;
        updatedAttachment.Name = updateFileName(updatedAttachment.Name);
        insert updatedAttachment;
    }

    private String updateFileName(String oldFileName) {
        String fileName = oldFileName;
        fileName = fileName.substring(0, fileName.indexOf('.'));
        return fileName + '(With Ids).csv';
    }
}
