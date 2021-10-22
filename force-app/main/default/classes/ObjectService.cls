public class ObjectService {
    static Integer s_num = 1;

    /**
     * Returns all the fields for a specified object
     * @param An object API name
     * @return A map containing the fields of the specified object
     */
    public static Map<String, SObjectField> getObjectFieldMap(String objectName) {
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();

        return fields;
    }

    /**
     * Returns all the fields on an object in a string delimited by ','
     * @param A map containing the fields of an object
     * @return A string of the field names
     */
    public static String objectFieldsToString(Map<String, SObjectField> objectFieldMap) {
        String fieldsToString = null;

        Set<String> fieldSet = objectFieldMap.keySet();
        for (String s : fieldSet) {
            SObjectField fieldToken = objectFieldMap.get(s);
            DescribeFieldResult selectedField = fieldToken.getDescribe();

            if (fieldsToString == null) {
                fieldsToString = selectedField.getName();
            } else {
                fieldsToString = fieldsToString + ', ' + selectedField.getName();
            }
        }

        return fieldsToString;
    }

    /**
     * Returns all the fields on an object in a string delimited by ','
     * Overload of String objectFieldsToString
     * @param An object API name
     * @return A string of the field names
     */
    public static String objectFieldsToString(String objectName) {
        String fieldsToString = null;

        Map<String, SObjectField> objectFieldMap = getObjectFieldMap(objectName);

        Set<String> fieldSet = objectFieldMap.keySet();
        for (String s : fieldSet) {
            SObjectField fieldToken = objectFieldMap.get(s);
            DescribeFieldResult selectedField = fieldToken.getDescribe();

            if (fieldsToString == null) {
                fieldsToString = selectedField.getName();
            } else {
                fieldsToString = fieldsToString + ', ' + selectedField.getName();
            }
        }

        return fieldsToString;
    }

    /**
     * Returns a string list of all the fields for an object
     * @param The object API Name
     * @return A string list of all field names for the object
     */
    public static List<String> getFieldLabelsToList(String objectName) {
        Map<String, Schema.SObjectField> obFields = getObjectFieldMap(objectName);

        List<String> fieldLabelsToList = new List<String>();
        for (String obf : obFields.keySet()) {
            fieldLabelsToList.add(obFields.get(obf).getDescribe().getLabel());
        }
        fieldLabelsToList.sort();

        return fieldLabelsToList;
    }

    /**
     * Generates a fake Id for the given object type
     * Comes from this SE post: http://salesforce.stackexchange.com/questions/21137/creating-unit-tests-without-interacting-with-the-database-creating-fake-ids
     * DO NOT INSERT RECORDS WITH FAKE IDS INTO DB. It will error.
     * @param sot A Schema.SObjectType
     * @return String A fake Id for the given SObjectType
     */
    public static String getFakeId(Schema.SObjectType sot) {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    /**
     * Returns the keyPrefix of the desired SObjectType
     * @param sot A Schema.SObjectType
     * @return String The the keyprefix for the passed object type
     */
    public static String getKeyPrefix(Schema.SObjectType sot) {
        return sot.getDescribe().getKeyPrefix();
    }

    /**
     * Generates a uuid
     * @return guid A string guid
     */
    public static String getGuid() {
        Blob blobby = Crypto.generateAesKey(128);
        return EncodingUtil.convertToHex(blobby);
    }

    /**
     * Use this method to prevent the ListException: Duplicate id in list
     * @param objs List<SObject>
     * @param objToAdd SObject
     */
    public static void addToListSafely(List<SObject> objs, SObject objToAdd) {
        boolean safeToAdd = true;

        for (SObject obj : objs) {
            if (obj.Id == objToAdd.Id) {
                safeToAdd = false;
            }
        }

        if (safeToAdd) {
            objs.add(objToAdd);
        }
    }

    /**
     * Get the map of the active picklist values from the picklist field of some object
     * this maps the label of each entry to it's respective value (repeated labels would cause issues)
     */
    public static Map<String, String> getPicklistChoicesMap(String objectName, String field) {
        Map<String, String> labelToValue = new Map<String, String>();
        Schema.DescribeSobjectResult describeObject = Schema.describeSObjects(new List<String>{ objectName })[0];
        List<Schema.PicklistEntry> picklistOptions = describeObject.fields.getMap()
            .get(field)
            .getDescribe()
            .getPicklistValues();
        for (Schema.PicklistEntry picklistItem : picklistOptions) {
            if (picklistItem.isActive())
                labelToValue.put(picklistItem.getLabel(), picklistItem.getValue());
        }
        return labelToValue;
    }
    /**
     * Get the list of SelectOptions of the active picklist values from the picklist field of some object
     */
    public static List<SelectOption> getPicklistChoicesSelectList(String objectName, String field) {
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        Map<String, String> labelToValue = getPicklistChoicesMap(objectName, field);
        for (String label : labelToValue.keySet()) {
            optionsToReturn.add(new SelectOption(labelToValue.get(label), label));
        }
        return optionsToReturn;
    }

    public class ObjectServiceException extends Exception {
    }
}
