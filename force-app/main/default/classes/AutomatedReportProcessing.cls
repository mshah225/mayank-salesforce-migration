public without sharing class AutomatedReportProcessing implements Queueable, Database.AllowsCallouts {
    private final static String LIST_PROCESSING_ENABLED = System.Label.Automated_List_Processing; // Master switch incase of recursive queueable issues
    private AutomatedReportService reportService;

    /**
     * Constructor
     */
    public AutomatedReportProcessing(BulkApiManager currentJob) {
        if (currentJob == null) {
            reportService = new AutomatedReportService(new BulkApiManager('CampaignMember', 'insert'));
        } else {
            reportService = new AutomatedReportService(currentJob);
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

            if (!reportService.nextAvailableReport()) {
                reportService.closeJob();
                return;
            }            

            reportService.recreateRowsFromReport();

            reportService.createBulkContent();

            reportService.sendBatchAndRefreshCsv();

            reportService.sendEmail();

            reportService.updateRunComplete();

            // Re-queue if enabled
            if (LIST_PROCESSING_ENABLED == 'TRUE') {
                System.enqueueJob(new AutomatedReportProcessing(reportService.bulkManager));
            }
        } catch (Exception ex) {
            // Update Report status
            reportService.updateRunComplete();            

            // Log
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', ex.getMessage()));
            vars.add(ErrorLogger.convertSObjectToJSON('report', reportService.report));
            ErrorLogger.log(ex, vars, true);

            // Re-queue if enabled
            if (LIST_PROCESSING_ENABLED == 'TRUE') {
                System.enqueueJob(new AutomatedReportProcessing(reportService.bulkManager));
            }
        }
    }    
}