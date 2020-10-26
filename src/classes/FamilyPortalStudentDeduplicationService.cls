public class FamilyPortalStudentDeduplicationService implements Queueable {
    private List<Family_Portal_Student__c> updatedStudents;
    private static List<Family_Portal_Student__c> studentsToDelete;
    private static List<Family_Portal_Student__c> studentsToUpdate;

    public FamilyPortalStudentDeduplicationService(List<Family_Portal_Student__c> updatedStudents) {
        this.updatedStudents = updatedStudents;
    }

    public void execute(QueueableContext context) {
        if (updatedStudents.size() > 0) {
            gatherStudentsAndStartDedupe(updatedStudents);
            try {
                if (studentsToUpdate != null && !studentsToUpdate.isEmpty()) {
                    Set<Family_Portal_Student__c> studentsToUpdateSet = new Set<Family_Portal_Student__c>();
                    studentsToUpdateSet.addAll(studentsToUpdate);
                    studentsToUpdate.clear();
                    studentsToUpdate.addAll(studentsToUpdateSet);
                    update studentsToUpdate;
                }
            } catch (DmlException e) {
                Set<Family_Portal_Student__c> studentsToUpdateSet = new Set<Family_Portal_Student__c>();
                studentsToUpdateSet.addAll(studentsToUpdate);
                studentsToUpdate.clear();
                studentsToUpdate.addAll(studentsToUpdateSet);
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('studentsToUpdate', studentsToUpdate));
                ErrorLogger.log(e, vars, false);
            }
            try {
                if (studentsToDelete != null && !studentsToDelete.isEmpty()) {
                    Set<Family_Portal_Student__c> studentsToDeleteSet = new Set<Family_Portal_Student__c>();
                    studentsToDeleteSet.addAll(studentsToDelete);
                    studentsToDelete.clear();
                    studentsToDelete.addAll(studentsToDeleteSet);
                    delete studentsToDelete;
                }
            } catch (DmlException e) {
                Set<Family_Portal_Student__c> studentsToDeleteSet = new Set<Family_Portal_Student__c>();
                studentsToDeleteSet.addAll(studentsToDelete);
                studentsToDelete.clear();
                studentsToDelete.addAll(studentsToDeleteSet);
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('studentsToDelete', studentsToDelete));
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    public static void gatherStudentsAndStartDedupe(List<Family_Portal_Student__c> updatedStudents) {
        Map<Family_Portal_Student__c, List<Family_Portal_Student__c>> updatedStudentWithMatchedStudents = new Map<Family_Portal_Student__c, List<Family_Portal_Student__c>>();
        List<Family_Portal_Student__c> guardiansToCheck;
        studentsToDelete = new List<Family_Portal_Student__c>();
        studentsToUpdate = new List<Family_Portal_Student__c>();

        for (Family_Portal_Student__c updatedStudent : updatedStudents) {
            List<Family_Portal_Student__c> matchedStudentsToCheck = [
                SELECT
                    Id,
                    Academic_College__c,
                    Active_Relationship__c,
                    Enrollment_Status__c,
                    Enrollment_Status_Year__c,
                    Family_Portal_Guardian__c,
                    Military_Affiliation__c,
                    Type__c
                FROM Family_Portal_Student__c
                WHERE
                    Family_Portal_Guardian__c = :updatedStudent.Family_Portal_Guardian__c
                    AND Enrollment_Status__c = :updatedStudent.Enrollment_Status__c
                    AND ((Enrollment_Status_Year__c = :updatedStudent.Enrollment_Status_Year__c
                    AND Military_Affiliation__c = :updatedStudent.Military_Affiliation__c)
                    OR (Academic_College__c = :updatedStudent.Academic_College__c
                    AND Type__c = :updatedStudent.Type__c
                    AND Military_Affiliation__c = :updatedStudent.Military_Affiliation__c))
            ];

            if (matchedStudentsToCheck.size() > 0) {
                updatedStudentWithMatchedStudents.put(updatedStudent, matchedStudentsToCheck);
            }
        }

        if (updatedStudentWithMatchedStudents.size() > 0) {
            deduplicateStudents(updatedStudentWithMatchedStudents);
        }
    }

    private static void deduplicateStudents(
        Map<Family_Portal_Student__c, List<Family_Portal_Student__c>> updatedStudentWithMatchedStudents
    ) {
        for (Family_Portal_Student__c updatedStudent : updatedStudentWithMatchedStudents.keySet()) {
            Family_Portal_Student__c oldestStudent;
            List<Family_Portal_Student__c> relatedstudentsToDelete = new List<Family_Portal_Student__c>();
            Map<Id, List<Family_Portal_Student__c>> relatedStudentIdsWithstudentsToDelete = new Map<Id, List<Family_Portal_Student__c>>();
            List<Family_Portal_Student__c> matchedStudentsToCheck = updatedStudentWithMatchedStudents.get(
                updatedStudent
            );

            for (Family_Portal_Student__c matchedStudent : matchedStudentsToCheck) {
                if (oldestStudent == null) {
                    oldestStudent = matchedStudent;
                    continue;
                }
                if (oldestStudent.Id == matchedStudent.Id) {
                    continue;
                }

                if (oldestStudent.CreatedDate < matchedStudent.CreatedDate) {
                    relatedstudentsToDelete.add(matchedStudent);
                } else if (oldestStudent.CreatedDate >= matchedStudent.CreatedDate) {
                    relatedstudentsToDelete.add(oldestStudent);
                    oldestStudent = matchedStudent;
                }
            }
            studentsToDelete.addAll(relatedstudentsToDelete);

            if (updatedStudent.Academic_College__c != null) {
                oldestStudent.Academic_College__c = updatedStudent.Academic_College__c;
            }
            if (updatedStudent.Active_Relationship__c != null) {
                oldestStudent.Active_Relationship__c = updatedStudent.Active_Relationship__c;
            }
            if (updatedStudent.Enrollment_Status__c != null) {
                oldestStudent.Enrollment_Status__c = updatedStudent.Enrollment_Status__c;
            }
            if (updatedStudent.Enrollment_Status_Year__c != null) {
                oldestStudent.Enrollment_Status_Year__c = updatedStudent.Enrollment_Status_Year__c;
            }
            if (updatedStudent.Military_Affiliation__c != null) {
                oldestStudent.Military_Affiliation__c = updatedStudent.Military_Affiliation__c;
            }
            if (updatedStudent.Type__c != null) {
                oldestStudent.Type__c = updatedStudent.Type__c;
            }

            if (!studentsToDelete.contains(updatedStudent)) {
                studentsToDelete.add(updatedStudent);
            }
            if (!studentsToUpdate.contains(oldestStudent)) {
                studentsToUpdate.add(oldestStudent);
            }
        }
    }
}
