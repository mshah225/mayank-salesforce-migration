public with sharing class DuoAuthUserId extends DuoAuth {
    private String user_id;

    /**
     * Authenticates a user against Duo with a user's unique identifier
     *
     * @param userId Permanent, unique identifier for the user as generated
     * by Duo upon user creation (e.g. DUYHV6TJBC3O4RITS1WC).
     * @param factor DuoAuthFactor to use for authentication.
     */
    public DuoAuthUserId(String userId, DuoAuthFactor factor) {
        this.user_id = userId;
        this.factor = factor;
    }
}
