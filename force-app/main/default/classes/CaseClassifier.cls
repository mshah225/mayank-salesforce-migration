/**
 *	Class to manage re-classifying cases that have no classifications in the new CC_ fields.
 *	To Use: construct with the case in question, call classifyCase.
 *	Required fields: Functional_Group__c, Category__c, Sub_Category__c
 */
public without sharing class CaseClassifier {
    private Case caseToClassify;
    private Set<String> missingClassifications;
    private Boolean invalidFunctionalGroup = false;
    private Boolean invalidCategory = false;
    private Boolean invalidSubCategory = false;

    public CaseClassifier(Case caseToClassify) {
        this.caseToClassify = caseToClassify;
        missingClassifications = new Set<String>();

        if (caseToClassify.Functional_Group__c != null && caseToClassify.CC_Functional_Group__c == null) {
            missingClassifications.add(caseToClassify.Functional_Group__c);
            invalidFunctionalGroup = true;
        }
        if (caseToClassify.Category__c != null && caseToClassify.CC_Category__c == null) {
            missingClassifications.add(caseToClassify.Category__c);
            invalidCategory = true;
        }
        if (caseToClassify.Sub_Category__c != null && caseToClassify.CC_Sub_Category__c == null) {
            missingClassifications.add(caseToClassify.Sub_Category__c);
            invalidSubCategory = true;
        }
    }

    public Set<String> getMissingClassifications() {
        return missingClassifications;
    }

    public Boolean hasInvalidCaseClassification() {
        return caseToClassify.CC_Functional_Group__c == null;
    }

    public Case classifyCase(Map<String, Case_Classification__c> nameToClassification) {
        if (invalidFunctionalGroup) {
            Case_Classification__c classification = nameToClassification.get(
                CaseClassifier.getClassificationUniqueName(
                    caseToClassify.Functional_Group__c,
                    '',
                    '',
                    'Functional Group'
                )
            );
            caseToClassify.CC_Functional_Group__c = classification == null ? null : classification.Id;
        }
        if (invalidCategory) {
            Case_Classification__c classification = nameToClassification.get(
                CaseClassifier.getClassificationUniqueName(
                    caseToClassify.Category__c,
                    caseToClassify.Functional_Group__c,
                    '',
                    'Category'
                )
            );
            caseToClassify.CC_Category__c = classification == null ? null : classification.Id;
        }
        if (invalidSubCategory) {
            Case_Classification__c classification = nameToClassification.get(
                CaseClassifier.getClassificationUniqueName(
                    caseToClassify.Sub_Category__c,
                    caseToClassify.Category__c,
                    caseToClassify.Functional_Group__c,
                    'Sub Category'
                )
            );
            caseToClassify.CC_Sub_Category__c = classification == null ? null : classification.Id;
        }

        return caseToClassify;
    }

    public static String getClassificationUniqueName(
        String name,
        String parentName,
        String parentsParentName,
        String recordTypeName
    ) {
        String uniqueName = '';
        uniqueName += name;
        uniqueName += parentName;
        uniqueName += parentsParentName;
        uniqueName += recordTypeName;
        return uniqueName;
    }
}
