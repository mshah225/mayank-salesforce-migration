@isTest
public class SuccessResourceFactory {
    public class DefaultCoachingResource extends TestFactory {
        public DefaultCoachingResource() {
            super(new Success_Resource__c(
                RecordTypeId = IdHelper.getRecordTypeId('Success_Student__c', '')
            ));
        }
    }
}
