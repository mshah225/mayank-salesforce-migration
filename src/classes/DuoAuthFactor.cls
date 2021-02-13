public interface DuoAuthFactor {
    /**
     * Returns the ApexType of the current class
     *
     * @return the ApexType of DuoPushFactor
     */
    Type getType();

    /**
     * Serializes the current class' state
     *
     * @return a JSON serialization of the current class' state
     */
    String serialize();
}
