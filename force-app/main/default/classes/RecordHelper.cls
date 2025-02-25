/**
 * Helper class for operating on records.
 *
 * getValue() lets you get the value of at some path ($.Account.Owner.Name)
 * hasNewOrChangedField() lets you check if a field single field differs between two records (usually the old vs new version of the record in a trigger)
 * hasNewOrChangedFields() lets you check if one of multiple fields have differ between two records (usually the old vs new version of the record in a trigger)
 *
 * For hasNewOrChangedField and hasNewOrChangedFields
 * You should, whenever possible, use the Schema.SObjectField variant, as this will expose the field usage to
 * Salesforce's metadata tooling (which will prevent admins from deleting the field until we remove the corresponding code)
 * however there are String variants that you can use if the fields you care about checking are dynamic
 */
public class RecordHelper {
    /**
     * Get the value for a field on a record by passing the field's path.
     * You can pass the path, either as a SOQL-compliant field path (Contact.Name) or as a JSON selector
     * string ($.Contact.Name).
     * Throws exception if the name is invalid, or if the path is invalid or if path includes fields
     * that were not returned on sObj (if they were returned but are null, safely handles resulting null checks)
     *
     * Their is a optional third parameter of the type GetValueConfig
     * This config has two flags:
     *   1. cache = should we use caching? Default = TRUE
     *   2. safe = should we check the path makes sense before traversing it? Default = TRUE
     *
     * My suggestion is usually you'll want to enable caching as it dramatically improves performance,
     * and only is problematic if the record changes mid transaction. Safe adds about ~100ms on each call
     * (or first if cache=true), so it really only makes sense to disable to caching is off and you need
     * to eek out that performance.
     *
     *  DEPTH           FIRST CALL          NO CACHE            CACHE           EXAMPLE PATH
     *    0                 1ms              60/ms              60/ms            $
     *    1                120ms             10/ms              60/ms            $.AccountId
     *    2                120ms              1ms               50/ms            $.Account.Name
     *    3                120ms              2ms               50/ms            $.Account.Contact__r.Name
     *
     * @param sObj The record you are reading from
     * @param path The path you want to read (e.g. "$.Contact.Name)
     * @return The value of the field requested
     * @throws RecordHelperFieldPathException If the path is invalid for object type
     * @throws RecordHelperFieldIncludedException If you ask for a field that was not included on the object (it wasn't incldued as path of the SOQL query)
     */
    public static Object getValue(SObject sObj, String path) {
        return getValue(sObj, path, new GetValueConfig());
    }
    public static Object getValue(SObject sObj, String path, GetValueConfig config) {
        if (config.cache && sObj?.Id != null && getValueCache.get(sObj.Id)?.containsKey(path) == true) {
            return getValueCache.get(sObj.Id).get(path);
        }

        // Asking for root element
        if (path == '$')
            return sObj;

        // More complex path? Check if valid for this object type
        if (config.safe)
            try {
                ObjectHelper.getFieldDescribe(sObj.getSObjectType().getDescribe().getName(), path);
            } catch (ObjectHelper.ObjectHelperFieldPathException ex) {
                throw new RecordHelperFieldPathException(ex.getMessage());
            }

        // Traverse record
        List<String> pathComponents = (path.startsWith('$.') ? path.substringAfter('$.') : path).split('\\.');
        SObject pathIter = sObj;
        for (Integer i = 0; i < pathComponents.size() - 1; i++) {
            String step = pathComponents[i];

            // Converts from lookup "Student__r" to "Student__c", which is the value needed to check using isSet
            String lookupFieldName = ObjectHelper.getDescribeFromLookupName(
                    pathIter.getSObjectType().getDescribe(),
                    step
                )
                .getName();

            // Field was actually included on record
            if (!pathIter.isSet(lookupFieldName))
                throw new RecordHelperFieldIncludedException(
                    'Tried to read path ' +
                        path +
                        ' from record, but failed at step ' +
                        step +
                        ' as ' +
                        lookupFieldName +
                        ' is not set on the record (usually this is beacuse it was not included in the SOQL query that returned this record)'
                );

            // Get field value
            pathIter = pathIter.getSObject(step);

            // Stop descending into record and just return null if we find it
            if (pathIter == null)
                return null;
        }

        String finalStep = pathComponents[pathComponents.size() - 1];

        // Field was actually included on record
        if (!pathIter.isSet(finalStep))
            throw new RecordHelperFieldIncludedException(
                'Tried to read path ' +
                    path +
                    ' from record, but failed at step ' +
                    finalStep +
                    ' since it is not set on the record (usually this is beacuse it was not included in the SOQL query that returned this record)'
            );

        Object value = pathIter.get(finalStep);
        
        // Cache value
        if (config.cache && sObj?.Id != null) {
            if (!getValueCache.containsKey(sObj.Id))
                getValueCache.put(sObj.Id, new Map<String, Object>());
            if (!getValueCache.get(sObj.Id).containsKey(path))
                getValueCache.get(sObj.Id).put(path, value);
        }

        // Return value
        return value;
    }
    private static Map<String, Map<String, Object>> getValueCache = new Map<String, Map<String, Object>>();

    /**
     * Check if one of multiple fields differ between records
     * Usually used to check if the new version of a record has changed several key fields compared to an old version of the record in a trigger.
     *
     * @example
     * Boolean emailOrNameChanged = RecordHelper.hasNewOrChangedFields(newContact, oldContact, new List<Schema.SObjectField>{Contact.FirstName, Contact.Email})
     * which returns true if the first name or email differs between the two records or if the oldContact is null (i.e. this is a new insert rather than an update)
     *
     * @param newItem The new version of the record
     * @param oldItem The old version of the record
     * @param fields List of fields to check
     * @return True if at least one field listed has changed
     */
    public static Boolean hasNewOrChangedFields(SObject newItem, SObject oldItem, List<Schema.SObjectField> fields) {
        List<String> fieldStrings = new List<String>();
        for (Schema.SObjectField fld : fields) {
            fieldStrings.add(fld.getDescribe().getName());
        }
        return hasNewOrChangedFields(newItem, oldItem, fieldStrings);
    }
    public static Boolean hasNewOrChangedFields(SObject newItem, SObject oldItem, List<String> fields) {
        for (String field : fields) {
            if (hasNewOrChangedField(newItem, oldItem, field)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check if one of multiple fields differ between records
     * Usually used to check if the new version of a record has changed several key fields compared to an old version of the record in a trigger.
     *
     * @example
     * Boolean emailOrNameChanged = RecordHelper.hasNewOrChangedField(newContact, oldContact, Contact.US_Citizen__c)
     * which returns true if the contact's citizenship flag has changed (or if oldContact=null as in an insert rather than update trigger)
     *
     * @param newItem The new version of the record
     * @param oldItem The old version of the record
     * @param fields List of fields to check
     * @return True if at least one field listed has changed
     */
    public static Boolean hasNewOrChangedField(SObject newItem, SObject oldItem, Schema.SObjectField field) {
        return hasNewOrChangedField(newItem, oldItem, field.getDescribe().getName());
    }
    public static Boolean hasNewOrChangedField(SObject newItem, SObject oldItem, String field) {
        return (oldItem == null || newItem.get(field) != oldItem.get(field));
    }

    /**
     * Get the old version of a record in a trigger context using the record's id, or null if it doesn't exist
     *
     * @param newRecordId
     * @return Old version of record from Trigger.oldMap, if exists, null otherwise
     */
    public static SObject getOldRecord(Id newRecordId) {
        if (Trigger.oldMap != null && Trigger.oldMap.containsKey(newRecordId))
            return Trigger.oldMap.get(newRecordId);
        return null;
    }

    // Config for using getValue function (to toggle on some additional functions that might be slow performance)
    public class GetValueConfig {
        public Boolean cache = true;
        public Boolean safe = true;
    }

    public class RecordHelperFieldPathException extends Exception {
    }
    public class RecordHelperFieldIncludedException extends Exception {
    }
}
