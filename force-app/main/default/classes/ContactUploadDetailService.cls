public class ContactUploadDetailService {
    private final Map<String, String> columnToFieldNames = new Map<String, String>{
        'ASURITE' => 'ASURITE__c',
        'First Name' => 'First_Name__c',
        'Last Name' => 'Last_Name__c',
        'Email Address' => 'Email__c',
        'Date of Birth' => 'Birthdate__c',
        'Phone' => 'Phone__c',
        'Street Address' => 'Address__c',
        'City' => 'City__c',
        'State' => 'State__c',
        'Country' => 'Country__c',
        'Postal Code' => 'Postal_Code__c',
        'EMPLID' => 'EMPLID__c'
    };

    private Map<Integer, String> columnNames;
    private Id contactUploadId;
    private Id subscriptionId;
    private String subscriberStatus;
    private Map<String, String> subscriberStatusMap;

    public ContactUploadDetailService(Id contactUploadIdIn, Map<Integer, String> columnValueIn) {
        contactUploadId = contactUploadIdIn;
        columnNames = columnValueIn;
    }

    public Contact_Upload_Detail__c createAndValidateRow(List<String> contactInformation) {
        Contact_Upload_Detail__c newUploadDetail = createDetailWithFields(contactInformation);
        ContactUploadValidator validator = new ContactUploadValidator(newUploadDetail);
        validator.validateAndClean();
        return newUploadDetail;
    }

    public Contact_Upload_Detail__c createAndValidateRowForMatcher(List<String> contactInformation) {
        Contact_Upload_Detail__c newUploadDetail = createDetailWithFields(contactInformation);
        ContactUploadValidator validator = new ContactUploadValidator(newUploadDetail);
        validator.validateDataForMatcher();
        return newUploadDetail;
    }

    private Contact_Upload_Detail__c createDetailWithFields(List<String> contactInformation) {
        Contact_Upload_Detail__c detailToPopulate = new Contact_Upload_Detail__c(
            Processing_Notes__c = ' ',
            Contact_Upload__c = contactUploadId,
            Status__c = 'Success',
            Subscription__c = subscriptionId,
            Subscriber_Status__c = subscriberStatus,
            Source_Line__c = String.join(contactInformation, ',')
        );

        for (Integer i = 0; i < contactInformation.size(); i++) {
            String columnValue = contactInformation[i];
            String fieldName = columnToFieldNames.get((columnNames.get(i)).removeStart('\uFEFF'));
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
            uploadDetail.Processing_Notes__c = (uploadDetail.Processing_Notes__c + 'Subscription not present. ')
                .left(255);
        } else {
            subToCreate = new Subscriber__c(
                Contact__c = uploadDetail.Contact__c,
                Subscription__c = uploadDetail.Subscription__c,
                Unique_Key__c = String.valueOf(uploadDetail.Subscription__c).left(15) +
                    '.' +
                    String.valueOf(uploadDetail.Contact__c).left(15)
            );
            if (isUnsubbed(subToCreate)) {
                subToCreate.Subscriber_Status__c = 'Unsubscribed';
                if (uploadDetail.Subscriber_Status__c == 'Subscribed') {
                    uploadDetail.Processing_Notes__c += ' Subscriber Status cannot be updated from Unsubscribed To Subscribed.';
                }
            } else {
                subToCreate.Subscriber_Status__c = uploadDetail.Subscriber_Status__c;
            }
        }
        return subToCreate;
    }

    public void createSubscriberStatusMap(List<Contact_Upload_Detail__c> details) {
        List<Id> contactsInDetails = new List<Id>();
        for (Contact_Upload_Detail__c cud : details) {
            contactsInDetails.add(cud.Contact__c);
        }
        List<Subscriber__c> currentSubscriber = [
            SELECT Unique_Key__c, Subscriber_Status__c
            FROM Subscriber__c
            WHERE Contact__c IN :contactsInDetails AND Subscription__c = :subscriptionId
        ];
        subscriberStatusMap = new Map<String, String>();
        for (Subscriber__c sub : currentSubscriber) {
            subscriberStatusMap.put(sub.Unique_Key__c, sub.Subscriber_Status__c);
        }
    }

    public void setSubscriptionId(Id subscriptionId) {
        this.subscriptionId = subscriptionId;
    }

    public void setSubscriberStatus(String subscriberStatus) {
        this.subscriberStatus = subscriberStatus;
    }

    private Boolean isUnsubbed(Subscriber__c subToCheck) {
        return subscriberStatusMap.get(subToCheck.Unique_Key__c) != null &&
            subscriberStatusMap.get(subToCheck.Unique_Key__c) == 'Unsubscribed';
    }
}
