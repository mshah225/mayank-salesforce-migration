@isTest
public class CaseClassificationFactory {

    public class DefaultFunctionalGroup extends TestFactory {
        public DefaultFunctionalGroup() {
            super(new Case_Classification__c(
                Name = 'Test Functional Group',
                RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Functional Group' LIMIT 1].Id,
                Active__c = true,
                Visible__c = true
            ));
            this.addToFieldsToIncrement('Name');
        }
    }

    public class DefaultCategory extends TestFactory {
        public DefaultCategory() {

            super(new Case_Classification__c(
                Name = 'Test Category',
                RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Category'].Id,
                Active__c = true,
                Visible__c = true
            ));
            this.addToFieldsToIncrement('Name');
        }
    }

    public class DefaultSubCategory extends TestFactory {
        public DefaultSubCategory() {

            super(new Case_Classification__c(
                Name = 'Test Sub Category',
                RecordTypeId = [SELECT Name, Id FROM RecordType WHERE Name = 'Sub Category'].Id,
                Active__c = true,
                Visible__c = true
            ));
            this.addToFieldsToIncrement('Name');
        }
    }

    public class NamedServiceFunctionalGroup extends TestFactory {
        public NamedServiceFunctionalGroup(String name) {

            super(new Case_Classification__c(
                Name = name,
                RecordTypeId = [Select Id FROM RecordType WHERE Name = 'Functional Group'].Id,
                Record_Types__c = 'ASU Service',
        		Active__c = true,
        		Visible__c = true
            ));
        }
    }

    public class NamedCategory extends TestFactory {
        public NamedCategory(String parent, String name) {

            super(new Case_Classification__c(
                Name = name,
                RecordTypeId = [Select Id FROM RecordType WHERE Name = 'Category'].Id,
                Parent__c = [Select Id FROM Case_Classification__c WHERE Name =: parent].Id,
        		Active__c = true,
        		Visible__c = true
            ));
        }
    }

    public List<Case_Classification__c> createAndInsertSetOfCaseClassification () {
        List<Case_Classification__c> caseClassificationsToReturn = new List<Case_Classification__c>();
        DefaultFunctionalGroup fgMaker = new DefaultFunctionalGroup();
        Case_Classification__c functionalGroup = (Case_Classification__c)fgMaker.create(1)[0];
        insert functionalGroup;
        caseClassificationsToReturn.add(functionalGroup);

        DefaultCategory catMaker = new DefaultCategory();
        Case_Classification__c category = (Case_Classification__c)catMaker.create(1)[0];
        category.Parent__c = functionalGroup.Id;
        insert category;
        caseClassificationsToReturn.add(category);

        DefaultSubCategory subCatMaker = new DefaultSubCategory();
        Case_Classification__c subCat = (Case_Classification__c)subCatMaker.create(1)[0];
        subCat.Parent__c = category.Id;
        insert subCat;
        caseClassificationsToReturn.add(subCat);

        return caseClassificationsToReturn;
    }

    public List<Case_Classification__c> createAndInsertSetOfAdvisorOutreachCaseClassification() {
        List<Case_Classification__c> caseClassificationsToReturn = new List<Case_Classification__c>();
        CaseClassificationFactory.NamedServiceFunctionalGroup functionalGroupMaker = new CaseClassificationFactory.NamedServiceFunctionalGroup('ASU Advisor Outreach');
        Case_Classification__c advisorFunctionalGroup = (Case_Classification__c)functionalGroupMaker.create(1)[0];
        insert advisorFunctionalGroup;
        caseClassificationsToReturn.add(advisorFunctionalGroup);

        CaseClassificationFactory.NamedCategory outreachCategoryMaker = new CaseClassificationFactory.NamedCategory('ASU Advisor Outreach', 'Outreach');
        Case_Classification__c outreachCategory = (Case_Classification__c)outreachCategoryMaker.create(1)[0];
        insert outreachCategory;
        caseClassificationsToReturn.add(outreachCategory);

        CaseClassificationFactory.NamedCategory watchlistCategoryMaker = new CaseClassificationFactory.NamedCategory('ASU Advisor Outreach', 'watchlist');
        Case_Classification__c watchlistCategory = (Case_Classification__c)watchlistCategoryMaker.create(1)[0];
        insert watchlistCategory;
        caseClassificationsToReturn.add(watchlistCategory);

        return caseClassificationsToReturn;
    }
}
