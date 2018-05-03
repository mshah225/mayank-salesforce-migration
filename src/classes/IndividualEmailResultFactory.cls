@isTest
public class IndividualEmailResultFactory {
    
    public class DefaultIndividualEmailResult extends TestFactory {
        public DefaultIndividualEmailResult() {
            super(new et4ae5__IndividualEmailResult__c(
                Name = 'IER-',
                View_Email_URL__c = ''
            ));
            this.addToFieldsToIncrement('Name');
        }
        
        public void setRealtedContacts(List<Contact> relatedContacts) {
            this.setRelatedObject('et4ae5__Contact__c', relatedContacts);
        }
        
        public void setRealtedLeads(List<Lead> relatedLeads) {
            this.setRelatedObject('et4ae5__Lead__c', relatedLeads);
        }
        
        public void setRealtedSendDefinitions(List<et4ae5__SendDefinition__c> relatedSendDefinitions) {
            this.setRelatedObject('et4ae5__SendDefinition__c', relatedSendDefinitions);
        }
    }
}
