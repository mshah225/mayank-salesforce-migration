/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
@isTest
public with sharing class CommunitiesSelfRegControllerTest {
    @isTest
    private static void differentPasswordCatchError() {
        PageReference pageRef = Page.CommunitiesSelfRegConfirm;
        Test.setCurrentPage(pageRef);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
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
        PageReference pageRef = Page.CommunitiesSelfRegConfirm;
        Test.setCurrentPage(pageRef);
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.password = 'asuIasu';
        controller.confirmPassword = 'asuIasu';

        Test.startTest();
        controller.registerAndRedirectUser();
        Test.stopTest();

        List<Apexpages.Message> pageMsgs = ApexPages.getMessages();
        System.assert(pageMsgs.get(0).getDetail().contains(CommunitiesSelfRegController.UNABLE_TO_CREATE_PORTAL_USER));
    }
}
