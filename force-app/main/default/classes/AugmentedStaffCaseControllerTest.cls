@isTest
public with sharing class AugmentedStaffCaseControllerTest {
    private static final String c1_EMPLID = '13000';
    private static final String c2_ASURiteId = '13095';
    private static final String category1Name = 'TestCategory';
    private static final String category2Name = 'TestCategory2';
    private static final String subCategory1Name = 'TestSubCategory';
    private static final String subCategory2Name = 'TestSubCategory2';
    private static final String subCategory3Name = 'TestSubCategory3';

    @TestSetup
    static void setup() {
        User runAsUser = new User(Id = UserInfo.getUserId());

        Case_Classification__c functionalGroup = new Case_Classification__c(
            Name = 'Help Desk',
            Active__c = true,
            Visible__c = true,
            Record_Types_String__c = 'wer',
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
        );
        insert functionalGroup;
        Case_Classification__c category = new Case_Classification__c(
            Name = category1Name,
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        Case_Classification__c category2 = new Case_Classification__c(
            Name = category2Name,
            Active__c = true,
            Visible__c = true,
            Parent__c = functionalGroup.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category')
        );
        insert new List<Case_Classification__c>{ category, category2 };
        Case_Classification__c subcategory = new Case_Classification__c(
            Name = subCategory1Name,
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        Case_Classification__c subcategory2 = new Case_Classification__c(
            Name = subCategory2Name,
            Active__c = true,
            Visible__c = true,
            Parent__c = category.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        Case_Classification__c subcategory3 = new Case_Classification__c(
            Name = subCategory3Name,
            Active__c = true,
            Visible__c = true,
            Parent__c = category2.Id,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category')
        );
        insert new List<Case_Classification__c>{ subcategory, subcategory2, subcategory3 };

        Augmented_Staff_Option__c option1 = new Augmented_Staff_Option__c(
            Name = 'TestAugmntdStfOpt1',
            Category__c = category.Id.to15(),
            Sub_Categories__c = subcategory.Id.to15() + ',' + subcategory2.Id.to15()
        );
        Augmented_Staff_Option__c option2 = new Augmented_Staff_Option__c(
            Name = 'TestAugmntdStfOpt2',
            Category__c = category2.Id.to15(),
            Sub_Categories__c = subcategory3.Id.to15()
        );
        insert new List<Augmented_Staff_Option__c>{ option1, option2 };

        Contact c1 = new Contact(
            FirstName = 'test',
            LastName = 'rtn-augmentedstaffcasecontroller',
            Email = 'test@email.rtn.test',
            EmplId__c = c1_EMPLID
        );
        Contact c2 = new Contact(
            FirstName = 'test',
            LastName = 'rtn-augmentedstaffcasecontroller',
            Email = 'test@email.rtn.test',
            ASURite_ID__c = c2_ASURiteId
        );
        insert new List<Contact>{ c1, c2 };

        User u1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user.Emperor.Of.Byzantium@test.test',
            Email = 'test.user@test.test',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        User u2 = new User(
            FirstName = 'Test2',
            LastName = 'User',
            Username = 'test.user.Emperor.Of.Byzantium2@test.test',
            Email = 'test.user2@test.test',
            Alias = 'testuse2',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert new List<User>{ u1, u2 };

        PermissionSet ps1 = new PermissionSet(Name = 'testPermSet', Label = 'testPermSet');
        System.runAs(runAsUser) {
            insert ps1;
        }
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'Augmented_Staff_Case_Creation' LIMIT 1];

        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = ps1.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps2.Id);
        System.runAs(runAsUser) {
            insert new List<PermissionSetAssignment>{ psa1, psa2 };
        }
    }

    @isTest
    public static void testPermission() {
        User noPerm = [SELECT Id FROM User WHERE Alias = 'testuser' LIMIT 1];
        User hasPerm = [SELECT Id FROM User WHERE Alias = 'testuse2' LIMIT 1];

        System.runAs(noPerm) {
            Boolean shouldBeFalse = AugmentedStaffCaseController.doesUserHavePermission();
            System.assert(!shouldBeFalse, 'This user should NOT have permission');
        }

        System.runAs(hasPerm) {
            Boolean shouldBeTrue = AugmentedStaffCaseController.doesUserHavePermission();
            System.assert(shouldBeTrue, 'This user should have permission');
        }
    }

    @isTest
    public static void testVerifyStudentId() {
        System.assert(AugmentedStaffCaseController.verifyStudentId(c1_EMPLID));
        System.assert(AugmentedStaffCaseController.verifyStudentId(c2_ASURiteId));
        System.assert(!AugmentedStaffCaseController.verifyStudentId('FAKE_ID'));
    }

    @isTest
    public static void testCategories() {
        List<AugmentedStaffCaseController.OptionWrapper> categoryOptions = AugmentedStaffCaseController.getCategories();
        System.assertEquals(2, categoryOptions.size());
        System.assert(containsLabel(categoryOptions, category1Name));
        System.assert(containsLabel(categoryOptions, category2Name));

        for (AugmentedStaffCaseController.OptionWrapper categoryOption : categoryOptions) {
            if (categoryOption.label == category1Name) {
                List<AugmentedStaffCaseController.OptionWrapper> subCategoryOptions = AugmentedStaffCaseController.getSubCategories(
                    categoryOption.value
                );
                System.assertEquals(2, subCategoryOptions.size());
                System.assert(containsLabel(subCategoryOptions, subCategory1Name));
                System.assert(containsLabel(subCategoryOptions, subCategory2Name));
            } else if (categoryOption.label == category2Name) {
                List<AugmentedStaffCaseController.OptionWrapper> subCategoryOptions = AugmentedStaffCaseController.getSubCategories(
                    categoryOption.value
                );
                System.assertEquals(1, subCategoryOptions.size());
                System.assert(containsLabel(subCategoryOptions, subCategory3Name));
            } else {
                System.assert(false, 'Should not run, as all categories should be handled');
            }
        }
    }

    @isTest
    public static void testCreateCase() {
        Id categoryId = [SELECT Id FROM Case_Classification__c WHERE Name = :category1Name LIMIT 1].Id;
        Id subCategoryId = [SELECT Id FROM Case_Classification__c WHERE Name = :subCategory2Name LIMIT 1].Id;
        Contact con = [SELECT Id, ASURite_ID__c FROM Contact WHERE ASURite_Id__c = :c2_ASURiteId LIMIT 1];
        String description = 'DESC_123';
        String phoneNumber = '9993450120';

        AugmentedStaffCaseController.createTheCase(
            description,
            categoryId,
            subCategoryId,
            phoneNumber,
            con.ASURite_Id__c,
            true
        );

        Case c = [SELECT Id, Subject, Description, ContactId, Status FROM Case LIMIT 1];
        System.assertEquals('Augmented Support', c.Subject);
        System.assertEquals(description + '\n\nBest Phone Number: ' + phoneNumber, c.Description);
        System.assertEquals(con.Id, c.ContactId);
        System.assertEquals('Closed: Resolved', c.Status);
    }

    private static boolean containsLabel(List<AugmentedStaffCaseController.OptionWrapper> optionList, String label) {
        for (AugmentedStaffCaseController.OptionWrapper option : optionList) {
            if (option.label == label) {
                return true;
            }
        }
        return false;
    }
}
