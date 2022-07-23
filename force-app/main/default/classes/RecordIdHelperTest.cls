@isTest
public class RecordIdHelperTest {
    public static Id pid;
    public static Id rtid;

    static {
        pid = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        rtid = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'ASU Service'].Id;
    }

    @testSetup
    public static void testSetup() {
        RecordIdHelper.rebuildCache();
    }

    public static testMethod void Test_RecordIdHelperClearCache() {
        RecordIdHelper.clearCache();
        system.assertEquals(0, RecordIdHelper.ProfileIdsRecordCount);
        system.assertEquals(0, RecordIdHelper.RecordTypeIdsRecordCount);
    }

    public static testMethod void Test_RecordIdHelperRebuildCache() {
        integer numberOfProfiles = (integer) [SELECT Count(Id) c FROM Profile][0].get('c');

        List<RecordType> allRecordTypes =  [SELECT Id FROM RecordType];

        system.assertEquals(numberOfProfiles, RecordIdHelper.ProfileIdsRecordCount);
        system.assertEquals(allRecordTypes.size(), RecordIdHelper.RecordTypeIdsRecordCount);
    }

    public static testMethod void Test_getRecordTypeId() {
        system.assertEquals(rtid, RecordIdHelper.getRecordTypeId('Case', 'ASU_Service'));
    }

    public static testMethod void Test_getProfileId() {
        system.assertEquals(pid, RecordIdHelper.getProfileId('System Administrator'));
    }

    public static testMethod void Test_getSizeInByes() {
        system.assertEquals(278, RecordIdHelper.recordTypeIdRecordSizeInBytes);
        system.assertEquals(373, RecordIdHelper.profileIdRecordSizeInBytes);
    }

    public static testMethod void Test_getUnachedProfile() {
        RecordIdHelper.clearProfileIdCache();
        system.assertEquals(pid, RecordIdHelper.getProfileId('System Administrator'));
    }

    public static testMethod void Test_getUncachedRecordType() {
        RecordIdHelper.clearRecordTypeIdCache();
        system.assertEquals(rtid, RecordIdHelper.getRecordTypeId('Case', 'ASU_Service'));
    }

    public static testMethod void Test_getFakeProfile() {
        system.assertEquals(null, RecordIdHelper.getProfileId('Gromeo Maltese'));
    }

    public static testMethod void Test_getFakeRecordType() {
        system.assertEquals(null, RecordIdHelper.getRecordTypeId('Cheese', 'Grumpkin'));
    }

    private static testMethod void testPrefixFound() {
        String objectName = RecordIdHelper.findObjectNameFromRecordIdPrefix('500');
        System.assertEquals(objectName, 'Case');
    }

    private static testMethod void testPrefixNotFound() {
        String objectName = RecordIdHelper.findObjectNameFromRecordIdPrefix('101');
        System.assertEquals(objectName, 'Error');
    }

    private static testMethod void testObjectFound() {
        String objectName = RecordIdHelper.findPrefixFromObjectName('Contract');
        System.assertEquals(objectName, '800');
    }

    private static testMethod void testObjectNotFound() {
        String objectName = RecordIdHelper.findPrefixFromObjectName('Cheese');
        System.assertEquals(objectName, 'Error');
    }

    private static testMethod void testName() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Interest' LIMIT 1];
        String objectName = RecordIdHelper.getRecordName('Case', RecordIdHelper.getRecordTypeId('Case', 'ASU_Service'));
        System.assertEquals(objectName, 'ASU_Service');
    }
}
