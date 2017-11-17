public class RTIDHelper {
    public static Id getRTID (String SObjectType, String Name) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = :SObjectType AND Name = :Name];
        return rt.id;
    }
}