@RestResource(urlMapping='/MCSMSOptIn')
global with sharing class MCSMSOptInController {
    static String errorMessage = '';

    @HttpPost
    global static OptInResult optIn(
        String subscriberKey,
        String mobileNumber,
        String shortCode,
        String messageText,
        String asurite,
        String emplid,
        String firstname,
        String lastName,
        String middlename,
        String email,
        String birthdate,
        String street,
        String city,
        String statecode,
        String postalcode,
        String countrycode
    ) {
        OptInResult oir = new OptInResult();
        Boolean errorEncountered = false;

        if (String.isBlank(mobileNumber) || String.isBlank(shortCode) || String.isBlank(messageText)) {
            errorEncountered = true;
            errorMessage = 'mobilenumber, shortCode, and messageText/keyword are required';
        }

        if (!errorEncountered && String.isBlank(subscriberKey)) {
            Map<String, String> parmMap = new Map<String, String>();
            if (!String.isBlank(mobileNumber))
                parmMap.put('phone', mobileNumber);
            if (!String.isBlank(asurite))
                parmMap.put('asurite', asurite);
            if (!String.isBlank(emplid))
                parmMap.put('emplid', emplid);
            if (!String.isBlank(firstname))
                parmMap.put('firstname', firstname);
            if (!String.isBlank(lastName))
                parmMap.put('lastName', lastName);
            if (!String.isBlank(middlename))
                parmMap.put('middlename', middlename);
            if (!String.isBlank(email))
                parmMap.put('email', email);
            if (!String.isBlank(birthdate))
                parmMap.put('birthdate', birthdate);
            if (!String.isBlank(street))
                parmMap.put('street', street);
            if (!String.isBlank(city))
                parmMap.put('city', city);
            if (!String.isBlank(statecode))
                parmMap.put('statecode', statecode);
            if (!String.isBlank(postalcode))
                parmMap.put('postalcode', postalcode);
            if (!String.isBlank(countrycode))
                parmMap.put('countrycode', countrycode);

            String contactId = getContact(parmMap);
            if (String.isBlank(contactId)) {
                errorEncountered = true;
                errorMessage = 'There was a problem retrieving a Subscriber Key/Contact ID';
            } else {
                subscriberKey = contactId;
            }
        }

        if (!errorEncountered) {
            // Send opt-in message via queueMO
            HTTPRestService_MarketingCloud mc = new HTTPRestService_MarketingCloud();
            String mcResponse = mc.queueMO(subscriberKey, mobileNumber, shortCode, messageText);
            if (String.isBlank(mcResponse)) {
                errorEncountered = true;
                errorMessage = 'There was a problem calling the Marketing Cloud API';
            }
        }

        if (!errorEncountered) {
            oir.success = true;
            oir.message = 'Opted in with Subscriber Key ' + subscriberKey;
        } else {
            oir.success = false;
            oir.message = errorMessage;
        }
        return oir;
    }

    private static String getContact(Map<String, String> parmMap) {
        if (parmMap.size() > 0) {
            String response;
            ContactResponse conResponse;
            ContactPostResponse conPostResponse;

            try {
                HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
                response = contactService.get(parmMap);
            } catch (Exception e) {
                errorMessage = 'Error calling Contact service: ' + e.getMessage();
                return null;
            }
            if (!String.isBlank(response)) {
                // Id is a reserved word, so let's change it
                response = response.replace('"id":', '"contactId":');
                response = response.replace('"contact"', '"contactDetails"');
                try {
                    conResponse = (ContactResponse) JSON.deserialize(response, ContactResponse.class);
                } catch (Exception e) {
                    errorMessage = 'Error parsing Contact service response: ' + e.getMessage();
                    return null;
                }

                if (conResponse.contactDetails != null && conResponse.contactDetails.size() > 0) {
                    if (!String.isBlank(conResponse.contactDetails[0].contactId)) {
                        return conResponse.contactDetails[0].contactId;
                    } else {
                        errorMessage = 'Contact ID was not returned by Contact service';
                        return null;
                    }
                } else {
                    // Contact was not found; call POST method to create
                    try {
                        HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
                        response = contactService.post(parmMap);
                    } catch (Exception e) {
                        errorMessage = 'Error calling Contact POST service: ' + e.getMessage();
                        return null;
                    }
                    if (!String.isBlank(response)) {
                        response = response.replace('"id":', '"contactId":');
                        try {
                            conPostResponse = (ContactPostResponse) JSON.deserialize(
                                response,
                                ContactPostResponse.class
                            );
                        } catch (Exception e) {
                            errorMessage = 'Error parsing Contact POST service response: ' + e.getMessage();
                            return null;
                        }
                        if (
                            conPostResponse.upsertResults != null &&
                            !String.isBlank(conPostResponse.upsertResults[0].contactId)
                        ) {
                            return conPostResponse.upsertResults[0].contactId;
                        } else {
                            errorMessage = 'Error calling Contact Creation service';
                            return null;
                        }
                    } else {
                        errorMessage = 'Error calling Contact Creation service';
                        return null;
                    }
                }
            }
        } else {
            errorMessage = 'No Contact matching fields found';
            return null;
        }
        return null;
    }

    global class OptInRequest {
        public String subscriberKey { get; set; }
        public String mobileNumber { get; set; }
        public String shortCode { get; set; }
        public String messageText { get; set; }
        public String asurite { get; set; }
        public String emplid { get; set; }
        public String firstname { get; set; }
        public String lastName { get; set; }
        public String middlename { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public String birthdate { get; set; }
        public String street { get; set; }
        public String city { get; set; }
        public String statecode { get; set; }
        public String postalcode { get; set; }
        public String countrycode { get; set; }
    }

    global class OptInResult {
        public Boolean success { get; set; }
        public String message { get; set; }
    }

    global class ContactResponse {
        public List<ContactDetail> contactDetails;
        public ContactResponse() {
            contactDetails = new List<ContactDetail>();
        }
    }

    global class ContactDetail {
        public String asurite;
        public String birthdate;
        public String email;
        public String emplid;
        public String firstname;
        public String contactId;
        public String lastname;
        public String middlename;
        public String phone;
        public String city;
        public String country;
        public String countrycode;
        public String street;
        public String postalcode;
        public String state;
        public String statecode;
    }

    global class ContactPostResponse {
        List<ContactUpsertResult> upsertResults;

        public ContactPostResponse() {
            upsertResults = new List<ContactUpsertResult>();
        }
    }

    global class ContactUpsertResult {
        public String created;
        public String contactId;
        public String success;
        public String message;
    }
}
