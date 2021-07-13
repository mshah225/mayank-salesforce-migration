@isTest
public with sharing class CaseCreationFormControllerTest {
    private static final String carOrigin = 'TestOrigin';
    private static final String userLastName = 'TestUserCaseCreationForm';

    @TestSetup
    static void setup() {
        String asurite = '12345678';

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'TestFunctionalGroup',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = 'TestCategory',
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert category;
        Case_Classification__c subcategory = new Case_Classification__c(
            Name = 'TestSubCategory',
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        insert subcategory;

        User u = new User(
            FirstName = 'Test',
            LastName = userLastName,
            Username = 'test.user.Emperor.Of.Byzantium@test.test',
            Email = 'test.user@test.test',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = IDHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US',
            ASURITE_for_External_ID__c = asurite
        );
        insert u;

        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', ASURITE_ID__c = asurite);
        insert c;

        Case_Assignment_Rule__c car = new Case_Assignment_Rule__c(
            CC_Functional_Group__c = functionalGroup.Id,
            CC_Category__c = category.Id,
            CC_Sub_Category__c = subcategory.Id,
            Case_Record_Type_Id__c = IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach').to15(),
            Origin__c = carOrigin,
            Queue_ID__c = u.Id.to15()
        );
        insert car;
    }

    @isTest
    private static void testCreateCase() {
        String subject = 'Test case subejct';
        String description = 'Description can be pretty much anything!';
        User u = [SELECT Id FROM User WHERE LastName = :userLastName LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Case_Assignment_Rule__c car = [SELECT Name FROM Case_Assignment_Rule__c];
        Id functionalGroupId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
            LIMIT 1
        ]
        .Id;
        Id categoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Category')
            LIMIT 1
        ]
        .Id;
        Id subCategoryId = [
            SELECT Id
            FROM Case_Classification__c
            WHERE RecordTypeId = :IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
            LIMIT 1
        ]
        .Id;

        System.runAs(u) {
            CaseCreationFormController.createFeedbackCase(car.Name, subject, description);
        }

        Case c = [
            SELECT
                Id,
                Subject,
                Description,
                Status,
                Visible_by_Contact__c,
                Origin__c,
                CC_Functional_Group__c,
                CC_Category__c,
                CC_Sub_Category__c,
                OwnerId,
                ContactId
            FROM Case
            LIMIT 1
        ];

        System.assertEquals(subject, c.Subject);
        System.assertEquals(description, c.Description);
        System.assertEquals('New', c.Status);
        System.assert(c.Visible_by_Contact__c);
        System.assertEquals(carOrigin, c.Origin__c);
        System.assertEquals(functionalGroupId, c.CC_Functional_Group__c);
        System.assertEquals(categoryId, c.CC_Category__c);
        System.assertEquals(subCategoryId, c.CC_Sub_Category__c);
        System.assertEquals(u.Id, c.OwnerId);
        System.assertEquals(con.Id, c.ContactId);
    }
}
