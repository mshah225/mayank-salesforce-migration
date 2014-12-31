@isTest(SeeAllData=true)
public class Test_SCLaunchController {
    
    public static Id createContact() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'External_Mastered' and SObjectType = 'Contact'];
        if (rt==null) return null;
        
        Contact c = new Contact(FirstName='TestFName1', LastName='TestLName1', Email='test8123@test.test', EMPLID__c='909090933', 
                                asurite_id__c='testasu1', RecordTypeId=rt.Id);
        insert c;
        return c.Id;
        
    }
    
    public static testMethod void testSCLaunchController() {
       // Create an External_Mastered Contact
       Id contactId = createContact();
       
       // Instantiate the Launch page with the POSTed assertions from MyASU
       PageReference pageRef = Page.SCLaunch;
       Test.setCurrentPage(pageRef);
       ApexPages.CurrentPage().getParameters().put('asuriteid', 'testasu1');
       ApexPages.CurrentPage().getParameters().put('navbar', '{"navbarLinks":[{"Home":"https://webapp4-dev.asu.edu/myasu"},{"Finances":"https://webapp4-dev.asu.edu/myasu/student/finances"},{"Campus Services":"https://webapp4-dev.asu.edu/myasu/student/campusservices"},{"Profile":"https://webapp4-dev.asu.edu/myasu/student/profile"}]}');
       ApexPages.CurrentPage().getParameters().put('time', '1402504492');
       ApexPages.CurrentPage().getParameters().put('signature', '9160cca8b6d303b81325bb9a4d67314544d4bb543b8abdef5d09ca35baedd98e');
       SCLaunchController controller = new SCLaunchController();
       controller.init();
       
       // Verify that a User record was provisioned and related to the new Contact
       List<User> userList = new List<User>([SELECT Id FROM User WHERE ContactId = :contactId]);
       system.assertEquals(userList.size(), 1);
        
    }

}