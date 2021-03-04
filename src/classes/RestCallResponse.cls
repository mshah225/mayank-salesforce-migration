global class RestCallResponse {
    private String status;
    private String message;

    public RestCallResponse(String status, String message) {
        this.status = status;
        this.message = message;
    }

    public Boolean isSuccessfull() {
        if (status == 'success') {
            return true;
        }
        return false;
    }

    public String getMessage() {
        return message;
    }
}
