public class SuccessStudentService {
    private static final Date TOMORROW = System.today().addDays(1);
    
    public static List<Success_Student__c> getStudentsRequiringOutreach(Map<Id, Success_Student__c> successStudents, Map<Id, Success_Student__c> oldMap) {
        List<Success_Student__c> studentsRequiringOutreach = new List<Success_Student__c>();
        
        for (Success_Student__c successStudent : successStudents.values()) {
            if (successStudent.Success_Resource__c != oldmap.get(successStudent.Id).Success_Resource__c &&
                successStudent.Coaching_Student__c) {
                studentsRequiringOutreach.add(successStudent);
            }
        }
        
        return studentsRequiringOutreach;
    }
    
    public static List<Case> createOutreachCases (List<Success_Student__c> successStudents) {
        Id coachCaseRecordTypeId = IDHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach');
        List<Case> newCases = new List<Case>();
        
        Case_Classification__c classification = [
            SELECT Id, (
                SELECT Id
                FROM Case_Classifications__r
                WHERE Name = 'Ad Hoc'
                LIMIT 1
            )
            FROM Case_Classification__c
            WHERE Name = 'ASU Coach Outreach'
            LIMIT 1
        ];
        
        Id asuCoachOutreachGroup = classification.Id;
        Id adHocCategory = classification.Case_Classifications__r[0].Id;
        
        for (Success_Student__c successStudent : successStudents) {
            Case newCase = new Case(
                CC_Functional_Group__c = asuCoachOutreachGroup,
                CC_Category__c = adHocCategory,
                Description = 'Transferred',
                Followup_Date__c = TOMORROW,
                Origin__c = 'Automated',
                Priority = '3 - Normal Priority',
                Status = 'New',
                Subject = 'New Student Assigned',
                Type = 'System Generated',
                Visible_by_Contact__c = false,
                ContactId = successStudent.Student__c,
                RecordTypeId = coachCaseRecordTypeId,
                OwnerId = successStudent.OwnerId
            );
            
            newCases.add(newCase);
        }
        
        return newCases;  
    }
}