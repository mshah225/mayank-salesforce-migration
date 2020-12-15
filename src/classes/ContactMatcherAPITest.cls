@isTest
private class ContactMatcherAPITest {
    @isTest
    static void testContactMatcherAPI() {
        Contact testContact = new Contact();
        testContact.FirstName = 'Sparky';
        testContact.LastName = 'Sundevil';
        testContact.Email = 'ssundevil@asu.edu.invalid';
        insert testContact;

        String json = '{"$schema":"http://json-schema.org/draft-04/schema#","title":"contactMatcher","description":"ContactMatcher","type":"object","required":["firstName","lastName","email"],"properties":{"asurite":{"description":"ASURITE(ASURITE__C)ofstudent","type":"string","value":""},"birthDate":{"description":"BirthDate","type":"string","value":""},"city":{"description":"cityofstudent","type":"string","value":""},"countryCode":{"description":"countrycodeofstudent","type":"string","value":""},"country":{"description":"countrynameofstudent","type":"string","value":""},"email":{"description":"emailofpersontosearch","type":"string","value":"ssundevil@asu.edu.invalid"},"emplid":{"description":"PeopleSoftEMPLID(EMPLID__c)ofstudent","type":"string","value":""},"firstName":{"description":"Firstnameofpersontosearch","type":"string","value":"Sparky"},"lastName":{"description":"Lastnameofpersontosearch","type":"string","value":"Sundevil"},"middleName":{"description":"Middlenameofperson","type":"string","value":""},"phone":{"description":"PhonenumberforStudent","type":"string","value":""},"postalCode":{"description":"PostalCodeofpersontosearch","type":"string","value":""},"preferredName":{"description":"Preferrednameofpersontosearch","type":"string","value":""},"stateProvince":{"description":"stateorofpersontosearch","type":"string","value":""},"streetAddress":{"description":"streetofpersontosearch","type":"string","value":""}}}';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactMatcher';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ContactMatcherAPI.matchContacts();
        Test.stopTest();
    }
}
