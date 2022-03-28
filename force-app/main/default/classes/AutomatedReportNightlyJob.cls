global without sharing class AutomatedReportNightlyJob implements Schedulable {

    global void execute(SchedulableContext sc) {
        List<Automated_Report_Processing_Options__c> reportsToRun = new List<Automated_Report_Processing_Options__c>();

        Datetime today = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        List<String> currentDays = new List<String>();
        currentDays.add(today.format('EEEE'));
        currentDays.add('' + today.day());


        List<Automated_Report_Processing_Options__c> listOfReports = [
            SELECT Id, Schedule_Day__c, Schedule_Frequency__c, Last_Run__c
            FROM Automated_Report_Processing_Options__c
            WHERE Active__c = TRUE AND Schedule_Day__c IN: currentDays
        ];

        for (Automated_Report_Processing_Options__c report : listOfReports) {
            switch on report.Schedule_Frequency__c {
                when 'Weekly' {
                    DateTime comparisonDate = today.addDays(-6);
                    if (comparisonDate >= report.Last_Run__c) {
                        report.Run_Required__c = true;
                        reportsToRun.add(report);
                    }
                }
                when 'Bi-Weekly' {
                    DateTime comparisonDate = today.addDays(-13);
                    if (comparisonDate >= report.Last_Run__c) {
                        report.Run_Required__c = true;
                        reportsToRun.add(report);
                    }

                }
                when 'Monthly' {
                    DateTime comparisonDate = today.addDays(-27);
                    if (comparisonDate >= report.Last_Run__c) {
                        report.Run_Required__c = true;
                        reportsToRun.add(report);
                    }

                }
            }

            update reportsToRun;

            if(!Test.isRunningTest()) {
            	System.enqueueJob(new AutomatedReportProcessing(null));
            }
        }
    }    
    
}