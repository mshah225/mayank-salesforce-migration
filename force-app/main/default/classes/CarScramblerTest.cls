@isTest
private class CarScramblerTest {
    @isTest
    private static void testtoCsv() {

        //Arrange
        Case_Assignment_Rule__c c1 = new Case_Assignment_Rule__c(Email_Address__c='testEmail@test.com',Reply_To_Email_Address__c='testReplyEmail@test.com');
        CarScrambler carToScramble1 = new CarScrambler(c1);

        //Act
        Test.startTest();
        String formattedString = carToScramble1.toCsvString();
        Test.stopTest();

        //Asset
        System.assertEquals(c1.Id+','+c1.Email_Address__c+','+c1.Reply_To_Email_Address__c+'\n',formattedString);
    }

    @isTest
    private static void testScrambler() {

        //Arrange
        String testemail = 'testEmail@test.com';
        String testreplyemail = 'testReplyEmail@test.com';
        Case_Assignment_Rule__c c2 = new Case_Assignment_Rule__c(Email_Address__c=testemail,Reply_To_Email_Address__c=testreplyemail);        
        CarScrambler carToScramble2 = new CarScrambler(c2);

        //Act
        Test.startTest();
        sObject sScramble =carToScramble2.scrambleFields();
        Test.stopTest();

        //Asset
        System.assertEquals('"testEmail@test.com.' + UserInfo.getUserName().substringAfterLast('.') + '"',sScramble.get('Email_Address__c'));
        System.assertEquals('"testReplyEmail@test.com.' + UserInfo.getUserName().substringAfterLast('.') + '"',sScramble.get('Reply_To_Email_Address__c'));
    }
}