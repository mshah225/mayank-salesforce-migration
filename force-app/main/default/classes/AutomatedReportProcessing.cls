public without sharing class AutomatedReportProcessing implements Queueable, Database.AllowsCallouts {
    private Boolean hasHeaderRow; // Flag for csv headers
    private Map<Integer, String> columnMap; // Mapping of the csv headers
    private CsvIterator fileIterator; // Iterator for CSV data
    private BulkApiManager bulkManager; // Bulk API
    private Integer currentBatchSize; // Current size of batch
    private Integer jobSize; // Max size for batch job
    private String bulkHeaders; // Headers for bulk api file
    private String csvFileForBulk; // CSV content used for bulk api
    private Automated_Report_Processing_Options__c report; // Custom setting options
    private Blob reportData; // Data from fetched report
    private List<List<String>> parsedCSV; // Parsed CSV data
    private final static String LIST_PROCESSING_ENABLED = System.Label.Automated_List_Processing; // Master switch incase of recursive queueable issues

    /**
     * Constructor
     */
    public AutomatedReportProcessing(BulkApiManager currentJob) {
        bulkHeaders = 'ContactId,CampaignId,Status\n';
        hasHeaderRow = true;
        currentBatchSize = 0;
        jobSize = 10000;
        csvFileForBulk = bulkHeaders;

        if (currentJob == null) {
            bulkManager = new BulkApiManager('CampaignMember', 'insert');
        } else {
            bulkManager = currentJob;
        }
    }

    /**
     * Execute our queueable invocation
     */
    public void execute(QueueableContext context) {
        run();
    }

    /**
     * Main method called by queueable
     */
    private void run() {
        try {
            
            report = AutomatedReportService.getNextAvailableReport();

            if (report == null) {
                closeJob();
                return;
            }

            // Get report export
            reportData = new PageReference('/' + report.Report_ID__c + '?export=1&isdtp=p1').getContent();

            // Check size
            if (reportData.size() == 0) {
                AutomatedReportService.updateRunComplete(report);
                return;
            }

            // Parse CSV using iterator
            fileIterator = new CsvIterator(reportData.toString(), '\n');
            List<String> allRows = new List<String>();
            while (fileIterator.hasNext()) {
                allRows.add(fileIterator.next());
            }

            // Recreate rows
            //parsedCSV = recreateRowsFromIteration(allRows);

            // Create csv for bulk job
            createBulkContent();

            // Close bulk job
            sendBatchAndRefreshCsv();

            // Send email
            sendEmail();

            // Update Report status
            AutomatedReportService.updateRunComplete(report);

            // Re-queue if enabled
            if (LIST_PROCESSING_ENABLED == 'TRUE') {
                System.enqueueJob(new AutomatedReportProcessing(bulkManager));
            }
        } catch (Exception ex) {
            // Update Report status
            if (report != null) {
                AutomatedReportService.updateRunComplete(report);
            }

            // Log
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', ex.getMessage()));
            vars.add(ErrorLogger.convertSObjectToJSON('report', report));
            vars.add(string.valueOf(reportData.size()));
            ErrorLogger.log(ex, vars, true);

            // Re-queue if enabled
            if (LIST_PROCESSING_ENABLED == 'TRUE') {
                System.enqueueJob(new AutomatedReportProcessing(bulkManager));
            }
        }
    }

    /**
     * Create csv content for bulk api batch
     */
    private void createBulkContent() {
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
     * Send email upon completion
     */
    private void sendEmail() {
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

    /**
     * Add row to bulk job
     */
    private void addRow(String rowToAdd) {
        if (currentBatchSize >= jobSize) {
            sendBatchAndRefreshCsv();
        }
        csvFileForBulk += rowToAdd;
        currentBatchSize += 1;
    }

    /**
     * Send bulk, start new with headers
     */
    private void sendBatchAndRefreshCsv() {
        bulkManager.sendBatch(csvFileForBulk);
        csvFileForBulk = bulkHeaders;
        currentBatchSize = 0;
    }

    /**
     * Close bulk job
     */
    private void closeJob() {
        bulkManager.closeJob();
    }
}