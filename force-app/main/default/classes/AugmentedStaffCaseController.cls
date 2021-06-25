public without sharing class AugmentedStaffCaseController {
    @AuraEnabled
    public static Boolean doesUserHavePermission() {
        List<PermissionSetAssignment> lstcurrentUserPerSet = [
            SELECT Id, PermissionSet.Name, AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :Userinfo.getUserId()
        ];
        for (PermissionSetAssignment psa : lstcurrentUserPerSet) {
            if (psa.PermissionSet.Name.equals('Augmented_Staff_Case_Creation'))
                return true;
        }

        return false;
    }

    @AuraEnabled
    public static Map<String, List<String>> categoryToSubCategoryMap {
        get {
            if (categoryToSubCategoryMap == null) {
                List<Augmented_Staff_Option__c> staffOptions = [
                    SELECT Category__c, Sub_Categories__c
                    FROM Augmented_Staff_Option__c
                ];
                categoryToSubCategoryMap = new Map<String, List<String>>();
                for (Augmented_Staff_Option__c option : staffOptions) {
                    if (option.Sub_Categories__c != null) {
                        List<String> subCategories = option.Sub_Categories__c.split(',');
                        categoryToSubCategoryMap.put(option.Category__c, subCategories);
                    } else {
                        categoryToSubCategoryMap.put(option.Category__c, null);
                    }
                }
            }

            return categoryToSubCategoryMap;
        }
        set;
    }

    @AuraEnabled
    public static Boolean verifyStudentId(String studentId) {
        List<Contact> student = [
            SELECT Id
            FROM Contact
            WHERE EMPLID__c = :studentID OR ASURite_ID__c = :studentID
            LIMIT 1
        ];

        return student.size() > 0;
    }

    @AuraEnabled
    public static List<OptionWrapper> getCategories() {
        List<OptionWrapper> categoryOptions = new List<OptionWrapper>();
        Set<String> categoryIds = categoryToSubCategoryMap.keyset();
        List<Case_Classification__c> categoryDetails = [
            SELECT Id, Name
            FROM Case_Classification__c
            WHERE Id IN :categoryIds
            ORDER BY Name
        ];

        for (Case_Classification__c detail : categoryDetails) {
            String convertedId = (String) detail.Id;
            convertedId = convertedId.left(15);
            categoryOptions.add(new OptionWrapper(detail.Name, convertedId, false));
        }

        return categoryOptions;
    }

    @AuraEnabled
    public static List<OptionWrapper> getSubCategories(String category) {
        List<OptionWrapper> subCategoryOptions = new List<OptionWrapper>();
        List<String> subCategoryIds = categoryToSubCategoryMap.get(category);
        List<Case_Classification__c> subCategoryDetails = [
            SELECT Id, Name
            FROM Case_Classification__c
            WHERE Id IN :subCategoryIds
            ORDER BY Name
        ];

        for (Case_Classification__c detail : subCategoryDetails) {
            String convertedId = (String) detail.Id;
            convertedId = convertedId.left(15);
            subCategoryOptions.add(new OptionWrapper(detail.Name, convertedId, false));
        }

        return subCategoryOptions;
    }

    @AuraEnabled
    public static Boolean createTheCase(
        String description,
        String category,
        String subCategory,
        String phoneNumber,
        String studentID,
        Boolean closed
    ) {
        Id functionalGroup = [
            SELECT Id
            FROM Case_Classification__c
            WHERE Name = 'Help Desk' AND Parent__c = NULL
            LIMIT 1
        ]
        .Id;
        Contact student = [SELECT Id FROM Contact WHERE EMPLID__c = :studentID OR ASURite_ID__c = :studentID LIMIT 1];
        Group helpDeskQueue = [SELECT ID FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Help_Desk_Case' LIMIT 1];

        Case augmentedStaffCase = new Case();
        augmentedStaffCase.Subject = 'Augmented Support';
        augmentedStaffCase.Description = description;
        if (phoneNumber != null) {
            augmentedStaffCase.Description += '\n\nBest Phone Number: ' + phoneNumber;
        }
        augmentedStaffCase.CC_Functional_Group__c = functionalGroup;
        augmentedStaffCase.CC_Category__c = category;
        augmentedStaffCase.CC_Sub_Category__c = subCategory;
        augmentedStaffCase.ContactId = student.Id;
        augmentedStaffCase.Origin__c = 'Incoming Call';
        augmentedStaffCase.OwnerId = helpDeskQueue.Id;
        if (closed != null && closed) {
            augmentedStaffCase.Status = 'Closed: Resolved';
        }

        try {
            insert augmentedStaffCase;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public class OptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean disabled;

        public OptionWrapper(String label, String value, Boolean disabled) {
            this.label = label;
            this.value = value;
            this.disabled = disabled;
        }
    }
}
