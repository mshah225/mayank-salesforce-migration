@isTest
public class AlertHandlerTest {
    @isTest
    private static void testConstructor() {
        AlertHandler handler = new AlertHandler();
        System.assert(handler.alerts.size() == 0);
    }

    @isTest
    private static void testNewAlert() {
        AlertHandler handler = new AlertHandler();

        Test.startTest();
        handler.newAlert('CONFIRM', 'test');
        Test.stopTest();

        System.assert(handler.alerts.size() == 1);
        System.assert(handler.alerts[0].severity == 'CONFIRM');
        System.assert(handler.alerts[0].message == 'test');
    }

    @isTest
    private static void testClear() {
        AlertHandler handler = new AlertHandler();

        Test.startTest();
        handler.newAlert('CONFIRM', 'test');
        handler.clear();
        Test.stopTest();

        System.assert(handler.alerts.size() == 0);
    }

    @isTest
    private static void testDuplicate() {
        AlertHandler handler = new AlertHandler();

        Test.startTest();
        handler.newAlert('CONFIRM', 'test');
        handler.newAlert('CONFIRM', 'test');
        Test.stopTest();

        System.assert(handler.alerts.size() == 1);
    }

    @isTest
    private static void testCategoricalGets() {
        AlertHandler handler = new AlertHandler();

        String fatalAlertMsg = 'testFatal';
        String warningAlertMsg = 'testWarning';
        String infoAlertMsg = 'testInfo';
        String confirmAlertMsg = 'testConfirm';

        Test.startTest();
        handler.newAlert('FATAL', fatalAlertMsg);
        handler.newAlert('WARNING', warningAlertMsg);
        handler.newAlert('INFO', infoAlertMsg);
        handler.newAlert('CONFIRM', confirmAlertMsg);
        Test.stopTest();

        System.assert(handler.getFatal().size() == 1);
        System.assert(handler.getFatal()[0].severity == 'FATAL');
        System.assert(handler.getFatal()[0].message == fatalAlertMsg);

        System.assert(handler.getWarning().size() == 1);
        System.assert(handler.getWarning()[0].severity == 'WARNING');
        System.assert(handler.getWarning()[0].message == warningAlertMsg);

        System.assert(handler.getInfo().size() == 1);
        System.assert(handler.getInfo()[0].severity == 'INFO');
        System.assert(handler.getInfo()[0].message == infoAlertMsg);

        System.assert(handler.getConfirm().size() == 1);
        System.assert(handler.getConfirm()[0].severity == 'CONFIRM');
        System.assert(handler.getConfirm()[0].message == confirmAlertMsg);
    }
}
