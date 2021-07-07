/**
 * Class containing tests for SiteRegisterController
 */
@isTest
public with sharing class SiteRegisterControllerTest {
    @isTest
    private static void differentPasswordCatchError() {
        PageReference pageRef = Page.SiteRegister;
        Test.setCurrentPage(pageRef);
        SiteRegisterController controller = new SiteRegisterController();
        controller.password = 'test!23';
        controller.confirmPassword = 'test123';

        Test.startTest();
        System.assert(controller.registerAndRedirectUser() == null);
        Test.stopTest();

        List<Apexpages.Message> pageMsgs = ApexPages.getMessages();
        System.assert(pageMsgs.get(0).getDetail().contains(Label.Site.passwords_dont_match));
    }

    @isTest
    private static void createPortalUserCatchError() {
        PageReference pageRef = Page.SiteRegister;
        Test.setCurrentPage(pageRef);
        SiteRegisterController controller = new SiteRegisterController();
        controller.password = 'asuIasu';
        controller.confirmPassword = 'asuIasu';

        Test.startTest();
        controller.registerAndRedirectUser();
        Test.stopTest();

        List<Apexpages.Message> pageMsgs = ApexPages.getMessages();
        System.assert(pageMsgs.get(0).getDetail().contains(controller.UNABLE_TO_CREATE_PORTAL_USER));
    }
}
