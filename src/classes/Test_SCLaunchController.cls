@isTest
public class Test_SCLaunchController
{
    @isTest static void testSCLaunchController()
    {
       // Instantiate the Launch page with the POSTed assertions from MyASU
       PageReference pageRef = Page.SCLaunch;
       Test.setCurrentPage(pageRef);
       ApexPages.CurrentPage().getParameters().put('asuriteid', 'testasu1');
       ApexPages.CurrentPage().getParameters().put('navbar',
               '{"navbarLinks":[{"Home":"https://webapp4-dev.asu.edu/myasu"},' +
               '{"Finances":"https://webapp4-dev.asu.edu/myasu/student/finances"},' +
               '{"Campus Services":"https://webapp4-dev.asu.edu/myasu/student/campusservices"},' +
               '{"Profile":"https://webapp4-dev.asu.edu/myasu/student/profile"}]}'
       );
       ApexPages.CurrentPage().getParameters().put('time', '1402504492');
       ApexPages.CurrentPage().getParameters().put('signature',
               '9160cca8b6d303b81325bb9a4d67314544d4bb543b8abdef5d09ca35baedd98e'
       );
       SCLaunchController controller = new SCLaunchController();
       controller.init();
       
       // Verify that the navbar cookie was written and the linkList was generated for the page
       System.assertNotEquals(null, controller.linkList);
    }
}