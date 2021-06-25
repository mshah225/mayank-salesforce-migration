public class AlertHandler {
    public List<customAlert> alerts { get; set; }

    /**
     * Create a new alert handler and instantiate the alerts list
     */
    public alertHandler() {
        clear(); // Use clear to save on character count limits
    }

    /**
     * Add a new alert to the alerts list
     *
     * <p>
     * Verifies no duplicate alerts exist prior to adding.
     * </p>
     *
     * @param customAlert the alert object to be added to the list
     */
    public void newAlert(customAlert a) {
        if (!isDuplicate(a)) {
            this.alerts.add(a);
        }
    }

    /**
     * Add a new alert to the alerts list
     *
     * <p>
     * Override to reduce amount of code required to add new alerts.
     * </p>
     *
     * @param String The severity of the alert (should use ApexPages.severity strings)
     * @param String The message to be displayed
     */
    public void newAlert(String severity, String message) {
        newAlert(new customAlert(severity, message));
    }

    /**
     * Empty the list of any existing alerts.
     *
     * <p>
     * Used to clear errors before posting a success message
     * </p>
     */
    public void clear() {
        this.alerts = new List<customAlert>();
    }

    /**
     * Get a list of only fatal alerts.
     *
     * @return List<customAlert> list of fatal alerts
     */
    public List<customAlert> getFatal() {
        List<customAlert> result = new List<customAlert>();

        for (customAlert ca : alerts) {
            if (ca.severity == customAlert.FATAL) {
                result.add(ca);
            }
        }

        return result;
    }

    /**
     * Get a list of only info alerts.
     *
     * @return List<customAlert> list of info alerts
     */
    public List<customAlert> getInfo() {
        List<customAlert> result = new List<customAlert>();

        for (customAlert ca : alerts) {
            if (ca.severity == customAlert.INFO) {
                result.add(ca);
            }
        }

        return result;
    }

    /**
     * Get a list of only Warning alerts.
     *
     * @return List<customAlert> list of Warning alerts
     */
    public List<customAlert> getWarning() {
        List<customAlert> result = new List<customAlert>();

        for (customAlert ca : alerts) {
            if (ca.severity == customAlert.WARNING) {
                result.add(ca);
            }
        }

        return result;
    }

    /**
     * Get a list of only Confirm alerts.
     *
     * @return List<customAlert> list of Confirm alerts
     */
    public List<customAlert> getConfirm() {
        List<customAlert> result = new List<customAlert>();

        for (customAlert ca : alerts) {
            if (ca.severity == customAlert.CONFIRM) {
                result.add(ca);
            }
        }

        return result;
    }

    /**
     * Check if the alert is a duplicate of an existing alert
     *
     * <p>
     * Alerts with the exact same severity and message are considered
     * duplicates.
     * </p>
     *
     * @param customAlert The object to check.
     */
    private boolean isDuplicate(customAlert a) {
        for (customAlert c : alerts) {
            if (c.severity == a.severity && c.message == a.message) {
                return true;
            }
        }

        return false;
    }
}
