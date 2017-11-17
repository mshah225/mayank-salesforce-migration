@isTest
public class Test_RTIDHelper {
    /*
    public static testmethod void Test_getRTID() {
        List<RecordType> tempRTs = [SELECT Name, SObjectType FROM RecordType LIMIT 2];
        Id tempId;
        
        tempId = RTIDHelper.getRTID(tempRTs[0].SObjectType, tempRTs[0].Name);
        
        system.assertEquals(tempRTs[0].Id, tempId);
        System.assertEquals(3, Limits.getQueries());
        
        tempId = RTIDHelper.getRTID(tempRTs[0].SObjectType, tempRTs[0].Name);
        
        system.assertEquals(tempRTs[0].Id, tempId);
        system.assertEquals(3, Limits.getQueries());
        
        tempId = RTIDHelper.getRTID(tempRTs[1].SObjectType, tempRTs[1].Name);
        
        system.assertEquals(tempRTs[1].Id, tempId);
        system.assertEquals(5, Limits.getQueries());
        
        tempId = RTIDHelper.getRTID(tempRTs[1].SObjectType, tempRTs[1].Name);
        
        system.assertEquals(tempRTs[1].Id, tempId);
        system.assertEquals(5, Limits.getQueries());
    }
*/
}