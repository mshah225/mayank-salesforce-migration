@isTest
public class MyASUHelpAttachmentsControllerTest {
    private static List<Case> openCases; // A list of all open cases
    private static User testCommUser; // A test Community User
    private static User testAdminUser; // A test Admin user

    @testSetup
    public static void setTestData() {
        List<Contact> testContactList; // A list of contacts to be inserted
        List<User> lstUser = new List<User>(); // A list of Users to Insert
        Profile sysAdmin; // System Admin profile
        sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        testContactList = ContactService.createTestContacts(1);
        insert testContactList;

        testCommUser = TestDataFactory.createCommunityUser('Test0', testContactList[0].Id);
        testAdminUser = TestDataFactory.createUser('Test1', sysAdmin.Id);
        lstUser.add(testCommUser);
        lstUser.add(testAdminUser);
        insert lstUser;

        openCases = CaseService.createTestCases(1, testContactList[0]);
        insert openCases;
    }

    static {
        openCases = [SELECT id FROM Case LIMIT 1];
        List<User> retAdminUser = [SELECT id, Profile.Name FROM User WHERE LastName = 'Test1' LIMIT 1];
        List<User> retCommUser = [SELECT id, Profile.Name FROM User WHERE LastName = 'Test0' LIMIT 1];
        if (retAdminUser != null && retAdminUser.size() > 0) {
            testAdminUser = retAdminUser[0];
        }
        if (retCommUser != null && retCommUser.size() > 0) {
            testCommUser = retCommUser[0];
        }
    }

    public static testMethod void Test_UploadAtt() {
        Boolean isAttPresent;
        List<Attachment> verifyAtt;
        Test.startTest();
        System.runAs(testAdminUser) {
            MyASUHelpAttachmentsController testAttBox = new MyASUHelpAttachmentsController();
            testAttBox.attParentId = openCases[0].Id;
            testAttBox.objAtt.Name = 'Test Attachment';
            testAttBox.objAtt.Body = Blob.valueOf('Test Attachment Body');
            isAttPresent = testAttBox.isAtt;
            System.assertEquals(isAttPresent, false);

            testAttBox.uploadAtt();
            isAttPresent = testAttBox.isAtt;
            System.assertEquals(isAttPresent, true);

            verifyAtt = [SELECT Id, Name FROM Attachment WHERE ParentId = :openCases[0].Id];
            System.assertEquals(verifyAtt[0].name, 'Test Attachment');
        }

        System.runAs(testCommUser) {
            MyASUHelpAttachmentsController testAttBox = new MyASUHelpAttachmentsController();
            testAttBox.attParentId = openCases[0].Id;
            testAttBox.objAtt.Name = 'Test Attachment';
            testAttBox.objAtt.Body = Blob.valueOf('Test Attachment Body');
            isAttPresent = testAttBox.isAtt;
            System.assertEquals(isAttPresent, false);

            testAttBox.uploadAtt();
        }
        Test.stopTest();
    }
}
