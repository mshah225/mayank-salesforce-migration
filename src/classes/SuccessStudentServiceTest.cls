@isTest
private class SuccessStudentServiceTest {
    private static final Integer COACHING_STUDENTS_TO_CREATE = 10;
    private static final Integer ADVISING_STUDENTS_TO_CREATE = 10;
    private static List<Success_Student__c> successStudents;
    
    static {
        successStudents = new List<Success_Student__c>([
            SELECT Id, Success_Resource__c, OwnerId
            FROM Success_Student__c
        ]);
    }

    @testSetup
    private static void testSetup () {
        TestDataFactory.createFunctionalGroupWithCategory('ASU Coach Outreach', 'Ad Hoc', 'N/A');
        
        List<Contact> newContacts = TestDataFactory.createContacts(COACHING_STUDENTS_TO_CREATE + ADVISING_STUDENTS_TO_CREATE);
        insert newContacts;

        List<User> resourceUsers = [
            SELECT Id
            FROM User
            WHERE ProfileId = :IDHelper.getPID('System Administrator')
            	AND IsActive = true
            LIMIT 2
        ];
        
        List<Success_Resource__c> newResources = new List<Success_Resource__c>();
        
        for (User resourceUser : resourceUsers) {
            newResources.add(new Success_Resource__c(
            	Resource__c = resourceUser.Id,
                RecordTypeId = IDHelper.getRTID('Success_Resource__c', 'Coach')
            ));
        }
        
        insert newResources;
        
        List<Success_Student__c> newSuccessStudents = new List<Success_Student__c>();
        
        for (Integer x = 0; x < COACHING_STUDENTS_TO_CREATE; x++) {
            newSuccessStudents.add(new Success_Student__c(
            	Success_Resource__c = newResources[0].Id,
                Student__c = newContacts[x].Id,
                Coaching_Student__c = true
            ));
        }
        
        for (Integer x = 0; x < ADVISING_STUDENTS_TO_CREATE; x++) {
            newSuccessStudents.add(new Success_Student__c(
            	Success_Resource__c = newResources[0].Id,
                Student__c = newContacts[(COACHING_STUDENTS_TO_CREATE-1) + x].Id,
                Coaching_Student__c = false
            ));
        }
        
        insert newSuccessStudents;
    }
    
    @isTest
    private static void studentTransferTest() {
        Id newResourceId = [
            SELECT Id
            FROM Success_Resource__c
            WHERE Id != :successStudents[0].Success_Resource__c
        ].Id;
        
        for (Success_Student__c successStudent : successStudents) {
            successStudent.Success_Resource__c = newResourceId;
        }
        
        test.startTest();
        update successStudents;
        test.stopTest();
        
        // Should only create cases for coaching students, not advisor students
        System.assertEquals(COACHING_STUDENTS_TO_CREATE, [SELECT Id FROM Case].size());
    }
    
    @isTest
    private static void deleteOnlyCoverageTest() {
        delete successStudents;
    }
    
    @isTest
    private static void undeleteOnlyCoverageTest() {
        delete successStudents;
        undelete successStudents;
    }
}