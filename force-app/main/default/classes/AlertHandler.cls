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
     * @param String The title to be displayed
     * @param String The message to be displayed
     * @param String The link to be appended to the alert
     */
    public void newAlert(String severity, String title, String message, String link) {
        newAlert(new customAlert(severity, title, message, link));
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
        newAlert(severity, null, message, null);
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

    // Note that ApexPages.currentPage().getParameters() seems to be a case-insenstive mapping (Feedback and feedback both return the same value)
    public void loadStandardAlertsFromMap(Map<String, String> paramMap) {
        if (paramMap.get('feedback') == 'yes') {
            this.newAlert(
                customAlert.CONFIRM,
                'Thank you for your feedback. ',
                'Your feedback helps ASU make the Knowledge Base better.',
                ''
            );
        }

        if (paramMap.get('confirm') == 'newcase') {
            this.newAlert(
                customAlert.CONFIRM,
                'Your request has been submitted. ',
                'We are working on responding to you as soon as possible. A member of the ASU team will contact you if additional information is needed to answer your request. Please check back here, in the My ASU Service Center, to track the status of your request.',
                ''
            );
        } else if (paramMap.get('confirm') == 'feedback') {
            this.newAlert(customAlert.CONFIRM, 'Thank you for your feedback about the My ASU Service Center!', '', '');
        }

        if (paramMap.get('suggest') == 'yes') {
            this.newAlert(
                customAlert.CONFIRM,
                'Thank you for suggesting an article! ',
                'Your suggestions help ASU make the Knowledge Base better.',
                ''
            );
        }
    }
}
