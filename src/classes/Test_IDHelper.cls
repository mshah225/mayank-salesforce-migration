@isTest
public class Test_IDHelper {
    public static Id pid;
    public static Id rtid;
    
    static {
        pid = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        rtid = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'ASU_Service'].Id;
    }
    
    @testSetup
    public static void testSetup() {
        IDHelper.rebuildCache();
    }
    
    public static testmethod void Test_IDHelperClearCache() {
        IDHelper.clearCache();
        system.assertEquals(0, IDHelper.ProfileIdsRecordCount);
        system.assertEquals(0, IDHelper.RecordTypeIdsRecordCount);
    }
    
    public static testmethod void Test_IDHelperRebuildCache() {
        integer numberOfProfiles = (integer) [SELECT Count(Id) c FROM Profile][0].get('c');
        integer numberOfRecordTypes = (integer) [SELECT Count(Id) c FROM RecordType][0].get('c');
        
        system.assertEquals(numberOfProfiles, IDHelper.ProfileIdsRecordCount);
        system.assertEquals(numberOfRecordTypes, IDHelper.RecordTypeIdsRecordCount);
    }
    
    public static testmethod void Test_getRecordTypeId() {
        system.assertEquals(rtid, IDHelper.getRTID('Case', 'ASU_Service'));
    }
    
    public static testmethod void Test_getProfileId() {
        system.assertEquals(pid, IDHelper.getPID('System Administrator'));
    }
    
    public static testmethod void Test_getSizeInByes() {
        system.assertEquals(278, IDHelper.recordTypeIdRecordSizeInBytes);
        system.assertEquals(373, IDHelper.profileIdRecordSizeInBytes);
    }
    
    public static testmethod void Test_getUnachedProfile() {
		IDHelper.clearProfileIdCache();
        system.assertEquals(pid, IDHelper.getPID('System Administrator'));
    }
    
    public static testmethod void Test_getUncachedRecordType() {
		IDHelper.clearRecordTypeIdCache();
        system.assertEquals(rtid, IDHelper.getRTID('Case', 'ASU_Service'));
    }
    
    public static testmethod void Test_getFakeProfile() {
        system.assertEquals(null, IDHelper.getPID('Gromeo Maltese'));
    }
    
    public static testmethod void Test_getFakeRecordType() {
        system.assertEquals(null, IDHelper.getRTID('Cheese', 'Grumpkin'));
    }
}