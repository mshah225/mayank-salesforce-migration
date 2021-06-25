@isTest
public class CaseAssignmentRuleAccessorTest {
    @isTest
    public static void checkDefualtErrorLoggerCar() {
        List<Case_Assignment_Rule__c> cars;

        Test.startTest();
        insert CaseAssignmentRuleAccessor.createDefaultCarForErrorLogger();
        Test.stopTest();

        cars = [SELECT Id, Priority__c FROM Case_Assignment_Rule__c WHERE Origin__c = 'Error Logger'];

        System.assertEquals(1, cars.size());
        System.assertEquals(10000, integer.valueOf(cars[0].Priority__c));
    }

    @isTest
    public static void checkDuplicateErrorLoggerCarPriority() {
        List<Case_Assignment_Rule__c> cars;

        Test.startTest();
        insert CaseAssignmentRuleAccessor.createDefaultCarForErrorLogger();
        insert CaseAssignmentRuleAccessor.createDefaultCarForErrorLogger();
        Test.stopTest();

        cars = [
            SELECT Priority__c
            FROM Case_Assignment_Rule__c
            WHERE Origin__c = 'Error Logger'
            ORDER BY Priority__c DESC
        ];

        System.assertEquals(2, cars.size());
        System.assertEquals(10001, integer.valueOf(cars[0].Priority__c));
    }
}
