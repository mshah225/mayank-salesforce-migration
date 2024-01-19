public class CustomMetadataHelper {
    private static Map<String, List<SObject>> fakeCustomMetadataCache = new Map<String, List<SObject>>();

    public static Boolean isNotTest() {
        return !Test.isRunningTest();
    }

    public static List<SObject> getFakeRecords(String key) {
        if (fakeCustomMetadataCache.containsKey(key))
            return fakeCustomMetadataCache.get(key);
        return new List<SObject>();
    }

    public static void setFakeRecords(String key, List<SObject> customMetadata) {
        fakeCustomMetadataCache.put(key, customMetadata);
    }
}
