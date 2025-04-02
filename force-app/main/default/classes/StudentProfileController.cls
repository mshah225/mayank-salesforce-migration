/**
 * Controller class for handling student profile functionalities in a Salesforce environment.
 * This class is responsible for managing and displaying various details related to a student's profile.
 */
global with sharing class StudentProfileController {
    private static List<String> vars = new List<String>();

    private static final Map<String, String> MEETUP_DAY_MAP = new Map<String, String>{
        'SUNDAY' => 'Su',
        'MONDAY' => 'M',
        'TUESDAY' => 'Tu',
        'WEDNESDAY' => 'W',
        'THURSDAY' => 'Th',
        'FRIDAY' => 'F',
        'SATURDAY' => 'Sa'
    };

    private static Map<String, String> LOCATION_CODE_TO_NAME_MAP {
        get {
            if (LOCATION_CODE_TO_NAME_MAP == null) {
                LOCATION_CODE_TO_NAME_MAP = new Map<String, String>();
                for (Location__c l : [SELECT Name, Location_Code__c FROM Location__c WHERE Location_Status__c = TRUE])
                    LOCATION_CODE_TO_NAME_MAP.put(l.Location_Code__c, l.Name);
            }
            return LOCATION_CODE_TO_NAME_MAP;
        }
        set;
    }

    @TestVisible
    private static final Map<String, String> GUEST_ACCESS_CODE_MAP = new Map<string, String>{
        'ADMS' => 'Admissions Status',
        'ACAD' => 'Class Schedule/Major/College',
        'FAID' => 'Fin Aid, Acct Charges, Payment',
        'GRAD' => 'Final Grades and GPA',
        'PERS' => 'Name/addresses/phones/ASUemail',
        'HOUS' => 'On-campus Housing',
        'OTHR' => 'Other Educational Records',
        'PPLS' => 'Parent PLUS Loans',
        'TASK' => 'Tasks'
    };

    private Boolean isContactId;
    private String aidYear;

    public String contactId { get; set; }
    public Boolean urlParamsExistAndAreValid { get; set; }
    public String contactName { get; set; }
    public Contact theContact { get; set; }
    public List<Case> openCases { get; set; }
    public List<Student_Group__c> sGroupList { get; set; }
    public List<GraduateProgramPlanWrapper> activeGraduatePrograms { get; set; }
    public List<GraduateProgramPlanWrapper> completedGraduatePrograms { get; set; }
    public List<GraduateProgramPlanWrapper> LOAGraduatePrograms { get; set; }  
    public List<Student_Program_Plan__c> ugProgramPlans { get; set; }
    public List<Student_Program_Plan__c> activeGradProgramPlans { get; set; }
    public List<Student_Program_Plan__c> completedGradProgramPlans { get; set; }
    public List<Service_Indicator__c> serviceIndicators { get; set; }
    public List<et4ae5__IndividualEmailResult__c> emailsForContact { get; set; }
    public List<CaseComment> caseComments { get; set; }
    public Student_Program_Plan__c studentProgram { get; set; }
    public List<Student_Program_Plan_Advisor__c> ugStudentProgramAdvisors { get; set; }
    public List<Student_Program_Plan_Advisor__c> gradStudentProgramAdvisors { get; set; }
    public Map<Id, List<Student_Program_Plan_Advisor__c>> gradStudentCommittees { get; set; }
    public Student_Account__c studentAccount { get; set; }
    public Financial_Aid_Package__c financialAidPackage { get; set; }
    public Me3__c me3Results { get; set; }
    public Me3__c me3HighSchoolResults { get; set; }
    public List<Student_Milestone__c> studentMilestonesUGrad { get; set; }
    public List<Student_Milestone__c> studentMilestonesGrad { get; set; }
    public FinancialAidWrapper faWrapper { get; set; }
    public List<Test_Score__c> testUndergradScoreList { get; set; }
    public List<Test_Score__c> testGradScoreList { get; set; }
    public String suncardPhotoURL { get; set; }
    public String deceased { get; set; }
    public String currentTerm { get; set; }
    public String currentTermName { get; set; }
    public String nextTerm { get; set; }
    public String nextTermName { get; set; }
    public String futureTerm { get; set; }
    public String futureTermName { get; set; }
    public String subPlanString { get; set; }
    public String eAdvisorStatus { get; set; }
    public String ciScore { get; set; }
    public String ciScoreUsed { get; set; }
    public List<System.SelectOption> caseFunctionaGroupPicklist { get; set; }
    public String serviceIndicatorTerm { get; set; }
    public Decimal undergradGPA { get; set; }
    public Decimal gradGPA { get; set; }
    public List<String> financialAidIndicators { get; set; }
    public Map<String, String> termToName { get; set; }
    public List<String> generalMessages { get; set; }
    public List<String> classesMessages { get; set; }
    public List<String> financesMessages { get; set; }
    public List<String> commentsMessages { get; set; }
    public List<String> careerDevelopmentMessages { get; set; }
    public List<String> undergraduateAcademicsMessages { get; set; }
    public List<String> undergraduateIndicatorsMessages { get; set; }
    public List<String> graduateAcademicsMessages { get; set; }
    public List<String> graduateIndicatorsMessages { get; set; }
    public List<String> careAndConcernMessages { get; set; }
    public List<String> careAndConcernRestrictedMessages { get; set; }

    /**
     * Property to get or set the substitute user details.
     * @return UserHelper.SubstituteUserWrapper instance with substitute user details.
     */
    public UserHelper.SubstituteUserWrapper substituteUser {
        get {
            if (substituteUser == null) {
                substituteUser = UserHelper.getSubstituteUserDetails();
            }
            return substituteUser;
        }
        set;
    }

    /**
     * Property to check if the substitute user has access to the Student 360 feature.
     * @return Boolean indicating if the substitute user has Student 360 access.
     */
    public Boolean substituteUserHasStudent360Access {
        get {
            return substituteUser.isSubstitutingAsAnotherUser &&
                PermissionsHelper.userHasCustomPermission('Student_360_Visible', substituteUser.substituteUserId);
        }
        set;
    }

    /**
     * Property to determine if the Student 360 feature should be shown to the substitute user.
     * @return Boolean indicating if the Student 360 feature should be shown to the substitute user.
     */
    public Boolean showRestrictedStudent360ToSubstituteUser {
        get {
            return substituteUser.isSubstitutingAsAnotherUser &&
                !substituteUserHasStudent360Access &&
                loggedInUserHasStudent360Access;
        }
        set;
    }

    /**
     * Property to check if the logged-in user has access to the Student 360 feature.
     * @return Boolean indicating if the logged-in user has Student 360 access.
     */
    public Boolean loggedInUserHasStudent360Access {
        get {
            return FeatureManagement.checkPermission('Student_360_Visible');
        }
        set;
    }

    /**
     * Property to check if the current user has access to the Student 360 feature.
     * @return Boolean indicating if the user has access to the Student 360 feature.
     */
    public Boolean hasStudent360Access {
        get {
            return substituteUser.isSubstitutingAsAnotherUser
                ? substituteUserHasStudent360Access && loggedInUserHasStudent360Access
                : loggedInUserHasStudent360Access;
        }
        set;
    }

    /**
     * Checks if the current user has permissions to create cases.
     * @return Boolean indicating if the current user has permissions to create cases.
     */
    public Boolean hasCreateCasePermissions {
        get {
            return PermissionsHelper.currentUserHasCreateCasePermissions();
        }
        set;
    }

    /**
     * Retrieves the undergraduate student program plan.
     */
    public Student_Program_Plan__c ugStudentProgram {
        get {
            return ugProgramPlans.isEmpty() ? new Student_Program_Plan__c() : ugProgramPlans[0];
        }
        set;
    }

    /**
     * Retrieves the graduate student program plan.
     */
    public Student_Program_Plan__c gradStudentProgram {
        get {
            return activeGraduatePrograms.isEmpty()
                ? new Student_Program_Plan__c()
                : activeGraduatePrograms[0].gradProgramPlan;
        }
        set;
    }

    /**
     * Checks if the academic integrity requirement is completed.
     */
    public String completedAcademicIntegrity {
        get {
            if (completedAcademicIntegrity == null) {
                List<Checklist_Item__c> academicIntegrity = [
                    SELECT Checklist_Item_Status__c
                    FROM Checklist_Item__c
                    WHERE Checklist_Item_Code__c = 'SRACIN' AND Contact__c = :theContact.Id
                    LIMIT 1
                ];
                if (academicIntegrity.isEmpty()) {
                    completedAcademicIntegrity = '--';
                } else if (academicIntegrity[0].Checklist_Item_Status__c.equals('Completed')) {
                    completedAcademicIntegrity = 'Yes';
                } else {
                    completedAcademicIntegrity = 'No';
                }
            }
            return completedAcademicIntegrity;
        }
        set;
    }

    /**
     * Constructor for StudentProfileController.
     * Initializes various lists and sets default values based on URL parameters.
     */
    public StudentProfileController() {
        if (ApexPages.currentPage().getParameters().get('contactId') != null) {
            contactId = ApexPages.currentPage().getParameters().get('contactId');
            urlParamsExistAndAreValid = true;
        } else {
            urlParamsExistAndAreValid = false;
        }
        subPlanString = '';
        ugProgramPlans = new List<Student_Program_Plan__c>();
        activeGraduatePrograms = new List<GraduateProgramPlanWrapper>();
        completedGraduatePrograms = new List<GraduateProgramPlanWrapper>();
        LOAGraduatePrograms = new List<GraduateProgramPlanWrapper>();
    }

    /**
     * Initializes the student profile. If the URL parameters exist and are valid, sets various student profile details.
     * Otherwise, initializes default values and adds a fatal error message indicating a missing EMPLID.
     */
    public void init() {
        if (urlParamsExistAndAreValid) {
            setStudentProfileMessages();
            setContactRecord();
            setDeceased();
            setMilestones();
            setCurrentAndNextTerms();
            setOpenCases();
            setStudentGroups();
            setServiceIndicators();
            setStudentProgramsAndAdvisors();
            setCaseFunctionalGroupPicklist();
            setTestScores();
            setFinancials();
            setMe3Results();
            setAdvisorStatus();
            setCI();
            setFinancialAidIndicator();
            setContactEmailRecords();
            setCaseCommentHistory();
        } else {
            initializeValuesForNullContactId();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.EMPLIDMissing));
        }
    }

    /**
     * Initializes default values for the student profile when contactId is null.
     */
    public void initializeValuesForNullContactId() {
        testUndergradScoreList = new List<Test_Score__c>();
        testGradScoreList = new List<Test_Score__c>();
        studentMilestonesUGrad = new List<Student_Milestone__c>();
        studentMilestonesGrad = new List<Student_Milestone__c>();
        faWrapper = new FinancialAidWrapper();
        openCases = new List<Case>();
        serviceIndicators = new List<Service_Indicator__c>();
        sGroupList = new List<Student_Group__c>();
        ugStudentProgramAdvisors = new List<Student_Program_Plan_Advisor__c>();
        gradStudentProgramAdvisors = new List<Student_Program_Plan_Advisor__c>();
        contactName = ApexPages.currentPage().getParameters().get('contactName');
    }

    /**
     * Checks if the student is part of the WICHE program based on their student groups.
     * @return Boolean indicating if the student is part of the WICHE program.
     */
    public Boolean getWICHE() {
        Boolean WICHE = false;
        for (Student_Group__c sg : sGroupList) {
            if (
                sg.SG_Status__c && (sg.SG_PeopleSoft_Code__c.equals('WRGP') || sg.SG_PeopleSoft_Code__c.equals('SFX6'))
            ) {
                WICHE = true;
            }
        }
        return WICHE;
    }

    /**
     * Checks if the student is part of an accelerated program based on their student groups.
     * @return Boolean indicating if the student is part of an accelerated program.
     */
    public Boolean getAccelerated() {
        Boolean accelerated = false;
        for (Student_Group__c sg : sGroupList) {
            if (
                sg.SG_Status__c &&
                (sg.SG_PeopleSoft_Code__c.equals('GRAI') ||
                (sg.SG_PeopleSoft_Code__c.equals('ADIP') && studentProgram.Education_Level__c == '17'))
            ) {
                accelerated = true;
            }
        }
        return accelerated;
    }

    /**
     * Sets the contact record based on the contactId.
     * Throws an exception if the contact record or EMPLID is missing.
     */
    private void setContactRecord() {
        if (Validator.validateId(contactId, Contact.class)) {
            isContactId = true;
        } else if (Validator.validateEMPLId(contactId)) {
            isContactId = false;
        } else {
            throw new StudentProfileException('URL Parameters are missing or invalid');
        }

        if (isContactId) {
            theContact = ContactService.getContactInformation(contactId, '');
        } else {
            theContact = ContactService.getContactInformation('', String.valueOf(contactId));
        }

        if (theContact == null || theContact.EMPLID__c == null) {
            throw new StudentProfileException('Contact missing EMPLID');
        }
    }

    /**
     * Sets the deceased status based on the contact record.
     */
    private void setDeceased() {
        deceased = theContact.Deceased__c ? 'Deceased' : '';
    }

    /**
     * Sets the student milestones for undergraduate and graduate programs.
     */
    private void setMilestones() {
        setStudentMilestoneUGrad();
        setStudentMilestoneGrad();
    }

    /**
     * Sets the undergraduate student milestones.
     */
    private void setStudentMilestoneUGrad() {
        studentMilestonesUGrad = [
            SELECT
                Id,
                Acad_Career__c,
                Acad_Program__c,
                Acad_Program__r.Name,
                Acad_Plan__r.Name,
                Milestone__c,
                Milestone_Complete__c,
                Descr__c,
                Descrformal__c,
                Milestone_Level__c,
                Milestone_Title__c,
                Term_Required__r.Name,
                Date_Completed__c,
                Anticipated_Term__c,
                Milestone_Nbr__c,
                Effdt__c
            FROM Student_Milestone__c
            WHERE Contact__c = :theContact.Id AND Acad_Career__c = 'UGRD'
            ORDER BY Effdt__c DESC
        ];
    }

    /**
     * Sets the financial aid indicators for the student.
     */
    private void setFinancialAidIndicator() {
        financialAidIndicators = new List<String>();
        if (theContact.Financial_Aid_Indicator__c == null || theContact.Financial_Aid_Indicator__c == '') {
            financialAidIndicators.add('--');
        } else {
            String financialAidIndicator = theContact.Financial_Aid_Indicator__c;
            financialAidIndicator = financialAidIndicator.replace('\\n', ';');
            financialAidIndicators = financialAidIndicator.split(';');
        }
    }

    /**
     * Sets the graduate student milestones.
     */
    private void setStudentMilestoneGrad() {
        studentMilestonesGrad = [
            SELECT
                Id,
                Acad_Career__c,
                Acad_Program__c,
                Acad_Program__r.Name,
                Acad_Plan__r.Name,
                Milestone__c,
                Milestone_Complete__c,
                Descr__c,
                Descrformal__c,
                Milestone_Level__c,
                Milestone_Title__c,
                Term_Required__r.Name,
                Date_Completed__c,
                Anticipated_Term__c,
                Milestone_Nbr__c,
                Effdt__c,
                Grad_Format_Advisor__c
            FROM Student_Milestone__c
            WHERE Contact__c = :theContact.Id AND (Acad_Career__c = 'GRAD' OR Acad_Career__c = 'LAW')
            ORDER BY Effdt__c DESC
        ];
    }

    /**
     * Sets the current and next terms for the student.
     */
    private void setCurrentAndNextTerms() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        String nextTermPeoplesoftCode = currentTermData.NextTerm__c;
        String futureTermPeoplesoftCode = currentTermData.FutureTerm__c;
        currentTerm = currentTermData.CurrTerm__c;
        nextTerm = currentTermData.NextTerm__c;
        futureTerm = currentTermData.FutureTerm__c;

        List<Term__c> termList = [
            SELECT Name, PeopleSoft_Code__c, Aid_Year__c
            FROM Term__c
            WHERE
                PeopleSoft_Code__c = :currentTerm
                OR PeopleSoft_Code__c = :nextTermPeoplesoftCode
                OR PeopleSoft_Code__c = :futureTermPeoplesoftCode
        ];

        for (Term__c term : termList) {
            if (term.PeopleSoft_Code__c == currentTerm) {
                currentTermName = term.Name;
                aidYear = term.Aid_Year__c;
            } else if (term.PeopleSoft_Code__c == nextTermPeoplesoftCode) {
                nextTermName = term.Name;
            } else if (term.PeopleSoft_Code__c == futureTermPeoplesoftCode) {
                futureTermName = term.Name;
            }
        }
    }

    /**
     * Sets various messages for the student profile based on custom metadata.
     */
    public void setStudentProfileMessages() {
        generalMessages = new List<String>();
        classesMessages = new List<String>();
        financesMessages = new List<String>();
        commentsMessages = new List<String>();
        careerDevelopmentMessages = new List<String>();
        undergraduateAcademicsMessages = new List<String>();
        undergraduateIndicatorsMessages = new List<String>();
        graduateAcademicsMessages = new List<String>();
        graduateIndicatorsMessages = new List<String>();
        careAndConcernMessages = new List<String>();
        careAndConcernRestrictedMessages = new List<String>();

        List<Student_Profile_Message__mdt> messages = [
            SELECT Message_to_Display__c, Student_Profile_Tab__c, DeveloperName
            FROM Student_Profile_Message__mdt
            WHERE Is_Active__c = TRUE
        ];

        for (Student_Profile_Message__mdt message : messages) {
            if (message.Student_Profile_Tab__c == 'General') {
                generalMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Classes') {
                classesMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Finances') {
                financesMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Comments') {
                commentsMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Career Development') {
                careerDevelopmentMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Undergraduate Academics') {
                undergraduateAcademicsMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Undergraduate Indicators') {
                undergraduateIndicatorsMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Graduate Academics') {
                graduateAcademicsMessages.add(message.Message_to_Display__c);
            } else if (message.Student_Profile_Tab__c == 'Graduate Indicators') {
                graduateIndicatorsMessages.add(message.Message_to_Display__c);
            } else if (
                message.Student_Profile_Tab__c == 'Care and Concern' &&
                message.DeveloperName == 'Care_and_Concern'
            ) {
                careAndConcernMessages.add(message.Message_to_Display__c);
            } else if (
                showRestrictedStudent360ToSubstituteUser &&
                message.Student_Profile_Tab__c == 'Care and Concern' &&
                message.DeveloperName == 'Care_and_Concern_Access'
            ) {
                careAndConcernRestrictedMessages.add(message.Message_to_Display__c);
            }
        }
    }

    private void setCaseFunctionalGroupPicklist() {
        caseFunctionaGroupPicklist = getCaseFunctionalGroupPicklist();
    }

    /**
     * Sets the open cases for the student.
     */
    private void setOpenCases() {
        openCases = CaseService.getAllOpenCases(theContact.Id);
    }

    /**
     * Sets the student groups for the student.
     */
    private void setStudentGroups() {
        sGroupList = StudentGroupService.getContactActiveStudentGroups(theContact.Id);
    }

    /**
     * Sets the service indicators for the student.
     */
    private void setServiceIndicators() {
        List<Service_Indicator__c> serviceIndicatorList = [
            SELECT SI_Code__c, SI_Description__c, SI_Reason__c, SI_Start_Date__c
            FROM Service_Indicator__c
            WHERE
                SI_Contact__c = :theContact.Id
                AND SI_Positive_Service_Indicator__c = FALSE
                AND (SI_Start_Date__c < :Date.today()
                OR SI_Start_Date__c = NULL)
            ORDER BY SI_Start_Date__c ASC, SI_Code__c ASC
        ];
        serviceIndicators = (!serviceIndicatorList.isEmpty() ? serviceIndicatorList : new List<Service_Indicator__c>());
    }

    /**
     * Sets the student programs and advisors for the student.
     */
    private void setStudentProgramsAndAdvisors() {
        setStudentProgramPlans();
        setUndergraduateStudentProgramPlanAdvisors();
        setGraduateStudentProgramPlanAdvisors();
        setGraduateStudentProgramPlanCommitteesAndAdvisors();
        setGraduateStudentProgramPlanMilestone();
    }

    /**
     * Sets the student program plans for the student.
     */
    private void setStudentProgramPlans() {
        List<Student_Program_Plan__c> allProgramPlans = [
            SELECT
                Career__c,
                Adm_Appl_Dt__c,
                Adm_Appl_Prog__c,
                Admit_Term__c,
                Admit_Term__r.Name,
                Admit_Type__c,
                Admission_Type_Description__c,
                Appt_Dt__c,
                Appt_Dt_Pending__c,
                ASUPGA_Status__c,
                Enrl_Deposit__c,
                Enrl_Hrs__c,
                Enrl_Hrs_Pending__c,
                Education_Level__c,
                Exp_Grad_Term__c,
                Exp_Grad_Term__r.Name,
                Cohort__c,
                Enrolled_Next_Term__c,
                Residency__c,
                Cum_GPA__c,
                Grad_Max_Time_Limit__c,
                Grad_Max_Time_Limit__r.Name,
                Grad_iPOS_Status__c,
                Grad_iPOS_Status_Date__c,
                Tot_Cumulative__c,
                Academic_Standing__c,
                eAdvisor__c,
                Requirement_Term__c,
                Status__c,
                Program_Description__c,
                Plan_Description__c,
                Degree__c,
                Campus__r.Name,
                Primary_Flag__c,
                Completion_Term__c,
                Plan_Type_Text__c,
                Plan_Code__c,
                ASU_AA_OVRL_GPA__c,
                ASU_AA_POS_GPA__c,
                Graduate_Specialization__c,
                Degree_Checkout_Status_Name__c,
                Grad_Culminating_Event__c,
                Grad_Advanced_To_Candidacy__c,
                Degree_Level__c,
                Grad_Continuous_Enrollment__c,
                Grad_Anticipated_Term__c,
                Grad_Anticipated_Term__r.Name,
                Grad_ASU_Hours_After__c,
                Grad_ASU_Hours_Before__c,
                Grad_ASU_Hours_Transfer__c,
                Grad_Blanket_Hours__c,
                Degree_Chkout_Stat_Code__c,
                Plan_Transcript_Description__c
            FROM Student_Program_Plan__c
            WHERE Contact__c = :theContact.Id
            ORDER BY
                Status__c,
                Primary_Flag__c DESC,
                Completion_Term__c DESC,
                Plan_Type_Text__c DESC,
                Plan_Description__c
        ];

        if (allProgramPlans.isEmpty()) {
            return;
        }

        List<String> allTerms = new List<String>();

        for (Student_Program_Plan__c programPlan : allProgramPlans) {
            if (programPlan.Career__c == null || programPlan.Career__c == 'Undergraduate') {
                ugProgramPlans.add(programPlan);
            } else {
                if (programPlan.Status__c == 'Active in Program') {
                    GraduateProgramPlanWrapper pgrm = new GraduateProgramPlanWrapper();
                    pgrm.gradProgramPlan = programPlan;
                    activeGraduatePrograms.add(pgrm);
                } else if (programPlan.Status__c == 'Leave of Absence') {
                    GraduateProgramPlanWrapper pgrm = new GraduateProgramPlanWrapper();
                    pgrm.gradProgramPlan = programPlan;
                    LOAGraduatePrograms.add(pgrm);  
                } else {
                    GraduateProgramPlanWrapper pgrm = new GraduateProgramPlanWrapper();
                    pgrm.gradProgramPlan = programPlan;
                    completedGraduatePrograms.add(pgrm);
                }
            }

            if (programPlan.Primary_Flag__c) {
                studentProgram = programPlan;
            }
            if (!String.isEmpty(programPlan.Requirement_Term__c)) {
                allTerms.add(programPlan.Requirement_Term__c);
            }
        }

        setTermMap(allTerms);

        for (Student_Program_Plan__c programPlan : allProgramPlans) {
            if (programPlan == null || programPlan.Requirement_Term__c == null) {
                programPlan.Requirement_Term__c = '--';
            } else {
                programPlan.Requirement_Term__c = termToName.get(programPlan.Requirement_Term__c);
            }
        }

        setSubplanString();

        setGPA();
    }

    /**
     * Sets the GPA for the undergraduate and graduate programs.
     */
    private void setGPA() {
        for (GraduateProgramPlanWrapper gppw : activeGraduatePrograms) {
            if (gppw.gradProgramPlan.Primary_Flag__c && gppw.gradProgramPlan.Tot_Cumulative__c > 0) {
                gradGPA = gppw.gradProgramPlan.Cum_GPA__c;
                break;
            }
            if (gppw.gradProgramPlan.Tot_Cumulative__c > 0) {
                gradGPA = gppw.gradProgramPlan.Cum_GPA__c;
            }
        }

        for (Student_Program_Plan__c ugpp : ugProgramPlans) {
            if (ugpp.Primary_Flag__c && ugpp.Tot_Cumulative__c > 0) {
                undergradGPA = ugpp.Cum_GPA__c;
                break;
            }
            if (ugpp.Tot_Cumulative__c > 0) {
                undergradGPA = ugpp.Cum_GPA__c;
            }
        }
    }

    /**
     * Sets the term map based on the provided list of terms.
     * @param terms List of term codes to be mapped to their names.
     */
    private void setTermMap(List<String> terms) {
        if (terms.isEmpty()) {
            return;
        }
        List<Term__c> termNames = [SELECT Name, PeopleSoft_Code__c FROM Term__c WHERE PeopleSoft_Code__c IN :terms];

        termToName = new Map<String, String>();

        if (termNames.isEmpty()) {
            return;
        }

        for (Term__c term : termNames) {
            termToName.put(term.PeopleSoft_Code__c, term.Name);
        }
    }

    /**
     * Sets the subplan string for the student program.
     */
    private void setSubplanString() {
        if (studentProgram == null || studentProgram.Id == null) {
            return;
        }
        List<Student_Program_Subplan__c> subplans = [
            SELECT Subplan_Description__c, Student_Program_Plan__c
            FROM Student_Program_Subplan__c
            WHERE Student_Program_Plan__c = :studentProgram.Id
        ];
        if (subplans == null || subplans.isEmpty()) {
            return;
        }
        for (Student_Program_Subplan__c subplan : subplans) {
            if (subplan.Student_Program_Plan__c == studentProgram.Id) {
                subPlanString = subplan.Subplan_Description__c;
            }
        }
    }

    /**
     * Sets the undergraduate student program plan advisors.
     */
    public void setUndergraduateStudentProgramPlanAdvisors() {
        ugStudentProgramAdvisors = [
            SELECT
                Student_Program_Plan__r.Career__c,
                Advisor_Email__c,
                Advisor_Id__c,
                Name,
                Advisor_Phone__c,
                Advisor_Name__c
            FROM Student_Program_Plan_Advisor__c
            WHERE Student_Program_Plan__c = :ugStudentProgram.Id AND Student_Program_Plan__r.Career__c = 'Undergraduate'
            ORDER BY Name
        ];
    }

    /**
     * Sets the graduate student program plan advisors.
     */
    public void setGraduateStudentProgramPlanAdvisors() {
        gradStudentProgramAdvisors = [
            SELECT
                Student_Program_Plan__r.Career__c,
                Advisor_Email__c,
                Advisor_Id__c,
                Name,
                Advisor_Phone__c,
                Advisor_Name__c
            FROM Student_Program_Plan_Advisor__c
            WHERE
                Student_Program_Plan__c = :gradStudentProgram.Id
                AND (Student_Program_Plan__r.Career__c = 'Graduate'
                OR Student_Program_Plan__r.Career__c = 'Law')
            ORDER BY Name
        ];
    }

    /**
     * Sets the graduate student program plan committees and advisors.
     */
    public void setGraduateStudentProgramPlanCommitteesAndAdvisors() {
        List<Id> programPlansUsed = new List<Id>();
        for (GraduateProgramPlanWrapper gppw : activeGraduatePrograms) {
            programPlansUsed.add(gppw.gradProgramPlan.Id);
        }
        List<Student_Program_Plan_Advisor__c> committeesAndAdvisors = [
            SELECT
                Business_Title__c,
                Committee_Name__c,
                Company_Description__c,
                Advisor_Role__c,
                Student_Program_Plan__c,
                Advisor_Name__c,
                Committee_Type__c,
                Committee_Member_Attend_Method__c
            FROM Student_Program_Plan_Advisor__c
            WHERE Student_Program_Plan__c IN :programPlansUsed AND Student_Program_Plan__r.Career__c = 'Graduate'
            ORDER BY Student_Program_Plan__c, Advisor_Role__c, Advisor_Name__c
        ];

        for (GraduateProgramPlanWrapper gppw : activeGraduatePrograms) {
            gppw.gradCommittees = new List<Student_Program_Plan_Advisor__c>();
            gppw.gradAdvisors = new List<Student_Program_Plan_Advisor__c>();
            String programPlanId = gppw.gradProgramPlan.Id;
            for (Student_Program_Plan_Advisor__c sppa : committeesAndAdvisors) {
                if (programPlanId == sppa.Student_Program_Plan__c && sppa.Committee_Type__c != 'GRADFAC') {
                    gppw.gradAdvisors.add(sppa);
                } else if (programPlanId == sppa.Student_Program_Plan__c) {
                    gppw.gradCommittees.add(sppa);
                }
            }
        }
    }

    /**
     * Sets the graduate student program plan milestones.
     */
    public void setGraduateStudentProgramPlanMilestone() {
        List<String> planCode = new List<String>();
        for (GraduateProgramPlanWrapper gppw : activeGraduatePrograms) {
            planCode.add(gppw.gradProgramPlan.Plan_Code__c);
        }
        List<Student_Milestone__c> defenseMilestones = [
            SELECT
                Defense_Building__c,
                Defense_Date_Time__c,
                Defense_Location__c,
                Defense_Room__c,
                Format_Document_Type__c,
                Format_Status__c,
                Defense_Status__c,
                Milestone__c,
                Final_Defense_Results_Status_DtTm__c,
                Format_Final_Defense_Results_Status__c,
                Format_Status_Last_Updated__c,
                Acad_Plan__r.Plan_Code__c,
                Grad_Format_Advisor__c
            FROM Student_Milestone__c
            WHERE
                Contact__c = :theContact.Id
                AND Acad_Plan__r.Plan_Code__c IN :planCode
                AND (Milestone__c = 'GRDEFENSE'
                OR Milestone__c = 'GRDISSERT'
                OR Milestone__c = 'GRTHESIS'
                OR Milestone__c = 'GRFORMAT'
                OR Milestone__c = 'GRRESPAPER'
                OR Milestone__c = 'GRPRACTIC'
                OR Milestone__c = 'GRBNDDOC')
                AND Milestone_Level__c != 'Not Required'
            ORDER BY Effdt__c ASC
        ];

        for (Student_Milestone__c milestone : defenseMilestones) {
            for (GraduateProgramPlanWrapper gppw : activeGraduatePrograms) {
                if (milestone.Acad_Plan__r.Plan_Code__c == gppw.gradProgramPlan.Plan_Code__c) {
                    if (milestone.Milestone__c == 'GRDEFENSE') {
                        gppw.gradMilestoneDefense = milestone;
                    } else if (
                        milestone.Milestone__c == 'GRDISSERT' ||
                        milestone.Milestone__c == 'GRTHESIS' ||
                        milestone.Milestone__c == 'GRRESPAPER' ||
                        milestone.Milestone__c == 'GRPRACTIC' ||
                        milestone.Milestone__c == 'GRBNDDOC'
                    ) {
                        gppw.gradMilestoneDiss = milestone;
                    } else if (milestone.Milestone__c == 'GRFORMAT') {
                        gppw.gradMilestoneFormat = milestone;
                    }
                }
            }
        }
    }

    /**
     * Retrieves the case functional group picklist options.
     * @return List of SelectOption for case functional group picklist.
     */
    public List<SelectOption> getCaseFunctionalGroupPicklist() {
        List<SelectOption> caseFunctionalGroupPicklist = new List<SelectOption>();
        List<Case_Classification__c> caseFunctionalGroupPicklistValues = [
            SELECT Name, Id
            FROM Case_Classification__c
            WHERE
                RecordTypeId = :RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
                AND Active__c = TRUE
            ORDER BY Name ASC
        ];

        caseFunctionalGroupPicklist.add(new SelectOption('', '<SELECT>'));
        for (Case_Classification__c functionalGroup : caseFunctionalGroupPicklistValues) {
            caseFunctionalGroupPicklist.add(new SelectOption(functionalGroup.Id, functionalGroup.Name));
        }

        return caseFunctionalGroupPicklist;
    }

    /**
     * Sets the test scores for the student.
     */
    private void setTestScores() {
        setUndergradStudentTestScores();
        setGraduateStudentTestScores();
    }

    /**
     * Sets the undergraduate student test scores.
     */
    private void setUndergradStudentTestScores() {
        Set<String> testCodes = new Set<String>{
            'ACT',
            'AECP',
            'AMPT',
            'AP',
            'CLEP',
            'DSST',
            'DSST2',
            'GED',
            'ALEKSMATH',
            'ALEKSMATHPL',
            'ACCUPLACER2',
            'HISET',
            'IELTS',
            'MPT',
            'PTE',
            'SAT I',
            'SAT II',
            'TOEFL',
            'TOEIC',
            'SATII',
            'GMAT',
            'GRE',
            'LSAT',
            'MAT',
            'MCAT'
        };
        testUndergradScoreList = [
            SELECT Test_Component_Score__c, Test_Component__c, Test_Date__c, Test_Type__c
            FROM Test_Score__c
            WHERE Contact__c = :theContact.Id AND Test_Type__c IN :testCodes AND Integration_Source__c = 'PeopleSoft'
            ORDER BY Test_Type__c, Test_Component__c, Test_Date__c DESC
        ];
    }

    /**
     * Sets the graduate student test scores.
     */
    private void setGraduateStudentTestScores() {
        Set<String> testCodes = new Set<String>{
            'GMAT',
            'GRE',
            'IELTS',
            'LSAT',
            'MAT',
            'MCAT',
            'PTE',
            'TOEFL',
            'TOEIC'
        };
        testGradScoreList = [
            SELECT Test_Component_Score__c, Test_Component__c, Test_Date__c, Test_Type__c
            FROM Test_Score__c
            WHERE Contact__c = :theContact.Id AND Test_Type__c IN :testCodes AND Integration_Source__c = 'PeopleSoft'
            ORDER BY Test_Type__c, Test_Component__c, Test_Date__c DESC
        ];
    }

    /**
     * Sets the financial details for the student.
     */
    private void setFinancials() {
        setFinancialAidWrapper();
        setStudentAccount();
        setFinancialAidPackage();
    }

    /**
     * Sets the financial aid wrapper for the student.
     */
    private void setFinancialAidWrapper() {
        faWrapper = new FinancialAidWrapper();

        Set<String> tempAidYears = new Set<String>();
        for (Financial_Aid_Detail__c faRecord : [
            SELECT
                Acad_Career__c,
                Accept_Amount__c,
                Aid_Year__c,
                Descr__c,
                Contact__c,
                Descr_Category__c,
                Disbursed_Amount__c,
                Id,
                Offer_Amount__c,
                Name
            FROM Financial_Aid_Detail__c
            WHERE Contact__c = :theContact.Id
            ORDER BY Aid_Year__c DESC, Descr_Category__c ASC, Name ASC
        ]) {
            tempAidYears.add(faRecord.Aid_Year__c);
            faWrapper.summaryRecords.add(faRecord);
        }
        if (!tempAidYears.isEmpty()) {
            faWrapper.aidYears.addAll(tempAidYears);
            faWrapper.aidYears.add('All');
        }
    }

    /**
     * Sets the student account details.
     */
    private void setStudentAccount() {
        List<Student_Account__c> studentAccounts = [
            SELECT Future_Balance__c, Account_Balance__c, Past_Due_Tip__c
            FROM Student_Account__c
            WHERE Contact__c = :theContact.Id
            LIMIT 1
        ];

        if (!studentAccounts.isEmpty()) {
            studentAccount = studentAccounts[0];
        } else {
            studentAccount = new Student_Account__c();
        }
    }

    /**
     * Sets the financial aid package details.
     */
    private void setFinancialAidPackage() {
        List<Financial_Aid_Package__c> financesPackageList = [
            SELECT
                Aid_Year__c,
                Contact__c,
                CreatedById,
                CreatedDate,
                EFC_Range__c,
                FA_Status_Time_Stamp__c,
                FAFSA_Date_Received__c,
                Fin_Aid_Package_Date__c,
                Financial_Aid_Status__c,
                Id,
                IsDeleted,
                LastModifiedById,
                LastModifiedDate,
                Name,
                Pell_Eligibility__c,
                Promise_Cohort__c,
                SystemModstamp
            FROM Financial_Aid_Package__c
            WHERE Contact__c = :theContact.Id AND Aid_Year__c = :aidYear
            LIMIT 1
        ];
        financialAidPackage = financesPackageList.isEmpty() ? new Financial_Aid_Package__c() : financesPackageList[0];
    }

    /**
     * Sets the Me3 results for the student.
     */
    private void setMe3Results() {
        setMe3DegreeSearchResult();
        setMe3HighSchoolResult();
    }

    /**
     * Sets the Me3 degree search results for the student.
     */
    private void setMe3DegreeSearchResult() {
        List<Me3__c> me3List = [
            SELECT
                Id,
                A_Score__c,
                C_Score__c,
                Contact__c,
                E_Score__c,
                I_Score__c,
                Name,
                R_Score__c,
                S_Score__c,
                Source__c,
                Test_Completed_Date__c,
                User_Id__c,
                (
                    SELECT
                        Active__c,
                        Alternate_Title__c,
                        Career_Interest__c,
                        Career_Major__c,
                        Degree_Interest__c,
                        Id,
                        Name,
                        O_NET_SOC_Code__c,
                        OwnerId,
                        Plan_Code__c,
                        Position__c,
                        Updated_Date__c
                    FROM Me3_Careers__r
                    WHERE Active__c = TRUE
                    ORDER BY Updated_Date__c DESC, Position__c ASC
                    LIMIT 10
                )
            FROM Me3__c
            WHERE Contact__c = :theContact.Id AND Source__c = 'DegreeSearch'
            ORDER BY Test_Completed_Date__c DESC
            LIMIT 1
        ];
        me3Results = (!me3List.isEmpty() ? me3List[0] : new Me3__c());
    }

    /**
     * Sets the Me3 high school results for the student.
     */
    private void setMe3HighSchoolResult() {
        List<Me3__c> me3List = [
            SELECT
                Id,
                A_Score__c,
                C_Score__c,
                Contact__c,
                E_Score__c,
                I_Score__c,
                Name,
                R_Score__c,
                S_Score__c,
                Source__c,
                Test_Completed_Date__c,
                User_Id__c,
                (
                    SELECT
                        Active__c,
                        Alternate_Title__c,
                        Career_Interest__c,
                        Career_Major__c,
                        Degree_Interest__c,
                        Id,
                        Name,
                        O_NET_SOC_Code__c,
                        OwnerId,
                        Plan_Code__c,
                        Position__c,
                        Updated_Date__c
                    FROM Me3_Careers__r
                    WHERE Active__c = TRUE
                    ORDER BY Updated_Date__c DESC, Position__c ASC, Plan_Code__c
                    LIMIT 10
                )
            FROM Me3__c
            WHERE Contact__c = :theContact.Id AND Source__c = 'me3hs'
            ORDER BY Test_Completed_Date__c DESC
            LIMIT 1
        ];
        me3HighSchoolResults = (!me3List.isEmpty() ? me3List[0] : new Me3__c());
    }

    /**
     * Sets the CI Index for the student based on the opportunity records.
     */
    private void setCI() {
        List<Opportunity> studentOpp = [
            SELECT CI_Score_Used__c, Current_CI_Score__c
            FROM Opportunity
            WHERE
                Contact__r.EMPLID__c = :theContact.EMPLID__c
                AND Career__c = 'Undergraduate'
                AND Application_Number__c != ''
                AND RecordType.Name = 'Undergraduate Application'
                AND CloseDate > TODAY
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        ciScore = '--';
        ciScoreUsed = '--';

        if (studentOpp.size() > 0) {
            if (studentOpp[0].Current_CI_Score__c != null)
                ciScore = '' + studentOpp[0].Current_CI_Score__c;
            if (studentOpp[0].CI_Score_Used__c != null)
                ciScoreUsed = '' + studentOpp[0].CI_Score_Used__c;
        }
    }

    /**
     * Sets the email records for the contact.
     */
    private void setContactEmailRecords() {
        emailsForContact = new List<et4ae5__IndividualEmailResult__c>();
        String businessUnitForEmails = Label.SP_BU_EmailSends;
        List<et4ae5__IndividualEmailResult__c> emailResults = [
            SELECT et4ae5__SubjectLine__c, et4ae5__DateSent__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE
                et4ae5__SendDefinition__r.et4ae5__Business_Unit__r.et4ae5__Business_Unit_ID__c = :businessUnitForEmails
                AND et4ae5__DateSent__c > LAST_YEAR
                AND et4ae5__Contact__c = :theContact.Id
            ORDER BY et4ae5__DateSent__c DESC
        ];

        if (emailResults != null) {
            emailsForContact = emailResults;
        }
    }

    private void setCaseCommentHistory() {
        caseComments = FullCaseCommentsController.getComments(theContact.Id);
    }

    /**
     * Sets the advisor status for the student based on their undergraduate programs.
     */
    private void setAdvisorStatus() {
        for (Student_Program_Plan__c spp : ugProgramPlans) {
            if (spp.eAdvisor__c == 'Off Track for Graduation') {
                eAdvisorStatus = 'Off Track for Graduation';
                return;
            }
        }

        eAdvisorStatus = 'No Status';
    }

    /**
     * Retrieves judicial data for the specified EMPLID.
     * @param emplid The EMPLID of the student.
     * @return Continuation object for the judicial data request.
     */
    @RemoteAction
    global static Object getJudicialData(String emplid) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('callout:Student_Judicial_Data/data/' + emplid);

            Continuation con = new Continuation(120);
            con.continuationMethod = 'processJudicialData';
            con.state = con.addHttpRequest(req);

            return con;
        } catch (Exception ex) {
            return null;
        }
    }

    /**
     * Processes the judicial data response.
     * @param state The state object from the continuation.
     * @return List of JudicialWrapper containing the judicial data.
     */
    private static Object processJudicialData(Object state) {
        List<JudicialWrapper> judicialData = new List<JudicialWrapper>();
        HttpResponse res;

        try {
            res = Continuation.getResponse((String) state);
            if (res.getStatusCode() == 200) {
                judicialData = (List<JudicialWrapper>) JSON.deserialize(res.getBody(), List<JudicialWrapper>.class);
            } else {
                throw new StudentProfileException('[ERROR] There was a problem parsing judicial data.');
            }
        } catch (Exception ex) {
            return null;
        }

        return judicialData;
    }

    /**
     * Filters unresolved financial aid checklist items.
     * @param financialAidChecklists List of FinancialAidChecklist to filter.
     * @return List of unresolved FinancialAidChecklist items.
     */
    private static List<FinancialAidChecklistWrapper.FinancialAidChecklist> filterFinancialAidUnresolvedItems(
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> financialAidChecklists
    ) {
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> unresolvedChecklists = new List<FinancialAidChecklistWrapper.FinancialAidChecklist>();
        for (FinancialAidChecklistWrapper.FinancialAidChecklist checklist : financialAidChecklists) {
            if (checklist.admin_function == 'FINA' && checklist.item_status == 'Initiated') {
                unresolvedChecklists.add(checklist);
            }
        }
        return unresolvedChecklists;
    }

    /**
     * Retrieves the SunCard photo URL for the specified ASURITE and EMPLID.
     * @param asurite The ASURITE ID of the student.
     * @param emplid The EMPLID of the student.
     * @return String containing the SunCard photo URL.
     */
    @RemoteAction
    global static String getSunCardPhotoRA(String asurite, String emplid) {
        String suncardPhotoUrl;

        try {
            suncardPhotoUrl = SuncardPhotoService.getSunCardPhotoUrl(asurite, emplid);
        } catch (Exception ex) {
            return null;
        }

        return suncardPhotoUrl;
    }

    /**
     * Retrieves advisor notes for the specified contact ID using Lightning Web Components.
     * @param contactId The contact ID of the student.
     * @return List of AdvisorNoteWrapper containing the advisor notes.
     */
    @AuraEnabled(cacheable=true)
    public static List<AdvisorNoteWrapper> getPSAdvisorNotesLWC(String contactId) {
        try {
            if (contactId == null)
                return null;

            Contact c = [SELECT Id, EMPLID__c FROM Contact WHERE Id = :contactId LIMIT 1];

            if (c.EMPLID__c == null)
                return null;

            return getAdvisingNotes(c.EMPLID__c);
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('contactId', contactId));
            ErrorLogger.log(e, vars, false);

            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get all the classes for a student, by term, along with other enrollment data such as credits/gpa.
     * @param emplId The student's EMPLID
     * @return Map of termCode to enrollment wrapper.
     */
    @RemoteAction
    global static Map<String, TermClassesWrapper> getTermClasses(String emplId) {
        try {
            Map<String, TermClassesWrapper> termDefWrapper = new Map<String, TermClassesWrapper>();
            Map<String, List<DataPotluck.DPLAcademicStatusReport>> termAndClassNumberToASR = new Map<String, List<DataPotluck.DPLAcademicStatusReport>>();

            Map<String, List<DataPotluck.DPLEnrollment>> enrollmentInfo = StudentProfileCallout.getEnrollmentInfo(
                emplId
            );
            List<DataPotluck.DPLAcademicStatusReport> acadStatusReports = StudentProfileCallout.getAcademicStatusReports(
                emplId
            );
            List<DataPotluck.DPLStudentCareerTerm> studentCareerTermList = StudentProfileCallout.getStudentCareerTermData(
                emplId
            );

            // Mpa term code to student career term
            Map<String, DataPotluck.DPLStudentCareerTerm> studentCareerTermMp = new Map<String, DataPotluck.DPLStudentCareerTerm>();
            for (DataPotluck.DPLStudentCareerTerm careerTerm : studentCareerTermList) {
                studentCareerTermMp.put(careerTerm.strm, careerTerm);
            }

            // Map class number/term to ASRs for that class
            for (DataPotluck.DPLAcademicStatusReport asr : acadStatusReports) {
                if (!termAndClassNumberToASR.containsKey(asr.strm + '|' + asr.classNumber))
                    termAndClassNumberToASR.put(
                        asr.strm + '|' + asr.classNumber,
                        new List<DataPotluck.DPLAcademicStatusReport>()
                    );
                termAndClassNumberToASR.get(asr.strm + '|' + asr.classNumber).add(asr);
            }

            // For each term create wrapper of all info
            for (String termCode : enrollmentInfo.keySet()) {
                TermClassesWrapper termClassWrap = new TermClassesWrapper();

                // add each class enrollment
                List<DataPotluck.DPLEnrollment> classEnrollmments = enrollmentInfo.get(termCode);
                for (DataPotluck.DPLEnrollment classEnrollment : classEnrollmments) {
                    List<DataPotluck.DPLAcademicStatusReport> correspondingAsrs = termAndClassNumberToASR.get(
                        classEnrollment.strm + '|' + classEnrollment.classNumber
                    );

                    ClassEnrollment eWrap = new ClassEnrollment(classEnrollment, correspondingAsrs);

                    if (eWrap.isEnrolled())
                        termClassWrap.addEnrolledClass(eWrap);
                    else
                        termClassWrap.addDroppedClass(eWrap);
                }

                // And grab term details from career term object
                DataPotluck.DPLStudentCareerTerm studentCareerTerm = studentCareerTermMp.containsKey(termCode)
                    ? studentCareerTermMp.get(termCode)
                    : null;
                termClassWrap.setTermEarnedUnits(studentCareerTerm?.unitsTakenTowardGpaForDisplay);
                termClassWrap.setCumulativeEarnedUnits(studentCareerTerm?.totalTakenTowardGpaForDisplay);
                termClassWrap.setTermGpa(studentCareerTerm?.termGpaForDisplay);
                termClassWrap.setCumulativeGpa(studentCareerTerm?.cumulativeGpaForDisplay);

                // Add to map
                termDefWrapper.put(termCode, termClassWrap);
            }

            return termDefWrapper;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, false);
            throw ex;
        }
    }

    /**
     * Retrieves all the credit by exam a student has achieved.
     * @param emplId The student's EMPLID
     * @return A list of all the credit by exam for the student.
     */
    @RemoteAction
    global static List<CreditByExamWrapper> getCreditByExam(String emplId) {
        try {
            List<CreditByExamWrapper> wrapperList = new List<CreditByExamWrapper>();

            StudentProfileTransferWork transferWork = StudentProfileCallout.getTransferWork(emplId);

            Map<String, Set<String>> termToCourseIds = new Map<String, Set<String>>();

            // Get all term and course ids (to do lookup for course names)
            if (transferWork.external_exam_data != null)
                for (StudentProfileTransferWork.ExternalExamDatum a : transferWork.external_exam_data)
                    if (a.exam_data != null)
                        for (StudentProfileTransferWork.ExternalExamExamDatum b : a.exam_data)
                            if (!String.isBlank(b.articulation_term) && !String.isBlank(b.course_Id)) {
                                if (!termToCourseIds.containsKey(b.articulation_term))
                                    termToCourseIds.put(b.articulation_term, new Set<String>());
                                termToCourseIds.get(b.articulation_term).add(b.course_Id);
                            }

            Map<String, DataPotluck.DPLCourse> termCourseIdOfferNumToCourseMp = new Map<String, DataPotluck.DPLCourse>();

            // We need to do a lookup to get course name/catalog number
            if (!termToCourseIds.isEmpty()) {
                for (String termCode : termToCourseIds.keySet()) {
                    List<DataPotluck.DPLCourse> courseList = StudentProfileCallout.getCourses(
                        termCode,
                        new List<String>(termToCourseIds.get(termCode))
                    );

                    for (DataPotluck.DPLCourse course : courseList)
                        termCourseIdOfferNumToCourseMp.put(
                            course.strm + '|' + course.courseId + '|' + course.courseOfferNumber,
                            course
                        );
                }
            }

            // Build the final wrappers to return
            if (transferWork.external_exam_data != null)
                for (StudentProfileTransferWork.ExternalExamDatum a : transferWork.external_exam_data)
                    if (a.exam_data != null)
                        for (StudentProfileTransferWork.ExternalExamExamDatum b : a.exam_data) {
                            if (!String.isBlank(b.course_Id))
                                wrapperList.add(
                                    new CreditByExamWrapper(
                                        b,
                                        termCourseIdOfferNumToCourseMp
                                            ?.get(b?.articulation_term + '|' + b?.course_Id + '|' + b?.course_offer_nbr)
                                    )
                                );
                        }

            // There might be duplicates - so look for the BEST version of each course and keep that one
            for (Integer i = 0; i < wrapperList.size(); i++) {
                for (Integer j = i + 1; j < wrapperList.size(); j++) {
                    CreditByExamWrapper a = wrapperList[i];
                    CreditByExamWrapper b = wrapperList[j];

                    // same soruce title - consolidate non null values
                    if (a.courseTitle == b.courseTitle) {
                        a.combine(b);
                        // remove b now that b's details are on a
                        wrapperList.remove(j);
                        j -= 1;
                    }
                }
            }

            return wrapperList;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, false);
            throw ex;
        }
    }

    /**
     * Retrieves the guest access permissions for a student.
     * @param emplId The student's EMPLID
     * @return A list of all the guest access for the student.
     */
    @RemoteAction
    global static List<GuestAccessWrapper> getGuestAccess(String emplId) {
        try {
            List<GuestAccessWrapper> wrapperList = new List<GuestAccessWrapper>();

            List<DataPotluck.DPLGuestAccess> guestAccessList = StudentProfileCallout.getGuestAccess(emplId);
            List<StudentProfileChecklistComment> commentList = StudentProfileCallout.getFerpaComments(emplId);

            Set<String> authorEmplIdSet = new Set<String>();
            Set<String> authorAsuriteSet = new Set<String>();
            Set<String> guestEmplIdSet = new Set<String>();
            for (DataPotluck.DPLGuestAccess gAccess : guestAccessList) {
                if (!String.isBlank(gAccess.guestEmplid))
                    guestEmplIdSet.add(gAccess.guestEmplid);
                if (!String.isBlank(gAccess.recordAddedBy))
                    authorAsuriteSet.add(gAccess.recordAddedBy);
            }
            for (StudentProfileChecklistComment cmm : commentList)
                if (!String.isBlank(cmm.CMNT_ID))
                    authorEmplIdSet.add(cmm.CMNT_ID);

            StringAddressHelper addrFormat = new StringAddressHelper(
                '%STREET% %CITY%, %STATE% %POSTAL%, %COUNTRY%',
                true
            );
            Map<String, String> guestCodeToNameMp = new Map<String, String>();
            // Construct name and address for each guest
            for (Contact c : [
                SELECT Id, Preferred_Full_Name__c, EMPLID__c, MailingAddress
                FROM Contact
                WHERE EMPLID__c IN :guestEmplIdSet
            ]) {
                String constructedName = '';

                if (!String.isBlank(c.Preferred_Full_Name__c))
                    constructedName += c.Preferred_Full_Name__c;
                else if (!String.isBlank(c.EMPLID__c))
                    constructedName += c.EMPLID__c;
                else
                    constructedName += '--';

                if (c.MailingAddress != null) {
                    String addrStr = addrFormat.format(c.MailingAddress);
                    if (!String.isBlank(addrStr)) {
                        constructedName += ', ' + addrStr;
                    }
                }

                guestCodeToNameMp.put(c.EMPLID__c, constructedName);
            }
            // Add mappings for author ids
            Map<String, String> authorCodeToNameMp = new Map<String, String>();
            for (Contact c : [
                SELECT Id, Preferred_Full_Name__c, EMPLID__c, ASURITE_ID__c
                FROM Contact
                WHERE ASURITE_ID__c IN :authorAsuriteSet OR EMPLID__c IN :authorEmplIdSet
            ]) {
                if (authorAsuriteSet.contains(c.ASURITE_ID__c) && !String.isBlank(c.Preferred_Full_Name__c))
                    authorCodeToNameMp.put(c.ASURITE_ID__c, c.Preferred_Full_Name__c);
                if (authorEmplIdSet.contains(c.EMPLID__c) && !String.isBlank(c.Preferred_Full_Name__c))
                    authorCodeToNameMp.put(c.EMPLID__c, c.Preferred_Full_Name__c);
            }

            // Each from DPL
            for (DataPotluck.DPLGuestAccess gAccess : guestAccessList) {
                // Should we show this guest access?
                // We only include those that acutally have some perms granted
                if (gAccess.permissionCodes != null && !gAccess.permissionCodes.isEmpty()) {
                    if (gAccess?.onlineAccess == true) {
                        // for online access, we only want to show is status code is active and perms are set
                        if (gAccess.statusCode == 'AC') {
                            GuestAccessWrapper wrapper = new GuestAccessWrapper(
                                gAccess,
                                guestCodeToNameMp,
                                authorCodeToNameMp
                            );
                            wrapperList.add(wrapper);
                        }
                    } else {
                        // for non online access, this is just a consent record, so it doesn't need to be active
                        GuestAccessWrapper wrapper = new GuestAccessWrapper(
                            gAccess,
                            guestCodeToNameMp,
                            authorCodeToNameMp
                        );
                        wrapperList.add(wrapper);
                    }
                }
            }

            // FERPA access from checklist API
            for (StudentProfileChecklistComment cmm : commentList) {
                GuestAccessWrapper wrapper = new GuestAccessWrapper(cmm, authorCodeToNameMp);
                wrapperList.add(wrapper);
            }

            wrapperList.sort();

            return wrapperList;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, false);
            throw ex;
        }
    }

    /**
     * Retrieves advising notes for a user - this includes the notes from the Advising Notes endpoint in DPL
     * as well as any CMNT_CATEGORY == 'GRGCPS' comments from the checklist API.
     * @param emplId The student's EMPLID
     * @return A list of all the advising notes for the student.
     */
    @RemoteAction
    global static List<AdvisorNoteWrapper> getAdvisingNotes(String emplId) {
        try {
            List<AdvisorNoteWrapper> wrapperList = new List<AdvisorNoteWrapper>();

            List<StudentProfileChecklistComment> commentList = StudentProfileCallout.getGradComments(emplId);
            List<DataPotluck.DPLAdvisingNote> advNoteList = StudentProfileCallout.getAdvisingNotes(emplId);

            // Get user ids based on commenter ids
            Set<String> emplIdSet = new Set<String>();
            Set<String> federationIdSet = new Set<String>();

            for (StudentProfileChecklistComment cmm : commentList)
                if (!String.isBlank(cmm.CMNT_ID))
                    emplIdSet.add(cmm.CMNT_ID);
            for (DataPotluck.DPLAdvisingNote advNote : advNoteList)
                if (!String.isBlank(advNote.createdByOprid))
                    federationIdSet.add(advNote.createdByOprid + '@admin.asu.edu');

            Map<String, User> commenterUserMap = new Map<String, User>();
            for (User user : [
                SELECT Id, Name, EmployeeNumber, FederationIdentifier
                FROM User
                WHERE EmployeeNumber IN :emplIdSet OR FederationIdentifier IN :federationIdSet
            ]) {
                if (emplIdSet.contains(user.EmployeeNumber))
                    commenterUserMap.put(user.EmployeeNumber, user);
                if (federationIdSet.contains(user.FederationIdentifier))
                    commenterUserMap.put(user.FederationIdentifier, user);
            }

            // Get program and plan names
            Set<String> programCodes = new Set<String>();
            Set<String> planCodes = new Set<String>();
            for (DataPotluck.DPLAdvisingNote advNote : advNoteList) {
                if (!String.isBlank(advNote.acadProgramCode))
                    programCodes.add(advNote.acadProgramCode);
                if (!String.isBlank(advNote.acadPlanCode))
                    planCodes.add(advNote.acadPlanCode);
            }
            for (StudentProfileChecklistComment cmm : commentList) {
                if (!String.isBlank(cmm.ACAD_PROGRAM))
                    programCodes.add(cmm.ACAD_PROGRAM);
                if (!String.isBlank(cmm.ACAD_PLAN))
                    planCodes.add(cmm.ACAD_PLAN);
            }

            Map<String, String> programCodeToName = new Map<String, String>();
            Map<String, String> planCodeToName = new Map<String, String>();

            if (!programCodes.isEmpty())
                for (Program__c p : [
                    SELECT Id, Name, Program_Code__c
                    FROM Program__c
                    WHERE Program_Code__c IN :programCodes
                ])
                    programCodeToName.put(p.Program_Code__c, p.Name);
            if (!planCodes.isEmpty())
                for (Plan__c p : [SELECT Id, Name, Plan_Code__c FROM Plan__c WHERE Plan_Code__c IN :planCodes])
                    planCodeToName.put(p.Plan_Code__c, p.Name);

            // Build response wrappers
            for (DataPotluck.DPLAdvisingNote advNote : advNoteList) {
                wrapperList.add(
                    new AdvisorNoteWrapper(
                        advNote,
                        commenterUserMap.get(advNote.createdByOprid + '@admin.asu.edu'),
                        programCodeToName.get(advNote.acadProgramCode),
                        planCodeToName.get(advNote.acadPlanCode)
                    )
                );
            }

            for (StudentProfileChecklistComment cmm : commentList)
                wrapperList.add(
                    new AdvisorNoteWrapper(
                        cmm,
                        commenterUserMap.get(cmm.CMNT_ID),
                        programCodeToName.get(cmm.ACAD_PROGRAM),
                        planCodeToName.get(cmm.ACAD_PLAN)
                    )
                );

            wrapperList.sort();

            return wrapperList;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, false);
            throw ex;
        }
    }

    /**
     * Retrieves the comments (advising comments) for a student
     * @param emplId The student's EMPLID
     * @return A list of all the comments for the student
     */
    @RemoteAction
    global static List<CommentWrapper> getComments(String emplId) {
        try {
            List<CommentWrapper> wrapperList = new List<CommentWrapper>();

            List<StudentProfileChecklistComment> commentList = StudentProfileCallout.getComments(emplId);

            // Get user ids based on commenter ids
            Set<String> emplIdSet = new Set<String>();
            for (StudentProfileChecklistComment cmm : commentList) {
                if (!String.isBlank(cmm.CMNT_ID))
                    emplIdSet.add(cmm.CMNT_ID);
            }
            Map<String, User> commenterUserMap = new Map<String, User>();
            for (User user : [SELECT Id, Name, EmployeeNumber FROM User WHERE EmployeeNumber IN :emplIdSet])
                commenterUserMap.put(user.EmployeeNumber, user);

            // Build response wrappers
            for (StudentProfileChecklistComment cmm : commentList)
                wrapperList.add(new CommentWrapper(cmm, commenterUserMap.get(cmm.CMNT_ID)));

            wrapperList.sort();

            return wrapperList;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, false);
            throw ex;
        }
    }

    /**
     * Retrieves the aid year for the student.
     * @return String containing the aid year.
     */
    public String getAidYear() {
        return aidYear;
    }

    /**
     * Creates a case based on the provided description, subject, functional group, and EMPLID.
     * @param descriptionIn The description of the case.
     * @param subjectIn The subject of the case.
     * @param functionalGroup The functional group of the case.
     * @param emplidIn The EMPLID of the student.
     * @return String containing the case number.
     */
    @RemoteAction
    global static String createCase(String descriptionIn, String subjectIn, String functionalGroup, String emplidIn) {
        try {
            String newCaseNumber = '';

            Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'ASU Service' LIMIT 1].Id;
            Id studentContactId = [SELECT Id FROM Contact WHERE EMPLID__c = :emplidIn LIMIT 1].Id;

            Case feedbackCase = new Case(
                Status = 'New',
                RecordTypeId = recordTypeId,
                ContactId = studentContactId,
                Subject = subjectIn,
                Description = descriptionIn,
                CC_Functional_Group__c = functionalGroup,
                Origin__c = 'Student Profile',
                IsVisibleInSelfService = false
            );

            SObjectAccessDecision caseCreationDecision = Security.stripInaccessible(
                AccessType.CREATABLE,
                new List<Case>{ feedbackCase }
            );
            insert caseCreationDecision.getRecords(); // insert accessible fields, if any

            for (Case newCase : (List<Case>) caseCreationDecision.getRecords()) {
                for (Case securedCase : [
                    SELECT CaseNumber
                    FROM Case
                    WHERE Id = :newCase.Id
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ]) {
                    newCaseNumber = (securedCase.CaseNumber != null) ? securedCase.CaseNumber : null;
                }
                break;
            }

            return newCaseNumber;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertStringToJSON('emplid', emplidIn));
            vars.add(ErrorLogger.convertStringToJSON('functional group', functionalGroup));
            vars.add(ErrorLogger.convertStringToJSON('subject', subjectIn));
            vars.add(ErrorLogger.convertStringToJSON('description', descriptionIn));
            ErrorLogger.log(e, vars, false);
        }

        return null;
    }

    /**
     * Retrieves the service indicators for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return List of ServiceIndicatorWrapper.ServiceIndicator containing the service indicators.
     */
    @RemoteAction
    global static List<ServiceIndicatorWrapper.ServiceIndicator> getServiceIndicatorsForStudent(String contactEmplid) {
        return StudentProfileCallout.getServiceIndicators(contactEmplid);
    }

    /**
     * Retrieves the financial aid checklist for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return List of FinancialAidChecklistWrapper.FinancialAidChecklist containing the financial aid checklist items.
     */
    @RemoteAction
    global static List<FinancialAidChecklistWrapper.FinancialAidChecklist> getFinancialAidChecklist(
        String contactEmplid
    ) {
        return StudentProfileCallout.getFinancialAidChecklists(contactEmplid);
    }

    /**
     * Retrieves unresolved financial aid checklist items for the specified list.
     * @param finAidChecklists The list of FinancialAidChecklist to filter.
     * @return List of unresolved FinancialAidChecklist items.
     */
    @RemoteAction
    global static List<FinancialAidChecklistWrapper.FinancialAidChecklist> getUnresolvedFinancialAidChecklist(
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> finAidChecklists
    ) {
        return filterFinancialAidUnresolvedItems(finAidChecklists);
    }

    /**
     * Retrieves edit messages for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return Map of aid year to list of EditMessageWrapper containing the edit messages.
     */
    @RemoteAction
    global static Map<String, List<EditMessageWrapper>> getEditMessages(String contactEmplid) {
        FinancialEditMessageWrapper editMessageWrapperDetails = StudentProfileCallout.getEditMessages(contactEmplid);

        Map<String, List<EditMessageWrapper>> aidYearToEditMessage = new Map<String, List<EditMessageWrapper>>();

        if (editMessageWrapperDetails == null) {
            return null;
        }

        editMessageWrapperDetails.edit_messages.sort();

        for (FinancialEditMessageWrapper.cls_edit_messages messages : editMessageWrapperDetails.edit_messages) {
            List<EditMessageWrapper> messagesForTerm = new List<EditMessageWrapper>();
            messages.message_details.sort();
            for (FinancialEditMessageWrapper.cls_message_details messageDetails : messages.message_details) {
                EditMessageWrapper emw = new EditMessageWrapper();
                emw.academic_year = messages.academic_year;
                emw.aid_year = messages.aid_year;
                emw.term = messageDetails.term;
                emw.action_description = messageDetails.action_description;
                emw.description = messageDetails.description;
                emw.item_type = messageDetails.item_type;
                messagesForTerm.add(emw);
            }
            aidYearToEditMessage.put(messages.academic_year, messagesForTerm);
        }

        return aidYearToEditMessage;
    }

    /**
     * Retrieves award status map for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return Map of aid year to list of term awards containing the award status.
     */
    @RemoteAction
    global static Map<String, List<FinancialAidAwardWrapper.cls_term_awards>> getAwardStatusMap(String contactEmplid) {
        FinancialAidAwardWrapper awardWrapper = StudentProfileCallout.getAwards(contactEmplid);
        awardWrapper.aid_years.sort();
        Map<String, List<FinancialAidAwardWrapper.cls_term_awards>> aidYearToAward = new Map<String, List<FinancialAidAwardWrapper.cls_term_awards>>();

        if (awardWrapper == null) {
            return null;
        }

        for (FinancialAidAwardWrapper.cls_aid_years yearsWithAwards : awardWrapper.aid_years) {
            yearsWithAwards.term_awards.sort();
            aidYearToAward.put(yearsWithAwards.financial_year, yearsWithAwards.term_awards);
            for (FinancialAidAwardWrapper.cls_term_awards specificTerm : yearsWithAwards.term_awards) {
                specificTerm.award_details.sort();
            }
        }

        return aidYearToAward;
    }

    /**
     * Retrieves charge history map for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return Map of term to charges containing the charge history.
     */
    @RemoteAction
    global static Map<String, FinancialAidChargeHistoryWrapper.cls_charges> getChargeHistoryMap(String contactEmplid) {
        FinancialAidChargeHistoryWrapper chargeHistoryWrapper = StudentProfileCallout.getChargeHistory(contactEmplid);

        Map<String, FinancialAidChargeHistoryWrapper.cls_charges> termToChargeHistory = new Map<String, FinancialAidChargeHistoryWrapper.cls_charges>();

        if (chargeHistoryWrapper == null) {
            return null;
        }

        chargeHistoryWrapper.charges.sort();

        for (FinancialAidChargeHistoryWrapper.cls_charges charges : chargeHistoryWrapper.charges) {
            charges.charge_details.sort();

            termToChargeHistory.put(charges.term_name, charges);
        }

        return termToChargeHistory;
    }

    /**
     * Retrieves financial aid account balance for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return FinancialAidBalanceWrapper containing the financial aid account balance.
     */
    @RemoteAction
    global static FinancialAidBalanceWrapper getFinancialAidAccountBalance(String contactEmplid) {
        return StudentProfileCallout.getAccountBalance(contactEmplid);
    }

    /**
     * Retrieves financial aid refunds for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return FinancialAidRefundWrapper containing the financial aid refunds.
     */
    @RemoteAction
    global static FinancialAidRefundWrapper getFinancialAidRefunds(String contactEmplid) {
        FinancialAidRefundWrapper refundWrapper = StudentProfileCallout.getRefunds(contactEmplid);

        if (refundWrapper != null && refundWrapper.refunds != null) {
            refundWrapper.refunds.sort();
        }

        return refundWrapper;
    }

    /**
     * Retrieves deposit status for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return DepositStatusWrapper containing the deposit status.
     */
    @RemoteAction
    global static DepositStatusWrapper getDepositStatus(String contactEmplid) {
        return StudentProfileCallout.getDepositStatus(contactEmplid);
    }

    /**
     * Retrieves renewable aid for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return RenewableAidWrapper containing the renewable aid.
     */
    @RemoteAction
    global static RenewableAidWrapper getRenewableAid(String contactEmplid) {
        RenewableAidWrapper aidWrapper = StudentProfileCallout.getRenewableAid(contactEmplid);
        aidWrapper.aid_years.sort();
        return aidWrapper;
    }

    /**
     * Retrieves book payments for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return BookPaymentWrapper containing the book payments.
     */
    @RemoteAction
    global static BookPaymentWrapper getBookPayments(String contactEmplid) {
        BookPaymentWrapper bookPaymentWrap = StudentProfileCallout.getBookPayments(contactEmplid);
        bookPaymentWrap.aid_years.sort();
        return bookPaymentWrap;
    }

    /**
     * Retrieves tuition residency status for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return TuitionResidencyWrapper containing the tuition residency status.
     */
    @RemoteAction
    global static TuitionResidencyWrapper getTuitionResidencyStatus(String contactEmplid) {
        try {
            TuitionResidencyWrapper residencyStatus = StudentProfileCallout.getTuitionResidencyStatus(contactEmplid);
            return residencyStatus;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Retrieves academic progress for the specified student EMPLID.
     * @param contactEmplid The EMPLID of the student.
     * @return Map of aid year to list of SAPWrapper.cls_sap containing the academic progress.
     */
    @RemoteAction
    global static Map<String, List<SAPWrapper.cls_sap>> getAcademicProgress(String contactEmplid) {
        SAPWrapper academicProgressWrapper = StudentProfileCallout.getAcademicProgress(contactEmplid);
        Map<String, List<SAPWrapper.cls_sap>> academicYearToSAP = new Map<String, List<SAPWrapper.cls_sap>>();

        if (academicProgressWrapper == null) {
            return null;
        }

        for (SAPWrapper.cls_academic_year yearsWithSAP : academicProgressWrapper.academic_year) {
            academicYearToSAP.put(yearsWithSAP.aid_year, yearsWithSAP.sap);
        }

        return academicYearToSAP;
    }

    /**
     * Wrapper class for financial aid details.
     */
    global class FinancialAidWrapper {
        public Set<String> aidYears { get; set; }
        public List<Financial_Aid_Detail__c> summaryRecords { get; set; }

        public FinancialAidWrapper() {
            aidYears = new Set<String>();
            summaryRecords = new List<Financial_Aid_Detail__c>();
        }
    }

    /**
     * Wrapper class for academic integrity data.
     */

    global class TermClassesWrapper {
        public String termEarnedUnits;
        public String cumEarnedUnits;
        public String termGpa;
        public String cumGpa;
        public List<ClassEnrollment> enrolledClasses = new List<ClassEnrollment>();
        public List<ClassEnrollment> droppedClasses = new List<ClassEnrollment>();

        public TermClassesWrapper() {
        }

        public void setTermEarnedUnits(String v) {
            if (v == null)
                termEarnedUnits = '0';
            else
                termEarnedUnits = v;
        }
        public void setCumulativeEarnedUnits(String v) {
            if (v == null)
                cumEarnedUnits = '0';
            else
                cumEarnedUnits = v;
        }
        public void setTermGpa(String v) {
            if (v == null)
                termGpa = '0';
            else
                termGpa = v;
        }
        public void setCumulativeGpa(String v) {
            if (v == null)
                cumGpa = '0';
            else
                cumGpa = v;
        }

        public void addEnrolledClass(ClassEnrollment v) {
            enrolledClasses.add(v);
        }
        public void addDroppedClass(ClassEnrollment v) {
            droppedClasses.add(v);
        }
    }

    global class ClassEnrollment {
        public String termName;
        public String termCode;
        public String session;
        public String classNumber;
        public String catalogNumber;
        public String classTitle;
        public String topic;
        public String units;
        public String status;
        public String instructor;
        public String days;
        public String times;
        public String dates;
        public String location;
        public String grade;
        public String confOfParticipation;
        public Boolean asr;
        public List<ASRWrapper> asrList;
        public Boolean enrolled;
        public Boolean hasAcademicIntegrity;
        public String academicIntegrityGrade;

        public ClassEnrollment(DataPotluck.DPLEnrollment cs, List<DataPotluck.DPLAcademicStatusReport> ars) {
            termCode = cs?.strm != null ? cs.strm : '--';
            termName = cs?.strmDescription != null ? cs?.strmDescription : '--';
            session = cs?.sessionCode != null ? cs.sessionCode : '--';
            classNumber = cs?.classNumber != null ? cs.classNumber : '--';
            catalogNumber = (cs?.classDetail?.subject != null &&
                cs?.classDetail?.catalogNumber != null)
                ? cs.classDetail.subject + ' ' + cs?.classDetail.catalogNumber
                : '--';
            classTitle = cs?.classDetail?.description != null ? cs.classDetail.description : '--';
            topic = cs?.classDetail?.courseTopicTitle != null ? cs.classDetail.courseTopicTitle : '--';
            units = cs?.unitsTaken != null ? cs.unitsTaken.stripTrailingZeros().toPlainString() : '--';
            status = cs?.enrollmentStatusReason != null ? cs.enrollmentStatusReason : '--';

            List<String> instructorList = new List<String>();
            List<String> daysList = new List<String>();
            List<String> timesList = new List<String>();
            List<String> datesList = new List<String>();
            List<String> locationList = new List<String>();

            if (cs?.classDetail?.meetings != null) {
                for (DataPotluck.DPLMeeting meetup : cs.classDetail.meetings) {
                    // Collate instructors for each meetup
                    if (meetup.instructors != null)
                        for (DataPotluck.DPLInstructor instructor : meetup.instructors)
                            if (!String.isBlank(instructor.firstName) && !String.isBlank(instructor.lastName))
                                instructorList.add(instructor.firstName + ' ' + instructor.lastName);

                    // Collate meeting days for each meetup
                    if (meetup.meetDays != null)
                        for (String meetDay : meetup.meetDays)
                            if (!String.isBlank(meetDay))
                                if (MEETUP_DAY_MAP.containsKey(meetDay))
                                    daysList.add(MEETUP_DAY_MAP.get(meetDay));
                                else
                                    daysList.add(meetDay);

                    // Collate start/end times for each meetup
                    if (meetup.startTime != null && meetup.endTime != null) {
                        Datetime startDt = Datetime.newInstance(meetup.startTime);
                        Datetime endDt = Datetime.newInstance(meetup.endTime);
                        timesList.add(
                            String.format(
                                '{0} - {1}',
                                new List<Object>{ startDt.format('hh:mm a', 'MST'), endDt.format('hh:mm a', 'MST') }
                            )
                        );
                    }

                    // Collate start/end dates for each meetup
                    if (meetup.startDate != null && meetup.endDate != null) {
                        Datetime startDt = Datetime.newInstance(meetup.startDate);
                        Datetime endDt = Datetime.newInstance(meetup.endDate);
                        datesList.add(
                            String.format(
                                '{0} - {1}',
                                new List<Object>{ startDt.format('MM/dd/yy', 'MST'), endDt.format('MM/dd/yy', 'MST') }
                            )
                        );
                    }

                    // Collate locaitons for each meetup
                    if (
                        meetup?.facilityLocationCode == 'ONLINE' &&
                        new List<String>{ 'ICOURSE', 'ASUONLINE' }.contains(cs?.classDetail?.locationCode)
                    ) {
                        // facility location is online, and course location is either iCourse or ASU Online
                        // then use the course location

                        // use location description if it is set, otherwise decode location code
                        String v = cs?.classDetail?.locationDescription != null
                            ? cs.classDetail.locationDescription
                            : cs.classDetail.locationCode == 'ICOURSE' ? 'iCourse' : 'ASU Online';

                        if (!locationList.contains(v))
                            locationList.add(v);
                    } else if (
                        meetup?.facilityLocationCode == 'ONLINE' &&
                        cs?.classDetail?.locationCode != 'ASUONLINE'
                    ) {
                        // facility location is online, and is not ASU Online
                        // then default to using iCourse
                        String v = 'iCourse';

                        if (!locationList.contains(v))
                            locationList.add(v);
                    } else {
                        // try to uset the facaility location, fallback on class location if it is null
                        if (!String.isBlank(meetup?.facilityLocationCode)) {
                            // If the location code matches a location in SF, use the name of location
                            // otherwise, fallback on location code
                            String v = LOCATION_CODE_TO_NAME_MAP.containsKey(meetup?.facilityLocationCode)
                                ? LOCATION_CODE_TO_NAME_MAP.get(meetup.facilityLocationCode)
                                : meetup?.facilityLocationCode;

                            if (!locationList.contains(v))
                                locationList.add(v);
                        } else {
                            // If the location code matches a location in SF, use the name of location, otherwise
                            // fallback on location description, and lastly, fallback on location code
                            String v = LOCATION_CODE_TO_NAME_MAP.containsKey(cs?.classDetail?.locationCode)
                                ? LOCATION_CODE_TO_NAME_MAP.get(cs.classDetail.locationCode)
                                : cs?.classDetail?.locationDescription != null
                                      ? cs.classDetail.locationDescription
                                      : cs?.classDetail?.locationCode;

                            if (!locationList.contains(v))
                                locationList.add(v);
                        }
                    }
                }
            }

            instructor = !instructorList.isEmpty() ? String.join(instructorList, '\n') : '--';
            days = !daysList.isEmpty() ? String.join(daysList, ' ') : '--';
            times = !timesList.isEmpty() ? String.join(timesList, '\n') : '--';
            dates = !datesList.isEmpty() ? String.join(datesList, '\n') : '--';
            location = !locationList.isEmpty()
                ? String.join(locationList, '\n')
                : (cs?.classDetail?.locationDescription != null
                      ? cs.classDetail.locationDescription
                      : (cs?.classDetail?.locationCode != null ? cs.classDetail.locationCode : '--'));

            grade = cs?.officialGrade != null ? cs.officialGrade : '--';
            confOfParticipation = cs?.faConfirmationOfParticipation != null
                ? (cs.faConfirmationOfParticipation ? 'Y' : 'N')
                : '--';
            asrList = new List<ASRWrapper>();
            asr = (ars != null && !ars.isEmpty()); // if not null, then there is an ASR for this class
            enrolled = cs?.enrollmentStatus == 'E' && cs?.enrollmentStatusReason == 'ENRL';

            // If ASR info exists, populate it
            if (asr) {
                for (DataPotluck.DPLAcademicStatusReport ar : ars) {
                    asrList.add(new ASRWrapper(ar));
                }
            }

            // Temporary override for conf of participation based on SPP campus/start term
            if (cs?.classDetail?.locationCode == null) {
                confOfParticipation = '--';
            } else if (new List<String>{ 'ASUONLINE' }.contains(cs?.classDetail?.locationCode)) {
                if (cs?.strm != null && cs?.strm < '2221')
                    confOfParticipation = '--';
            } else {
                if (cs?.strm != null && cs?.strm < '2227')
                    confOfParticipation = '--';
            }

            // Only set academic integrity info if current user has permission to this info
            // access granted via custom perm, or sys admin, or in tests
            if (
                UserInfo.getProfileId() == RecordIdHelper.getProfileID('System Administrator') ||
                Test.isRunningTest() ||
                FeatureManagement.checkPermission('Student_360_Visible')
            ) {
                // Set academic integrity grade if the student has one AND they weren't in class in auditting capacity
                hasAcademicIntegrity =
                    cs?.academicIntegrityGrade != null &&
                    cs.academicIntegrityGrade.contains('X') &&
                    cs?.auditGradingBasis != true;
                academicIntegrityGrade = hasAcademicIntegrity ? cs.academicIntegrityGrade : '--';
            }
        }

        public Boolean isEnrolled() {
            return enrolled;
        }
    }

    global class ASRWrapper {
        public String asrRptNo;
        public String asrGrade;
        public String asrReason;
        public String asrAction;
        public String asrComment;

        public ASRWrapper(DataPotluck.DPLAcademicStatusReport ar) {
            asrRptNo = ar.asrPeriodCode != null ? ar.asrPeriodCode : '--';
            asrGrade = ar.grade != null ? ar.grade : '--';
            if (ar.reasons != null && !ar.reasons.isEmpty()) {
                List<String> reasons = new List<String>();
                for (DataPotluck.DPLASRReason descr : ar.reasons)
                    reasons.add(descr.gradeReasonDescription);
                asrReason = String.join(reasons, ', ');
            } else {
                asrReason = '--';
            }
            if (ar.actions != null && !ar.actions.isEmpty()) {
                List<String> actions = new List<String>();
                for (DataPotluck.DPLASRAction descr : ar.actions)
                    actions.add(descr.gradeActionDescription);
                asrAction = String.join(actions, ', ');
            } else {
                asrAction = '--';
            }
            asrComment = ar.commentText != null ? ar.commentText : '--';
        }
    }

    /**
     * Wrapper for Guest Access.
     */
    global class GuestAccessWrapper implements Comparable {
        public String author;
        public String comment;
        public Long commentTimestamp;

        public GuestAccessWrapper(
            DataPotluck.DPLGuestAccess gAccess,
            Map<String, String> emplIdToNameMp,
            Map<String, String> asuriteIdToNameMp
        ) {
            // Record author
            author = gAccess?.recordAddedBy != null && asuriteIdToNameMp.containsKey(gAccess.recordAddedBy)
                ? asuriteIdToNameMp.get(gAccess.recordAddedBy)
                : !String.isBlank(gAccess?.recordAddedBy) ? gAccess.recordAddedBy : '--';

            // Start of comment depends on if guest user has MyASU guest access
            if (gAccess?.onlineAccess == true) {
                comment = 'My ASU GUEST ACCESS for ';
            } else {
                comment = 'CONSENT FOR ';
            }

            // Add all codes to comment
            if (gAccess.permissionCodes != null && !gAccess.permissionCodes.isEmpty()) {
                List<String> permissionLabels = new List<String>();
                for (String permCode : gAccess.permissionCodes) {
                    if (GUEST_ACCESS_CODE_MAP.containsKey(permCode))
                        permissionLabels.add(GUEST_ACCESS_CODE_MAP.get(permCode));
                    else
                        permissionLabels.add(permCode);
                }
                comment += String.join(permissionLabels, ', ');
            } else {
                comment += 'no listed perms';
            }

            // and specify who the guest is
            // first use provisional name, then use EMPLID lookup, then external org name, and finally leave as -- if unknown
            if (comment != null)
                comment += ' TO ';
            if (gAccess.provisionalGuestName != null) {
                comment += gAccess.provisionalGuestName;
            } else if (gAccess.guestEmplid != null && emplIdToNameMp.containsKey(gAccess.guestEmplid)) {
                comment += emplIdToNameMp.get(gAccess.guestEmplid);
            } else if (gAccess.externalOrganizationName != null) {
                comment += gAccess.externalOrganizationName;
            } else if (gAccess.relationshipDescription != null) {
                comment += gAccess.relationshipDescription;
            } else {
                comment += '--';
            }

            // And timestamp
            commentTimestamp = gAccess?.effectiveDate;
        }

        public GuestAccessWrapper(StudentProfileChecklistComment cmm, Map<String, String> emplIdToNameMp) {
            // Record author
            author = cmm?.CMNT_ID != null && emplIdToNameMp.containsKey(cmm.CMNT_ID)
                ? emplIdToNameMp.get(cmm.CMNT_ID)
                : !String.isBlank(cmm?.CMNT_ID) ? cmm.CMNT_ID : '--';

            // comment
            comment = cmm?.COMMENTS != null ? cmm.COMMENTS : '--';
            // And timestamp
            commentTimestamp = cmm?.COMMENT_DTTM != null ? cmm.COMMENT_DTTM.getTime() : null;
        }

        global Integer compareTo(Object comparison) {
            GuestAccessWrapper that = (GuestAccessWrapper) comparison;

            if (that.commentTimestamp == this.commentTimestamp)
                return 0;
            if (that.commentTimestamp == null)
                return -1;
            if (this.commentTimestamp == null)
                return 1;

            return that.commentTimestamp - this.commentTimestamp > 0 ? 1 : -1;
        }
    }

    /**
     * Advisor Note wrapper
     */
    global class AdvisorNoteWrapper implements Comparable {
        @AuraEnabled
        public String authorUserId;
        @AuraEnabled
        public String authorName;
        @AuraEnabled
        public String programName;
        @AuraEnabled
        public String planName;
        @AuraEnabled
        public Long commentDt;
        @AuraEnabled
        public String comment;

        public AdvisorNoteWrapper(DataPotluck.DPLAdvisingNote advNote, User u, String programName, String planName) {
            comment = advNote?.advisingNoteText != null ? advNote.advisingNoteText : '--';
            commentDt = advNote?.createdAt != null ? advNote.createdAt : null;
            this.programName = programName != null
                ? programName
                : (advNote?.acadProgramCode != null && !String.isBlank(advNote.acadProgramCode)
                      ? advNote.acadProgramCode
                      : '--');
            this.planName = planName != null
                ? planName
                : (advNote?.acadPlanCode != null && !String.isBlank(advNote.acadPlanCode)
                      ? advNote.acadPlanCode
                      : '--');
            authorName = u?.Name != null
                ? u.Name
                : (advNote?.createdByOprid != null && !String.isBlank(advNote?.createdByOprid)
                      ? advNote.createdByOprid
                      : '--');
            authorUserId = u?.Id; // null if unset since we will check this for null in JS to determine if make a link or not

            // standardize newlines in comment
            comment = comment.replaceAll('[\\n\\r]+', '\n');
        }

        public AdvisorNoteWrapper(StudentProfileChecklistComment cmm, User u, String programName, String planName) {
            comment = cmm?.COMMENTS != null ? cmm.COMMENTS : '--';
            commentDt = cmm?.COMMENT_DTTM != null ? cmm.COMMENT_DTTM.getTime() : null;
            this.programName = programName != null
                ? programName
                : (cmm?.ACAD_PROGRAM != null && !String.isBlank(cmm.ACAD_PROGRAM) ? cmm.ACAD_PROGRAM : '--');
            this.planName = planName != null
                ? planName
                : (cmm?.ACAD_PLAN != null && !String.isBlank(cmm.ACAD_PLAN) ? cmm.ACAD_PLAN : '--');
            authorName = u?.Name != null
                ? u.Name
                : (cmm?.CMNT_ID != null && !String.isBlank(cmm.CMNT_ID) ? cmm.CMNT_ID : '--');
            authorUserId = u?.Id; // null if unset since we will check this for null in JS to determine if make a link or not

            // standardize newlines in comment
            comment = comment.replaceAll('[\\n\\r]+', '\n');
        }

        global Integer compareTo(Object comparison) {
            AdvisorNoteWrapper that = (AdvisorNoteWrapper) comparison;

            if (that.commentDt == this.commentDt)
                return 0;
            if (that.commentDt == null)
                return -1;
            if (this.commentDt == null)
                return 1;

            return that.commentDt - this.commentDt > 0 ? 1 : -1;
        }
    }

    global class JudicialWrapper {
        public String CASE_NUMBER { get; set; }
        public String FILE_ID { get; set; }
        public String TYPE { get; set; }
        public String STATUS { get; set; }
        public String SID { get; set; }
        public String ROLE { get; set; }
        public String CASE_CREATED_DATE { get; set; }
        public String REPORTED_DATE { get; set; }
        public String INCIDENT_DATE { get; set; }
        public String INCIDENT_TIME { get; set; }
        public String INCIDENT_LOCATION { get; set; }
        public String INCIDENT_LOCATION_SPECIFIC { get; set; }
        public String INCIDENT_DESCRIPTION { get; set; }
        public String INCIDENT_SUMMARY { get; set; }
        public String CHARGE_1 { get; set; }
        public String FINDING_1 { get; set; }
        public String CHARGE_2 { get; set; }
        public String FINDING_2 { get; set; }
        public String CHARGE_3 { get; set; }
        public String FINDING_3 { get; set; }
        public String CHARGE_4 { get; set; }
        public String FINDING_4 { get; set; }
        public String CHARGE_5 { get; set; }
        public String FINDING_5 { get; set; }
        public String CHARGE_6 { get; set; }
        public String FINDING_6 { get; set; }
    }

    /**
     * Wrapper class for comments.
     */
    global class CommentWrapper implements Comparable {
        public String authorUserId;
        public String authorName;
        public Long commentDt;
        public String comment;

        public CommentWrapper(StudentProfileChecklistComment cmm, User u) {
            comment = cmm?.COMMENTS != null ? cmm.COMMENTS : '--';
            commentDt = cmm?.COMMENT_DTTM != null ? cmm.COMMENT_DTTM.getTime() : null;
            authorName = u?.Name != null ? u.Name : (cmm?.CMNT_ID != null ? cmm.CMNT_ID : '--');
            authorUserId = u?.Id; // null if unset since we will check this for null in JS to determine if make a link or not
        }

        global Integer compareTo(Object comparison) {
            CommentWrapper that = (CommentWrapper) comparison;

            if (that.commentDt == this.commentDt)
                return 0;
            if (that.commentDt == null)
                return -1;
            if (this.commentDt == null)
                return 1;

            return that.commentDt - this.commentDt > 0 ? 1 : -1;
        }
    }

    /**
     * Wrapper class for credits by exam
     */
    global class CreditByExamWrapper {
        public String title;
        public String courseTitle;
        public String score;
        public String unitsTransferred;

        public CreditByExamWrapper(
            StudentProfileTransferWork.ExternalExamExamDatum examData,
            DataPotluck.DPLCourse cs
        ) {
            title = cs?.description != null ? cs.description : '--';
            courseTitle = (cs?.subject != null &&
                cs?.catalogNumber != null)
                ? cs.subject + ' ' + cs?.catalogNumber
                : '--';

            // This is a temporary hardcode for the (Elective Credit) /course/.
            // This is not a real course, since it is not enrollable - it is just a credit ASU gives to students as a result of taking CLEP
            // This is the ONLY course like this, where it has a course id but where DPL doesn't include it
            if (cs == null && examData.course_Id == '001013') {
                title = '(Elective Credit)';
                courseTitle = 'ASU RDE';
            }

            score = examData?.score != null ? examData.score.toString() : '--';
            unitsTransferred = examData?.unit_transfer != null ? examData.unit_transfer.toString() : '--';
        }

        public void combine(CreditByExamWrapper replica) {
            if (courseTitle == '--')
                courseTitle = replica.courseTitle;
            if (title == '--')
                title = replica.title;
            if (score == '--')
                score = replica.score;
            if (unitsTransferred == '--')
                unitsTransferred = replica.unitsTransferred;
        }
    }

    /**
     * Wrapper class for graduate program plans.
     */
    public class GraduateProgramPlanWrapper {
        public Student_Milestone__c gradMilestoneDefense { get; set; }
        public Student_Milestone__c gradMilestoneFormat { get; set; }
        public Student_Milestone__c gradMilestoneDiss { get; set; }

        public Date defenseDate {
            get {
                if (gradMilestoneDefense == null || gradMilestoneDefense.Defense_Date_Time__c == null) {
                    return null;
                } else {
                    return Date.newInstance(
                        gradMilestoneDefense.Defense_Date_Time__c.year(),
                        gradMilestoneDefense.Defense_Date_Time__c.month(),
                        gradMilestoneDefense.Defense_Date_Time__c.day()
                    );
                }
            }
            set;
        }
        public String defenseTime {
            get {
                if (gradMilestoneDefense == null || gradMilestoneDefense.Defense_Date_Time__c == null) {
                    return '--';
                } else {
                    return gradMilestoneDefense.Defense_Date_Time__c.format('h:mm a');
                }
            }
            set;
        }

        public Student_Program_Plan__c gradProgramPlan { get; set; }
        public List<Student_Program_Plan_Advisor__c> gradCommittees { get; set; }
        public List<Student_Program_Plan_Advisor__c> gradAdvisors { get; set; }
    }

    /**
     * Wrapper class for edit messages.
     */
    public class EditMessageWrapper {
        public String term { get; set; }
        public String action_description { get; set; }
        public String description { get; set; }
        public String item_type { get; set; }
        public String academic_year { get; set; }
        public String aid_year { get; set; }
    }

    /**
     * Custom exception for student profile errors.
     */
    private class StudentProfileException extends Exception {
    }
}