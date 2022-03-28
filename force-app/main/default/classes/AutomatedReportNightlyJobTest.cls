@isTest
public without sharing class AutomatedReportNightlyJobTest {
    static Integer reportId = 1;

    @TestSetup
    static void makeData() {
        List<Automated_Report_Processing_Options__c> reportsToCreate = new List<Automated_Report_Processing_Options__c>();

        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String currentDayOfWeek = dt.format('EEEE');
        String notCurrentDayOfWeek = dt.addDays(1).format('EEEE');

        reportsToCreate.add(createReport('Weekly', 8, currentDayOfWeek, 'Weekly')); 
        reportsToCreate.add(createReport('Bi-Weekly', 15, currentDayOfWeek, 'Bi-Weekly')); 
        reportsToCreate.add(createReport('Monthly', 32, currentDayOfWeek, 'Monthly')); 

        insert reportsToCreate;
        
    }

    private static Automated_Report_Processing_Options__c createReport (String reportName, Integer offset, String scheduledDay, String scheduleFrequency) {
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

        Automated_Report_Processing_Options__c newReport = new Automated_Report_Processing_Options__c();
        newReport.Name = reportName;
        newReport.Campaign_ID__c = 'test';
        newReport.Campaign_Member_Status__c = 'test';
        newReport.Report_ID__c = '00X00000000000000' + reportId;
        newReport.Last_Run__c = dt.addDays(offset);
        newReport.Schedule_Day__c = scheduledDay;
        newReport.Schedule_Frequency__c = scheduleFrequency;
        newReport.Active__c = true;

        reportId += 1;
        return newReport;
    }

    
}