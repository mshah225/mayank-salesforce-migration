public class FamilyPortalGuardianDeduplicationService implements Queueable {
    private List<Family_Portal_Guardian__c> newlyInsertedGuardians;
    private static List<Family_Portal_Guardian__c> guardiansToDelete;
    private static List<Family_Portal_Guardian__c> guardiansToUpdate;
    private static List<Family_Portal_Guardian_Interest__c> interestsToUpdate;
    private static List<Family_Portal_Student__c> studentsToUpdate;

    public FamilyPortalGuardianDeduplicationService(List<Family_Portal_Guardian__c> newlyInsertedGuardians) {
        this.newlyInsertedGuardians = newlyInsertedGuardians;
    }

    public void execute(QueueableContext context) {
        if (newlyInsertedGuardians.size() > 0) {
            gatherGuardiansAndStartDedupe(newlyInsertedGuardians);

            Set<Family_Portal_Guardian__c> guardiansToUpdateSet = new Set<Family_Portal_Guardian__c>();
            guardiansToUpdateSet.addAll(guardiansToUpdate);
            guardiansToUpdate.clear();
            guardiansToUpdate.addAll(guardiansToUpdateSet);
            try {
                update guardiansToUpdate;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('guardiansToUpdate', guardiansToUpdate));
                ErrorLogger.log(e, vars, false);
            }

            Set<Family_Portal_Guardian_Interest__c> interestsToUpdateSet = new Set<Family_Portal_Guardian_Interest__c>();
            interestsToUpdateSet.addAll(interestsToUpdate);
            interestsToUpdate.clear();
            interestsToUpdate.addAll(interestsToUpdateSet);
            try {
                update interestsToUpdate;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('interestsToUpdate', interestsToUpdate));
                ErrorLogger.log(e, vars, false);
            }

            FamilyPortalInterestDeduplicationService interestDedupeService = new FamilyPortalInterestDeduplicationService(
                interestsToUpdate
            );
            interestDedupeService.initialize();

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

            FamilyPortalStudentDeduplicationService studentDedupeService = new FamilyPortalStudentDeduplicationService(
                studentsToUpdate
            );
            studentDedupeService.initialize();

            Set<Id> guardianIdsToCheck = new Set<Id>();
            for (Family_Portal_Guardian__c guardian : guardiansToUpdate) {
                if (!guardiansToDelete.contains(guardian)) {
                    guardianIdsToCheck.add(guardian.Id);
                }
            }

            Set<Id> studentIdsToAvoid = new Set<Id>();
            if (guardianIdsToCheck.size() > 0) {
                for (Family_Portal_Student__c student : studentsToUpdate) {
                    if (guardianIdsToCheck.contains(student.Family_Portal_Guardian__c)) {
                        studentIdsToAvoid.add(student.Id);
                    }
                }
            }

            if (guardianIdsToCheck.size() > 0) {
                List<Family_Portal_Student__c> studentsToDeactivate = [
                    SELECT Id
                    FROM Family_Portal_Student__c
                    WHERE
                        Id NOT IN :studentIdsToAvoid
                        AND LastModifiedDate < :System.now().addMinutes(-5)
                        AND Family_Portal_Guardian__c IN :guardianIdsToCheck
                ];

                if (studentsToDeactivate.size() > 0) {
                    for (Family_Portal_Student__c student : studentsToDeactivate) {
                        student.Active_Relationship__c = false;
                    }
                    update studentsToDeactivate;
                }
            }

            Set<Family_Portal_Guardian__c> guardiansToDeleteSet = new Set<Family_Portal_Guardian__c>();
            guardiansToDeleteSet.addAll(guardiansToDelete);
            guardiansToDelete.clear();
            guardiansToDelete.addAll(guardiansToDeleteSet);
            try {
                delete guardiansToDelete;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('guardiansToDelete', guardiansToDelete));
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    public static void gatherGuardiansAndStartDedupe(List<Family_Portal_Guardian__c> insertedGuardians) {
        Map<Family_Portal_Guardian__c, List<Family_Portal_Guardian__c>> insertedGuardianWithMatchedGuardians = new Map<Family_Portal_Guardian__c, List<Family_Portal_Guardian__c>>();
        guardiansToDelete = new List<Family_Portal_Guardian__c>();
        guardiansToUpdate = new List<Family_Portal_Guardian__c>();
        interestsToUpdate = new List<Family_Portal_Guardian_Interest__c>();
        studentsToUpdate = new List<Family_Portal_Student__c>();

        Set<Id> guardiansToCloneIds = new Set<Id>();
        for (Family_Portal_Guardian__c guardian : insertedGuardians) {
            guardiansToCloneIds.add(guardian.Id);
        }

        List<Family_Portal_Guardian__c> insertedGuardiansList = [
            SELECT
                Id,
                ASU_Alumni__c,
                ASURITE_ID__c,
                Business_Unit_Source__c,
                City__c,
                Contact__c,
                Country__c,
                CreatedById,
                CreatedDate,
                Email__c,
                EMPLID__c,
                First_Name__c,
                Hash_ID__c,
                LastModifiedById,
                Last_Name__c,
                Middle_Name__c,
                OwnerId,
                Phone__c,
                Name,
                Return_URL__c,
                State__c,
                Street__c,
                Zip_Code__c
            FROM Family_Portal_Guardian__c
            WHERE Id IN :guardiansToCloneIds
        ];

        for (Family_Portal_Guardian__c insertedGuardian : insertedGuardiansList) {
            List<Family_Portal_Guardian__c> matchedGuardiansToCheck = [
                SELECT
                    Id,
                    ASU_Alumni__c,
                    ASURITE_ID__c,
                    Business_Unit_Source__c,
                    City__c,
                    Contact__c,
                    Country__c,
                    CreatedById,
                    CreatedDate,
                    Email__c,
                    EMPLID__c,
                    First_Name__c,
                    Hash_ID__c,
                    LastModifiedById,
                    Last_Name__c,
                    Middle_Name__c,
                    OwnerId,
                    Phone__c,
                    Name,
                    Return_URL__c,
                    State__c,
                    Street__c,
                    Zip_Code__c
                FROM Family_Portal_Guardian__c
                WHERE
                    (First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c
                    AND Phone__c = :insertedGuardian.Phone__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Middle_Name__c = :insertedGuardian.Middle_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c
                    AND Street__c = :insertedGuardian.Street__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Email__c = :insertedGuardian.Email__c)
                    OR Hash_ID__c = :insertedGuardian.Hash_ID__c
                ORDER BY CreatedDate ASC
            ];

            if (matchedGuardiansToCheck.size() > 0) {
                insertedGuardianWithMatchedGuardians.put(insertedGuardian, matchedGuardiansToCheck);
            }
        }
        if (insertedGuardianWithMatchedGuardians.size() > 0) {
            deduplicateGuardians(insertedGuardianWithMatchedGuardians);
        }
    }

    private static void deduplicateGuardians(
        Map<Family_Portal_Guardian__c, List<Family_Portal_Guardian__c>> insertedGuardianWithMatchedGuardians
    ) {
        for (Family_Portal_Guardian__c insertedGuardian : insertedGuardianWithMatchedGuardians.keySet()) {
            Family_Portal_Guardian__c oldestGuardian = insertedGuardian;
            Family_Portal_Guardian__c newestGuardian = insertedGuardian;
            List<Family_Portal_Guardian__c> relatedGuardiansToDelete = new List<Family_Portal_Guardian__c>();
            Set<Id> relatedGuardianIdsToDelete = new Set<Id>();
            List<Family_Portal_Guardian__c> matchedGuardiansToCheck = insertedGuardianWithMatchedGuardians.get(
                insertedGuardian
            );

            Set<Id> guardianIdsToDelete = new Set<Id>();
            for (Family_Portal_Guardian__c guardian : guardiansToDelete) {
                guardianIdsToDelete.add(guardian.Id);
            }

            if (guardianIdsToDelete.contains(insertedGuardian.Id)) {
                continue;
            }
            if (matchedGuardiansToCheck.size() == 1 && matchedGuardiansToCheck[0].Id == oldestGuardian.Id) {
                continue;
            }
            if (matchedGuardiansToCheck.size() > 1) {
                oldestGuardian = matchedGuardiansToCheck[0];
                newestGuardian = matchedGuardiansToCheck[matchedGuardiansToCheck.size() - 1];
            }

            for (Family_Portal_Guardian__c matchedGuardian : matchedGuardiansToCheck) {
                if (
                    matchedGuardian.Id != oldestGuardian.Id &&
                    matchedGuardian.Id != newestGuardian.Id &&
                    matchedGuardian.CreatedDate > oldestGuardian.CreatedDate
                ) {
                    relatedGuardiansToDelete.add(matchedGuardian);
                }
            }

            guardiansToDelete.addAll(relatedGuardiansToDelete);

            for (Family_Portal_Guardian__c relatedGuardianToDelete : relatedGuardiansToDelete) {
                relatedGuardianIdsToDelete.add(relatedGuardianToDelete.Id);
            }

            for (Family_Portal_Guardian_Interest__c interestToReparent : [
                SELECT
                    Id,
                    Active_Interest__c,
                    Chosen_Interest__c,
                    Family_Portal_Guardian__c,
                    Interest_Choices__c,
                    Name,
                    CreatedDate,
                    Guardian_Contact__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c IN :relatedGuardianIdsToDelete
            ]) {
                interestToReparent.Active_Interest__c = false;
                interestToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                interestToReparent.Guardian_Contact__c = oldestGuardian.Contact__c;
                interestsToUpdate.add(interestToReparent);
            }

            for (Family_Portal_Student__c studentToReparent : [
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
                    LastModifiedDate,
                    Guardian_Contact__c
                FROM Family_Portal_Student__c
                WHERE Family_Portal_Guardian__c IN :relatedGuardianIdsToDelete
            ]) {
                studentToReparent.Active_Relationship__c = false;
                studentToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                studentToReparent.Guardian_Contact__c = oldestGuardian.Contact__c;
                studentsToUpdate.add(studentToReparent);
            }

            if (newestGuardian.ASU_Alumni__c != null) {
                oldestGuardian.ASU_Alumni__c = newestGuardian.ASU_Alumni__c;
            }
            if (newestGuardian.ASURITE_ID__c != null) {
                oldestGuardian.ASURITE_ID__c = newestGuardian.ASURITE_ID__c;
            }
            if (newestGuardian.Business_Unit_Source__c != null) {
                oldestGuardian.Business_Unit_Source__c = newestGuardian.Business_Unit_Source__c;
            }
            if (newestGuardian.City__c != null) {
                oldestGuardian.City__c = newestGuardian.City__c;
            }
            if (newestGuardian.Contact__c != null) {
                oldestGuardian.Contact__c = newestGuardian.Contact__c;
            }
            if (newestGuardian.Country__c != null) {
                oldestGuardian.Country__c = newestGuardian.Country__c;
            }
            if (newestGuardian.Email__c != null) {
                oldestGuardian.Email__c = newestGuardian.Email__c;
            }
            if (newestGuardian.EMPLID__c != null) {
                oldestGuardian.EMPLID__c = newestGuardian.EMPLID__c;
            }
            if (newestGuardian.First_Name__c != null) {
                oldestGuardian.First_Name__c = newestGuardian.First_Name__c;
            }
            if (newestGuardian.Last_Name__c != null) {
                oldestGuardian.Last_Name__c = newestGuardian.Last_Name__c;
            }
            if (newestGuardian.Middle_Name__c != null) {
                oldestGuardian.Middle_Name__c = newestGuardian.Middle_Name__c;
            }
            if (newestGuardian.OwnerId != null) {
                oldestGuardian.OwnerId = newestGuardian.OwnerId;
            }
            if (newestGuardian.Phone__c != null) {
                oldestGuardian.Phone__c = newestGuardian.Phone__c;
            }
            if (newestGuardian.State__c != null) {
                oldestGuardian.State__c = newestGuardian.State__c;
            }
            if (newestGuardian.Street__c != null) {
                oldestGuardian.Street__c = newestGuardian.Street__c;
            }
            if (newestGuardian.Zip_Code__c != null) {
                oldestGuardian.Zip_Code__c = newestGuardian.Zip_Code__c;
            }

            for (Family_Portal_Guardian_Interest__c interestToReparent : [
                SELECT
                    Id,
                    Active_Interest__c,
                    Chosen_Interest__c,
                    Family_Portal_Guardian__c,
                    Interest_Choices__c,
                    CreatedDate,
                    Guardian_Contact__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c = :newestGuardian.Id
            ]) {
                interestToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                interestToReparent.Guardian_Contact__c = oldestGuardian.Contact__c;
                interestsToUpdate.add(interestToReparent);
            }

            for (Family_Portal_Student__c studentToReparent : [
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
                    LastModifiedDate,
                    Guardian_Contact__c
                FROM Family_Portal_Student__c
                WHERE Family_Portal_Guardian__c = :newestGuardian.Id
            ]) {
                studentToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                studentToReparent.Guardian_Contact__c = oldestGuardian.Contact__c;
                studentsToUpdate.add(studentToReparent);
            }

            if (!guardiansToDelete.contains(newestGuardian)) {
                guardiansToDelete.add(newestGuardian);
            }
            if (!guardiansToUpdate.contains(oldestGuardian)) {
                guardiansToUpdate.add(oldestGuardian);
            }
        }
    }
}
