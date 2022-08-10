@isTest
public without sharing class AutomatedReportServiceTest {   
    @isTest
    static void getNextAvailableReport() {
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

        Automated_Report_Processing_Options__c newReport = new Automated_Report_Processing_Options__c();
        newReport.Name = 'Weekly Report';
        newReport.Campaign_ID__c = 'test';
        newReport.Campaign_Member_Status__c = 'test';
        newReport.Report_ID__c = '00X000000000000001';
        newReport.Last_Run__c = dt.addDays(-8);
        newReport.Schedule_Day__c = 'Monday';
        newReport.Schedule_Frequency__c = 'Weekly';
        newReport.Active__c = true;
        newReport.Run_Required__c = true;

        insert newReport;

        AutomatedReportService ars = new AutomatedReportService(null);
        ars.report = newReport;

        System.assert(ars.nextAvailableReport());

        ars.updateRunComplete();

        System.assert(!ars.nextAvailableReport());
    }

    @isTest 
    static void emailSent() {
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Integer invocations;
        Automated_Report_Processing_Options__c newReport = new Automated_Report_Processing_Options__c();
        newReport.Name = 'Weekly Report';
        newReport.Campaign_ID__c = 'test';
        newReport.Campaign_Member_Status__c = 'test';
        newReport.Report_ID__c = '00X000000000000001';
        newReport.Last_Run__c = dt.addDays(-8);
        newReport.Schedule_Day__c = 'Monday';
        newReport.Schedule_Frequency__c = 'Weekly';
        newReport.Active__c = true;
        newReport.Run_Required__c = true;
        newReport.Distribution_List__c = 'test@test.com';

        insert newReport;

        AutomatedReportService ars = new AutomatedReportService(null);
        ars.report = newReport;
        ars.reportData = Blob.valueOf('nothing');

        Test.startTest();
        ars.sendEmail();
        invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'An email should be sent');
    }
    
}