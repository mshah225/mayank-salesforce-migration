@IsTest
public class StudentProfileCalloutServiceTest {

    @isTest
    public static void getServiceIndicatorsFromCallout() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileServiceIndicatorMock());

        List<ServiceIndicatorWrapper.ServiceIndicators> serviceIndicators = StudentProfileCalloutService.getServiceIndicators('1206104779');

        System.assertEquals(serviceIndicators[0].ServiceIndicatorCode, 'A15');
    }

}
