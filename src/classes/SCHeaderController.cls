public without sharing class SCHeaderController {
    public boolean isUnsubscribeGuestUser { get; set; }
    
    public SCHeaderController() {
        List<Profile> profiles = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' LIMIT 1]);
        
        if (profiles.size() > 0) {
            if (userinfo.getProfileId() == profiles[0].Id) {
                isUnsubscribeGuestUser = true;
            } else {
                isUnsubscribeGuestUser = false;
            }
        }
    }
}