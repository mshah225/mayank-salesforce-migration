@IsTest
public class StudentProfileCalloutServiceTest {
    public static HttpResponse getServiceIndicatorsFromCallout() {
        Test.setMock(HttpCalloutMock.class, new StudentProfileServiceIndicatorMock());

        Map<String, List<ServiceIndicatorWrapper.ServiceIndicators>> serviceIndicators = StudentProfileCalloutService.getServiceIndicators('1206104779');

        System.assertEquals(serviceIndicators.keySet().size(), 1);

        System.assert(serviceIndicators.get('2201') != null);

        ServiceIndicatorWrapper.ServiceIndicators specificRecord = serviceIndicators.get('2201');

        System.assertEquals(specificRecord.ServiceIndicatorCode, 'A15');
    }

}
