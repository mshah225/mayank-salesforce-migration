/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public with sharing class CommunitiesSelfRegController {
    public String firstName { get; set; }
    public String lastName { get; set; }
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

    public static final String UNABLE_TO_CREATE_PORTAL_USER = 'Unable to create Portal User. Please contact your System Administrator if the problem persists.';

    public CommunitiesSelfRegController() {
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
        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.

        User portalUser = new User();
        portalUser.Username = email;
        portalUser.Email = email;
        portalUser.FirstName = firstName;
        portalUser.LastName = lastName;
        portalUser.CommunityNickname = communityNickname;
        portalUser.ProfileId = profileId;

        String portalUserId = Site.createPortalUser(portalUser, accountId, password);
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
            return Site.login(email, password, null);
        } else {
            PageReference sitePage = System.Page.CommunitiesSelfRegConfirm;
            sitePage.setRedirect(true);
            return sitePage;
        }
    }

    private class CannotCreatePortalUserException extends Exception {
    }
    private class PasswordNoMatchException extends Exception {
    }
}
