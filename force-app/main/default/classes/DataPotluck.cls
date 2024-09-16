/**
 * Various object shapes that the Data Potluck API can return.
 * It often returns maps of these objects, the consumer code should
 * try to do something like JSON.deserialize(str, Map<String, DataPotluck.DPLEnrollment>.class)
 *
 * You should then try-catch JSONException errors (which can happen if the format is not as expected),
 * and you can use parseErrorMessage to parse the error message and raise a DPLException if
 * parseErrorMessage returns not null
 *
 * I've also commented out any fields that we aren't using, that way changes to these fields
 * don't cause issues with deserializing - uncomment them out if you need them for future work
 *
 * DPL docs: https://asudev.jira.com/wiki/spaces/DPL/pages/2923954448/WIP+API+endpoint
 */
global class DataPotluck {
    global class DPLEnrollment {
        // public String acadCareer;
        public String acadCareerDescription;
        public String academicIntegrityGrade;
        public Boolean auditGradingBasis;
        // public String catalogNumber;
        public DPLClass classDetail;
        public String classNumber;
        // public String classSection;
        // public Long completeSessionWithdrawalDeadlineDate;
        // public String courseId;
        // public String courseOfferNumber;
        // public Long dropDeadlineDate;
        // public String emplid;
        // public Long enrollmentDropDate;
        public String enrollmentStatus;
        public String enrollmentStatusReason;
        public Boolean faConfirmationOfParticipation;
        // public Decimal gradePoints;
        // public String gradingBasis;
        // public String gradingBasisDescription;
        // public String instructorChoiceEmplid;
        public String officialGrade;
        // public String primaryAsuriteid;
        // public String promodCohortCode;
        public String sessionCode;
        // public DPLPerson studentDetail;
        // public String subject;
        public String strm;
        public String strmDescription;
        // public Long timestamp;
        public Decimal unitsTaken;
        // public Long withdrawalDeadlineDate;
    }

    global class DPLPerson {
        // public String campusId;
        // public String emplid;
        // public String gender;
        // public Map<String, DPLPersonName> names; // Maps from a nameTypeCode to DPLPersonName
        // public String primaryAsuriteid;
        // public String sevisId;
    }

    global class DPLPersonName {
        // public String familyName;
        // public String givenName;
        // public String middleName;
        // public String namePrefix;
        // public String nameSuffix;
        // public String nameType; // {PRI (Primary), PRF (Preferred), ...}
    }

    global class DPLCourse {
        // public String acadCareerCode;
        // public Decimal academicProgressUnits;
        // public Boolean allowMultipleEnrollmentsInTerm;
        // public Decimal approvedUnitsMinimum;
        // public Decimal approvedUnitsMaximum;
        public String catalogNumber;
        // public Boolean catalogPrint;
        // public List<DPLCourseComponent> components;
        public String courseId;
        public String courseOfferNumber;
        // public Boolean courseRepeatable;
        // public Decimal defaultUnitsMinimum;
        // public Decimal defaultUnitsMaximum;
        public String description;
        // public String equivalentCourseGroupId;
        // public Decimal financialAidProgressUnits;
        // public String fullDescription;
        // public String gradingBasisCode;
        // public String gradingBasisDescription;
        // public String greatestTermOffered;
        // public String primaryOwningDepartmentAcadOrg;
        // public String primaryOwningDepartmentDescription;
        // public String primaryOwningParentCollegeAcadOrg;
        // public String primaryOwningParentCollegeDescription;
        // public String requirementDesignationCode;
        // public String requirementDesignationDescription;
        // public String requirementGroupCode;
        // public String requirementGroupDescription;
        // public List<DPLCourseSplitOwner> splitOwners;
        public String strm;
        public String subject;
        // public Integer totalCompletionsAllowed;
        // public Decimal totalUnitsAllowed;
        // public List<DPLCourseTopic> topics;
    }

    global class DPLCourseSplitOwner {
        // public String departmentAcadOrg;
        // public Decimal percentOwned;
    }

    global class DPLCourseTopic {
        // public Boolean courseRepeatable;
        // public String description;
        // public String topicLinkId;
        // public Integer totalCompletionsAllowed;
        // public Decimal totalUnitsAllowed;
    }

    global class DPLCourseComponent {
        // public String code;
        // public String description;
        // public Boolean primary;
        // public Boolean graded;
        // public Boolean optional;
    }

    global class DPLClass {
        // public Long associatedClass;
        public String catalogNumber;
        // public String campusCode;
        // public List<String> classNotes;
        // public String classNumber;
        // public String classSection;
        // public String classStatusCode;
        // public String classStatusDescription;
        // public String combinedSectionsId;
        // public String courseComponent;
        // public String courseComponentDescription;
        public String courseId;
        // public String courseOfferNumber;
        public String courseTopicTitle;
        public String description;
        public String displayTitle;
        // public Long endDate;
        // public Long enrollmentCapacity;
        // public String finalGradeRosterPosted;
        // public Boolean gradedComponent;
        // public String instructionMode;
        // public String instructorEdit;
        public String locationCode;
        public String locationDescription;
        public List<DPLMeeting> meetings;
        // public String offeredByDepartmentAcadOrgCode;
        // public String offeredByCollegeAcadOrgCode;
        // public Boolean promodShell;
        // public Boolean schedulePrint;
        // public String sessionCode;
        // public Long startDate;
        // public String strm;
        public String subject;
    }

    global class DPLMeeting {
        // public String buildingAddress1;
        // public String buildingAddress2;
        // public String buildingAddress3;
        // public String buildingAddress4;
        // public String buildingCampus;
        // public String buildingCity;
        // public String buildingCode;
        // public String buildingCountry;
        // public String buildingDescription;
        // public String buildingPostal;
        // public String buildingState;
        public Long endDate;
        public Long endTime;
        // public String facilityDescription;
        // public String facilityId;
        public String facilityLocationCode;
        // public String facilityRoom;
        public List<DPLInstructor> instructors;
        public List<String> meetDays;
        // public Integer meetingNumber;
        public Long startDate;
        public Long startTime;
    }

    global class DPLInstructor {
        // public String emplid;
        // public Boolean schedulePrint;
        // public String instructorRole;
        // public Integer assignSequence;
        public String firstName;
        public String lastName;
        // public String asuriteid;
        // public String iSearchUrl;
    }

    global class DPLAcademicStatusReport {
        // public String acadCareer;
        public List<DPLASRAction> actions;
        public String asrPeriodCode;
        // public String asrPeriodDescription;
        public String classNumber;
        public String commentText;
        // public String emplid;
        public String grade;
        // public String gradeDescription;
        public List<DPLASRReason> reasons;
        public String strm;
    }

    global class DPLASRAction {
        // public String gradeActionCode;
        public String gradeActionDescription;
    }

    global class DPLASRReason {
        // public String gradeReasonCode;
        public String gradeReasonDescription;
    }

    global class DPLGuestAccess {
        // public Long accessExpirationDate;
        public Long effectiveDate;
        // public Integer effectiveSequence;
        public String externalOrganizationName;
        // public DPLPerson guestDetail; // returned if &include=guestDetail, but we don't have permission
        public String guestEmplid;
        // public Integer guestId;
        // public Boolean inSuspense;
        public Boolean onlineAccess;
        // public Boolean parentPlusAccess;
        public List<String> permissionCodes;
        public String provisionalGuestName;
        public String recordAddedBy;
        // public Long recordAddedTimestamp;
        // public String relationshipCode;
        public String relationshipDescription;
        public String statusCode;
        // public String statusDescription;
        // public DPLPerson studentDetail; // returned if calling guest-access/guest endpoint with &include=studentDetail, but we don't have permission
        // public String studentEmplid;
        // public Long timestamp;
    }

    global class DPLStudentCareerTerm {
        // public String acadCareerCode;
        // public String academicLevelBeginningOfTermCode;
        // public String academicLevelBeginningOfTermDescription;
        // public String academicStandingCode;
        // public String academicStandingDescription;
        // public String combinedTotalInProgressForDisplay;
        // public String combinedTotalTransferForDisplay;
        // public String combinedUnitsInProgressForDisplay;
        // public String combinedUnitsTransferForDisplay;
        // public Decimal cumulativeGpa;
        public String cumulativeGpaForDisplay;
        // public Boolean cumulativeGpaForDisplayCapped;
        // public Boolean eligibleToEnroll;
        // public String emplid;
        // public Decimal enrollmentGradePoints;
        // public String enrollmentGradePointsForDisplay;
        // public String primaryAcadProgramCode;
        public String strm;
        // public Decimal termGpa;
        public String termGpaForDisplay;
        // public Long timestamp;
        // public Decimal totalEnrollmentGradePoints;
        // public String totalEnrollmentGradePointsForDisplay;
        // public Decimal totalFromOtherCredit;
        // public Decimal totalFromTestCredit;
        // public Decimal totalInProgressNotForGpa;
        // public Decimal totalInProgressForGpa;
        // public Decimal totalTakenForProgress;
        // public Decimal totalTakenNotTowardGpa;
        // public String totalTakenNotTowardGpaForDisplay;
        // public Decimal totalTakenTowardGpa;
        public String totalTakenTowardGpaForDisplay;
        // public Decimal totalTransferred;
        // public Decimal unitsFromOtherCredit;
        // public Decimal unitsFromTestCredit;
        // public Decimal unitsInProgressForGpa;
        // public Decimal unitsInProgressNotForGpa;
        // public Decimal unitsTakenNotTowardGpa;
        // public String unitsTakenNotTowardGpaForDisplay;
        // public Decimal unitsTakenTowardGpa;
        public String unitsTakenTowardGpaForDisplay;
        // public Decimal unitsTransferred;
    }

    global class DPLAdvisingNote {
        // public String acadCareerCode;
        public String acadPlanCode;
        public String acadProgramCode;
        public Long createdAt;
        public String createdByOprid;
        public String advisingNoteText;
        // public String emplid;
        // public String institution;
        // public String studentCareerNumber;
        // public String strm;
        // public String sequenceNumber;
        // public Long timestamp;
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
            // format has changed - could not extract message
            return null;
        }
    }

    private class ErrorPayload {
        public String error;
    }

    public class DPLException extends Exception {
    }
}
