@isTest
public class CaseClassificationFactory {
    public class DefaultFunctionalGroup extends TestFactory {
        public DefaultFunctionalGroup() {
            super(
                new Case_Classification__c(
                    Name = 'Test Functional Group',
                    RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1]
                    .Id,
                    Active__c = true,
                    Visible__c = true
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class DefaultCategory extends TestFactory {
        public DefaultCategory() {
            super(
                new Case_Classification__c(
                    Name = 'Test Category',
                    RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Category']
                    .Id,
                    Active__c = true,
                    Visible__c = true
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class DefaultSubCategory extends TestFactory {
        public DefaultSubCategory() {
            super(
                new Case_Classification__c(
                    Name = 'Test Sub Category',
                    RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Sub Category']
                    .Id,
                    Active__c = true,
                    Visible__c = true
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class NamedServiceFunctionalGroup extends TestFactory {
        public NamedServiceFunctionalGroup(String name) {
            super(
                new Case_Classification__c(
                    Name = name,
                    RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Functional Group']
                    .Id,
                    Record_Types__c = 'ASU Service',
                    Active__c = true,
                    Visible__c = true
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class NamedCategory extends TestFactory {
        public NamedCategory(Id parent, String name) {
            super(
                new Case_Classification__c(
                    Name = name,
                    RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Category']
                    .Id,
                    Parent__c = parent,
                    Active__c = true,
                    Visible__c = true
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class NotVisibleFunctionalGroup extends TestFactory {
        public NotVisibleFunctionalGroup() {
            super(
                new Case_Classification__c(
                    Name = 'Not Visible Functional Group',
                    RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1]
                    .Id,
                    Active__c = true,
                    Visible__c = false
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class NotVisibleCategory extends TestFactory {
        public NotVisibleCategory() {
            super(
                new Case_Classification__c(
                    Name = 'Not Visible Category',
                    RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Category']
                    .Id,
                    Active__c = true,
                    Visible__c = false
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public class NotVisibleSubCategory extends TestFactory {
        public NotVisibleSubCategory() {
            super(
                new Case_Classification__c(
                    Name = 'Not Visible Sub Category',
                    RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Sub Category']
                    .Id,
                    Active__c = true,
                    Visible__c = false
                )
            );
            this.addToFieldsToIncrement('Name');
        }
    }

    public List<Case_Classification__c> createAndInsertSetOfCaseClassification() {
        List<Case_Classification__c> caseClassificationsToReturn = new List<Case_Classification__c>();
        DefaultFunctionalGroup fgMaker = new DefaultFunctionalGroup();
        Case_Classification__c functionalGroup = (Case_Classification__c) fgMaker.create(1)[0];
        insert functionalGroup;
        caseClassificationsToReturn.add(functionalGroup);

        DefaultCategory catMaker = new DefaultCategory();
        Case_Classification__c category = (Case_Classification__c) catMaker.create(1)[0];
        category.Parent__c = functionalGroup.Id;
        insert category;
        caseClassificationsToReturn.add(category);

        DefaultSubCategory subCatMaker = new DefaultSubCategory();
        Case_Classification__c subCat = (Case_Classification__c) subCatMaker.create(1)[0];
        subCat.Parent__c = category.Id;
        insert subCat;
        caseClassificationsToReturn.add(subCat);

        return caseClassificationsToReturn;
    }

    public List<Case_Classification__c> createAndInsertSetOfAdvisorOutreachCaseClassification() {
        List<Case_Classification__c> caseClassificationsToReturn = new List<Case_Classification__c>();
        CaseClassificationFactory.NamedServiceFunctionalGroup functionalGroupMaker = new CaseClassificationFactory.NamedServiceFunctionalGroup(
            'ASU Advisor Outreach'
        );
        Case_Classification__c advisorFunctionalGroup = (Case_Classification__c) functionalGroupMaker.create(1)[0];
        insert advisorFunctionalGroup;
        caseClassificationsToReturn.add(advisorFunctionalGroup);

        CaseClassificationFactory.NamedCategory outreachCategoryMaker = new CaseClassificationFactory.NamedCategory(
            advisorFunctionalGroup.Id,
            'Outreach'
        );
        Case_Classification__c outreachCategory = (Case_Classification__c) outreachCategoryMaker.create(1)[0];
        insert outreachCategory;
        caseClassificationsToReturn.add(outreachCategory);

        CaseClassificationFactory.NamedCategory watchlistCategoryMaker = new CaseClassificationFactory.NamedCategory(
            advisorFunctionalGroup.Id,
            'Watchlist'
        );
        Case_Classification__c watchlistCategory = (Case_Classification__c) watchlistCategoryMaker.create(1)[0];
        insert watchlistCategory;
        caseClassificationsToReturn.add(watchlistCategory);

        return caseClassificationsToReturn;
    }

    public List<Case_Classification__c> createAndInsertSetOfNotVisibleCaseClassification() {
        List<Case_Classification__c> caseClassificationsToReturn = new List<Case_Classification__c>();
        NotVisibleFunctionalGroup nvfgMaker = new NotVisibleFunctionalGroup();
        Case_Classification__c notVisibleFunctionalGroup = (Case_Classification__c) nvfgMaker.create(1)[0];
        insert notVisibleFunctionalGroup;
        caseClassificationsToReturn.add(notVisibleFunctionalGroup);

        NotVisibleCategory nvcatMaker = new NotVisibleCategory();
        Case_Classification__c notVisibleCategory = (Case_Classification__c) nvcatMaker.create(1)[0];
        notVisibleCategory.Parent__c = notVisibleFunctionalGroup.Id;
        insert notVisibleCategory;
        caseClassificationsToReturn.add(notVisibleCategory);

        NotVisibleSubCategory nvsubCatMaker = new NotVisibleSubCategory();
        Case_Classification__c notVisibleSubCategory = (Case_Classification__c) nvsubCatMaker.create(1)[0];
        notVisibleSubCategory.Parent__c = notVisibleCategory.Id;
        insert notVisibleSubCategory;
        caseClassificationsToReturn.add(notVisibleSubCategory);

        return caseClassificationsToReturn;
    }
}
