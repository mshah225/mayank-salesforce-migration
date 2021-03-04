public without sharing class SCHeaderController {
    public boolean isUnsubscribeGuestUser { get; set; }
    public Contact loggedInContact;

    public SCHeaderController() {
        loggedInContact = ContactService.getLoggedInContact();
        if (loggedInContact == null) {
            isUnsubscribeGuestUser = true;
        } else {
            isUnsubscribeGuestUser = false;
        }
    }
}
