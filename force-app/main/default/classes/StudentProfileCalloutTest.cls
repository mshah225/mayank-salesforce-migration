@IsTest
public class StudentProfileCalloutTest {
    @isTest
    public static void getServiceIndicatorsFromCallout() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileCalloutMock());

        List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicators = StudentProfileCallout.getServiceIndicators(
            '1206104779'
        );

        System.assertEquals(serviceIndicators[0].ServiceIndicatorCode, 'A15');
    }
}