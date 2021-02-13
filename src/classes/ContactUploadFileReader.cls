public without sharing class ContactUploadFileReader {
    public Attachment contactCSV;
    public CsvIterator fileIterator { get; set; }

    public ContactUploadFileReader(Id fileId) {
        List<Attachment> attachmentListForContactUpload = [
            SELECT Body, ParentId
            FROM Attachment
            WHERE Id = :fileId
            LIMIT 1
        ];
        if (!attachmentListForContactUpload.isEmpty()) {
            contactCSV = attachmentListForContactUpload[0];
            fileIterator = new CsvIterator(contactCSV.Body.toString(), '\r');
        }
    }
}
