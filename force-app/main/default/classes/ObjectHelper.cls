/**
 * A helper class providing utility methods for working with Salesforce objects and data categories.
 */
public with sharing class ObjectHelper {
    private static final Boolean DEBUG = false;

    /**
     * Get the DescribeFieldResult for a field on an object by passing the field's path.
     * You can pass the path, either as a SOQL-compliant field path (Contact.Name) or as a JSON selector
     * string ($.Contact.Name).
     * Throws exception if the name is invalid, or if the path is invalid.
     *
     * Caches results - performance is primairly dependent on if the value is cached
     * If it is cached, then it is practically immediately, taking around .025 ms (40/ms)
     * If it is not cached, performance if much slower, starting at 200ms, and increasing
     * as the path's depth increases.
     *
     *  DEPTH       FIRST CALL
     *    1           200ms
     *    2           220ms
     *    3           260ms
     *    4           430ms
     *    5           480ms
     *
     * @param objectName The object name (e.g. "Case")
     * @param path The path you want to read (e.g. "$.Contact.Name)
     * @return The Schema.DescribeFieldResult of the field requested
     * @throws ObjectHelperFieldPathException If the path is invalid
     * @throws ObjectHelperObjectNameException If the object name is invalid
     */
    public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String path) {
        // Check cache first
        if (isInFieldDescribeCache(objectName, path)) {
            return getFromFieldDescribeCache(objectName, path);
        }

        // no null values - throw errors
        if (!validSObjectType(objectName)) {
            ObjectHelperObjectNameException ex = new ObjectHelperObjectNameException(
                'Tried to read path from object of type ' + objectName + ', but no such type exists'
            );
            addToFieldDescribeCache(objectName, path, ex);
            throw ex;
        }
        if (String.isBlank(path)) {
            ObjectHelperFieldPathException ex = new ObjectHelperFieldPathException(
                'Tried to read empty path from object of type ' + objectName + ', but path must not be empty'
            );
            addToFieldDescribeCache(objectName, path, ex);
            throw ex;
        }
        // Asking for root element - error
        if (path == '$') {
            ObjectHelperFieldPathException ex = new ObjectHelperFieldPathException(
                'Tried to read path ' + path + ' from object of type ' + objectName + ' but cannot ask for root element'
            );
            addToFieldDescribeCache(objectName, path, ex);
            throw ex;
        }
        // Traverse record
        List<String> pathComponents = (path.startsWith('$.') ? path.substringAfter('$.') : path).split('\\.');
        Schema.DescribeSObjectResult descrIter = Schema.getGlobalDescribe().get(objectName).getDescribe();
        for (Integer i = 0; i < pathComponents.size() - 1; i++) {
            String step = pathComponents[i];

            Schema.DescribeFieldResult dfr = getDescribeFromLookupName(descrIter, step);

            if (dfr == null) {
                ObjectHelperFieldPathException ex = new ObjectHelperFieldPathException(
                    'Tried to read path ' +
                        path +
                        ' from object of type ' +
                        objectName +
                        ' but failed to read at step ' +
                        step +
                        ' as this field does not exist or is not a lookup field'
                );
                addToFieldDescribeCache(objectName, path, ex);
                throw ex;
            }

            // if the lookup is to mulitple types we just look at first type
            descrIter = dfr.getReferenceTo()[0].getDescribe();
        }

        // Final step, field exists?
        String step = pathComponents[pathComponents.size() - 1];
        Map<String, Schema.SObjectField> fldMp = descrIter.fields.getMap();
        if (!fldMp.containsKey(step)) {
            ObjectHelperFieldPathException ex = new ObjectHelperFieldPathException(
                'Tried to read path ' +
                    path +
                    ' from object of type ' +
                    objectName +
                    ' but failed to read at step ' +
                    step +
                    ' as this field does not exist'
            );
            addToFieldDescribeCache(objectName, path, ex);
            throw ex;
        }

        // Return value
        Schema.DescribeFieldResult v = fldMp.get(step).getDescribe();
        addToFieldDescribeCache(objectName, path, v);
        return v;
    }
    private static Boolean isInFieldDescribeCache(String objectName, String path) {
        return getFieldDescribeCache?.get(objectName)?.containsKey(path) == true;
    }
    private static Schema.DescribeFieldResult getFromFieldDescribeCache(String objectName, String path) {
        if (!isInFieldDescribeCache(objectName, path))
            throw new ObjectHelperCacheException(
                'Tried geting ' + objectName + ' ' + path + 'from cache but it is not in the cache'
            );

        Object o = getFieldDescribeCache?.get(objectName)?.get(path);

        if (o == null || o instanceof Schema.DescribeFieldResult) {
            return (Schema.DescribeFieldResult) o;
        } else if (o instanceof Exception) {
            throw (Exception) o;
        } else {
            throw new ObjectHelperCacheException(
                'Tried geting ' + objectName + ' ' + path + 'from cache but an illegal value was found in the cache'
            );
        }
    }
    private static void addToFieldDescribeCache(String objectName, String path, Object o) {
        if (!getFieldDescribeCache.containsKey(objectName))
            getFieldDescribeCache.put(objectName, new Map<String, Object>());
        getFieldDescribeCache.get(objectName).put(path, o);
    }
    private static Map<String, Map<String, Object>> getFieldDescribeCache = new Map<String, Map<String, Object>>();

    /**
     * If we are doing a lookup field, we will have something like "Contact" or "Student__r", while the field name is
     * "ContactId" or "Student__c". There are two formats possible - either it is a standard field, in which case we
     * need to add "Id" to the end, or it is a custom field and we need to convert "__r" to "__c".
     *
     * @param descr The object we are examining
     * @param lookupName The name of the lookup field
     * @return The field result if it exists, or null otherwise
     */
    public static Schema.DescribeFieldResult getDescribeFromLookupName(
        Schema.DescribeSObjectResult descr,
        String lookupName
    ) {
        String v = null;

        if (lookupName.endsWith('__r'))
            v = lookupName.substringBeforeLast('__r') + '__c';
        else
            v = lookupName + 'Id';

        return descr.fields.getMap().get(v)?.getDescribe();
    }

    /**
     * Checks if an SObject type exists in the org
     */
    public static Boolean validSObjectType(String objectName) {
        return Schema.getGlobalDescribe().containsKey(objectName);
    }

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
     * @return A map containing the fields in the field set and the object label.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFieldsFromFieldSet(String objectName, String fieldSetName) {
        if (!String.isEmpty(objectName) && !String.isEmpty(fieldSetName)) {
            Map<String, Object> returnMap = new Map<String, Object>();
            SObject objectToCheck = (SObject) (Type.forName('Schema.' + objectName)?.newInstance());

            String objectLabel = objectToCheck?.getSObjectType()?.getDescribe()?.getLabel();
            List<Schema.FieldSetMember> fieldsInFieldSet = objectToCheck
                ?.getSObjectType()
                ?.getDescribe()
                ?.fieldSets.getMap()
                .get(fieldSetName)
                ?.getFields();

            List<FieldSetMemberWrapper> fieldSetMemberWrappers = new List<FieldSetMemberWrapper>();
            for (Schema.FieldSetMember fsm : fieldsInFieldSet)
                fieldSetMemberWrappers.add(new FieldSetMemberWrapper(fsm));

            returnMap.put('OBJECT_LABEL', objectLabel);
            returnMap.put('OBJECT_NAME', objectName);
            returnMap.put('FIELD_SET_NAME', fieldSetName);
            returnMap.put('FIELD_LIST', fieldSetMemberWrappers);

            return returnMap;
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

    public class ObjectHelperFieldPathException extends Exception {
    }
    public class ObjectHelperObjectNameException extends Exception {
    }
    public class ObjectHelperCacheException extends Exception {
    }
    /**
     * Wrapper class for FieldSetMember objects.
     * Provides Aura-enabled properties to facilitate usage in Lightning components.
     */
    public class FieldSetMemberWrapper {
        @AuraEnabled
        public Boolean dbRequired;

        @AuraEnabled
        public String fieldPath;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public Boolean required;

        @AuraEnabled
        public String type;

        @AuraEnabled
        public String typeApex;

        public FieldSetMemberWrapper(Schema.FieldSetMember fldSetMember) {
            this.dbRequired = fldSetMember?.getDBRequired();
            this.fieldPath = fldSetMember?.getFieldPath();
            this.label = fldSetMember?.getLabel();
            this.required = fldSetMember?.getRequired();
            this.type = fldSetMember?.getType()?.name()?.toLowerCase();
            this.typeApex = fldSetMember?.getType()?.name();
        }
    }
}
