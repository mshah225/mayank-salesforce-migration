/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username { get; set; }

    public ForgotPasswordController() {
    }

    public PageReference forgotPassword() {
        Boolean success = Site.forgotPassword(username);
        PageReference forgotPasswordConfirmationPage = Page.ForgotPasswordConfirm;
        forgotPasswordConfirmationPage.setRedirect(true);

        if (success) {
            return forgotPasswordConfirmationPage;
        }
        return null;
    }
}
