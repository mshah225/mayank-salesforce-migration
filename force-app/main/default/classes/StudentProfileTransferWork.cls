/**
 * Payload from the Trasnfer Work API
 * It returns an instance of this object so you need to use
 * JSON.deserialize(str, StudentProfileTransferWork.class)
 *
 * Make sure you try-catch JSONException errors (which can happen if the format is not as expected),
 * and you can use parseErrorMessage to parse the error message and raise a TrasnferWorkAPIException
 * if parseErrorMessage returns not null
 *
 * I've also commented out any fields that we aren't using, that way changes to these fields
 * don't cause issues with deserializing - uncomment them out if you need them for future work
 */
global class StudentProfileTransferWork {
    // public List<TransferWorkCreditDatum> transfer_credit_data;
    // public List<ExternalEducationDatum> external_education_data;
    public List<ExternalExamDatum> external_exam_data;

    public class TransferWorkCreditDatum {
        // public String external_org_id;
        // public String external_org_descr;
        // public String acad_career;
        // public String institution;
        // public List<TransferWorkCreditCourse> courses;
    }

    public class TransferWorkCreditCourse {
        // public Integer model_nbr;
        // public String articulation_term;
        // public Integer trans_eqvlncy_grp;
        // public Integer trans_eqvlncy_seq;
        // public String transfer_status;
        // public String ext_term;
        // public Integer term_year;
        // public String school_subj;
        // public String school_course_nbr;
        // public String course_descr;
        // public String course_title;
    }

    public class ExternalEducationDatum {
        // public String external_org_id;
        // public String external_org_descr;
        // public List<ExternalEducationCareer> external_career;
    }

    public class ExternalEducationCareer {
        // public String external_career;
        // public List<ExternalEducationCourse> courses;
    }

    public class ExternalEducationCourse {
        // public Integer external_course_nbr;
        // public String ext_term;
        // public Integer term_year;
        // public String school_subj;
        // public String school_coures_nbr;
        // public String course_descr;
        // public String course_grade_official;
    }

    public class ExternalExamDatum {
        public String test_id;
        public String test_descr;
        public List<ExternalExamExamDatum> exam_data;
    }

    public class ExternalExamExamDatum {
        // public String acad_career;
        // public String institution;
        // public Integer model_nbr;
        public String articulation_term;
        // public Integer transEqvlncy_grp;
        // public Integer transEqvlncy_seq;
        // public String transfer_status;
        // public String test_eqvlncy;
        // public String trans_eqvlncy_cmp;
        // public String test_component;
        // public String test_date;
        // public String data_source;
        public Decimal score;
        // public Integer percentile;
        public String course_Id;
        public Integer course_offer_nbr;
        public Integer unit_transfer;
        // public String grading_scheme;
        // public String grading_basis;
        // public String course_grade_official;
        // public Integer grade_points_per_unit;
        // public String earn_credit;
        // public String include_in_gpa;
        // public String units_attempted;
        // public String repeat_code;
        // public String requirement_designation;
        // public String freeze_record;
        // public String input_change;
        // public String reject_reason;
        // public String transfer_overridden;
        // public String override_reason;
        // public String valid_attempt;
        // public String grade_category;
        // public String weeks_of_instruction_stats;
    }

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

    public class TrasnferWorkAPIException extends Exception {
    }
}
