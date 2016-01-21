@isTest
public with sharing class Test_UserRequestAccess
{
    @isTest static void testMuleCallout()
    {
        MuleSoft_BB_Courses__c mule = new MuleSoft_BB_Courses__c(
            Name = 'MuleSoft Dev',
            URL__c = 'nowhere.none.com',
            Username__c = 'Test',
            Password__c = 'test'
        );

        insert mule;

        SingleRequestMock fakeResponse = new SingleRequestMock(
            200,
            'Complete',
            '[{"Name": "sForceTest1"}]',
            null
        );

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        List<String> strList = UserRequestAccess.callMuleSoft();

        Test.stopTest();

        System.assertNotEquals(null, strList);
    }

    @isTest static void testMuleFail()
    {
        SingleRequestMock fakeResponse = new SingleRequestMock(
            200,
            'Complete',
            '[{"Name": "sForceTest1"}]',
            null
        );

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        List<String> strList = UserRequestAccess.callMuleSoft();

        Test.stopTest();

        System.assertEquals(null, strList);
    }
}