public with sharing class BatchContactUpload implements Database.batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id attachmentId;
    private String contactUploadId;
    private static final Integer SCOPE_SIZE = 50; //Batch limit of 100 callouts; 50 allows for 2 per record (1 GET and 1 POST)
    private Boolean errorEncountered = false;
    private Map<Integer, String> columnMap;
    ContactUploadFileReader uploadReader;
    
    public BatchContactUpload(Id attachmentId) {
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
        
        List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>();
        ContactUploadDetailService detailCreator = new ContactUploadDetailService(contactUploadId, columnMap);
        for (List<String> lineValues: csvLines) {
           cudList.add(detailCreator.createContactFromRow(lineValues));
        }
        detailCreator.searchAndMatchContactWithEmplId(cudList);
        List<Subscriber__c> subscriberList = new List<Subscriber__c>();
        for (Contact_Upload_Detail__c cud: cudList) {
            Subscriber__c subToAdd = detailCreator.createSubscriberForCUD(cud);
            if(subtoAdd != NULL) {
                subscriberList.add(detailCreator.createSubscriberForCUD(cud));
            } else {
                cud = updateDetailStatus(cud, 'Error', 'Failed To Create Subscriber Record');
            }
        }
        if (subscriberList.size() > 0) {
            Database.upsert(subscriberList, Subscriber__c.Unique_Key__c, false);
        }
        
        Map<String, Id> subKeyToSubIdMap = new Map<String, Id>();

        for (Subscriber__c subscriber: subscriberList) {
            subKeyToSubIdMap.put(subscriber.Unique_Key__c, subscriber.Id);
        }
        
        for (Contact_Upload_Detail__c cud: cudList) {
            cud = detailCreator.addSubscriberToDetail(cud, subKeyToSubIdMap);
        }

        if (cudList.size() > 0) {
            Database.insert(cudList, false);
        }
    }
    
    public void finish(Database.BatchableContext batchableContext) {
        List<Contact_Upload_Detail__c> cudsWithErrors = [Select Id FROM Contact_Upload_Detail__c WHERE Contact_Upload__c =: contactUploadId AND Status__c = 'Error'];
        String errorStatus = (cudsWithErrors.isEmpty() ? 'No Errors' : 'Errors');

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