@isTest
public class CoachingStudentFactory {
    public class DefaultSuccessStudent extends TestFactory {
        public DefaultSuccessStudent() {
            super(new Success_Student__c(
            	Coaching_Student__c = true
            ));
        }
    }
}