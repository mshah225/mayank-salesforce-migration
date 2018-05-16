public class ContactUploadDetailService {

    private final Map<String, String> columnToFieldNames = new Map<String, String> {
        'ASURITE' => 'ASURITE__c',
        'First Name' => 'First_Name__c',
        'Last Name' => 'Last_Name__c',
        'Email Address' => 'Email__c',
        'Date of Birth' => 'Birthdate__c',
        'Phone' => 'Phone__c',
        'Street Address' => 'Address__c',
        'City' => 'City__c',
        'State Code' => 'State__c',
        'Country Code' => 'Country__c',
        'Postal Code' => 'Postal_Code__c',
        'Subscription ID' => 'Subscription__c',
        'EMPLID' => 'EMPLID__c'
    };

    private Map<Integer, String> columnNames;
    private Id contactUploadId;
    
    public ContactUploadDetailService (Id contactUploadIdIn, Map<Integer, String> columnValueIn) {
        contactUploadId = contactUploadIdIn;
        columnNames = columnValueIn;
    }
    
    public Contact_Upload_Detail__c createContactFromRow(List<String> contactInformation) {
        Contact_Upload_Detail__c contactUpLoadDetailToCreate = new Contact_Upload_Detail__c(
                Processing_Notes__c = ' ',
                Contact_Upload__c = contactUploadId,
                Status__c = 'Success',
                Source_Line__c = String.join(contactInformation, ',')
        );
        Boolean validRow = true;
        for (Integer i = 0; i < contactInformation.size(); i++) {
            String columnValue = contactInformation[i];
            String fieldName = columnToFieldNames.get(columnNames.get(i));
            if (!String.isBlank(columnValue)) {
                columnValue = columnValue.trim();
                
                if (fieldName == 'Contact__c') {
                    validRow = UploadContactValidator.validateId(columnValue, Schema.Contact.sObjectType);
                } else if (fieldName == 'Subscription__c') {
                    validRow = UploadContactValidator.validateId(columnValue, Schema.Subscription__c.sObjectType);
                }

                if (fieldName == 'Phone__c') {
                    columnValue = UploadContactValidator.cleanPhoneNumber(columnValue);
                }

                contactUpLoadDetailToCreate.put(fieldName, columnValue);
            }
       }
       if (!validRow) {
           contactUpLoadDetailToCreate.Status__c = 'Error';
       }
       
       return contactUpLoadDetailToCreate;
    }
    
    public Subscriber__c createSubscriberForCUD(Contact_Upload_Detail__c cud) {
        Subscriber__c subToCreate;
        if (cud.Subscription__c == null) {
            cud.Status__c = 'Error';
        } else if (cud.Contact__c == null) {
            ContactUploadSearcher contactMatcher = new ContactUploadSearcher();
            contactMatcher.getContact(cud);
        }
        if (cud.Contact__c != null && cud.Subscription__c != null) {
            subToCreate = new Subscriber__c(
                Contact__c = cud.Contact__c,
                Subscription__c = cud.Subscription__c,
                Unique_Key__c = String.valueOf(cud.Subscription__c).left(15) + '.' + 
                    String.valueOf(cud.Contact__c).left(15), 
                Subscriber_Status__c = 'Subscribed');
        }
        return subToCreate;
    }
    
    public Contact_Upload_Detail__c addSubscriberToDetail(Contact_Upload_Detail__c cudToUpdate, Map<String, Id> subKeyToSubIdMap) {
        if (UploadContactValidator.validContactUploadDetail(cudToUpdate)) {
            String uniqueKey = String.valueOf(cudToUpdate.Subscription__c).left(15) + '.' + 
            String.valueOf(cudToUpdate.Contact__c).left(15);
            if (subKeyToSubIdMap.containsKey(uniqueKey)) {
                cudToUpdate.Subscriber__c = subKeyToSubIdMap.get(uniqueKey);
            }
        }
        return cudToUpdate;
    }
}