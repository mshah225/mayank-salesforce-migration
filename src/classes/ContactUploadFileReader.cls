public without sharing class ContactUploadFileReader {
    public Attachment contactCSV;
    public CsvIterator fileIterator {get; set;}
    public Map<Integer, String> columnMap {get; set;}
    public List<List<String>> csvLines {get; set;}
    
    public ContactUploadFileReader(Id fileId) {
        List<Attachment> attachmentListForContactUpload = [SELECT Body, ParentId FROM Attachment WHERE Id = :fileId LIMIT 1];
        if (!attachmentListForContactUpload.isEmpty()) {
            contactCSV = attachmentListForContactUpload[0];
            createHeaderMapping();
            String fileWithoutHeader = contactCSV.Body.toString().subString(contactCSV.Body.toString().indexOf('\r'));
            fileIterator = new CsvIterator(fileWithoutHeader, '\r');
        }
    }
    
    public void createHeaderMapping() {
        csvLines = CsvReader.readCsvFile(contactCSV.Body);
        if (!csvLines.isEmpty()) {
            Integer mapPos = 0;
            columnMap = new Map<Integer, String>();
            for (String s : csvLines[0]) {
                columnMap.put(mapPos, s);
                mapPos++;
            } 
            csvLines.remove(0);
        }
    }
}