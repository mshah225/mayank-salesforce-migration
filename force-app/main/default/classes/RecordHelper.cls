public class RecordHelper {
    public static Boolean hasNewOrChangedField(SObject newItem, SObject oldItem, String field) {
        return (oldItem == null || newItem.get(field) != oldItem.get(field));
    }

    public static Boolean hasNewOrChangedFields(SObject newItem, SObject oldItem, List<String> fields) {
        for (String field : fields) {
            if (hasNewOrChangedField(newItem, oldItem, field)) {
                return true;
            }
        }

        return false;
    }

    public static SObject getOldRecord(Id newRecordId) {
        return Trigger.oldMap != null && Trigger.oldMap.containsKey(newRecordId)
            ? Trigger.oldMap.get(newRecordId)
            : null;
    }
}