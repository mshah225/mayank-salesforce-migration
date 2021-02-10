public without sharing class CaseAssignmentRuleAccessor {
    public static Case_Assignment_Rule__c createDefaultCarForErrorLogger() {
        Case_Assignment_Rule__c defaultCar = new Case_Assignment_Rule__c();
        List<Case_Classification__c> lstCaseCategory = [
            SELECT Id, Name, Parent__c
            FROM Case_Classification__c
            WHERE Active__c = TRUE AND Name = 'General' AND Parent__r.Name = 'ASU Salesforce Support'
        ];
        List<RecordType> lstRT = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE DeveloperName = 'Functional_Group' OR DeveloperName = 'Category'
        ];
        Integer priority;
        String QueueId = [SELECT Id FROM Group WHERE Name = 'ASU Salesforce Support (Case)'].Id;
        List<Case_Assignment_Rule__c> highestPriority = new List<Case_Assignment_Rule__c>(
            [SELECT Priority__c FROM Case_Assignment_Rule__c ORDER BY Priority__c DESC LIMIT 1]
        );
        String recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'ASU Service' LIMIT 1]
        .Id;

        if (highestPriority.size() == 1) {
            priority = integer.valueOf(highestPriority[0].Priority__c) + 1;
        } else {
            priority = 10000;
        }

        defaultCar.Customer_Notice_Email_From_Name__c = 'ASU Salesforce Support';
        defaultCar.Queue_ID__c = QueueId.left(15);
        defaultCar.Priority__c = priority;

        if (lstCaseCategory != null && lstCaseCategory.size() > 0) {
            defaultCar.CC_Functional_Group__c = lstCaseCategory[0].Parent__c;
            defaultCar.CC_Category__c = lstCaseCategory[0].Id;
        } else {
            Case_Classification__c defaultFuncGroup = new Case_Classification__c();
            defaultFuncGroup.Name = 'ASU Salesforce Support';
            defaultFuncGroup.Record_Types__c = 'ASU Coach Outreach; ASU Service';
            defaultFuncGroup.Record_Types_String__c = 'ASU Coach Outreach;ASU Service';
            defaultFuncGroup.Active__c = true;
            defaultFuncGroup.Visible__c = true;
            if (lstRT[0].DeveloperName == 'Functional_Group')
                defaultFuncGroup.RecordTypeId = lstRT[0].Id;
            else
                defaultFuncGroup.RecordTypeId = lstRT[1].Id;

            insert defaultFuncGroup;

            Case_Classification__c defaultCategory = new Case_Classification__c();
            defaultCategory.Name = 'General';
            defaultCategory.Active__c = true;
            defaultCategory.Visible__c = true;
            defaultCategory.Parent__c = defaultFuncGroup.Id;
            if (lstRT[0].DeveloperName == 'Category')
                defaultCategory.RecordTypeId = lstRT[0].Id;
            else
                defaultCategory.RecordTypeId = lstRT[1].Id;

            insert defaultCategory;

            defaultCar.CC_Functional_Group__c = defaultCategory.Parent__c;
            defaultCar.CC_Category__c = defaultCategory.Id;
        }
        defaultCar.Email_Address__c = '';
        defaultCar.Case_Feed_Email_Template_Id__c = '';
        defaultCar.Campus__c = '';
        defaultCar.Origin__c = 'Error Logger';
        defaultCar.Case_Record_Type_Id__c = recordTypeId.left(15);

        return defaultCar;
    }

    public static Case_Assignment_Rule__c getErrorLoggerCar() {
        List<Case_Assignment_Rule__c> sfCar = new List<Case_Assignment_Rule__c>(
            [
                SELECT
                    Queue_ID__c,
                    CC_Functional_Group__c,
                    CC_Category__c,
                    CC_Sub_Category__c,
                    Email_Address__c,
                    Case_Feed_Email_Template_Id__c,
                    Campus__c,
                    Origin__c,
                    Case_Record_Type_Id__c
                FROM Case_Assignment_Rule__c
                WHERE Origin__c = 'Error Logger'
                ORDER BY Priority__c DESC
                LIMIT 1
            ]
        );

        if (sfCar.isEmpty()) {
            sfCar.add(CaseAssignmentRuleAccessor.createDefaultCarForErrorLogger());

            insert sfCar;
        }
        return sfCar[0];
    }

    public static Case getNewCaseFromCar() {
        Case_Assignment_Rule__c sfCar = getErrorLoggerCar();
        Case newCase = new Case();
        newCase.OwnerId = sfCar.Queue_ID__c;
        newCase.CC_Functional_Group__c = sfCar.CC_Functional_Group__c;
        newCase.CC_Category__c = sfCar.CC_Category__c;
        newCase.CC_Sub_Category__c = sfCar.CC_Sub_Category__c;
        newCase.Case_Feed_Email__c = sfCar.Email_Address__c;
        newCase.Case_Feed_Email_Template_Id__C = sfCar.Case_Feed_Email_Template_Id__c;
        newCase.Campus__c = sfCar.Campus__c;
        newCase.Origin__c = sfCar.Origin__c;
        newCase.Visible_by_Contact__c = false;
        return newCase;
    }
}
