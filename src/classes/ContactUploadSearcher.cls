public class ContactUploadSearcher {
    public class ContactResponse {
        public List<ContactDetail> contactDetails;
        public ContactResponse() {
            contactDetails = new List<ContactDetail>();
        }
    }

    public class ContactDetail {
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

    public class ContactPostResponse {
        List<ContactUpsertResult> upsertResults;

        public ContactPostResponse() {
            upsertResults = new List<ContactUpsertResult>();
        }
    }

    public class ContactUpsertResult {
        public String created;
        public String contactId;
        public String success;
        public String message;
    }
    
    private final Map<String, String> matchingFieldMap = new Map<String, String> {
        'ASURITE__c' => 'asurite',
        'First_Name__c' => 'firstname',
        'Last_Name__c' => 'lastname',
        'Email__c' => 'email',
        'Birthdate__c' => 'birthdate',
        'Phone__c' => 'phone',
        'Address__c' => 'street',
        'City__c' => 'city',
        'State__c' => 'statecode',
        'Country__c' => 'countrycode',
        'Postal_Code__c' => 'postalcode'
    };
    
    public Boolean getContact(Contact_Upload_Detail__c cud) {
        Map<String, String> parmMap = new Map<String, String>();
        for (String key : matchingFieldMap.keySet()) {
            if (!String.isBlank(String.valueOf(cud.get(key)))) {
                parmMap.put(matchingFieldMap.get(key), String.valueOf(cud.get(key)));
            }
        }

        if (parmMap.size() > 0) {
            String response;
            ContactResponse conResponse = new ContactResponse();
            ContactPostResponse conPostResponse = new ContactPostResponse();

            try {
                HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
                response = contactService.get(parmMap);
            } catch (Exception e) {
                return false;
            }
            if (!String.isBlank(response)) {
                // Id is a reserved word, so let's change it
                response = response.replace('"id":', '"contactId":');
                response = response.replace('"contact"','"contactDetails"');
                try {
                    conResponse = (ContactResponse)JSON.deserialize(response, ContactResponse.class);
                } catch (Exception e) {
                    return false;
                }

                if (conResponse.contactDetails != null && !conResponse.contactDetails.isEmpty()) {
                    if (!String.isBlank(conResponse.contactDetails[0].contactId)) {
                        cud.Contact__c = conResponse.contactDetails[0].contactId;
                        cud.Processing_Notes__c += 'Found existing Contact ID: ' + conResponse.contactDetails[0].contactId;
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return createContact(parmMap, cud);
                }
            }
        } else {
            return false;
        }
        return true;
    }
    
    private boolean createContact(Map<String, String> parameterMap, Contact_Upload_Detail__c cud) {
        // Contact was not found; call POST method to create
        ContactPostResponse conPostResponse;
        String response;
        try {
            HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
            response = contactService.post(parameterMap);
        } catch (Exception e) {
            return false;
        }
        if (!String.isBlank(response)) {
            response = response.replace('"id":', '"contactId":');
            try {
                conPostResponse = (ContactPostResponse)JSON.deserialize(response, ContactPostResponse.class);
            } catch (Exception e) {
                return false;
            }
            if (conPostResponse.upsertResults != null && !String.isBlank(conPostResponse.upsertResults[0].contactId)) {
                cud.Contact__c = conPostResponse.upsertResults[0].contactId;
                cud.Processing_Notes__c += 'Created new Contact ID: ' + conPostResponse.upsertResults[0].contactId;
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}