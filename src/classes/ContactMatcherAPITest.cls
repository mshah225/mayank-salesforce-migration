@isTest
private class ContactMatcherAPITest {
    @isTest
    static void testContactMatcherAPI() {
        Contact testContact = new Contact();
        testContact.FirstName = 'Sparky';
        testContact.LastName = 'Sundevil';
        testContact.Email = 'ssundevil@asu.edu.invalid';
        insert testContact;

        String json = '{"$schema":"http://json-schema.org/draft-04/schema#","title":"contactMatcher","description":"ContactMatcher","type":"object","required":["firstName","lastName","email"],"properties":{"asurite":{"description":"ASURITE(ASURITE__C)ofstudent","type":"string","value":"ssundevil"},"birthDate":{"description":"BirthDate","type":"string","value":"1990-01-01"},"city":{"description":"cityofstudent","type":"string","value":"Tempe"},"countryCode":{"description":"countrycodeofstudent","type":"string","value":"US"},"country":{"description":"countrynameofstudent","type":"string","value":"United States"},"email":{"description":"emailofpersontosearch","type":"string","value":"ssundevil@asu.edu.invalid"},"emplid":{"description":"PeopleSoftEMPLID(EMPLID__c)ofstudent","type":"string","value":"111111111"},"firstName":{"description":"Firstnameofpersontosearch","type":"string","value":"Sparky"},"lastName":{"description":"Lastnameofpersontosearch","type":"string","value":"Sundevil"},"middleName":{"description":"Middlenameofperson","type":"string","value":"Maroon"},"phone":{"description":"PhonenumberforStudent","type":"string","value":"4805555555"},"postalCode":{"description":"PostalCodeofpersontosearch","type":"string","value":"85281"},"preferredName":{"description":"Preferrednameofpersontosearch","type":"string","value":"Spark"},"stateProvince":{"description":"stateorofpersontosearch","type":"string","value":"Arizona"},"streetAddress":{"description":"streetofpersontosearch","type":"string","value":"123 Sparky Dr"}}}';

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
