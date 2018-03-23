@isTest
public with sharing class SuccessStudentFactory {
    public class DefaultAdvisingStudent extends TestFactory {
        public DefaultAdvisingStudent() {
            super(new Success_Student__c(
            	Coaching_Student__c = false
            ));
        }
        
        public void setRelatedSuccessResource(List<Success_Resource__c> successResources) {
            this.setRelatedObject('Success_Resource__c', successResources);
        }
        
        public void setRelatedStudentContact(List<Contact> studentContact) {
            this.setRelatedObject('Student__c', studentContact);
        }
    }
    
    public class DefaultCoachingStudent extends TestFactory {
        public DefaultCoachingStudent() {
            super(new Success_Student__c(
                Coaching_Student__c = true
            ));
        }
        
        public void setRelatedSuccessResource(List<Success_Resource__c> successResources) {
            this.setRelatedObject('Success_Resource__c', successResources);
        }
        
        public void setRelatedStudentContact(List<Contact> studentContact) {
            this.setRelatedObject('Student__c', studentContact);
        }
    }
}