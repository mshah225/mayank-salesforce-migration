public class FamilyPortalStudentDeduplicationService {
    private List<Family_Portal_Student__c> studentsWithChanges;
    private static List<Family_Portal_Student__c> studentsToDelete;
    private static List<Family_Portal_Student__c> studentsToUpdate;

    public FamilyPortalStudentDeduplicationService(List<Family_Portal_Student__c> studentsWithChanges) {
        this.studentsWithChanges = studentsWithChanges;
    }

    public void initialize() {
        if (studentsWithChanges.size() > 0) {
            gatherStudentsAndStartDedupe(studentsWithChanges);

            Set<Family_Portal_Student__c> studentsToUpdateSet = new Set<Family_Portal_Student__c>();
            studentsToUpdateSet.addAll(studentsToUpdate);
            studentsToUpdate.clear();
            studentsToUpdate.addAll(studentsToUpdateSet);
            try {
                update studentsToUpdate;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('studentsToUpdate', studentsToUpdate));
                ErrorLogger.log(e, vars, false);
            }

            Set<Family_Portal_Student__c> studentsToDeleteSet = new Set<Family_Portal_Student__c>();
            studentsToDeleteSet.addAll(studentsToDelete);
            studentsToDelete.clear();
            studentsToDelete.addAll(studentsToDeleteSet);
            try {
                delete studentsToDelete;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('studentsToDelete', studentsToDelete));
                ErrorLogger.log(e, vars, false);
            }

            for (Family_Portal_Student__c updatedStudent : studentsToUpdate) {
                Family_Portal_Student__c updatedStudentWithLMD = [
                    SELECT Id, LastModifiedDate
                    FROM Family_Portal_Student__c
                    WHERE Id = :updatedStudent.Id
                    LIMIT 1
                ];
                DateTime updatedStudentLastModifiedDate = updatedStudentWithLMD.LastModifiedDate;

                List<Family_Portal_Student__c> studentsToSetInactive = [
                    SELECT Id, Active_Relationship__c, LastModifiedDate
                    FROM Family_Portal_Student__c
                    WHERE
                        Family_Portal_Guardian__c = :updatedStudent.Family_Portal_Guardian__c
                        AND Id != :updatedStudent.Id
                        AND LastModifiedDate < :updatedStudentLastModifiedDate
                ];
                if (studentsToSetInactive.size() > 0) {
                    for (Family_Portal_Student__c student : studentsToSetInactive) {
                        student.Active_Relationship__c = false;
                    }
                    update studentsToSetInactive;
                }
            }
        }
    }

    public static void gatherStudentsAndStartDedupe(List<Family_Portal_Student__c> updatedStudents) {
        Map<Family_Portal_Student__c, List<Family_Portal_Student__c>> updatedStudentWithMatchedStudents = new Map<Family_Portal_Student__c, List<Family_Portal_Student__c>>();
        studentsToDelete = new List<Family_Portal_Student__c>();
        studentsToUpdate = new List<Family_Portal_Student__c>();

        for (Family_Portal_Student__c updatedStudent : updatedStudents) {
            List<Family_Portal_Student__c> matchedStudentsToCheck = [
                SELECT
                    Id,
                    Academic_College__c,
                    Academic_Year__c,
                    Active_Relationship__c,
                    Enrollment_Status__c,
                    Enrollment_Status_Year__c,
                    Family_Portal_Guardian__c,
                    Military_Affiliation__c,
                    Type__c,
                    CreatedDate,
                    LastModifiedDate
                FROM Family_Portal_Student__c
                WHERE
                    Family_Portal_Guardian__c = :updatedStudent.Family_Portal_Guardian__c
                    AND ((Enrollment_Status__c = :updatedStudent.Enrollment_Status__c
                    AND Enrollment_Status_Year__c = :updatedStudent.Enrollment_Status_Year__c
                    AND Military_Affiliation__c = :updatedStudent.Military_Affiliation__c
                    AND Academic_College__c = :updatedStudent.Academic_College__c
                    AND Academic_Year__c = :updatedStudent.Academic_Year__c
                    AND Type__c = :updatedStudent.Type__c)
                    OR (Enrollment_Status__c = :updatedStudent.Enrollment_Status__c
                    AND Enrollment_Status_Year__c = :updatedStudent.Enrollment_Status_Year__c
                    AND Military_Affiliation__c = :updatedStudent.Military_Affiliation__c))
                ORDER BY CreatedDate ASC
            ];

            if (matchedStudentsToCheck.size() > 0) {
                updatedStudentWithMatchedStudents.put(updatedStudent, matchedStudentsToCheck);

                List<Family_Portal_Student__c> allStudentsFromGuardian = [
                    SELECT Id
                    FROM Family_Portal_Student__c
                    WHERE Family_Portal_Guardian__c = :updatedStudent.Family_Portal_Guardian__c
                    ORDER BY CreatedDate ASC
                ];
            }
        }
        deduplicateStudents(updatedStudentWithMatchedStudents);
    }

    private static void deduplicateStudents(
        Map<Family_Portal_Student__c, List<Family_Portal_Student__c>> updatedStudentWithMatchedStudents
    ) {
        for (Family_Portal_Student__c updatedStudent : updatedStudentWithMatchedStudents.keySet()) {
            Family_Portal_Student__c oldestStudent = updatedStudent;
            Family_Portal_Student__c newestStudent = updatedStudent;
            List<Family_Portal_Student__c> relatedstudentsToDelete = new List<Family_Portal_Student__c>();
            List<Family_Portal_Student__c> matchedStudentsToCheck = updatedStudentWithMatchedStudents.get(
                updatedStudent
            );

            Set<Id> studentIdsToDelete = new Set<Id>();
            for (Family_Portal_Student__c student : studentsToDelete) {
                studentIdsToDelete.add(student.Id);
            }

            if (studentIdsToDelete.contains(updatedStudent.Id)) {
                continue;
            }
            if (matchedStudentsToCheck.size() == 1 && matchedStudentsToCheck[0].Id == oldestStudent.Id) {
                continue;
            }
            if (matchedStudentsToCheck.size() > 1) {
                oldestStudent = matchedStudentsToCheck[0];
                newestStudent = matchedStudentsToCheck[matchedStudentsToCheck.size() - 1];
            }

            for (Family_Portal_Student__c matchedStudent : matchedStudentsToCheck) {
                if (
                    matchedStudent.Id != oldestStudent.Id &&
                    matchedStudent.Id != newestStudent.Id &&
                    matchedStudent.CreatedDate > oldestStudent.CreatedDate
                ) {
                    relatedstudentsToDelete.add(matchedStudent);
                }
            }

            studentsToDelete.addAll(relatedstudentsToDelete);

            if (newestStudent.Academic_College__c != null) {
                oldestStudent.Academic_College__c = newestStudent.Academic_College__c;
            }
            if (newestStudent.Academic_Year__c != null) {
                oldestStudent.Academic_Year__c = newestStudent.Academic_Year__c;
            }
            if (newestStudent.Active_Relationship__c != null) {
                oldestStudent.Active_Relationship__c = newestStudent.Active_Relationship__c;
            }
            if (newestStudent.Enrollment_Status__c != null) {
                oldestStudent.Enrollment_Status__c = newestStudent.Enrollment_Status__c;
            }
            if (newestStudent.Enrollment_Status_Year__c != null) {
                oldestStudent.Enrollment_Status_Year__c = newestStudent.Enrollment_Status_Year__c;
            }
            if (newestStudent.Military_Affiliation__c != null) {
                oldestStudent.Military_Affiliation__c = newestStudent.Military_Affiliation__c;
            }
            if (newestStudent.Type__c != null) {
                oldestStudent.Type__c = newestStudent.Type__c;
            }

            if (!studentsToUpdate.contains(oldestStudent)) {
                studentsToUpdate.add(oldestStudent);
            }
            if (!studentsToDelete.contains(newestStudent)) {
                studentsToDelete.add(newestStudent);
            }
        }
    }
}
