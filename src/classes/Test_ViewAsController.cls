@isTest
public class Test_ViewAsController {
    public static testMethod void Test_ViewAsConstructor() {
        ViewAsController vac = new ViewAsController();

        system.assertEquals(UserInfo.getUserId(), vac.viewAsId);
    }
}
