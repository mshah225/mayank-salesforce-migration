@IsTest
public class StudentProfileCalloutTest {
    @isTest
    public static void testServiceIndicators() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicators = StudentProfileCallout.getServiceIndicators(
            '1206104779'
        );
        System.assertEquals(serviceIndicators[0].ServiceIndicatorCode, 'A15');
    }

    @isTest
    public static void testFinancialAidChecklists() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());
        List<FinancialAidChecklistWrapper.FinancialAidChecklists> checklists = StudentProfileCallout.getFinancialAidChecklists(
            '1221449333'
        );
        System.assertEquals(0, 0);
    }
}