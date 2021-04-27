@RestResource(urlMapping='/ContactMatcher')
global with sharing class ContactMatcherAPI {
    private static List<ConstituentDetail> contactDetailsToSearch;

    @HttpPost
    global static void matchContacts() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);

        if (
            (String) payload.get('type') == 'object' &&
            (String) payload.get('description') == 'Contact Matcher One-to-Many'
        ) {
            matchOneToMany(payload);
        } else if (
            (String) payload.get('type') == 'array' &&
            (String) payload.get('description') == 'Contact Matcher Many-to-Many'
        ) {
            matchManyToMany(payload);
        }
    }

    private static void matchOneToMany(Map<String, Object> payload) {
        ConstituentMatcher contactMatcher = new ConstituentMatcher(
            processPayloadProperties((Map<String, Object>) payload.get('properties'))
        );
        contactMatcher.searchConstituents();
        List<Contact> contactMatches = contactMatcher.getContactsWithMatches();

        RestResponse res = RestContext.response;
        if (contactMatches.size() > 0) {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(contactMatches, true).replace('\n', ''));
        }
    }

    private static void matchManyToMany(Map<String, Object> payload) {
        List<Object> items = (List<Object>) payload.get('items');
        contactDetailsToSearch = new List<ConstituentDetail>();

        for (Object item : items) {
            Map<String, Object> itemMap = (Map<String, Object>) item;
            contactDetailsToSearch.add(processPayloadProperties((Map<String, Object>) itemMap.get('properties')));
        }

        ConstituentMatcher contactMatcher = new ConstituentMatcher(contactDetailsToSearch);
        contactMatcher.searchConstituents();
        List<Contact> contactMatches = contactMatcher.getContactsWithMatches();

        RestResponse res = RestContext.response;
        if (contactMatches.size() > 0) {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(contactMatches, true).replace('\n', ''));
        }
    }

    private static ConstituentDetail processPayloadProperties(Map<String, Object> properties) {
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

        return new ConstituentDetail(detailFieldsMap);
    }
}
