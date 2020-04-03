public without sharing class ASUBrandHeaderController {
    public boolean isUnsubscribeGuestUser { get; set; }
    public Contact loggedInContact;

    public ASUBrandHeaderController() {
        loggedInContact=ContactService.getLoggedInContact();
            if (loggedInContact==null) {
                isUnsubscribeGuestUser = true;
            } else {
                isUnsubscribeGuestUser = false;
            }
    }
}