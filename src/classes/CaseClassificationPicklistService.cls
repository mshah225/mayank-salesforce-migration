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
        set;
    }
    
    public String selectedCategory {
        get {
            if (selectedCategory == null) {
                selectedCategory = '--';
            }
            return selectedCategory;
        }
        set;
    }

    public String selectedSubCategory {
        get {
            if (selectedSubCategory == null) {
                selectedSubCategory = '--';
            }
            return selectedSubCategory;
        }
        set;
    }

    public List<SelectOption> functionalGroupOptions {
        get {
            if (functionalGroupOptions == null) {
                functionalGroupOptions = new List<SelectOption>();
                functionalGroupOptions.add(new SelectOption('--', '--', true));
                for (String functionalGroupOption : allFunctionalGroups.keyset()) {
                    functionalGroupOptions.add(new SelectOption(functionalGroupOption, functionalGroupOption, false));
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
        Id functionalGroupRecordType = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group');
        List<Case_Classification__c> functionalGroups = [
            SELECT Name
            FROM Case_Classification__c
            WHERE RecordTypeId =: functionalGroupRecordType
            AND Active__c =: TRUE
            AND Visible__c =: TRUE
            ORDER By Name
        ];
        Map<String, Case_Classification__c> allFgs = new Map<String, Case_Classification__c>();                                        
        for (Case_Classification__c functionalGroup : functionalGroups) {
            allFgs.put(functionalGroup.Name, functionalGroup);
        }
        return allFgs;
    }
    
    private Map<String, Map<String, Case_Classification__c>> fetchAllCategoriesAndMapToFunctionalGroup() {
        Map<String, Map<String, Case_Classification__c>> categoryToFunctionalGroup = new Map<String, Map<String, Case_Classification__c>>();
        Id categoryRecordType = IDHelper.getRecordTypeId('Case_Classification__c', 'Category');
        List<Case_Classification__c> categories = [
            SELECT Name, Parent__c, Parent__r.Name, Default_Case_Description__c
            FROM Case_Classification__c
            WHERE RecordTypeId =: categoryRecordType
            AND Active__c =: TRUE
            AND Visible__c =: TRUE
            ORDER By Parent__c, Parent__r.Name, Name
        ];
        if (!categories.isEmpty()) {
            Map<String, Case_Classification__c> uniqueParentMap = new Map<String, Case_Classification__c>();
            uniqueParentMap.put('--', null);
            String currentParent = categories[0].Parent__r.Name;
            for (Case_Classification__c cat : categories) {
                if (currentParent == cat.Parent__r.Name) {
                    uniqueParentMap.put(cat.Name, cat);
                } else {
                    categoryToFunctionalGroup.put(currentParent, uniqueParentMap);
                    uniqueParentMap = new Map<String, Case_Classification__c>();
                    uniqueParentMap.put('--', null);
                    currentParent = cat.Parent__r.Name;
                    uniqueParentMap.put(cat.Name, cat);
                }
            }
            categoryToFunctionalGroup.put(currentParent, uniqueParentMap);

            Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
            noSelectOption.put('--', null);
            categoryToFunctionalGroup.put('--',  noSelectOption);
        }
        for (String functionalGroupName : allFunctionalGroups.keySet()) {
            if (categoryToFunctionalGroup.get(functionalGroupName) == null ) {
            Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
            noSelectOption.put('--', null);
            categoryToFunctionalGroup.put(functionalGroupName, noSelectOption);
            }
        }
        return categoryToFunctionalGroup;
    }
    
    private Map<String, Map<String, Case_Classification__c>> fetchAllSubCategoriesAndMapToCategories() {
        Map<String, Map<String, Case_Classification__c>> subCategoriesToCategory = new Map<String, Map<String, Case_Classification__c>>();
        Id subCategoryRecordType = IDHelper.getRecordTypeId('Case_Classification__c', 'Sub_Category');
        List<Case_Classification__c> subCategories = [
            SELECT Name, Parent__c, Parent__r.Name
            FROM Case_Classification__c
            WHERE RecordTypeId =: subCategoryRecordType
            AND Active__c =: TRUE
            AND Visible__c =: TRUE
            ORDER By Parent__c, Parent__r.Name, Name
        ];
        if (!subCategories.isEmpty()) {
            Map<String, Case_Classification__c> uniqueParentMap = new Map<String, Case_Classification__c>();
            uniqueParentMap.put('--', null);
            String currentParentId = subCategories[0].Parent__c;
            for (Case_Classification__c subCat : subCategories) {
                if (currentParentId == subCat.Parent__c) {
                    uniqueParentMap.put(subCat.Name, subCat);
                } else {
                    subCategoriesToCategory.put(currentParentId, uniqueParentMap);
                    uniqueParentMap = new Map<String, Case_Classification__c>();
                    uniqueParentMap.put('--', null);
                    currentParentId = subCat.Parent__c;
                    uniqueParentMap.put(subCat.Name, subCat);
                }
            }
            subCategoriesToCategory.put(currentParentId, uniqueParentMap);

            Map<String, Case_Classification__c> noSelectOption = new Map<String, Case_Classification__c>();
            noSelectOption.put('--', null);
            subCategoriesToCategory.put('--',  noSelectOption);
        }
        return subCategoriesToCategory;
    }
    
    private List<SelectOption> setOptionsForCategory() {
        List<SelectOption> optionsForCategory = new List<SelectOption>();
        if (allCategories != null && selectedFunctionalGroup != null) {
            Map<String, Case_Classification__c> categoriesForFunctionalGroup = allCategories.get(selectedFunctionalGroup);
            if (categoriesForFunctionalGroup != null && !categoriesForFunctionalGroup.isEmpty()) {
                for (String categoryOption : categoriesForFunctionalGroup.keySet()) {
                    if (categoryOption.equals('--')) {
                        optionsForCategory.add(new SelectOption('--', '--', false));
                    } else {
                        optionsForCategory.add(new SelectOption(categoriesForFunctionalGroup.get(categoryOption).Id, categoryOption, false));
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
                    optionsForSubCategory.add(new SelectOption(subCategoryOption, subCategoryOption, false));
                }
            } else {
                optionsForSubCategory.add(new SelectOption('--', '--', false));
            }
        } else {
            optionsForSubCategory.add(new SelectOption('--', '--', false));
        }
        return optionsForSubCategory;
    }
    
    public PageReference updateCategoryAndSubCategory() {
        updateCategories();
        updateOnCategoryChange();
        return null;
    }
    
    public PageReference updateCategories() {
        categoryOptions = setOptionsForCategory();
        selectedCategory = '--';
        return null;
    }

    public PageReference updateOnCategoryChange() {
        updateSubCategories();
        return null;
    }
    
    public PageReference updateSubCategories() {
        subCategoryOptions = setOptionsForSubCategory();
        return null;
    }
    
    public void addCaseClassificationToCase(Case caseToAddClassification) {
        Case_Classification__c functionalGroupToAdd = allFunctionalGroups.get(selectedFunctionalGroup);

        if (functionalGroupToAdd != null) {
            caseToAddClassification.CC_Functional_Group__c = functionalGroupToAdd.Id;
            if (allCategories.get(functionalGroupToAdd.Name) == NULL || selectedCategory.equals('--')) {
                caseToAddClassification.CC_Category__c = null;
            } else {
                String categoryName = [SELECT Name FROM Case_Classification__c WHERE Id =: selectedCategory].Name;
                Case_Classification__c categoryToAdd = allCategories.get(functionalGroupToAdd.Name).get(categoryName);
                if (categoryToAdd != null) {
                    caseToAddClassification.CC_Category__c = categoryToAdd.Id;
                    if (allSubCategories.get(selectedCategory) == NULL) {
                        caseToAddClassification.CC_Sub_Category__c = null;
                    } else {
                        Case_Classification__c subCategoryToAdd = allSubCategories.get(categoryToAdd.Id).get(selectedSubCategory);
                        if (subCategoryToAdd != null) {
                            caseToAddClassification.CC_Sub_Category__c = subCategoryToAdd.Id;
                        } else {
                            caseToAddClassification.CC_Sub_Category__c = null;
                        }
                    }
                } else {
                    caseToAddClassification.CC_Category__c = null;
                }
            }
        }
    }
}