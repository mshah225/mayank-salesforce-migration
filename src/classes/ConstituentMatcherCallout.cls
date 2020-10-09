@RestResource(urlMapping='/ConstituentMatcher')
global with sharing class ConstituentMatcherCallout {
    public List<ConstituentDetail> contactDetailsToMatch;

    public ConstituentMatcherCallout() {
        contactDetailsToMatch = new List<ConstituentDetail>();
    }

    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // https://docs.google.com/spreadsheets/d/17_BNq83NZ8GqsrBjiY2WQkpyHyjp5G6JaL9LDlzwCWI
        // Loop over the provided JSON data to assign to detailFieldsMap
        // Need to get example data from Roger

        // Contact ID (SF ID) - use constituentId on detail
        // EMPLID
        // First Name
        // Preferred Name
        // Last Name
        // Middle Name
        // Email
        // Birthdate
        // Phone
        // Street Address
        // City
        // State
        // Zip
        // Country

        // LOOP START

        Map<String, String> detailFieldsMap = new Map<String, String>();

        if (req.params.get('emplid') != null) {
            detailFieldsMap.put('emplid', req.params.get('emplid'));
        }
        if (req.params.get('firstName') != null) {
            detailFieldsMap.put('firstName', req.params.get('firstName'));
        }
        if (req.params.get('preferredName') != null) {
            detailFieldsMap.put('preferredName', req.params.get('preferredName'));
        }
        if (req.params.get('lastName') != null) {
            detailFieldsMap.put('lastName', req.params.get('lastName'));
        }
        if (req.params.get('middleName') != null) {
            detailFieldsMap.put('middleName', req.params.get('middleName'));
        }
        if (req.params.get('email') != null) {
            detailFieldsMap.put('email', req.params.get('email'));
        }
        if (req.params.get('birthdate') != null) {
            detailFieldsMap.put('birthdate', req.params.get('birthdate'));
        }
        if (req.params.get('phone') != null) {
            detailFieldsMap.put('phone', req.params.get('phone'));
        }
        if (req.params.get('mailingStreet') != null) {
            detailFieldsMap.put('mailingStreet', req.params.get('mailingStreet'));
        }
        if (req.params.get('mailingCity') != null) {
            detailFieldsMap.put('mailingCity', req.params.get('mailingCity'));
        }
        if (req.params.get('mailingState') != null) {
            detailFieldsMap.put('mailingState', req.params.get('mailingState'));
        }
        if (req.params.get('mailingPostalCode') != null) {
            detailFieldsMap.put('mailingPostalCode', req.params.get('mailingPostalCode'));
        }
        if (req.params.get('mailingCountry') != null) {
            detailFieldsMap.put('mailingCountry', req.params.get('mailingCountry'));
        }

        ConstituentDetail contactDetail = new ConstituentDetail(detailFieldsMap);
        contactDetailsToMatch.add(contactDetail);

        // LOOP END

        ConstituentMatcher contactMatcher = new ConstituentMatcher(contactDetailsToMatch);
        contactMatcher.searchConstituents();
        List<ConstituentDetail> matchedDetailsWithContacts = contactMatcher.getListOfConstituentsWithMatches();

        String matchedDetailsWithContactsJSON = JSON.serialize(matchedDetailsWithContacts);
        return matchedDetailsWithContactsJSON;
    }
}
