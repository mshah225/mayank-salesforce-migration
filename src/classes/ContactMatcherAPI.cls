@RestResource(urlMapping='/ContactMatcher')
global with sharing class ContactMatcherAPI {
    @HttpPost
    global static void matchContacts() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
        Map<String, Object> properties = (Map<String, Object>) payload.get('properties');

        String asurite = (String) ((Map<String, Object>) properties.get('asurite')).get('value');
        String birthDate = (String) ((Map<String, Object>) properties.get('birthDate')).get('value');
        String city = (String) ((Map<String, Object>) properties.get('city')).get('value');
        String country = (String) ((Map<String, Object>) properties.get('country')).get('value');
        String email = (String) ((Map<String, Object>) properties.get('email')).get('value');
        String emplid = (String) ((Map<String, Object>) properties.get('emplid')).get('value');
        String firstName = (String) ((Map<String, Object>) properties.get('firstName')).get('value');
        String lastName = (String) ((Map<String, Object>) properties.get('lastName')).get('value');
        String middleName = (String) ((Map<String, Object>) properties.get('middleName')).get('value');
        String phone = (String) ((Map<String, Object>) properties.get('phone')).get('value');
        String postalCode = (String) ((Map<String, Object>) properties.get('postalCode')).get('value');
        String preferredName = (String) ((Map<String, Object>) properties.get('preferredName')).get('value');
        String stateProvince = (String) ((Map<String, Object>) properties.get('stateProvince')).get('value');
        String streetAddress = (String) ((Map<String, Object>) properties.get('streetAddress')).get('value');

        Map<String, String> detailFieldsMap = new Map<String, String>();
        if (asurite != null && asurite != '') {
            detailFieldsMap.put('asuriteId', asurite);
        }
        if (birthDate != null && birthDate != '') {
            detailFieldsMap.put('birthdate', birthDate);
        }
        if (city != null && city != '') {
            detailFieldsMap.put('mailingCity', city);
        }
        if (country != null && country != '') {
            detailFieldsMap.put('mailingCountry', country);
        }
        if (email != null && email != '') {
            detailFieldsMap.put('email', email);
        }
        if (emplid != null && emplid != '') {
            detailFieldsMap.put('emplid', emplid);
        }
        if (firstName != null && firstName != '') {
            detailFieldsMap.put('firstName', firstName);
        }
        if (lastName != null && lastName != '') {
            detailFieldsMap.put('lastName', lastName);
        }
        if (middleName != null && middleName != '') {
            detailFieldsMap.put('middleName', middleName);
        }
        if (phone != null && phone != '') {
            detailFieldsMap.put('phone', phone);
        }
        if (postalCode != null && postalCode != '') {
            detailFieldsMap.put('mailingPostalCode', postalCode);
        }
        if (preferredName != null && preferredName != '') {
            detailFieldsMap.put('preferredName', preferredName);
        }
        if (stateProvince != null && stateProvince != '') {
            detailFieldsMap.put('mailingState', stateProvince);
        }
        if (streetAddress != null && streetAddress != '') {
            detailFieldsMap.put('mailingStreet', streetAddress);
        }

        ConstituentDetail contactDetail = new ConstituentDetail(detailFieldsMap);
        ConstituentMatcher contactMatcher = new ConstituentMatcher(contactDetail);
        contactMatcher.searchConstituents();
        List<Contact> contactMatches = contactMatcher.getContactsWithMatches();

        RestResponse res = RestContext.response;
        if (contactMatches.size() > 0) {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(contactMatches, true).replace('\n', ''));
        } else {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('No matching contacts based on provided data.')
        }
    }
}
