public without sharing class ASUBrandHeaderController {
    public Boolean isLoggedInUser;

    public ASUBrandHeaderController() {
        isLoggedInUser = false;
        setUserStatus();
    }

    public Boolean getIsLoggedInUser() {
        return isLoggedInUser;
    }

    private void setUserStatus() {
        if (UserInfo.getUserId() != null && !UserInfo.getLastName().containsIgnoreCase('guest')) {
            isLoggedInUser = true;
        }
    }
}
