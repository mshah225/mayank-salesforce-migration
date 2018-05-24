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
    
    public Contact_Upload_Detail__c createAndValidateRow(List<String> contactInformation) {
        Contact_Upload_Detail__c newUploadDetail = createDetailWithFields(contactInformation);
        ContactUploadValidator validator = new ContactUploadValidator(newUploadDetail);
        validator.validateAndClean();
        return newUploadDetail;
    }
    
    private Contact_Upload_Detail__c createDetailWithFields(List<String> contactInformation) {
         Contact_Upload_Detail__c detailToPopulate = new Contact_Upload_Detail__c(
            Processing_Notes__c = ' ',
            Contact_Upload__c = contactUploadId,
            Status__c = 'Success',
            Source_Line__c = String.join(contactInformation, ','));
        
        for (Integer i = 0; i < contactInformation.size(); i++) {
            String columnValue = contactInformation[i];
            String fieldName = columnToFieldNames.get(columnNames.get(i));
            if (!String.isBlank(columnValue) && fieldName != null) {
                columnValue = columnValue.trim();
                detailToPopulate.put(fieldName, columnValue);
            }
       }
       
       return detailToPopulate;
    }
    
    public Subscriber__c createSubscriberForUploadDetail(Contact_Upload_Detail__c uploadDetail) {
        Subscriber__c subToCreate;
        if (uploadDetail.Contact__c == null) {
            uploadDetail.Status__c = 'Error';
            uploadDetail.Processing_Notes__c = (uploadDetail.Processing_Notes__c + 'Contact not present. ').left(255);
        } else if (uploadDetail.Subscription__c == null) {
            uploadDetail.Status__c = 'Error';
            uploadDetail.Processing_Notes__c = (uploadDetail.Processing_Notes__c + 'Subscription not present. ').left(255);
        } else {
            subToCreate = new Subscriber__c(
                Contact__c = uploadDetail.Contact__c,
                Subscription__c = uploadDetail.Subscription__c,
                Unique_Key__c = String.valueOf(uploadDetail.Subscription__c).left(15) + '.' + 
                    String.valueOf(uploadDetail.Contact__c).left(15), 
                Subscriber_Status__c = 'Subscribed');
        }
        return subToCreate;
    }
}