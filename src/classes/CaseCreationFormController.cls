public with sharing class CaseCreationFormController {

    @AuraEnabled
    public static String createFeedbackCase(String carName, String subject, String description) {
        Case caseToCreate = new Case();

        caseToCreate.Status = 'New';
        caseToCreate.Visible_by_Contact__c = true;
        setCarDefaults(carName, caseToCreate);
        setContact(caseToCreate);
        caseToCreate.Subject = subject;
        caseToCreate.Description = Description;

        insert caseToCreate;

        return 'Success';
    }

    private static void setCarDefaults(String carName, Case caseToModify) {
        try {
            Case_Assignment_Rule__c carToAssignTo = [
                SELECT CC_Category__c, CC_Functional_Group__c, CC_Sub_Category__c,
                Case_Record_Type_Id__c, Origin__c, OwnerId
                FROM Case_Assignment_Rule__c
                WHERE Name =: CarName
            ];

            caseToModify.Origin__c = carToAssignTo.Origin__c;
            caseToModify.CC_Functional_Group__c = carToAssignTo.CC_Functional_Group__c;
            caseToModify.CC_Category__c = carToAssignTo.CC_Category__c;
            caseToModify.CC_Sub_Category__c = carToAssignTo.CC_Sub_Category__c;
            caseToModify.RecordTypeId = carToAssignTo.Case_Record_Type_Id__c;
            caseToModify.OwnerId = carToAssignTo.OwnerId;

        } catch (Exception e) {

        }
        
    }

    private static void setContact(Case caseToModify) {
        String userId = UserInfo.getUserId();

        User userWithAlias = [SELECT Alias FROM User Where Id =: userId LIMIT 1];

        List<User> usersWithContact = [SELECT ContactId FROM User WHERE Alias =: userWithAlias.Alias];

        if (!usersWithContact.isEmpty()) {
            caseToModify.ContactId = usersWithContact[0].ContactId;
        }

    }
}
