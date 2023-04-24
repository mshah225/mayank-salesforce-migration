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

    @isTest
    public static void testDepositStatus() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        DepositStatusWrapper deposits = StudentProfileCallout.getDepositStatus(
            '1206104779'
        );

        System.assertEquals(deposits.emplid, '1206104779');
    }

    @isTest
    public static void testRenewableAid() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        RenewableAidWrapper renewableAidForStudent = StudentProfileCallout.getRenewableAid(
            '1206104779'
        );

        System.assertEquals(renewableAidForStudent.emplid, '1206104779');
    }

    @isTest
    public static void testBookPayment() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        BookPaymentWrapper bookPaymentsForStudent = StudentProfileCallout.getBookPayments(
            '1206104779'
        );

        System.assertEquals(bookPaymentsForStudent.emplid, '1206104779');
    }
}
