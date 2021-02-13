public with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.
    private static final Id PORTAL_ACCOUNT_ID = '001x000xxx35tPN';
    public final String UNABLE_TO_CREATE_PORTAL_USER = 'Unable to create Portal User. Please contact your System Administrator if the problem persists.';

    public SiteRegisterController() {
    }

    public String username { get; set; }
    public String email { get; set; }
    public String password {
        get;
        set {
            password = value == null ? value : value.trim();
        }
    }
    public String confirmPassword {
        get;
        set {
            confirmPassword = value == null ? value : value.trim();
        }
    }
    public String communityNickname {
        get;
        set {
            communityNickname = value == null ? value : value.trim();
        }
    }

    public PageReference registerAndRedirectUser() {
        try {
            throwErrorIfPasswordMismatch();
            createNewPortalUser();
            return redirectUser();
        } catch (Exception ex) {
            showErrorMsgOnPage(ex.getMessage());
        }
        return null;
    }

    private void throwErrorIfPasswordMismatch() {
        if (passwordIsNotSame()) {
            throw new PasswordNoMatchException(Label.Site.PASSWORDS_DONT_MATCH);
        }
    }

    private Boolean passwordIsNotSame() {
        return password != confirmPassword;
    }

    private void createNewPortalUser() {
        User portalUser = new User();
        portalUser.Username = username;
        portalUser.Email = email;
        portalUser.CommunityNickname = communityNickname;

        String portalUserId = Site.createPortalUser(portalUser, PORTAL_ACCOUNT_ID, password);
        if (portalUserId == null) {
            throw new CannotCreatePortalUserException(UNABLE_TO_CREATE_PORTAL_USER);
        }
    }

    private void showErrorMsgOnPage(String errorMsg) {
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(errorMessage);
    }

    private PageReference redirectUser() {
        if (String.isNotBlank(password)) {
            return Site.login(username, password, null);
        } else {
            PageReference sitePage = System.Page.SiteRegisterConfirm;
            sitePage.setRedirect(true);
            return sitePage;
        }
    }

    private class CannotCreatePortalUserException extends Exception {
    }
    private class PasswordNoMatchException extends Exception {
    }
}
