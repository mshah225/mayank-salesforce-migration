@isTest
private class ContactMatcherAPITest {
    @isTest
    static void testSingularContactMatch() {
        Contact testContact = new Contact();
        testContact.FirstName = 'Sparky';
        testContact.LastName = 'Sundevil';
        testContact.Email = 'ssundevil@asu.edu.invalid';
        insert testContact;

        String json = '{"$schema":"http://json-schema.org/draft-04/schema#","title":"contactMatcherSingular","description":"Contact Matcher Singular","type":"object","required":["firstName","lastName","email"],"properties":{"asurite":{"description":"ASURITE(ASURITE__C)ofstudent","type":"string","value":"ssundevil"},"birthDate":{"description":"BirthDate","type":"string","value":"1990-01-01"},"city":{"description":"cityofstudent","type":"string","value":"Tempe"},"countryCode":{"description":"countrycodeofstudent","type":"string","value":"US"},"country":{"description":"countrynameofstudent","type":"string","value":"United States"},"email":{"description":"emailofpersontosearch","type":"string","value":"ssundevil@asu.edu.invalid"},"emplid":{"description":"PeopleSoftEMPLID(EMPLID__c)ofstudent","type":"string","value":"111111111"},"firstName":{"description":"Firstnameofpersontosearch","type":"string","value":"Sparky"},"lastName":{"description":"Lastnameofpersontosearch","type":"string","value":"Sundevil"},"middleName":{"description":"Middlenameofperson","type":"string","value":"Maroon"},"phone":{"description":"PhonenumberforStudent","type":"string","value":"4805555555"},"postalCode":{"description":"PostalCodeofpersontosearch","type":"string","value":"85281"},"preferredName":{"description":"Preferrednameofpersontosearch","type":"string","value":"Spark"},"stateProvince":{"description":"stateorofpersontosearch","type":"string","value":"Arizona"},"streetAddress":{"description":"streetofpersontosearch","type":"string","value":"123 Sparky Dr"}}}';

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

    @isTest
    static void testBulkContactMatch() {
        List<Contact> contactsToInsert = new List<Contact>();

        Contact testContact = new Contact();
        testContact.FirstName = 'Sparky';
        testContact.LastName = 'Sundevil';
        testContact.Email = 'ssundevil@asu.edu.invalid';
        contactsToInsert.add(testContact);

        Contact testContact2 = new Contact();
        testContact2.FirstName = 'Oregon';
        testContact2.LastName = 'Duck';
        testContact2.Email = 'odduck@asu.edu.invalid';
        contactsToInsert.add(testContact2);

        Contact testContact3 = new Contact();
        testContact3.FirstName = 'Sparty';
        testContact3.LastName = 'Spartan';
        testContact3.Email = 'sgspartan@asu.edu.invalid';
        contactsToInsert.add(testContact3);

        insert contactsToInsert;

        String json = '{"$schema":"http://json-schema.org/draft-04/schema#","title":"contactMatcherBulk","description":"Contact Matcher Bulk","type":"array","required":["firstName","lastName","email"],"items":[{"properties":{"asurite":{"description":"ASURITE(ASURITE__C)ofstudent","type":"string","value":""},"birthDate":{"description":"BirthDate","type":"string","value":""},"city":{"description":"cityofstudent","type":"string","value":""},"countryCode":{"description":"countrycodeofstudent","type":"string","value":""},"country":{"description":"countrynameofstudent","type":"string","value":""},"email":{"description":"emailofpersontosearch","type":"string","value":"ssundevil@asu.edu.invalid"},"emplid":{"description":"PeopleSoftEMPLID(EMPLID__c)ofstudent","type":"string","value":""},"firstName":{"description":"Firstnameofpersontosearch","type":"string","value":"Sparky"},"lastName":{"description":"Lastnameofpersontosearch","type":"string","value":"Sundevil"},"middleName":{"description":"Middlenameofperson","type":"string","value":""},"phone":{"description":"PhonenumberforStudent","type":"string","value":""},"postalCode":{"description":"PostalCodeofpersontosearch","type":"string","value":""},"preferredName":{"description":"Preferrednameofpersontosearch","type":"string","value":""},"stateProvince":{"description":"stateorofpersontosearch","type":"string","value":""},"streetAddress":{"description":"streetofpersontosearch","type":"string","value":""}}},{"properties":{"asurite":{"description":"ASURITE(ASURITE__C)ofstudent","type":"string","value":""},"birthDate":{"description":"BirthDate","type":"string","value":""},"city":{"description":"cityofstudent","type":"string","value":""},"countryCode":{"description":"countrycodeofstudent","type":"string","value":""},"country":{"description":"countrynameofstudent","type":"string","value":""},"email":{"description":"emailofpersontosearch","type":"string","value":"odduck@asu.edu.invalid"},"emplid":{"description":"PeopleSoftEMPLID(EMPLID__c)ofstudent","type":"string","value":""},"firstName":{"description":"Firstnameofpersontosearch","type":"string","value":"Oregon"},"lastName":{"description":"Lastnameofpersontosearch","type":"string","value":"Duck"},"middleName":{"description":"Middlenameofperson","type":"string","value":""},"phone":{"description":"PhonenumberforStudent","type":"string","value":""},"postalCode":{"description":"PostalCodeofpersontosearch","type":"string","value":""},"preferredName":{"description":"Preferrednameofpersontosearch","type":"string","value":""},"stateProvince":{"description":"stateorofpersontosearch","type":"string","value":""},"streetAddress":{"description":"streetofpersontosearch","type":"string","value":""}}},{"properties":{"asurite":{"description":"ASURITE(ASURITE__C)ofstudent","type":"string","value":""},"birthDate":{"description":"BirthDate","type":"string","value":""},"city":{"description":"cityofstudent","type":"string","value":""},"countryCode":{"description":"countrycodeofstudent","type":"string","value":""},"country":{"description":"countrynameofstudent","type":"string","value":""},"email":{"description":"emailofpersontosearch","type":"string","value":"sgspartan@asu.edu.invalid"},"emplid":{"description":"PeopleSoftEMPLID(EMPLID__c)ofstudent","type":"string","value":""},"firstName":{"description":"Firstnameofpersontosearch","type":"string","value":"Sparty"},"lastName":{"description":"Lastnameofpersontosearch","type":"string","value":"Spartan"},"middleName":{"description":"Middlenameofperson","type":"string","value":""},"phone":{"description":"PhonenumberforStudent","type":"string","value":""},"postalCode":{"description":"PostalCodeofpersontosearch","type":"string","value":""},"preferredName":{"description":"Preferrednameofpersontosearch","type":"string","value":""},"stateProvince":{"description":"stateorofpersontosearch","type":"string","value":""},"streetAddress":{"description":"streetofpersontosearch","type":"string","value":""}}}]}';

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
