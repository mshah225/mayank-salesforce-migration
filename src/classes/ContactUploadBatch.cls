public with sharing class ContactUploadBatch implements Database.batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id attachmentId;
    private String contactUploadId;
    private static final Integer SCOPE_SIZE = 50; //Batch limit of 100 callouts; 50 allows for 2 per record (1 GET and 1 POST)
    private Boolean errorEncountered = false;
    private Map<Integer, String> columnMap;
    ContactUploadFileReader uploadReader;
    
    public ContactUploadBatch(Id attachmentId) {
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
        searcher.searchAndCreateContacts();
        List<Subscriber__c> subscriberList = new List<Subscriber__c>();
        for (Contact_Upload_Detail__c uploadDetail : detailsToProcess) {
            Subscriber__c subToAdd = detailCreator.createSubscriberForUploadDetail(uploadDetail);
            if (subtoAdd != null) {
                subscriberList.add(subToAdd);
            }
        }
        
        if (subscriberList.size() > 0) {
            Database.upsert(subscriberList, Subscriber__c.Unique_Key__c, false);
        }
        
        Map<String, Id> subKeyToSubIdMap = new Map<String, Id>();

        for (Subscriber__c subscriber: subscriberList) {
            subKeyToSubIdMap.put(subscriber.Unique_Key__c, subscriber.Id);
        }
        
        for (Contact_Upload_Detail__c uploadDetail: detailsToProcess) {
            uploadDetail = detailCreator.addSubscriberToDetail(uploadDetail, subKeyToSubIdMap);
        }
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
    }

    private void updateUploadStatus(String status) {
        
        Contact_Upload__c cu = new Contact_Upload__c(
                Id = contactUploadId, 
                Status__c = status);
        update cu;
    }

    private Contact_Upload_Detail__c updateDetailStatus(Contact_Upload_Detail__c cudToUpdate, String status, String error) {
        cudToUpdate.Status__c = status;
        cudToUpdate.Processing_Notes__c += error;
        cudToUpdate.Processing_Notes__c = cudToUpdate.Processing_Notes__c.left(255);
        return cudToUpdate;
    }
    
    private List<List<String>> recreateRowsFromIteration(List<String> tableOfContacts) {
        String csvFile = '';
        for (String row : tableOfContacts) {
            csvFile += row + '\r';
        }
        
        return CsvReader.readCsvFile(Blob.valueOf(csvFile));
    }
}