/**
 * Payload from the Student checklist API, comments endpoint
 * It returns a list of these so you'll want to use
 * JSON.deserialize(str, List<StudentProfileChecklistComment>.class)
 *
 * Make sure you try-catch JSONException errors (which can happen if the format is not as expected),
 * and you can use parseErrorMessage to parse the error message and raise a ChecklistAPIException
 * if parseErrorMessage returns not null
 *
 * I've also commented out any fields that we aren't using, that way changes to these fields
 * don't cause issues with deserializing - uncomment them out if you need them for future work
 */
global class StudentProfileChecklistComment {
    public String ACAD_PLAN;
    public String ACAD_PROGRAM;
    // public String ADMIN_FUNCTION;
    // public String DESCR;
    public String CMNT_CATEGORY;
    public String CMNT_ID;
    public DateTime COMMENT_DTTM;
    public String COMMENTS;
    // public String EMPLID;

    /**
     * If we failed to parse payload, try to parse it as an error payload so we can raise an error
     */
    public static String parseErrorMessage(String responseBody) {
        if (responseBody == null)
            return null;
        if (String.isBlank(responseBody))
            return null;

        try {
            ErrorPayload ePayload = (ErrorPayload) (JSON.deserialize(responseBody, ErrorPayload.class));
            return ePayload.error;
        } catch (JSONException ex) {
            // format not the standard JSON error format

            // let's check if it is the 503 error from API not running?
            if (responseBody.toLowerCase().contains('503 service unavailable'))
                return '503 Error, API is not running';

            // Still could not extract message
            return null;
        }
    }

    private class ErrorPayload {
        public String error;
    }

    public class ChecklistAPIException extends Exception {
    }
}
