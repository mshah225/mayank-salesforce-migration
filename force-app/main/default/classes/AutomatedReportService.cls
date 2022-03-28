public without sharing class AutomatedReportService {    
    private  FINAL Integer JOB_SIZE = 10000;
    private  FINAL String BULK_HEADERS = 'ContactId,CampaignId,Status\n';

    private  List<List<String>> parsedCSV; // Parsed CSV data
    private  Integer currentBatchSize = 0;
    private  String csvFileForBulk = BULK_HEADERS;
    private  Boolean hasHeaderRow = true;
    private  Map<Integer, String> columnMap; // Mapping of the csv headers
    
    public Blob reportData;
    public  BulkApiManager bulkManager; // Bulk API
    public  Automated_Report_Processing_Options__c report;

    public AutomatedReportService(BulkApiManager bulkManagerToUse) {
        bulkManager = bulkManagerToUse;
    }
    
    public Boolean nextAvailableReport() {
        // Custom setting that holds the job details
        List<Automated_Report_Processing_Options__c> jobList = new List<Automated_Report_Processing_Options__c>();

        // Get settings for job
        jobList = [
            SELECT Id, Campaign_ID__c, Distribution_List__c, Print_List__c, Report_ID__c, Campaign_Member_Status__c
            FROM Automated_Report_Processing_Options__c
            WHERE Run_Required__c = TRUE AND Active__c = TRUE
            LIMIT 1
        ];

        if (jobList.size() > 0) {
            report = jobList[0];
            return true;
        }

        return false;
    }

    /**
     * Update job status
     */
    public void updateRunComplete() {
        if (report == null) {
            return;
        }
        try {            
            report.Run_Required__c = false;
            report.Last_Run__c = Datetime.now();
            update report;
        } catch (DmlException ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', ex.getMessage()));
            ErrorLogger.log(ex, vars, true);
        }
    }

    /**
     * Create rows
     */
    public void recreateRowsFromReport() {
        // Get report export
        reportData = new PageReference('/' + report.Report_ID__c + '?export=1&isdtp=p1').getContent();

        // Check size
        if (reportData.size() == 0) {
            updateRunComplete();
            return;
        }

        CsvIterator fileIterator = new CsvIterator(reportData.toString(), '\n');
        List<String> allRows = new List<String>();
        while (fileIterator.hasNext()) {
            allRows.add(fileIterator.next());
        }

        String csvFile = '';
        List<List<String>> csvColumnData = new List<List<String>>();
        for (String row : allRows) {
            if (hasHeaderRow) {
                createHeaderMappings(row);
                hasHeaderRow = false;
                continue;
            }
            csvColumnData.addAll(CsvReader.readCsvFile(row));
        }
        parsedCSV = csvColumnData;
    }

    /**
     * Create csv content for bulk api batch
     */
    public void createBulkContent() {
        // Iterate over each line in our csv
        for (List<String> lineValues : parsedCSV) {
            String row = '';
            row += lineValues.get(getColumnIndex('Contact ID'));
            row += ',';
            row += report.Campaign_ID__c;
            row += ',';
            row += report.Campaign_Member_Status__c;
            row += '\n';

            // Add row
            addRow(row);
        }
    }    

    /**
     * Send bulk, start new with headers
     */
    public void sendBatchAndRefreshCsv() {
        bulkManager.sendBatch(csvFileForBulk);
        csvFileForBulk = BULK_HEADERS;
        currentBatchSize = 0;
    }

        /**
     * Send email upon completion
     */
    public void sendEmail() {
        // Check if we have a distribution list
        if (report.Distribution_List__c == '') {
            return;
        }

        // Get our To address
        List<String> toAddress = new List<String>();
        toAddress = report.Distribution_List__c.split(',');

        String fileName = report.Print_List__c + '.' + report.Report_ID__c + '.csv';
        String subject = 'Print List Automation - ' + report.Print_List__c;

        // Create attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(fileName);
        attachment.setBody(reportData);
        attachment.setContentType('text/csv');

        // Create message
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
        message.setSubject(subject);
        message.setPlainTextBody('The report is attached.');
        message.setToAddresses(toAddress);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ message });
    }

    /**
     * Close bulk job
     */
    public void closeJob() {
        bulkManager.closeJob();
    }

    /**
     * Get the index of the provided column in the report
     */
    private Integer getColumnIndex(String columnName) {
        Integer columnId;
        for (Integer key : columnMap.keySet()) {
            if (columnMap.get(key) == columnName) {
                columnId = key;
            }
        }
        return columnId;
    }

    /**
     * Add row to bulk job
     */
    private void addRow(String rowToAdd) {
        if (currentBatchSize >= JOB_SIZE) {
            sendBatchAndRefreshCsv();
        }
        csvFileForBulk += rowToAdd;
        currentBatchSize += 1;
    }

    /**
     * Create header map
     */
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
}