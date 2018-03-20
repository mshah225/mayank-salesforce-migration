public with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    private static Id PORTAL_ACCOUNT_ID = '001x000xxx35tPN';
    
    public SiteRegisterController () {}

    public String username {get; set;} 
    public String email {get; set;}
    public String password {get; set{password = value == null ? value : value.trim();}}
    public String confirmPassword {get; set{confirmPassword = value == null ? value : value.trim();}}
    public String communityNickname {get; set{communityNickname = value == null ? value : value.trim();}}
      
    public PageReference registerUser() {
        if (isPasswordNotSame()) {
            showErrorMsgOnPage(Label.Site.passwords_dont_match);
            return null;
        }
        
        try {
            String userId = returnNewPortalUserId();
            if (isPasswordValid()) {
                return Site.login(username, password, null);
            } else {
                PageReference sitePage = System.Page.SiteRegisterConfirm;
                sitePage.setRedirect(true);
                return sitePage;
            }
        } catch (Exception ex) {
            showErrorMsgOnPage(ex.getMessage());
            return null;
        }
    }
    
    private Boolean isPasswordNotSame() {
        return password != confirmPassword;
    }
    
    private String returnNewPortalUserId() {
        User portalUser = new User();
        portalUser.Username = username;
        portalUser.Email = email;
        portalUser.CommunityNickname = communityNickname;
        
        String portalUserId = Site.createPortalUser(portalUser, PORTAL_ACCOUNT_ID, password);
        if (portalUserId == null) {
            NoDataFoundException noDataException = new NoDataFoundException();
            throw noDataException;
        } else {
            return portalUserId;
        }
    }
    
    private Boolean isPasswordValid() {
        return password != null && password.length() > 1;
    }
    
    private void showErrorMsgOnPage(String errorMsg) {
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
        ApexPages.addMessage(errorMessage);
    }
}