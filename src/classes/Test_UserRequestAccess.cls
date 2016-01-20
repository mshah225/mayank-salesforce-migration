@isTest
public with sharing class Test_UserRequestAccess
{
    @testSetup static void setUp()
    {
        MuleSoft_BB_Courses__c mule = new MuleSoft_BB_Courses__c();
        mule.Name = 'MuleSoft Dev';
        mule.URL__c = 'https://test.nowhere.com';
        mule.Username__c = 'Test';
        mule.Password__c = 'test';

        insert mule;
    }

    @isTest static void testCallout()
    {
        System.assertEquals(null, UserRequestAccess.callMuleSoft());
    }
}