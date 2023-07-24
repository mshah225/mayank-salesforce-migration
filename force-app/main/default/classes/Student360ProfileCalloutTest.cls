@IsTest
public class Student360ProfileCalloutTest {
    @isTest
    public static void testServiceIndicators() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        List<ServiceIndicatorWrapper.ServiceIndicator> serviceIndicators = Student360ProfileCallout.getServiceIndicators(
            '1206104779'
        );
        System.assertEquals(serviceIndicators[0].ServiceIndicatorCode, 'A15');
    }

    @isTest
    public static void testFinancialAidChecklists() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> checklists = Student360ProfileCallout.getFinancialAidChecklists(
            '1221449333'
        );
        System.assertEquals(checklists[0].checklist_cd, 'FTNOTI');
    }

    @isTest
    public static void testFinancialAidAwardStatus() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        FinancialAidAwardWrapper awards = Student360ProfileCallout.getAwards('1221449333');

        System.assertEquals(awards.aid_years[0].financial_year, '2013-2014');
    }

    @isTest
    public static void testFinancialAidEditMessages() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        FinancialEditMessageWrapper editMessages = Student360ProfileCallout.getEditMessages('1206104779');

        System.assertEquals(editMessages.emplid, '1206104779');
    }

    @isTest
    public static void testfinancialAidChargeHistory() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        FinancialAidChargeHistoryWrapper chargeHistory = Student360ProfileCallout.getChargeHistory('1206104779');

        System.assertEquals(chargeHistory.charges.size(), 2);
    }

    @isTest
    public static void testFinancialAidAccountBalance() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        FinancialAidBalanceWrapper accountBalance = Student360ProfileCallout.getAccountBalance('1206104779');

        System.assertEquals(accountBalance.emplid, '1206104779');
    }

    @isTest
    public static void testFinancialAidRefunds() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        FinancialAidRefundWrapper refunds = Student360ProfileCallout.getRefunds('1206104779');

        System.assertEquals(refunds.emplid, '1206104779');
    }

    @isTest
    public static void testDepositStatus() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        DepositStatusWrapper deposits = Student360ProfileCallout.getDepositStatus('1206104779');

        System.assertEquals(deposits.emplid, '1206104779');
    }

    @isTest
    public static void testRenewableAid() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        RenewableAidWrapper renewableAidForStudent = Student360ProfileCallout.getRenewableAid('1206104779');

        System.assertEquals(renewableAidForStudent.emplid, '1206104779');
    }

    @isTest
    public static void testBookPayment() {
        Test.setMock(HttpCalloutMock.class, new Student360ProfileCalloutMock());
        BookPaymentWrapper bookPaymentsForStudent = Student360ProfileCallout.getBookPayments('1206104779');

        System.assertEquals(bookPaymentsForStudent.emplid, '1206104779');
    }
}