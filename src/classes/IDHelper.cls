public class IDHelper {
    public static List<Record_Type_ids__c> RecordTypeIds {
        /*
         * Initializes to the values from the cache
         */
        get {
            if (RecordTypeIds == null) {
                RecordTypeIds = Record_Type_ids__c.getAll().values();
            }
            
            return RecordTypeIds;
        }
        
        set;
    }
    
    public static List<Profile_Ids__c> ProfileIds {
        /*
         * Initializes to the values from the cache
         */
        get {
            if (ProfileIds == null) {
                ProfileIds = Profile_Ids__c.getAll().values();
            }
            
            return ProfileIds;
        }
        
        set;
    }
    
    public static Integer ProfileIdsRecordCount {
        get {
            return ProfileIds.size();
        }
        
        set;
    }
    
    public static Integer RecordTypeIdsRecordCount {
        get {
            return RecordTypeIds.size();
        }
        
        set;
    }
    
    public static Integer recordTypeIdRecordSizeInBytes {
        get {
            return 278;
        }
        
        set;
    }
    
    public static Integer profileIdRecordSizeInBytes {
        get {
            return 373;
        }
        
        set;
    }
    
    /*
     * Returns the desired record type ID. Method Provided as shorthand.
     * 
     * @param String The API name of the desired object.
     * @param String The name of the record type required.
     * 
     * @return Id The Id of the desired record type
     */
    public static Id getRTID (String SObjectType, String Name) {
        return getRecordTypeId(SObjectType, Name);
    }
    
    
    /*
     * Returns the desired record type ID.
     * 
     * @param String The API name of the desired object.
     * @param String The name of the record type required.
     * 
     * @return Id The Id of the desired record type
     */
    public static Id getRecordTypeId (String SObjectType, String Name) {
        for (Record_Type_ids__c RTID : RecordTypeIds) {
            if (RTID.Name__c == Name && RTID.SObject_Type__c == SObjectType) {
                System.debug(RTID.Id__C);
                return RTID.Id__c;
            }
        }
        
        if (rebuildRecordTypeIdCache(SObjectType, Name) ){
        	return getRecordTypeId(SObjectType, Name);
        } else {
            return null;
        }
    }
    
    
    /*
     * Returns the desired profile ID. Method provided as shorthand.
     * 
     * @param String The name of the desired profile.
     * 
     * @return Id The Id of the desired record type
     */
    public static Id getPID(String Name) {
        return getProfileId(Name);
    }
    
    /*
     * Returns the desired profile ID.
     * 
     * @param String The name of the desired profile.
     * 
     * @return Id The Id of the desired record type
     */
    public static Id getProfileId (String Name) {
        for (Profile_Ids__c pi : ProfileIds) {
            if (pi.Name__c == Name) {
                return pi.Id__c;
            }
        }
        
        if (rebuildProfileIdCache(Name)) {
            return getProfileId (Name);
        } else {
            return null;
        }
    }
    
    /*
     * Should there be any concern about the integrity of the cache,
     * this method can be used to clear out and re-build the cache.
     */
    public static void rebuildCache() {
        rebuildRecordTypeIdCache();
        rebuildProfileIdCache();
    }
    
    /*
     * Calls rebuildRecordTypeIdCache(String SObjectType, String Name) with
     * null params. Method provided as shorthand.
     */
    public static void rebuildRecordTypeIdCache() {
        rebuildRecordTypeIdCache(null, null);
    }
    
    /*
     * Deletes all existing cached Record_Type_ids__c and re-creates them.
     */
    private static boolean rebuildRecordTypeIdCache(String SObjectType, String Name) {
        clearRecordTypeIdCache();
        Record_Type_ids__c temp;
        RecordTypeIds = new List<Record_Type_ids__c>();
        integer key = 0;
        boolean exists = false;
        
        for (RecordType rt : [
            SELECT Id, DeveloperName, SObjectType
            FROM RecordType
            ORDER BY SObjectType ASC
        ]) {
            if (rt.DeveloperName == Name && rt.SobjectType == SObjectType) {
                exists = true;
            }
            
            temp = new Record_Type_ids__c();
            
            temp.Name = string.valueOf(++key);
            temp.Name__c = rt.DeveloperName;
            temp.SObject_Type__c = rt.SobjectType;
            temp.Id__c = rt.Id;
            
            RecordTypeIds.add(temp);
        }
        
        insert RecordTypeIds; // Insert seems to be failing
        return exists;
    }
    
    /*
     * Calls rebuildProfileIdCache(String Name) with a null param.
     * Method provided as shorthand.
     */
    public static void rebuildProfileIdCache() {
        rebuildProfileIdCache(null);
    }
    
    /*
     * Deletes all existing cached Profile_Ids__c and re-creates them.
     */
    private static boolean rebuildProfileIdCache(String Name) {
        clearProfileIdCache();
        Profile_Ids__c temp;
        ProfileIds = new List<Profile_Ids__c>();
        integer key = 0;
        boolean exists = false;
        
        for (Profile p : [
            SELECT Id, Name
            FROM Profile
        ]) {
            if (p.Name == Name) {
                exists = true;
            }
            
            temp = new Profile_Ids__c();
            
            temp.Name = string.valueOf(++key);
            temp.Name__c = p.Name;
            temp.Id__c = p.Id;
            
            ProfileIds.add(temp);
        }
        
        insert ProfileIds;
        return exists;
    }
    
    /*
     * Should there be any concerns about the integrity of the cache,
     * this method can be used to clear it out. This will not re-build the
     * cache.
     * 
     * <p>
     * To re-build the cache, call rebuildCache(). Alternatively, once the
     * cache has been cleared, any attempt at accessing the cached data will
     * result in the data being re-cached automatically.
     * </p>
     */
    public static void clearCache() {
        clearRecordTypeIdCache();
        clearProfileIdCache();
    }
    
    /*
     * Deletes all existing Record_Type_ids__c
     */
    @testVisible
    private static void clearRecordTypeIdCache() {
        if (RecordTypeIds.size() > 0) {
            delete RecordTypeIds;
        }
        
        RecordTypeIds = null;
    }
    
    /*
     * Deletes all existing Profile_Ids__c
     */
    @testVisible
    private static void clearProfileIdCache() {
        if (ProfileIds.size() > 0) {
            delete ProfileIds;
        }
        
        ProfileIds = null;
    }
}