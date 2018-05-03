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
}