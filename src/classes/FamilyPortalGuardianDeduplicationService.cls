public class FamilyPortalGuardianDeduplicationService implements Queueable {
    private List<Family_Portal_Guardian__c> newlyInsertedGuardians;
    private static List<Family_Portal_Guardian__c> guardiansToDelete;
    private static List<Family_Portal_Guardian__c> guardiansToUpdate;
    private static List<Family_Portal_Guardian_Interest__c> guardianInterestsToUpdate;
    private static List<Family_Portal_Student__c> studentsToUpdate;
    private Map<Id, List<Family_Portal_Guardian_Interest__c>> guardianIdWithInterests;
    private Map<Id, List<Family_Portal_Student__c>> guardianIdWithStudents;

    public FamilyPortalGuardianDeduplicationService(List<Family_Portal_Guardian__c> newlyInsertedGuardians) {
        this.newlyInsertedGuardians = newlyInsertedGuardians;
    }

    public void execute(QueueableContext context) {
        if (newlyInsertedGuardians.size() > 0) {
            gatherGuardiansAndStartDedup(newlyInsertedGuardians);
            if (
                guardianInterestsToUpdate != null && !guardianInterestsToUpdate.isEmpty() &&
                guardianInterestsToUpdate.size() > 0
            ) {
                Set<Family_Portal_Guardian_Interest__c> guardianInterestsToUpdateSet = new Set<Family_Portal_Guardian_Interest__c>();
                guardianInterestsToUpdateSet.addAll(guardianInterestsToUpdate);
                guardianInterestsToUpdate.clear();
                guardianInterestsToUpdate.addAll(guardianInterestsToUpdateSet);
                update guardianInterestsToUpdate;
            }
            if (studentsToUpdate != null && !studentsToUpdate.isEmpty() && studentsToUpdate.size() > 0) {
                Set<Family_Portal_Student__c> studentsToUpdateSet = new Set<Family_Portal_Student__c>();
                studentsToUpdateSet.addAll(studentsToUpdate);
                studentsToUpdate.clear();
                studentsToUpdate.addAll(studentsToUpdateSet);
                update studentsToUpdate;
            }

            try {
                if (guardiansToUpdate != null && !guardiansToUpdate.isEmpty() && guardiansToUpdate.size() > 0) {
                    Set<Family_Portal_Guardian__c> guardiansToUpdateSet = new Set<Family_Portal_Guardian__c>();
                    guardiansToUpdateSet.addAll(guardiansToUpdate);
                    guardiansToUpdate.clear();
                    guardiansToUpdate.addAll(guardiansToUpdateSet);
                    update guardiansToUpdate;
                }
            } catch (DmlException e) {
                Set<Family_Portal_Guardian__c> guardiansToUpdateSet = new Set<Family_Portal_Guardian__c>();
                guardiansToUpdateSet.addAll(guardiansToUpdate);
                guardiansToUpdate.clear();
                guardiansToUpdate.addAll(guardiansToUpdateSet);
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('guardiansToUpdate', guardiansToUpdate));
                ErrorLogger.log(e, vars, false);
            }
            try {
                if (guardiansToDelete != null && !guardiansToDelete.isEmpty() && guardiansToDelete.size() > 0) {
                    Set<Family_Portal_Guardian__c> guardiansToDeleteSet = new Set<Family_Portal_Guardian__c>();
                    guardiansToDeleteSet.addAll(guardiansToDelete);
                    guardiansToDelete.clear();
                    guardiansToDelete.addAll(guardiansToDeleteSet);
                    delete guardiansToDelete;
                }
            } catch (DmlException e) {
                Set<Family_Portal_Guardian__c> guardiansToDeleteSet = new Set<Family_Portal_Guardian__c>();
                guardiansToDeleteSet.addAll(guardiansToDelete);
                guardiansToDelete.clear();
                guardiansToDelete.addAll(guardiansToDeleteSet);
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertListToJSON('guardiansToDelete', guardiansToDelete));
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    public static void gatherGuardiansAndStartDedup(List<Family_Portal_Guardian__c> insertedGuardians) {
        Map<Family_Portal_Guardian__c, List<Family_Portal_Guardian__c>> insertedGuardianWithMatchedGuardians = new Map<Family_Portal_Guardian__c, List<Family_Portal_Guardian__c>>();
        List<Family_Portal_Guardian__c> guardiansToCheck;
        guardiansToDelete = new List<Family_Portal_Guardian__c>();
        guardiansToUpdate = new List<Family_Portal_Guardian__c>();
        guardianInterestsToUpdate = new List<Family_Portal_Guardian_Interest__c>();
        studentsToUpdate = new List<Family_Portal_Student__c>();

        for (Family_Portal_Guardian__c insertedGuardian : insertedGuardians) {
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
                    Id != :insertedGuardian.Id
                    AND ((First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c
                    AND Phone__c = :insertedGuardian.Phone__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c
                    AND Middle_Name__c = :insertedGuardian.Middle_Name__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c
                    AND Street__c = :insertedGuardian.Street__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Last_Name__c = :insertedGuardian.Last_Name__c
                    AND Email__c = :insertedGuardian.Email__c)
                    OR (First_Name__c = :insertedGuardian.First_Name__c
                    AND Email__c = :insertedGuardian.Email__c)
                    OR Hash_ID__c = :insertedGuardian.Hash_ID__c)
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
            Family_Portal_Guardian__c oldestGuardian;
            Family_Portal_Guardian__c newestGuardian = insertedGuardian;
            List<Family_Portal_Guardian__c> relatedGuardiansToDelete = new List<Family_Portal_Guardian__c>();
            Map<Id, List<Family_Portal_Guardian__c>> relatedGuardianIdsWithGuardianToDelete = new Map<Id, List<Family_Portal_Guardian__c>>();
            List<Family_Portal_Guardian__c> matchedGuardiansToCheck = insertedGuardianWithMatchedGuardians.get(
                insertedGuardian
            );

            for (Family_Portal_Guardian__c matchedGuardian : matchedGuardiansToCheck) {
                if (oldestGuardian == null) {
                    oldestGuardian = matchedGuardian;
                    continue;
                }
                if (oldestGuardian.Id == matchedGuardian.Id) {
                    continue;
                }

                if (oldestGuardian.CreatedDate < matchedGuardian.CreatedDate) {
                    relatedGuardiansToDelete.add(matchedGuardian);
                } else if (oldestGuardian.CreatedDate >= matchedGuardian.CreatedDate) {
                    relatedGuardiansToDelete.add(oldestGuardian);
                    oldestGuardian = matchedGuardian;
                }
            }
            guardiansToDelete.addAll(relatedGuardiansToDelete);

            for (Family_Portal_Guardian__c relatedGuardianToDelete : relatedGuardiansToDelete) {
                relatedGuardianIdsWithGuardianToDelete.put(relatedGuardianToDelete.Id, relatedGuardiansToDelete);
            }

            for (Family_Portal_Guardian_Interest__c interestToReparent : [
                SELECT Id, Active_Interest__c, Family_Portal_Guardian__c, Guardian_Contact__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c IN :relatedGuardianIdsWithGuardianToDelete.keySet()
            ]) {
                interestToReparent.Active_Interest__c = false;
                interestToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                interestToReparent.Guardian_Contact__c = oldestGuardian.Contact__c;
                guardianInterestsToUpdate.add(interestToReparent);
            }

            for (Family_Portal_Student__c studentToReparent : [
                SELECT Id, Active_Relationship__c, Family_Portal_Guardian__c, Guardian_Contact__c
                FROM Family_Portal_Student__c
                WHERE Family_Portal_Guardian__c IN :relatedGuardianIdsWithGuardianToDelete.keySet()
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

            for (Family_Portal_Guardian_Interest__c interestToSetInactive : [
                SELECT Id, Family_Portal_Guardian__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c = :oldestGuardian.Id
            ]) {
                interestToSetInactive.Active_Interest__c = false;
                guardianInterestsToUpdate.add(interestToSetInactive);
            }

            for (Family_Portal_Student__c studentToSetInactive : [
                SELECT Id, Family_Portal_Guardian__c
                FROM Family_Portal_Student__c
                WHERE Family_Portal_Guardian__c = :oldestGuardian.Id
            ]) {
                studentToSetInactive.Active_Relationship__c = false;
                studentsToUpdate.add(studentToSetInactive);
            }

            for (Family_Portal_Guardian_Interest__c interestToReparent : [
                SELECT Id, Family_Portal_Guardian__c, Guardian_Contact__c
                FROM Family_Portal_Guardian_Interest__c
                WHERE Family_Portal_Guardian__c = :newestGuardian.Id
            ]) {
                interestToReparent.Family_Portal_Guardian__c = oldestGuardian.Id;
                interestToReparent.Guardian_Contact__c = oldestGuardian.Contact__c;
                guardianInterestsToUpdate.add(interestToReparent);
            }

            for (Family_Portal_Student__c studentToReparent : [
                SELECT Id, Family_Portal_Guardian__c, Guardian_Contact__c
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
