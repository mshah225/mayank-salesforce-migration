@isTest
public with sharing class SuccessStudentFactory {
    public class DefaultSuccessStudent extends TestFactory {
        public DefaultSuccessStudent() {
            super(new Success_Student__c(
            	Coaching_Student__c = false
            ));
        }
    }
    
    public class DefaultCoachingStudent extends TestFactory {
        public DefaultCoachingStudent() {
            super(new Success_Student__c(
                Coaching_Student__c = true
            ));
        }
    }
}