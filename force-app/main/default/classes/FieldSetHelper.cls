public with sharing class FieldSetHelper {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFieldsFromFieldSet(String objectName, String fieldSetName) {
        try {
            if (!String.isEmpty(objectName) && !String.isEmpty(fieldSetName)) {
                Map<String, Object> returnMap = new Map<String, Object>();

                Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
                if (!sObjects.containsKey(objectName)) {
                    throw new FieldSetHelperException(objectName + ' is not a valid object type');
                }
                DescribeSObjectResult sObjDescr = sObjects?.get(objectName)?.getDescribe();

                Map<String, Schema.FieldSet> fieldSetMp = sObjDescr?.fieldSets.getMap();
                if (!fieldSetMp.containsKey(fieldSetName)) {
                    throw new FieldSetHelperException(
                        'There is no fieldset named ' + fieldSetName + ' on the ' + objectName + ' object'
                    );
                }

                //get fields from FieldSet
                List<Schema.FieldSetMember> lstFSMember = fieldSetMp.get(fieldSetName)?.getFields();

                returnMap.put('FIELD_LIST', JSON.deserializeUntyped(JSON.serialize(lstFSMember))); // convert from FieldSetMembers to Maps
                returnMap.put('OBJECT_LABEL', sObjDescr?.getLabel());

                return returnMap;
            }
            return null;
        } catch (FieldSetHelperException e) {
            throw e; // rethrow expected types
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); // wrap all other types
        }
    }

    public class FieldSetHelperException extends Exception {
    }
}
