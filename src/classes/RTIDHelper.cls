public class RTIDHelper {
    private static List<Record_Type_ids__c> RTIDs;
    
    static {
        setRTIDS();
    }
    
    public static Id getRTID (String SObjectType, String Name) {
        for (Record_Type_ids__c RTID : RTIDs) {
            if (RTID.Name__c == Name && RTID.SObject_Type__c == SObjectType) {
                return RTID.Id__c;
            }
        }
        
        return cacheNewRTID(SObjectType, Name);
    }
    
    private static Id cacheNewRTID(String SObjectType, String Name) {
        Integer RTIDKey; // The key for the new RTID
        RecordType tempRT; // Stores the RT retrieved from the database
        Record_Type_Ids__c newRTID; // Used to store the custom setting
        
        // if the method has not returned, we do not have a custom setting for the Id
        newRTID = new Record_Type_ids__c();
        
        // Get the record type
        tempRT = [SELECT Id, Name, SObjectType
            FROM RecordType
            WHERE SObjectType = :SObjectType
            AND Name = :Name];
        
        // Get the highest key and add 1 to generate the new key
        for (Record_Type_ids__c r : [SELECT Name
            FROM Record_Type_ids__c
            ORDER BY Name DESC
            Limit 1]) {
            RTIDKey = Integer.valueOf(r.Name) + 1;
        }
        
        if (RTIDKey == null) {
            RTIDKey = 1;
        }
        
        newRTID.Name = String.ValueOf(RTIDKey);
        newRTID.Name__c = tempRT.Name;
        newRTID.Id__c = tempRT.Id;
        newRTID.SObject_Type__c = tempRT.SobjectType;
        
        insert newRTID;
        setRTIDS();
        
        return newRTID.Id__c;
    }
    
    private static void setRTIDS() {
        RTIDs = Record_Type_ids__c.getAll().values();
    }
}