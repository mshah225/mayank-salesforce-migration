public class InsertEmailMessageCalloutBody {
    private String emailTextBody;
    private String parentId;
    private String emailSubject;
    private String fromName;
    private String fromAddress;
    private String toAddress;

    public InsertEmailMessageCalloutBody(
        String emailTextBody,
        String parentId,
        String emailSubject,
        String fromName,
        String fromAddress,
        String toAddress
    ) {
        this.emailTextBody = emailTextBody;
        this.parentId = parentId;
        this.emailSubject = emailSubject;
        this.fromName = fromName;
        this.fromAddress = fromAddress == null ? '' : fromAddress;
        this.toAddress = toAddress == null ? '' : toAddress;
    }

    public String getEmailTextBody() {
        return emailTextBody;
    }

    public String getParentId() {
        return parentId;
    }

    public String getEmailSubject() {
        return emailSubject;
    }

    public String getFromName() {
        return fromName;
    }

    public String getFromAddress() {
        return fromAddress;
    }

    public String getToAddress() {
        return toAddress;
    }
}
