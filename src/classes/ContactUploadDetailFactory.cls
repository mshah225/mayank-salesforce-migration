@isTest
public class ContactUploadDetailFactory {

    public class DefaultContactUploadDetail extends TestFactory {
        public DefaultContactUploadDetail(Contact_Upload__c connectedUpload) {
            super(new Contact_Upload_Detail__c(
                Contact_Upload__c = connectedUpload.Id
            ));
        }
    }
    
    public class ContactUploadDetailWithEMPLID extends TestFactory {
        public ContactUploadDetailWithEMPLID(Contact_Upload__c connectedUpload) {
            super(new Contact_Upload_Detail__c(
                Contact_Upload__c = connectedUpload.Id,
                EMPLID__c = '100000000'
            ));
            this.addToFieldsToIncrement('EMPLID__c');
        }
    }
}