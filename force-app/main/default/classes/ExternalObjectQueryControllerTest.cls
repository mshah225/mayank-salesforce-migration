@isTest
public class ExternalObjectQueryControllerTest {
    public static testMethod void quickTest() {
        PageReference pageRef = Page.ExternalObjectQuery;
        Test.setCurrentPage(pageRef);

        ExternalObjectQueryController controller = new ExternalObjectQueryController();
        controller.SelectedObject = 'Contact';
        controller.ObjectFields();
        controller.ShowTable();
    }
}
