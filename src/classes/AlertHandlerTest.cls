@isTest
public class AlertHandlerTest {
    static AlertHandler handler;

    static {
        handler = new AlertHandler();
    }

    public static testMethod void Test_Constructor() {
        system.assert(handler.alerts.size() == 0);
    }

    public static testMethod void Test_newAlert() {
        test.startTest();
        handler.newAlert('CONFIRM', 'test');
        test.stopTest();

        system.assert(handler.alerts.size() == 1);
        system.assert(handler.alerts[0].severity == 'CONFIRM');
        system.assert(handler.alerts[0].message == 'test');
    }

    public static testMethod void Test_Clear() {
        handler.newAlert('CONFIRM', 'test');

        test.startTest();
        handler.clear();
        test.stopTest();

        system.assert(handler.alerts.size() == 0);
    }

    public static testMethod void Test_Duplicate() {
        handler.newAlert('CONFIRM', 'test');
        test.startTest();
        handler.newAlert('CONFIRM', 'test');
        test.stopTest();

        system.assert(handler.alerts.size() == 1);
    }
}
