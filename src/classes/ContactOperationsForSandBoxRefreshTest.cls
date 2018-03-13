@isTest
private class ContactOperationsForSandBoxRefreshTest {

    private static final Integer ACCOUNT_NUM = 100;
    private static final Integer CONTACT_NUM = 100;
    
	private static testMethod void test() {
        
        //Create Account Test Data 
        List<Account> lstAccount= TestDataFactory.createAccounts(ACCOUNT_NUM);
        insert lstAccount;
        
        //Create Contact Test data
        List<Contact> lstCon = TestDataFactory.createContacts(CONTACT_NUM);
        for (Integer i = 0; i < CONTACT_NUM; i++) {
            lstCon[i].AccountId = lstAccount[0].Id;
            lstCon[i].LastName = 'Test';
            lstCon[i].email = 'Test' + i + '@Test.com';
            lstCon[i].Corporate_Relations_Email__c = 'Test@Test.com';
            lstCon[i].EPO_Email__c = 'Test@Test.com';
            lstCon[i].ASU_Email__c = 'Test@Test.com';
            lstCon[i].Last_Case_Email_Used__c = 'Test@Test.com';
            lstCon[i].Lead_Email__c = 'Test@Test.com';
            lstCon[i].Lead_Secondary_Email__c = 'Test@Test.com';
            lstCon[i].Parent_Email__c = 'Test@Test.com';
            lstCon[i].Personal_Email__c = 'Test@Test.com';
            lstCon[i].Birthdate = system.today();
        } 
        
        insert lstCon;
        
        Test.startTest();
            ContactOperationsForSandBoxRefresh obj = new ContactOperationsForSandBoxRefresh();
            obj.baseUrl = 'https://asu--roger.UAT.cs53.my.salesforce.com';
            DataBase.executeBatch(obj);
            obj.baseUrl = 'https://asu--roger.QA.cs53.my.salesforce.com';
            DataBase.executeBatch(obj);
            obj.baseUrl = 'https://asu--roger.DEV.cs53.my.salesforce.com';
            DataBase.executeBatch(obj);
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}