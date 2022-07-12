public class CaseClassificationPicklistService {
    public Map<String, Case_Classification__c> allFunctionalGroups {
        get {
            if (allFunctionalGroups == null) {
                allFunctionalGroups = fetchAllFunctionalGroups();
            }
            return allFunctionalGroups;
        }
        set;
    }

    public Map<String, Map<String, Case_Classification__c>> allCategories {
        get {
            if (allCategories == null) {
                allCategories = fetchAllCategoriesAndMapToFunctionalGroup();
            }
            return allCategories;
        }
        set;
    }

    public Map<String, Map<String, Case_Classification__c>> allSubCategories {
        get {
            if (allSubCategories == null) {
                allSubCategories = fetchAllSubCategoriesAndMapToCategories();
            }
            return allSubCategories;
        }
        set;
    }

    public String selectedFunctionalGroup {
        get {
            if (selectedFunctionalGroup == null) {
                selectedFunctionalGroup = '--';
            }
            return selectedFunctionalGroup;
        }
        set {
            if (value == null) {
                selectedFunctionalGroup = '--';
            } else {
                selectedFunctionalGroup = value;
            }
        }
    }

    public String selectedCategory {
        get {
            if (selectedCategory == null) {
                selectedCategory = '--';
            }
            return selectedCategory;
        }
        set {
            if (value == null) {
                selectedCategory = '--';
            } else {
                selectedCategory = value;
            }
        }
    }

    public String selectedSubCategory {
        get {
            if (selectedSubCategory == null) {
                selectedSubCategory = '--';
            }
            return selectedSubCategory;
        }
        set {
            if (value == null) {
                selectedSubCategory = '--';
            } else {
                selectedSubCategory = value;
            }
        }
    }

    public List<SelectOption> functionalGroupOptions {
        get {
            if (functionalGroupOptions == null) {
                functionalGroupOptions = new List<SelectOption>();
                functionalGroupOptions.add(new SelectOption('--', '--', true));
                for (String functionalGroupOption : allFunctionalGroups.keyset()) {
                    functionalGroupOptions.add(
                        new SelectOption(
                            functionalGroupOption,
                            allFunctionalGroups.get(functionalGroupOption).Name,
                            false
                        )
                    );
                }
            }
            return functionalGroupOptions;
        }
        set;
    }

    public List<SelectOption> categoryOptions {
        get {
            if (categoryOptions == null) {
                categoryOptions = setOptionsForCategory();
            }
            return categoryOptions;
        }
        set;
    }

    public List<SelectOption> subCategoryOptions {
        get {
            if (subCategoryOptions == null) {
                subCategoryOptions = setOptionsForSubCategory();
            }
            return subCategoryOptions;
        }
        set;
    }

    private Map<String, Case_Classification__c> fetchAllFunctionalGroups() {
        Id functionalGroupRecordType = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group');
        List<Case_Classification__c> functionalGroups = [
            SELECT Name
            FROM Case_Classification__c
            WHERE RecordTypeId = :functionalGroupRecordType AND Active__c = :true AND Visible__c = :true
            ORDER BY Name
        ];
        Map<String, Case_Classification__c> allFgs = new Map<String, Case_Classification__c>();
        for (Case_Classification__c functionalGroup : functionalGroups) {
            allFgs.put(functionalGroup.Id, functionalGroup);
        }
        return allFgs;
    }

    private Map<String, Map<String, Case_Classification__c>> fetchAllCategoriesAndMapToFunctionalGroup() {
        Map<String, Map<String, Case_Classification__c>> categoryToFunctionalGroup = new Map<String, Map<String, Case_Classification__c>>();
        Id categoryRecordType = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Category');
        List<Case_Classification__c> categories = [
            SELECT Name, Parent__c, Parent__r.Id, Default_Case_Description__c
            FROM Case_Classification__c
            WHERE RecordTypeId = :categoryRecordType AND Active__c = :true AND Visible__c = :true
            ORDER BY Parent__c, Parent__r.Id, Name
        ];
        if (!categories.isEmpty()) {
            Map<String, Case_Classification__c> uniqueParentMap = new Map<String, Case_Classification__c>();
            uniqueParentMap.put('--', null);
            String currentParent = categories[0].Parent__r.Id;
            for (Case_Classification__c cat : categories) {
                if (currentParent == cat.Parent__r.Id) {
                    uniqueParentMap.put(cat.Id, cat);
                } else {
                    categoryToFunctionalGroup.put(currentParent, uniqueParentMap);
                    uniqueParentMap = new Map<String, Case_Classification__c>();
                    uniqueParentMap.put('--', null);
                    currentParent = cat.Parent__r.Id;
                    uniqueParentMap.put(cat.Id, cat);
                }
            }
            categoryToFunctionalGroup.put(currentParent, uniqueParentMap);

            Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
            noSelectOption.put('--', null);
            categoryToFunctionalGroup.put('--', noSelectOption);
        }
        for (String functionalGroupName : allFunctionalGroups.keySet()) {
            if (categoryToFunctionalGroup.get(functionalGroupName) == null) {
                Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
                noSelectOption.put('--', null);
                categoryToFunctionalGroup.put(functionalGroupName, noSelectOption);
            }
        }
        return categoryToFunctionalGroup;
    }

    private Map<String, Map<String, Case_Classification__c>> fetchAllSubCategoriesAndMapToCategories() {
        Map<String, Map<String, Case_Classification__c>> subCategoriesToCategory = new Map<String, Map<String, Case_Classification__c>>();
        Id subCategoryRecordType = RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category');
        List<Case_Classification__c> subCategories = [
            SELECT Name, Parent__c, Parent__r.Name
            FROM Case_Classification__c
            WHERE RecordTypeId = :subCategoryRecordType AND Active__c = :true AND Visible__c = :true
            ORDER BY Parent__c, Parent__r.Id, Name
        ];
        if (!subCategories.isEmpty()) {
            Map<String, Case_Classification__c> uniqueParentMap = new Map<String, Case_Classification__c>();
            uniqueParentMap.put('--', null);
            String currentParentId = subCategories[0].Parent__c;
            for (Case_Classification__c subCat : subCategories) {
                if (currentParentId == subCat.Parent__c) {
                    uniqueParentMap.put(subCat.Id, subCat);
                } else {
                    subCategoriesToCategory.put(currentParentId, uniqueParentMap);
                    uniqueParentMap = new Map<String, Case_Classification__c>();
                    uniqueParentMap.put('--', null);
                    currentParentId = subCat.Parent__c;
                    uniqueParentMap.put(subCat.Id, subCat);
                }
            }
            subCategoriesToCategory.put(currentParentId, uniqueParentMap);

            Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
            noSelectOption.put('--', null);
            subCategoriesToCategory.put('--', noSelectOption);
        }
        return subCategoriesToCategory;
    }

    private List<SelectOption> setOptionsForCategory() {
        List<SelectOption> optionsForCategory = new List<SelectOption>();
        if (allCategories != null && selectedFunctionalGroup != null) {
            Map<String, Case_Classification__c> categoriesForFunctionalGroup = allCategories.get(
                selectedFunctionalGroup
            );
            if (categoriesForFunctionalGroup != null && !categoriesForFunctionalGroup.isEmpty()) {
                for (String categoryOption : categoriesForFunctionalGroup.keySet()) {
                    if (categoryOption.equals('--')) {
                        optionsForCategory.add(new SelectOption('--', '--', false));
                    } else {
                        optionsForCategory.add(
                            new SelectOption(
                                categoryOption,
                                categoriesForFunctionalGroup.get(categoryOption).Name,
                                false
                            )
                        );
                    }
                }
            } else {
                optionsForCategory.add(new SelectOption('--', '--', false));
            }
        } else {
            optionsForCategory.add(new SelectOption('--', '--', false));
        }
        return optionsForCategory;
    }

    private List<SelectOption> setOptionsForSubCategory() {
        List<SelectOption> optionsForSubCategory = new List<SelectOption>();
        if (allSubCategories != null && selectedCategory != null) {
            Map<String, Case_Classification__c> subCategoriesForParent = allsubCategories.get(selectedCategory);

            if (subCategoriesForParent != null && !subCategoriesForParent.isEmpty()) {
                for (String subCategoryOption : subCategoriesForParent.keySet()) {
                    if (subCategoryOption.equals('--')) {
                        optionsForSubCategory.add(new SelectOption('--', '--', false));
                    } else {
                        optionsForSubCategory.add(
                            new SelectOption(
                                subCategoryOption,
                                subCategoriesForParent.get(subCategoryOption).Name,
                                false
                            )
                        );
                    }
                }
            } else {
                optionsForSubCategory.add(new SelectOption('--', '--', false));
            }
        } else {
            optionsForSubCategory.add(new SelectOption('--', '--', false));
        }
        return optionsForSubCategory;
    }

    public void updateCategoryAndSubCategory() {
        categoryOptions = setOptionsForCategory();
        selectedCategory = '--';
        updateSubCategories();
    }

    public void updateSubCategories() {
        subCategoryOptions = setOptionsForSubCategory();
    }

    public void addCaseClassificationToCase(Case caseToAddClassification) {
        Case_Classification__c functionalGroupToAdd = allFunctionalGroups.get(selectedFunctionalGroup);

        if (functionalGroupToAdd == null) {
            return;
        }

        caseToAddClassification.CC_Functional_Group__c = functionalGroupToAdd.Id;
        if (allCategories.get(functionalGroupToAdd.Id) == null || selectedCategory.equals('--')) {
            caseToAddClassification.CC_Category__c = null;
            caseToAddClassification.CC_Sub_Category__c = null;
            return;
        }

        Case_Classification__c categoryToAdd = allCategories.get(functionalGroupToAdd.Id).get(selectedCategory);

        if (categoryToAdd == null) {
            caseToAddClassification.CC_Category__c = null;
            caseToAddClassification.CC_Sub_Category__c = null;
            return;
        }

        caseToAddClassification.CC_Category__c = categoryToAdd.Id;

        if (allSubCategories.get(selectedCategory) == null) {
            caseToAddClassification.CC_Sub_Category__c = null;
            return;
        }

        Case_Classification__c subCategoryToAdd = allSubCategories.get(categoryToAdd.Id).get(selectedSubCategory);
        if (subCategoryToAdd != null) {
            caseToAddClassification.CC_Sub_Category__c = subCategoryToAdd.Id;
        } else {
            caseToAddClassification.CC_Sub_Category__c = null;
        }
    }

    public Map<Id, Case_Classification__c> getCCNames() {
        List<Id> caseClassificationIds = new List<Id>();
        caseClassificationIds.add(selectedFunctionalGroup);
        if (!selectedCategory.equals('--')) {
            caseClassificationIds.add(selectedCategory);
        }
        if (!selectedSubCategory.equals('--')) {
            caseClassificationIds.add(selectedSubCategory);
        }
        return new Map<Id, Case_Classification__c>(
            [SELECT Name FROM Case_Classification__c WHERE Id IN :caseClassificationIds]
        );
    }

    public void setCurrentCaseClassification(Case caseWithDetails) {
        selectedFunctionalGroup = caseWithDetails.CC_Functional_Group__c;
        updateCategoryAndSubCategory();
        selectedCategory = caseWithDetails.CC_Category__c;
        updateSubCategories();
        selectedSubCategory = caseWithDetails.CC_Sub_Category__c;
    }
}
