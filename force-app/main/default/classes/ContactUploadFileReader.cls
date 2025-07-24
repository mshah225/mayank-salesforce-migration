public without sharing class ContactUploadFileReader {
    public ContentVersion fileRecord { get; private set; }
    public CsvIterator fileIterator { get; private set; }
    
    public ContactUploadFileReader(Id fileId) {
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, VersionData, Title
            FROM ContentVersion
            WHERE Id = :fileId
            LIMIT 1
        ];
        if (!versions.isEmpty()) {
            fileRecord = versions[0];
            fileIterator = new CsvIterator(fileRecord.VersionData.toString(), '\r');
        }
    }
}