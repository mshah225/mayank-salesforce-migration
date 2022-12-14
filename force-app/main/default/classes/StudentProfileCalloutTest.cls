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
        FinancialEditMessageWrapper editMessages = StudentProfileCallout.getEditMessages(
            '1206104779'
        );

        System.assertEquals(editMessages.emplid, '1206104779');
    }
}