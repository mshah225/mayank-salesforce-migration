public class SuccessStudentService {
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
    
    public static void createOutreachCases (List<Success_Student__c> successStudents) {
        Id coachCaseRTID = IDHelper.getRTID('Case', 'ASU_Coach_Outreach');
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
        
        for (Success_Student__c successStudent : successStudents) {
            Case newCase = new Case(
                CC_Functional_Group__c = classification.Id,
                CC_Category__c = classification.Case_Classifications__r[0].Id,
                Description = 'Transferred',
                Followup_Date__c = Date.today().addDays(1),
                Origin__c	= 'Automated',
                Priority = '3 - Normal Priority',
                Status = 'New',
                Subject = 'New Student Assigned',
                Type = 'System Generated',
                Visible_by_Contact__c	= false,
                ContactId = successStudent.Student__c,
                RecordTypeId = coachCaseRTID,
                OwnerId = successStudent.OwnerId
            );
            
            newCases.add(newCase);
        }
        
        insert newCases; 	
    }
}