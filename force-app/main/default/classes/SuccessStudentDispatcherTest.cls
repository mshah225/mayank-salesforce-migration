@isTest
private class SuccessStudentDispatcherTest {
    /*    private static final Integer COACHING_STUDENTS_TO_CREATE = 10;
    private static final Integer ADVISING_STUDENTS_TO_CREATE = 5;
    private static List<Success_Student__c> successStudents;
    
    private static void queryTestData() {
        successStudents = new List<Success_Student__c>([
            SELECT Id, Success_Resource__c, OwnerId
            FROM Success_Student__c
        ]);
    }

    @testSetup
    private static void testSetup () {
        TestDataFactory.createFunctionalGroupWithCategory('ASU Coach Outreach', 'Ad Hoc', 'N/A');
        
        ContactFactory.DefaultContact defaultContactFactory = new ContactFactory.DefaultContact();
        List<Contact> coachingContacts = defaultContactFactory.create(COACHING_STUDENTS_TO_CREATE);
        insert coachingContacts;
        
        List<Contact> advisingContacts = defaultContactFactory.create(ADVISING_STUDENTS_TO_CREATE);
        insert advisingContacts;

        List<User> resourceUsers = [
            SELECT Id
            FROM User
            WHERE ProfileId = :IDHelper.getPID('System Administrator')
            	AND IsActive = true
            LIMIT 2
        ];
        
        SuccessResourceFactory.DefaultCoachingResource coachingResourceFactory = new SuccessResourceFactory.DefaultCoachingResource();
        coachingResourceFactory.setRelatedObject('Resource__c', resourceUsers);
        List<Success_Resource__c> oneExtraResource = coachingResourceFactory.create(2);
        insert oneExtraResource;
        
        List<Success_Student__c> newSuccessStudents = new List<Success_Student__c>();
        SuccessStudentFactory.DefaultCoachingStudent coachingStudentFactory = new SuccessStudentFactory.DefaultCoachingStudent();
        coachingStudentFactory.setRelatedSuccessResource(new List<Success_Resource__c> {oneExtraResource[0]});
        coachingStudentFactory.setRelatedStudentContact(coachingContacts);
        newSuccessStudents.addAll((List<Success_Student__c>) coachingStudentFactory.create(COACHING_STUDENTS_TO_CREATE));
        
        SuccessStudentFactory.DefaultAdvisingStudent advisingStudentFactory = new SuccessStudentFactory.DefaultAdvisingStudent();
        advisingStudentFactory.setRelatedSuccessResource(new List<Success_Resource__c> {oneExtraResource[0]});
        advisingStudentFactory.setRelatedStudentContact(advisingContacts);
        newSuccessStudents.addAll((List<Success_Student__c>) advisingStudentFactory.create(ADVISING_STUDENTS_TO_CREATE));
        
        insert newSuccessStudents;
    }
    
    @isTest
    private static void studentTransferTest() {
        queryTestData();
        Id transferToResourceId = [
            SELECT Id
            FROM Success_Resource__c
            WHERE Id != :successStudents[0].Success_Resource__c
            LIMIT 1
        ].Id;
        
        for (Success_Student__c successStudent : successStudents) {
            successStudent.Success_Resource__c = transferToResourceId;
        }
        
        test.startTest();
        update successStudents;
        test.stopTest();
        
        System.assertEquals(COACHING_STUDENTS_TO_CREATE, [SELECT Id FROM Case].size());
        System.assertNotEquals(ADVISING_STUDENTS_TO_CREATE, [SELECT Id FROM Case].size());
    }
    
    @isTest
    private static void deleteOnlyCoverageTest() {
        queryTestData();
        
        Test.startTest();
        delete successStudents;
        Test.stopTest();
        
        System.assert(TRUE);
    }
    
    @isTest
    private static void undeleteOnlyCoverageTest() {
        queryTestData();
        delete successStudents;
        
        Test.startTest();
        undelete successStudents;
        Test.stopTest();
        
        System.assert(TRUE);
    }*/
}
