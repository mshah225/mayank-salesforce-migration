/**
 * A helper class providing utility methods for working with Salesforce objects and data categories.
 */
public with sharing class ObjectHelper {
    private static final Boolean DEBUG = false;

    /**
     * Checks if a field exists on a specified Salesforce object.
     *
     * @param objectName The API name of the Salesforce object.
     * @param fieldName The API name of the field to check.
     * @return True if the field exists on the object; false otherwise.
     */
    public static Boolean fieldExistsOnObject(String objectName, String fieldName) {
        return ((SObject) (Type.forName('Schema.' + objectName)?.newInstance()))
            ?.getSObjectType()
            ?.getDescribe()
            ?.fields.getMap()
            ?.keySet()
            ?.contains(fieldName?.toLowerCase());
    }

    /**
     * Retrieves fields from a specified field set on a Salesforce object.
     *
     * @param objectName The API name of the Salesforce object.
     * @param fieldSetName The name of the field set.
     * @return A JSON string containing the fields in the field set and the object label.
     */
    @AuraEnabled(cacheable=true)
    public static String getFieldsFromFieldSet(String objectName, String fieldSetName) {
        if (!String.isEmpty(fieldSetName)) {
            Map<String, String> returnMap = new Map<String, String>();
            SObject objectToCheck = (SObject) (Type.forName('Schema.' + objectName)?.newInstance());

            String objectLabel = objectToCheck?.getSObjectType()?.getDescribe()?.getLabel();
            List<Schema.FieldSetMember> fieldsInFieldSet = objectToCheck
                ?.getSObjectType()
                ?.getDescribe()
                ?.fieldSets.getMap()
                .get(fieldSetName)
                ?.getFields();

            returnMap.put('FIELD_LIST', JSON.serialize(fieldsInFieldSet));
            returnMap.put('OBJECT_LABEL', objectLabel);

            return JSON.serialize(returnMap);
        }
        return null;
    }

    /**
     * Retrieves the data category label based on the object type, data category group, and data category.
     *
     * @param objectType The API name of the Salesforce object type.
     * @param dataCategoryGroup The name of the data category group (without '__c' suffix).
     * @param dataCategory The name of the data category (without '__c' suffix).
     * @return The label of the data category if valid; an empty string otherwise.
     */
    public static String getDataCategoryLabelByName(String objectType, String dataCategoryGroup, String dataCategory) {
        List<DescribeDataCategoryGroupResult> categoryGroups;
        List<Schema.DescribeDataCategoryGroupStructureResult> categoryGroupStructures;

        if (String.isNotBlank(objectType) && String.isNotBlank(dataCategoryGroup) && String.isNotBlank(dataCategory)) {
            try {
                categoryGroups = Schema.describeDataCategoryGroups(new List<String>{ objectType });
                dataCategory = dataCategory.contains('__c') ? dataCategory.split('__')[0] : dataCategory;
                dataCategoryGroup = dataCategoryGroup.contains('__c')
                    ? dataCategoryGroup.split('__')[0]
                    : dataCategoryGroup;

                for (DescribeDataCategoryGroupResult categoryGroup : categoryGroups) {
                    categoryGroupStructures = new List<Schema.DescribeDataCategoryGroupStructureResult>();

                    try {
                        DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
                        pair.setSobject(objectType);
                        pair.setDataCategoryGroupName(categoryGroup.getName());

                        categoryGroupStructures = Schema.describeDataCategoryGroupStructures(
                            new List<DataCategoryGroupSobjectTypePair>{ pair },
                            false
                        );

                        for (
                            DescribeDataCategoryGroupStructureResult categoryGroupStructure : categoryGroupStructures
                        ) {
                            for (Schema.DataCategory allCategories : categoryGroupStructure.getTopCategories()) {
                                for (Schema.DataCategory category : allCategories.getChildCategories()) {
                                    if (category.getName() == dataCategory) {
                                        return category.getLabel();
                                    }
                                }
                            }
                        }
                    } catch (Exception ex) {
                        List<String> vars = new List<String>();
                        vars.add(ErrorLogger.convertStringToJSON('objectType', objectType));
                        vars.add(ErrorLogger.convertStringToJSON('dataCategoryGroup', dataCategoryGroup));
                        vars.add(ErrorLogger.convertStringToJSON('dataCategory', dataCategory));
                        ErrorLogger.log(ex, vars, DEBUG);
                    }
                }
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('objectType', objectType));
                vars.add(ErrorLogger.convertStringToJSON('dataCategoryGroup', dataCategoryGroup));
                vars.add(ErrorLogger.convertStringToJSON('dataCategory', dataCategory));
                ErrorLogger.log(ex, vars, DEBUG);
            }
        }

        return '';
    }

    /**
     * Retrieves a wrapped data category matching the specified label and object type.
     *
     * @param objectType The API name of the Salesforce object type to search within.
     * @param labelName The label name of the data category to find.
     * @return DataCategoryWrapper instance containing category details if found; otherwise an empty DataCategoryWrapper.
     */
    public static DataCategoryWrapper getDataCategoryNameAndGroupByLabel(String objectType, String labelName) {
        List<DescribeDataCategoryGroupResult> categoryGroups;
        List<Schema.DescribeDataCategoryGroupStructureResult> categoryGroupStructures;

        if (String.isNotBlank(objectType) && String.isNotBlank(labelName)) {
            try {
                categoryGroups = Schema.describeDataCategoryGroups(new List<String>{ objectType });

                for (DescribeDataCategoryGroupResult categoryGroup : categoryGroups) {
                    categoryGroupStructures = new List<Schema.DescribeDataCategoryGroupStructureResult>();

                    try {
                        DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
                        pair.setSobject(objectType);
                        pair.setDataCategoryGroupName(categoryGroup.getName());

                        categoryGroupStructures = Schema.describeDataCategoryGroupStructures(
                            new List<DataCategoryGroupSobjectTypePair>{ pair },
                            false
                        );

                        for (
                            DescribeDataCategoryGroupStructureResult categoryGroupStructure : categoryGroupStructures
                        ) {
                            for (Schema.DataCategory allCategories : categoryGroupStructure.getTopCategories()) {
                                for (Schema.DataCategory category : allCategories.getChildCategories()) {
                                    if (category.getLabel() == labelName) {
                                        return new DataCategoryWrapper(
                                            category.getLabel(),
                                            category.getName() + '__c',
                                            categoryGroupStructure.getName() + '__c',
                                            objectType
                                        );
                                    }
                                }
                            }
                        }
                    } catch (Exception ex) {
                        List<String> vars = new List<String>();
                        vars.add(ErrorLogger.convertStringToJSON('objectType', objectType));
                        vars.add(ErrorLogger.convertStringToJSON('labelName', labelName));
                        ErrorLogger.log(ex, vars, DEBUG);
                    }
                }
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('objectType', objectType));
                vars.add(ErrorLogger.convertStringToJSON('labelName', labelName));
                ErrorLogger.log(ex, vars, DEBUG);
            }
        }

        return new DataCategoryWrapper();
    }

    /**
     * Validates if a specified data category exists within a given object type and data category group.
     *
     * @param objectType The API name of the Salesforce object type.
     * @param dataCategoryGroup The name of the data category group (without '__c' suffix).
     * @param dataCategory The name of the data category (without '__c' suffix).
     * @return Boolean indicating if the data category is valid.
     */
    public static Boolean isValidDataCategory(String objectType, String dataCategoryGroup, String dataCategory) {
        List<DescribeDataCategoryGroupResult> categoryGroups;
        List<Schema.DescribeDataCategoryGroupStructureResult> categoryGroupStructures;

        try {
            categoryGroups = Schema.describeDataCategoryGroups(new List<String>{ objectType });
            dataCategory = dataCategory.contains('__c') ? dataCategory.split('__')[0] : dataCategory;
            dataCategoryGroup = dataCategoryGroup.contains('__c')
                ? dataCategoryGroup.split('__')[0]
                : dataCategoryGroup;

            for (DescribeDataCategoryGroupResult categoryGroup : categoryGroups) {
                categoryGroupStructures = new List<Schema.DescribeDataCategoryGroupStructureResult>();

                try {
                    DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
                    pair.setSobject(objectType);
                    pair.setDataCategoryGroupName(categoryGroup.getName());

                    categoryGroupStructures = Schema.describeDataCategoryGroupStructures(
                        new List<DataCategoryGroupSobjectTypePair>{ pair },
                        false
                    );

                    for (DescribeDataCategoryGroupStructureResult categoryGroupStructure : categoryGroupStructures) {
                        if (categoryGroupStructure.getName() != dataCategoryGroup) {
                            continue;
                        }

                        for (Schema.DataCategory allCategories : categoryGroupStructure.getTopCategories()) {
                            for (Schema.DataCategory category : allCategories.getChildCategories()) {
                                if (category.getName() == dataCategory) {
                                    return true;
                                }
                            }
                        }
                    }
                } catch (Exception ex) {
                    List<String> vars = new List<String>();
                    vars.add(ErrorLogger.convertStringToJSON('objectType', objectType));
                    vars.add(ErrorLogger.convertStringToJSON('dataCategoryGroup', dataCategoryGroup));
                    vars.add(ErrorLogger.convertStringToJSON('dataCategory', dataCategory));
                    ErrorLogger.log(ex, vars, DEBUG);
                }
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('objectType', objectType));
            vars.add(ErrorLogger.convertStringToJSON('dataCategoryGroup', dataCategoryGroup));
            vars.add(ErrorLogger.convertStringToJSON('dataCategory', dataCategory));
            ErrorLogger.log(ex, vars, DEBUG);
        }

        return false;
    }

    /**
     * Wrapper class for data category details.
     * Provides Aura-enabled properties to facilitate usage in Lightning components.
     */
    public class DataCategoryWrapper {
        @AuraEnabled
        public String label;

        @AuraEnabled
        public String name;

        @AuraEnabled
        public String parentGroup;

        @AuraEnabled
        public String objectType;

        /**
         * Default constructor initializing an empty instance.
         */
        public DataCategoryWrapper() {
        }

        /**
         * Constructs an instance of DataCategoryWrapper with specific details.
         *
         * @param label The label of the data category.
         * @param name The API name of the data category.
         * @param parentGroup The name of the parent data category group.
         * @param objectType The Salesforce object type associated with this category.
         */
        public DataCategoryWrapper(String label, String name, String parentGroup, String objectType) {
            this.label = label;
            this.name = name;
            this.parentGroup = parentGroup;
            this.objectType = objectType;
        }
    }
}
