public with sharing class DuoAuthButtonController {
    /**
     * Attempts to send a push notification to a duo user based on the provided
     * user and device information
     *
     * @param user The Duo user Id to send the notification to
     * @param device The Duo user's device to send the notification to
     *
     * @return a boolean denoting whether or not the user has been authenticated
     */
    @AuraEnabled
    public static Boolean authenticate(String user, String device) {
        Boolean authenticated = false;

        DuoAuthUserId authUserId = new DuoAuthUserId(user, new DuoPushFactor(device));

        DuoResponse response = new DuoAPI().send(authUserId);

        if (response.getResult() instanceof DuoAPI.Error) {
            throw new AuraHandledException(JSON.serialize(response.getResult()));
        } else {
            DuoAuth.Success success = (DuoAuth.Success) response.getResult();

            authenticated = success.result.equals('allow');
        }

        return authenticated;
    }
}
