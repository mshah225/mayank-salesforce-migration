public with sharing class DuoAuthUsername extends DuoAuth {
    private String username;

    /**
     * Authenticates a user against Duo with a user's Duo username
     *
     * @param userId Unique identifier for the user that is commonly specified
     * by your application during user creation (e.g. user@domain.com).
     * @param factor DuoAuthFactor to use for authentication.
     */
    public DuoAuthUsername(String username, DuoAuthFactor factor) {
        this.username = username;
        this.factor = factor;
    }
}
