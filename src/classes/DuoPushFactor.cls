public with sharing class DuoPushFactor implements DuoAuthFactor {
    private String device;
    private String type;
    private String display_username;
    private String pushinfo;

    /**
     * Authenticates a user with Duo Push.
     *
     * @param device ID of the device. This device must have the "push"
     * capability.
     */
    public DuoPushFactor(String device) {
        this.device = device;
    }

    /**
     * This string is displayed in the Duo Mobile app before the word "request".
     * The default is "Login", so the phrase "Login request" appears in the
     * push notification text and on the request details screen. You may
     * want to specify "Transaction", "Transfer", etc.
     *
     * @param type a string to display in the Duo Mobile app before the word
     * "request"
     *
     * @return the current DuoPushFactor instance
     */
    public DuoPushFactor setType(String type) {
        this.type = type;
        return this;
    }

    /**
     * String to display in Duo Mobile in place of the user's Duo username.
     *
     * @param displayUsername a string to display in place of the Duo username
     *
     * @return the current DuoPushFactor instance
     */
    public DuoPushFactor setDisplayUsername(String displayUsername) {
        this.display_username = displayUsername;
        return this;
    }

    /**
     * A set of URL-encoded key/value pairs with additional contextual
     * information associated with this authentication attempt. The Duo Mobile
     * app will display this information to the user.
     *
     * For example: from=login%20portal&domain=example.com
     *
     * The URL-encoded string's total length must be less than 20,000 bytes.
     *
     * @param pushInfo a set of URL-encoded key/value pairs
     *
     * @return the current DuoPushFactor instance
     */
    public DuoPushFactor setPushInfo(Map<String, String> pushInfo) {
        this.pushinfo = DuoUtil.urlEncodeParams(pushInfo);
        return this;
    }

    /**
     * Returns the ApexType of the current class
     *
     * @return the ApexType of DuoPushFactor
     */
    public Type getType() {
        return DuoPushFactor.class;
    }

    /**
     * Serializes the current class' state
     *
     * @return a JSON serialization of the current class' state
     */
    public String serialize() {
        return JSON.serialize(this, true);
    }
}
