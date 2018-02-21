public class InsertEmailMessageCalloutBody {
        private String emailTextBody;
        private String parentId;
        private String emailSubject;
        private Boolean isIncoming;
        private String fromName;
        private String fromAddress;
        private String toAddress;
        private String status;
        
        public InsertEmailMessageCalloutBody(String emailTextBody, String parentId,
                String emailSubject, Boolean isIncoming,
                String fromName, String fromAddress,
                String toAddress, String status) {
            this.emailTextBody = emailTextBody;
            this.parentId = parentId;
            this.emailSubject = emailSubject;
            this.isIncoming = isIncoming;
            this.fromName = fromName;
            this.fromAddress = fromAddress;
            this.toAddress = toAddress;
            this.status = status;
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
        
        public Boolean getIsIncoming() {
            return isIncoming;
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
        
        public String getStatus() {
            return status;
        }
        
}