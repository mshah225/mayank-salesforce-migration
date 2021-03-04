@isTest
public with sharing class SuccessStudentFactory {
    public class DefaultAdvisingStudent extends TestFactory {
        public DefaultAdvisingStudent() {
            super(new Success_Student__c(Coaching_Student__c = false));
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
            super(new Success_Student__c(Coaching_Student__c = true));
        }

        public void setRelatedSuccessResource(List<Success_Resource__c> successResources) {
            this.setRelatedObject('Success_Resource__c', successResources);
        }

        public void setRelatedStudentContact(List<Contact> studentContact) {
            this.setRelatedObject('Student__c', studentContact);
        }
    }

    public class DefaultSuccessPodStudent extends TestFactory {
        public DefaultSuccessPodStudent(Id successPodId, Id contactId) {
            super(
                new Success_Student__c(
                    Is_Active__c = true,
                    Success_Pod__c = successPodId,
                    Student__c = contactId,
                    Coaching_Student__c = false
                )
            );
        }
    }

    public List<Success_Student__c> createSuccessPodStudents(List<Success_Pod__c> pods, Integer numberOfStudents) {
        List<Success_Student__c> successStudents = new List<Success_Student__c>();
        Map<Id, List<Contact>> successPodRelatedContacts = new Map<Id, List<Contact>>();
        ContactFactory.DefaultContact contactMaker = new ContactFactory.DefaultContact();

        for (Success_Pod__c sp : pods) {
            successPodRelatedContacts.put(sp.Id, new List<Contact>());
            successPodRelatedContacts.get(sp.Id).addAll((List<Contact>) contactMaker.create(numberOfStudents));
        }

        for (Id i : successPodRelatedContacts.keySet()) {
            insert successPodRelatedContacts.get(i);
        }

        for (Success_Pod__c sp : pods) {
            for (Contact c : successPodRelatedContacts.get(sp.Id)) {
                DefaultSuccessPodStudent successStudentMaker = new DefaultSuccessPodStudent(sp.Id, c.Id);
                successStudents.add((Success_Student__c) successStudentMaker.create(1)[0]);
            }
        }
        insert successStudents;
        return successStudents;
    }
}
