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
     * Use this method to update the version of an SObject in a map
     * If the SObject is not in the map (Key is ID), then insert it
     * Otherwise update the fields of the version in the map, with the values set on the sObjDetails
     *
     * @param sObjMap Map<String, SObject> key to SObject map. We want to either insert into this map, or update the SObjects in this map
     * @param sObjDetails The SObject that has details we want to copy over into the version in sObjMap
     */
    public static void updateSObjectInMap(Map<Id, SObject> sObjMap, SObject sObjDetails) {
        Map<String, SObject> sObjMapWithStrKeys = new Map<String, SObject>();
        Map<String, SObject> sObjDetailsInMap = new Map<String, SObject>();

        // make sObjMap with string keys
        for (Id key : sObjMap.keySet())
            sObjMapWithStrKeys.put((String) key, sObjMap.get(key));

        // Create map for sObjDetails
        sObjDetailsInMap.put((String) (sObjDetails.Id), sObjDetails);

        // Do the copy over
        updateSObjectInMap(sObjMapWithStrKeys, sObjDetailsInMap);

        // copy back into id-keyed map
        for (String key : sObjMapWithStrKeys.keySet()) {
            sObjMap.put((Id) key, sObjMapWithStrKeys.get(key));
        }
    }

    /**
     * Use this method to update the version of an SObject in a map
     * For each item in newSObjDetailsMap, if it exists in sObjMap copy the non-null fields from the version in
     * newSObjDetailsMap to the version in sObjMap. If it does not exist, insert the item into sObjMap
     *
     * @param sObjMap Map<String, SObject> key to SObject map. We want to either insert into this map, or update the SObjects in this map
     * @param newSObjDetailsMap Map<String, SObject> key to SObject map. We want to copy the non-null fields for the SObjects in this map
     *                          to their corresponding copy in the sObjMap
     */
    public static void updateSObjectInMap(Map<String, SObject> sObjMap, Map<String, SObject> newSObjDetailsMap) {
        for (String key : newSObjDetailsMap.keySet()) {
            if (!sObjMap.containsKey(key)) {
                // Insert if there is no existing match
                sObjMap.put(key, newSObjDetailsMap.get(key));
            } else {
                // Copy over the details to existing match
                SObject newSObjDetails = newSObjDetailsMap.get(key);
                SObject curSObjDetails = sObjMap.get(key);

                updateNonNullFields(curSObjDetails, newSObjDetails);
            }
        }
    }

    /**
     * Copy any non-null fields from sObjDetails to sObjBase
     * @param sObjBase SObject the object that we want to modify
     * @param sObjDetails SObject the object that contains values we want to copy over to sObjBase
     */
    public static void updateNonNullFields(SObject sObjBase, SObject sObjDetails) {
        Schema.SObjectType objectType = sObjDetails.getSObjectType();
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        // check each field on object
        for (Schema.SObjectField field : fieldMap.values()) {
            String fieldName = field.getDescribe().getName(); // field name
            Object newValue = null;
            Object curValue = null;

            try {
                newValue = sObjDetails.get(fieldName); // new value for field
                curValue = sObjBase.get(fieldName); // current value for field
            } catch (System.SObjectException ex) {
                // SObject row was retrieved via SOQL without the field - that's fine
            }

            // If being changed to something other than null, set it on the SObject in the map
            if (newValue != null && newValue != curValue) {
                sObjBase.put(fieldName, newValue);
            }
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
