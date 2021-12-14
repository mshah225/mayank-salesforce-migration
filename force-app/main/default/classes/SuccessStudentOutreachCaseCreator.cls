public class SuccessStudentOutreachCaseCreator {
    private static final Date TOMORROW = System.today().addDays(1);
    private static final Id COACH_CASE_RECORD_TYPE = RecordIdHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach');
    private static Id asuCoachOutreachGroup;
    private static Id adHocCategory;

    private Map<Id, Success_Student__c> successStudents;
    private Map<Id, Success_Student__c> previousValues;
    private List<Success_Student__c> studentsRequiringOutreach;
    private Set<Id> outreachStudentIds;
    private List<Case> outreachCases;

    public SuccessStudentOutreachCaseCreator(
        Map<Id, Success_Student__c> successStudents,
        Map<Id, Success_Student__c> previousValues
    ) {
        this.successStudents = successStudents;
        this.previousValues = previousValues;
        studentsRequiringOutreach = new List<Success_Student__c>();
        outreachStudentIds = new Set<Id>();
        outreachCases = new List<Case>();

        findStudentsRequiringOutreach();
        setOutreachClassification();
        reQueryStudentsRequiringOutreach();
        createOutreachCases();
    }

    private void findStudentsRequiringOutreach() {
        for (Success_Student__c successStudent : successStudents.values()) {
            if (studentRequiresOutreach(successStudent)) {
                studentsRequiringOutreach.add(successStudent);
                outreachStudentIds.add(successStudent.Id);
            }
        }
    }

    private static void setOutreachClassification() {
        Case_Classification__c classification = [
            SELECT Id, (SELECT Id FROM Case_Classifications__r WHERE Name = 'Ad Hoc' LIMIT 1)
            FROM Case_Classification__c
            WHERE Name = 'ASU Coach Outreach'
            LIMIT 1
        ];

        asuCoachOutreachGroup = classification.Id;
        adHocCategory = classification.Case_Classifications__r[0].Id;
    }

    private void reQueryStudentsRequiringOutreach() {
        studentsRequiringOutreach = [
            SELECT Student__c, Success_Resource__r.Resource__c, Coaching_Student__c
            FROM Success_Student__c
            WHERE Id IN :outreachStudentIds
        ];
    }

    private Boolean studentRequiresOutreach(Success_Student__c successStudent) {
        return successStudent.Success_Resource__c != previousValues.get(successStudent.Id).Success_Resource__c &&
            successStudent.Coaching_Student__c;
    }

    private void createOutreachCases() {
        for (Success_Student__c successStudent : studentsRequiringOutreach) {
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
                RecordTypeId = COACH_CASE_RECORD_TYPE,
                OwnerId = successStudent.Success_Resource__r.Resource__c
            );
            outreachCases.add(newCase);
        }
    }

    public List<Case> getOutreachCases() {
        return outreachCases;
    }
}
