public without sharing class ContactMatcherBatch implements Database.batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id attachmentId;
    private String contactUploadId;
    private Boolean errorEncountered = false;
    private Map<Integer, String> columnMap;
    ContactUploadFileReader uploadReader;

    public ContactMatcherBatch(Id attachmentId) {
        this.attachmentId = attachmentId;
    }

    public Iterable<String> start(Database.BatchableContext batchableContext) {
        if (attachmentId != null) {
            uploadReader = new ContactUploadFileReader(attachmentId);
            contactUploadId = uploadReader.contactCSV.ParentId;
            columnMap = uploadReader.columnMap;
            updateUploadStatus('Processing');
            return uploadReader.fileIterator;
        } else {
            return null;
        }
    }

    public void execute(Database.BatchableContext batchableContext, List<String> scope) {
        List<List<String>> csvLines = recreateRowsFromIteration(scope);

        List<Contact_Upload_Detail__c> detailsToProcess = new List<Contact_Upload_Detail__c>();
        List<Contact_Upload_Detail__c> detailsInError = new List<Contact_Upload_Detail__c>();
        List<Contact_Upload_Detail__c> allDetailsFromLines = new List<Contact_Upload_Detail__c>();
        ContactUploadDetailService detailCreator = new ContactUploadDetailService(contactUploadId, columnMap);
        for (List<String> lineValues: csvLines) {
            Contact_Upload_Detail__c detailFromLine = detailCreator.createAndValidateRow(lineValues);
            if (detailFromLine.Status__c != 'Error') {
                detailsToProcess.add(detailFromLine);
            } else {
                detailsInError.add(detailFromLine);
            }
        }
        ContactUploadSearcher searcher = new ContactUploadSearcher(detailsToProcess);
        searcher.searchForContacts();
        addContactIdToCSV(scope, allDetailsFromLines);
        
        detailsToProcess.addAll(detailsInError);
        if (detailsToProcess.size() > 0) {
            Database.insert(detailsToProcess, false);
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        List<Contact_Upload_Detail__c> processedDetails = [
            SELECT Status__c
            FROM Contact_Upload_Detail__c
            WHERE Contact_Upload__c =: contactUploadId
            LIMIT 50000
        ];

        String errorStatus = (processedDetails.isEmpty() ? 'Errors' : 'No Errors');

        for (Contact_Upload_Detail__c detail : processedDetails) {
            if (detail.Status__c == 'Error') {
                errorStatus = 'Errors';
            }
        }

        if (contactUploadId != null) {
            updateUploadStatus('Complete with ' + errorStatus);
        }
        
        updateAttachment();
    }

    private void updateUploadStatus(String status) {

        Contact_Upload__c cu = new Contact_Upload__c(
                Id = contactUploadId,
                Status__c = status);
        update cu;
    }

    private List<List<String>> recreateRowsFromIteration(List<String> tableOfContacts) {
        String csvFile = '';
        for (String row : tableOfContacts) {
            csvFile += row + '\r';
        }

        return CsvReader.readCsvFile(Blob.valueOf(csvFile));
    }
    
    private void addContactIdToCSV(List<String> tableOfContacts, List<Contact_Upload_Detail__c> contactDetails) {
        Integer i = 0;
        if (String.isEmpty(updatedCSVBody)) {
            createHeaderForContactMatcher();
            tableOfContacts.remove(0);
        }
        for (String row : tableOfContacts) {
            updatedCSVBody += row + ',' + contactDetails[i].Contact__c + '\r';
            i++;
        }
    }
    
    private void createHeaderForContactMatcher() {
        for (String headerColumnName : columnMap.values()) {
            updatedCSVBody += headerColumnName + ',';
        }
        updatedCSVBody += 'Contact Id\r';
    }
    
    private void updateAttachment() {
        Attachment updatedAttachment = [SELECT Body FROM Attachment WHERE Id =: attachmentId LIMIT 1];
        updatedAttachment.Body = Blob.valueOf(updatedCSVBody);
        updatedAttachment.Id = null;
        updatedAttachment.Name += '(With Ids)'; 
        insert updatedAttachment;
    }
}