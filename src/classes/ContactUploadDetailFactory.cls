@isTest
public class ContactUploadDetailFactory {
    public class DefaultContactUploadDetail extends TestFactory {
        public DefaultContactUploadDetail(Contact_Upload__c connectedUpload) {
            super(
                new Contact_Upload_Detail__c(
                    Contact_Upload__c = connectedUpload.Id,
                    First_Name__c = 'Alice',
                    Last_Name__c = 'Test',
                    Email__c = 'atest@example.com',
                    Subscription__c = 'a28000000000000'
                )
            );
        }
    }

    public class ContactUploadDetailWithEMPLID extends TestFactory {
        public ContactUploadDetailWithEMPLID(Contact_Upload__c connectedUpload) {
            super(
                new Contact_Upload_Detail__c(
                    Contact_Upload__c = connectedUpload.Id,
                    EMPLID__c = '100000000',
                    First_Name__c = 'Alice',
                    Last_Name__c = 'Test',
                    Email__c = 'atest@example.com',
                    Subscription__c = 'a28000000000000'
                )
            );
            this.addToFieldsToIncrement('EMPLID__c');
        }
    }
}
