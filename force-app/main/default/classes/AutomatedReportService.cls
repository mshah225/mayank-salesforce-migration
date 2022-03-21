public without sharing class AutomatedReportService {    
    private static FINAL Integer JOB_SIZE = 10000;
    private static FINAL String BULK_HEADERS = 'ContactId,CampaignId,Status\n';

    private static List<List<String>> parsedCSV; // Parsed CSV data
    private static Integer currentBatchSize = 0;
    private static String csvFileForBulk = BULK_HEADERS;
    private Boolean hasHeaderRow = true;
    
    public static Automated_Report_Processing_Options__c getNextAvailableReport() {
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
            return jobList[0];
        }

        return null;
    }

    /**
     * Update job status
     */
    public static void updateRunComplete(Automated_Report_Processing_Options__c report) {
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
    public static List<List<String>> recreateRowsFromIteration(List<String> csvContacts) {
        String csvFile = '';
        List<List<String>> csvColumnData = new List<List<String>>();
        for (String row : csvContacts) {
            if (hasHeaderRow) {
                createHeaderMappings(row);
                hasHeaderRow = false;
                continue;
            }
            csvColumnData.addAll(CsvReader.readCsvFile(row));
        }
        parsedCSV = csvColumnData;
    }
}