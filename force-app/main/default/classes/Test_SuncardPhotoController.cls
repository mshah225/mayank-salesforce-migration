@isTest
private class Test_SuncardPhotoController {
    @isTest
    static void testSuncardPhotoURL() {
        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testing';
        testContact.EMPLID__c = '1234567890';

        insert testContact;

        Suncard_Photo__c sunSetting = new Suncard_Photo__c(
            Name = 'Suncard Photo Service',
            URL__c = 'https://nowhere.come'
        );

        insert sunSetting;

        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'Complete', '[{"Name": "sForceTest1"}]', null);

        PageReference sunPage = Page.SuncardPhoto;
        Test.setCurrentPage(sunPage);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        ApexPages.StandardController std = new ApexPages.StandardController(testContact);
        SuncardPhotoController sun = new SuncardPhotoController(std);

        String testURL = sun.getSuncardPhotoURL();

        Test.stopTest();

        System.assertNotEquals(null, testURL);
    }
}
