@isTest
public class SendDefinitionFactory {
    public class DefaultSendDefinition extends TestFactory {
        public DefaultSendDefinition() {
            super(new et4ae5__SendDefinition__c(et4ae5__JobId__c = 'jobId'));
            this.addToFieldsToIncrement('et4ae5__JobId__c');
        }

        public void setRelatedBusinessUnits(List<et4ae5__Business_Unit__c> relatedBusinessUnits) {
            this.setRelatedObject('et4ae5__Business_Unit__c', relatedBusinessUnits);
        }
    }
}
