public with sharing class BatchContactUpload implements Database.batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private Id attachmentId;
    private String contactUploadId;
    private static final Integer SCOPE_SIZE = 50; //Batch limit of 100 callouts; 50 allows for 2 per record (1 GET and 1 POST)
    private Boolean errorEncountered = false;
    private final Map<Integer, String> columnMap = new Map<Integer, String> {
        0 => 'Contact__c', 
        1 => 'ASURITE__c', 
        2 => 'First_Name__c', 
        3 => 'Last_Name__c', 
        4 => 'Email__c', 
        5 => 'Campaign__c', 
        6 => 'Subscription__c',
        7 => 'Birthdate__c', 
        8 => 'Address__c', 
        9 => 'City__c', 
        10 => 'State__c', 
        11 => 'Postal_Code__c', 
        12 => 'Country__c', 
        13 => 'Phone__c'
    };
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

    public BatchContactUpload(Id attachmentId) {
        this.attachmentId = attachmentId;
    }

    public Iterable<String> start(Database.BatchableContext batchableContext) {
        List<Attachment> attList = [SELECT Body, ParentId FROM Attachment WHERE Id = :attachmentId];
        if (!attList.isEmpty()) {
            contactUploadId = attList[0].ParentId;
            Contact_Upload__c cu = new Contact_Upload__c(
                Id = contactUploadId, 
                Status__c = 'Processing');
            update cu;
            return new CsvIterator(attList[0].Body.toString(), '\r');
        } else {
            return null;
        }
    }

    public void execute(Database.BatchableContext batchableContext, List<String> scope) {
        String csvFile = '';
        for (String row : scope) {
            csvFile += row + '\r';
        }
        
        List<List<String>> csvLines = CsvReader.readCsvFile(Blob.valueOf(csvFile));
        Set<String> campaignIds = new Set<String>();
        List<Contact_Upload_Detail__c> cudList = new List<Contact_Upload_Detail__c>();
        for (List<String> lineValues: csvLines) {
            // Skip the Header row
            if (lineValues[0].contains('Contact')) {
                continue;
            }
            Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
                Processing_Notes__c = ' ',
                Contact_Upload__c = contactUploadId,
                Status__c = 'Success',
                Source_Line__c = String.join(lineValues, ',')
            );
            for (Integer i = 0; i < lineValues.size(); i++) {
                String val = lineValues[i];
                if (!String.isBlank(val)) {
                    val = val.trim();
                    try {
                        // Validate IDs from the source file to avoid Malformed ID exceptions upon insert
                        if (columnMap.get(i) == 'Contact__c') {
                            Id valId = Id.ValueOf(val); // Throws exception on invalid ID
                            System.assertEquals(Schema.Contact.SobjectType, valId.getSobjectType());
                        } else if (columnMap.get(i) == 'Subscription__c') {
                            Id valId = Id.ValueOf(val); // Throws exception on invalid ID
                            System.assertEquals(Schema.Subscription__c.SobjectType, valId.getSobjectType());
                        } else if (columnMap.get(i) == 'Campaign__c') {
                            Id valId = Id.ValueOf(val); // Throws exception on invalid ID
                            System.assertEquals(Schema.Campaign.SobjectType, valId.getSobjectType());
                            campaignIds.add(val);
                        }

                        // Be sure the phone number is digits-only
                        if (columnMap.get(i) == 'Phone__c') {
                            val = val.replaceAll('[^0-9]', '');
                        }

                        if (columnMap.get(i).contains('__c')) {
                            cud.put(columnMap.get(i), val);
                        }
                    } catch (Exception e) {
                        setDetailError(cud, 'Exception: ' + e.getMessage());
                    }
                }
           }
           cudList.add(cud);
        }

        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([
            SELECT Id, Subscription__c 
            FROM Campaign 
            WHERE Id IN :campaignIds
        ]);

        List<Subscriber__c> subscriberList = new List<Subscriber__c>();
        for (Contact_Upload_Detail__c cud: cudList) {
            // If a Campaign was supplied, update the record with its corresponding Subscription
            if (cud.Campaign__c != null && cud.Subscription__c == null && campaignMap.containsKey(cud.Campaign__c)) {
                cud.Subscription__c = campaignMap.get(cud.Campaign__c).Subscription__c;
            }
            // Validate the Contact Upload Detail record
            if (cud.Subscription__c == null && cud.Campaign__c == null) {
                setDetailError(cud, 'Either Subscription or Campaign must be specified');
            }
            if (cud.Contact__c == null && cud.Status__c != 'Error') {
                getContact(cud);
            }
            if (cud.Contact__c != null && cud.Subscription__c != null) {
                subscriberList.add(new Subscriber__c(
                    Contact__c = cud.Contact__c,
                    Subscription__c = cud.Subscription__c,
                    Unique_Key__c = String.valueOf(cud.Subscription__c).left(15) + '.' + 
                        String.valueOf(cud.Contact__c).left(15),
                    Subscriber_Status__c = 'Subscribed')
                );
            }
        }
        System.debug('cudList: ' + cudList);
        if (subscriberList.size() > 0) {
            upsert subscriberList Unique_Key__c;
        }
        Map<String, Id> subKeyToSubIdMap = new Map<String, Id>();

        for (Subscriber__c subscriber: subscriberList) {
            subKeyToSubIdMap.put(subscriber.Unique_Key__c, subscriber.Id);
        }
        for (Contact_Upload_Detail__c cud: cudList) {
            if (cud.Status__c == 'Error' || (cud.Contact__c == null || cud.Subscription__c == null)) {
                continue;
            }
            String uniqueKey = String.valueOf(cud.Subscription__c).left(15) + '.' + 
                String.valueOf(cud.Contact__c).left(15);
            if (subKeyToSubIdMap.containsKey(uniqueKey)) {
                cud.Subscriber__c = subKeyToSubIdMap.get(uniqueKey);
            }
        }

        if (cudList.size() > 0) {
            insert cudList;
        }
    }

    private Boolean getContact(Contact_Upload_Detail__c cud) {
        Map<String, String> parmMap = new Map<String, String>();
        for (String key : matchingFieldMap.keySet()) {
            if (!String.isBlank(String.valueOf(cud.get(key)))) {
                parmMap.put(matchingFieldMap.get(key), EncodingUtil.urlEncode(String.valueOf(cud.get(key)),'UTF-8'));
            }
        }
        System.debug('parmMap: ' + parmMap);

        if (parmMap.size() > 0) {
            String response;
            ContactResponse conResponse;
            ContactPostResponse conPostResponse;

            try {
                HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
                response = contactService.get(parmMap);
            } catch (Exception e) {
                setDetailError(cud, 'Error calling Contact service: ' + e.getMessage());
                return false;
            }
            if (!String.isBlank(response)) {
                // Id is a reserved word, so let's change it
                response = response.replace('"id":', '"contactId":');
                response = response.replace('"contact"','"contactDetails"');
                system.debug('response: ' + response);
                try {
                    conResponse = (ContactResponse)JSON.deserialize(response, ContactResponse.class);
                } catch (Exception e) {
                    setDetailError(cud, 'Error parsing Contact service response: ' + e.getMessage());
                    return false;
                }
                System.debug('conResponse: ' + conResponse);

                if (conResponse.contactDetails != null && conResponse.contactDetails.size() > 0) {
                    if (!String.isBlank(conResponse.contactDetails[0].contactId)) {
                        cud.Contact__c = conResponse.contactDetails[0].contactId;
                        cud.Processing_Notes__c += 'Found existing Contact ID: ' + conResponse.contactDetails[0].contactId;
                        return true;
                    } else {
                        setDetailError(cud, 'Contact ID was not returned by Contact service');
                        return false;
                    }
                } else {
                    // Contact was not found; call POST method to create
                    try {
                        HTTPRestService_EnterpriseContact contactService = new HTTPRestService_EnterpriseContact();
                        response = contactService.post(parmMap);
                    } catch (Exception e) {
                        setDetailError(cud, 'Error calling Contact POST service: ' + e.getMessage());
                        return false;
                    }
                    if (!String.isBlank(response)) {
                        response = response.replace('"id":', '"contactId":');
                        try {
                            conPostResponse = (ContactPostResponse)JSON.deserialize(response, ContactPostResponse.class);
                        } catch (Exception e) {
                            setDetailError(cud, 'Error parsing Contact POST service response: ' + e.getMessage());
                            return false;
                        }
                        System.debug('conPostResponse: ' + conPostResponse);
                        if (conPostResponse.upsertResults != null && !String.isBlank(conPostResponse.upsertResults[0].contactId)) {
                            cud.Contact__c = conPostResponse.upsertResults[0].contactId;
                            cud.Processing_Notes__c += 'Created new Contact ID: ' + conPostResponse.upsertResults[0].contactId;
                            return true;
                        } else {
                            setDetailError(cud, 'Error calling Contact Creation service');
                            return false;
                        }
                    } else {
                        setDetailError(cud, 'Error calling Contact Creation service');
                        return false;
                    }
                }
            }
        } else {
            setDetailError(cud, 'No Contact matching fields found');
            return false;
        }
        return true;
    }

    private void setDetailError(Contact_Upload_Detail__c cud, String errorMsg) {
        errorEncountered = true;
        cud.Status__c = 'Error';
        cud.Processing_Notes__c = (cud.Processing_Notes__c == null ? errorMsg : cud.Processing_Notes__c + errorMsg) + '; ';
    }

    public void finish(Database.BatchableContext batchableContext) {
        String errorStatus = (errorEncountered ? 'Errors' : 'No Errors');

        if (contactUploadId != null) {
            Contact_Upload__c cu = new Contact_Upload__c(Id = contactUploadId, Status__c = 'Complete with ' + errorStatus);
            update cu;
        }
    }

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
}