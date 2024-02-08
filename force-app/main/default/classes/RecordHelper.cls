/**
 * Helper class for comparing two records, usually the oldRecord and the newRecord in a trigger context.
 * Main utility are the hasNewOrChangedField and hasNewOrChangedFields functions which let you check
 * if specific fields differ on the two SObjects.
 *
 * You should, whenever possible, use the Schema.SObjectField variant, as this will expose the field usage to
 * Salesforce's metadata tooling (which will prevent admins from deleting the field until we remove the corresponding code)
 * however there are String variants that you can use if the fields you care about checking are dynamic
 *
 * Example usage:
 * Boolean emailOrNameChanged = RecordHelper.hasNewOrChangedFields(newContact, oldContact, new List<Schema.SObjectField>{Contact.FirstName, Contact.Email})
 * which returns true if the first name or email differs between the two records or if the oldContact is null (i.e. this is a new insert rather than an update)
 */
public class RecordHelper {
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

    public static Boolean hasNewOrChangedField(SObject newItem, SObject oldItem, Schema.SObjectField field) {
        return hasNewOrChangedField(newItem, oldItem, field.getDescribe().getName());
    }

    public static Boolean hasNewOrChangedField(SObject newItem, SObject oldItem, String field) {
        return (oldItem == null || newItem.get(field) != oldItem.get(field));
    }

    public static SObject getOldRecord(Id newRecordId) {
        return Trigger.oldMap != null && Trigger.oldMap.containsKey(newRecordId)
            ? Trigger.oldMap.get(newRecordId)
            : null;
    }
}
