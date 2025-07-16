public without sharing class ContactMatcherBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id fileVersionId;
    private Id subscriptionId;
    private Id myContactUploadId;
    private Id contactUploadId;
    private Map<Integer, String> columnMap;
    private Boolean headerRow;
    private String updatedCSVBody = '';
    private ContactUploadFileReader uploadReader;

    public ContactMatcherBatch(Id fileVersionId, Id subscriptionId,Id myContactUploadId) {
        this.fileVersionId = fileVersionId;
        this.subscriptionId = subscriptionId;
        this.myContactUploadId =  myContactUploadId;
        system.debug('this.fileVersionId :: '+ this.fileVersionId);
        system.debug('this.subscriptionId :: '+ this.subscriptionId);
    }

    public Iterable<String> start(Database.BatchableContext batchableContext) {
        if (fileVersionId == null) return null;

        headerRow = true;

        // Use ContactUploadFileReader to read the ContentVersion file
        uploadReader = new ContactUploadFileReader(fileVersionId);
        System.debug('uploadReader :: '+ uploadReader);
        // Find the parent Contact_Upload__c via ContentDocumentLink
        ContentDocumentLink link = [
            SELECT LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :uploadReader.fileRecord.ContentDocumentId
            LIMIT 1
        ];
        System.debug('link :: '+ link);
        contactUploadId = myContactUploadId;//link.LinkedEntityId;
        System.debug('contactUploadId :: '+ contactUploadId);
        updateUploadStatus('Processing');
        System.debug('uploadReader.fileIterator :: '+ uploadReader.fileIterator);
        return uploadReader.fileIterator;
    }

    public void execute(Database.BatchableContext batchableContext, List<String> scope) {
        List<List<String>> csvLines = recreateRowsFromIteration(scope);
        System.debug('scope :: '+ scope);
        List<Contact_Upload_Detail__c> detailsToProcess = new List<Contact_Upload_Detail__c>();
        List<Contact_Upload_Detail__c> detailsInError = new List<Contact_Upload_Detail__c>();
        List<Contact_Upload_Detail__c> allDetailsFromLines = new List<Contact_Upload_Detail__c>();

        ContactUploadDetailService detailCreator = new ContactUploadDetailService(contactUploadId, columnMap);
        System.debug('detailCreator :: '+ detailCreator);
        detailCreator.setSubscriptionId(subscriptionId);
        
        for (List<String> lineValues : csvLines) {
            system.debug('lineValues :: '+ lineValues);
            Contact_Upload_Detail__c detail = detailCreator.createAndValidateRowForMatcher(lineValues);
            System.debug('detail 55:: '+ detail);
            if (detail.Status__c != 'Error') {
                detailsToProcess.add(detail);
            } else {
                detailsInError.add(detail);
            }
            allDetailsFromLines.add(detail);
        }

        ContactUploadSearcher searcher = new ContactUploadSearcher(detailsToProcess);
        searcher.searchContactsToMatch();
        System.debug('allDetailsFromLines 64:: '+ allDetailsFromLines);
        addContactIdToCSV(scope, allDetailsFromLines);

        detailsToProcess.addAll(detailsInError);
        if (!detailsToProcess.isEmpty()) {
            Database.insert(detailsToProcess, false);
        }
    }

    private List<List<String>> recreateRowsFromIteration(List<String> csvContacts) {
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
                columnMap.put(columnIndex++, s);
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext) {
        createUpdatedFile();

        if (hasSuccessfulRecords() && noErroredRecords()) {
            updateUploadStatus('Complete with no errors');
        } else {
            updateUploadStatus('Complete with errors');
        }
    }

    private Boolean hasSuccessfulRecords() {
        return ![
            SELECT Id
            FROM Contact_Upload_Detail__c
            WHERE Contact_Upload__c = :contactUploadId AND Status__c = 'Success'
            LIMIT 1
        ].isEmpty();
    }

    private Boolean noErroredRecords() {
        return [
            SELECT Id
            FROM Contact_Upload_Detail__c
            WHERE Contact_Upload__c = :contactUploadId AND Status__c = 'Error'
            LIMIT 1
        ].isEmpty();
    }

    private void updateUploadStatus(String status) {
        if (String.isNotEmpty(contactUploadId)) {
            update new Contact_Upload__c(Id = contactUploadId, Status__c = status);
        }
    }

    private void addContactIdToCSV(List<String> csvRows, List<Contact_Upload_Detail__c> contactDetails) {
        Integer detailIndex = 0;
        if (String.isEmpty(updatedCSVBody)) {
            createHeaderForContactMatcher();
            csvRows.remove(0);  // remove header
        }
       System.debug('csvRows Size :: '+ csvRows.size());
        for (String row : csvRows) {
            system.debug('detailIndex :: '+ detailIndex);
            System.debug('row :: '+ row);
            Contact_Upload_Detail__c detail = contactDetails[detailIndex++];
            system.debug('detail :: '+ detail);
            system.debug('detail.Contact__c :: '+ detail.Contact__c);
            String contactId = '';
            if (detail.Contact__c != null) {
                contactId = detail.Contact__c;
            }

            updatedCSVBody += row + ',' + contactId + '\r';
        }
    }

    private void createHeaderForContactMatcher() {
        for (String column : columnMap.values()) {
            updatedCSVBody += column + ',';
        }
        updatedCSVBody += 'Contact Id\r';
    }

    private void createUpdatedFile() {
        system.debug('updatedCSVBody :: '+ updatedCSVBody);
        ContentVersion newVersion = new ContentVersion();
        newVersion.Title = uploadReader.fileRecord.Title + ' (With Ids)';
        newVersion.PathOnClient = uploadReader.fileRecord.Title + '(WithIds).csv';
        newVersion.VersionData = Blob.valueOf(updatedCSVBody);
        system.debug('newVersion :: '+ newVersion);
        insert newVersion;

        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :newVersion.Id
            LIMIT 1
        ];

        insert new ContentDocumentLink(
            ContentDocumentId = insertedVersion.ContentDocumentId,
            LinkedEntityId = contactUploadId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
    }
}