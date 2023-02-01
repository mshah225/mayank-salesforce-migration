@IsTest
public class StudentProfileCalloutTest {
    @isTest
    public static void testServiceIndicators() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        List<ServiceIndicatorWrapper.ServiceIndicator> serviceIndicators = StudentProfileCallout.getServiceIndicators(
            '1206104779'
        );
        System.assertEquals(serviceIndicators[0].ServiceIndicatorCode, 'A15');
    }

    @isTest
    public static void testFinancialAidChecklists() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> checklists = StudentProfileCallout.getFinancialAidChecklists(
            '1221449333'
        );
        System.assertEquals(checklists[0].checklist_cd, 'FTNOTI');
    }

    @isTest
    public static void testFinancialAidAwardStatus() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        FinancialAidAwardWrapper awards = StudentProfileCallout.getAwards(
            '1221449333'
        );

        System.assertEquals(awards.aid_years[0].financial_year, '2013-2014');
    }

    @isTest
    public static void testFinancialAidEditMessages() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        FinancialEditMessageWrapper editMessages = StudentProfileCallout.getEditMessages(
            '1206104779'
        );

        System.assertEquals(editMessages.emplid, '1206104779');
    }

    @isTest
    public static void testfinancialAidChargeHistory() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        FinancialAidChargeHistoryWrapper chargeHistory = StudentProfileCallout.getChargeHistory(
            '1206104779'
        );

        System.assertEquals(chargeHistory.charges.size(), 2);
    }

    @isTest
    public static void testFinancialAidAccountBalance() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        FinancialAidBalanceWrapper accountBalance = StudentProfileCallout.getAccountBalance(
            '1206104779'
        );

        System.assertEquals(accountBalance.emplid, '1206104779');
    }

    @isTest
    public static void testFinancialAidRefunds() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        FinancialAidRefundWrapper refunds = StudentProfileCallout.getRefunds(
            '1206104779'
        );

        System.assertEquals(refunds.emplid, '1206104779');
    }
}