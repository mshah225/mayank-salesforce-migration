public class customAlert {
    /**
     * Severity variables for ease of use
     */
    public static final String FATAL;
    public static final String INFO;
    public static final String WARNING;
    public static final String CONFIRM;

    /**
     * Initialize severity variables
     */
    static {
        FATAL = 'FATAL';
        INFO = 'INFO';
        WARNING = 'WARNING';
        CONFIRM = 'CONFIRM';
    }

    /**
     * The severity of the issue. Used to determine alert style.
     * <p>
     * Should use the static constants to set values for this property
     * </p>
     */
    public String severity { get; set; }

    /**
     * The title to be displayed
     */
    public String title { get; set; }

    /**
     * The message to be displayed
     */
    public String message { get; set; }

    /**
     * A link, if there is one, to be displayed
     */
    public String link { get; set; }

    /**
     * Constructor with initializers
     */
    public customAlert(String severity, String title, String message, String link) {
        this.severity = severity;
        this.title = title;
        this.message = message;
        this.link = link;
    }

    /**
     * Simple constructor
     */
    public customAlert() {
    }
}
