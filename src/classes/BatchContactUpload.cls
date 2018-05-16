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
            updateStatus('Processing'); 
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

        List<Subscriber__c> subscriberList = new List<Subscriber__c>();
        for (Contact_Upload_Detail__c cud: cudList) {
            subscriberList.add(detailCreator.createSubscriberForCUD(cud));
        }
        
        if (subscriberList.size() > 0) {
            upsert subscriberList Unique_Key__c;
        }
        
        Map<String, Id> subKeyToSubIdMap = new Map<String, Id>();

        for (Subscriber__c subscriber: subscriberList) {
            subKeyToSubIdMap.put(subscriber.Unique_Key__c, subscriber.Id);
        }
        
        for (Contact_Upload_Detail__c cud: cudList) {
            cud = detailCreator.addSubscriberToDetail(cud, subKeyToSubIdMap);
        }

        if (cudList.size() > 0) {
            insert cudList;
        }
    }
    
    public void finish(Database.BatchableContext batchableContext) {
        String errorStatus = (errorEncountered ? 'Errors' : 'No Errors');

        if (contactUploadId != null) {
            Contact_Upload__c cu = new Contact_Upload__c(Id = contactUploadId, Status__c = 'Complete with ' + errorStatus);
            update cu;
        }
    }

    private void updateStatus(String status) {
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
}