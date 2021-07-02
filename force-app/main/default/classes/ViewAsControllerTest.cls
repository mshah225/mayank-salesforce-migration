@isTest
public class ViewAsControllerTest {
    public static testMethod void Test_ViewAsConstructor() {
        ViewAsController vac = new ViewAsController();

        system.assertEquals(UserInfo.getUserId(), vac.viewAsId);
    }
}
