global with sharing class StudentProfileController {
    private static List<String> vars = new List<String>();

    private Boolean isContactId;
    private String aidYear;

    public String contactId { get; set; }
    public boolean urlParamsExistAndAreValid { get; set; }
    public String contactName { get; set; }
    public Contact theContact { get; set; }
    public List<Case> openCases { get; set; }
    public List<Student_Group__c> sGroupList { get; set; }
    public List<GraduateProgramPlanWrapper> activeGraduatePrograms { get; set; }
    public List<GraduateProgramPlanWrapper> completedGraduatePrograms { get; set; }
    public List<Student_Program_Plan__c> ugProgramPlans { get; set; }
    public List<Student_Program_Plan__c> activeGradProgramPlans { get; set; }
    public List<Student_Program_Plan__c> completedGradProgramPlans { get; set; }
    public List<Service_Indicator__c> serviceIndicators { get; set; }
    public List<et4ae5__IndividualEmailResult__c> emailsForContact { get; set; }
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
    public string futureTerm { get; set; }
    public string futureTermName { get; set; }
    public String subPlanString { get; set; }
    public String eAdvisorStatus { get; set; }
    public String ciIndex { get; set; }
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
    public List<String> studentCareAndConcernMessages { get; set; }

    public Student_Program_Plan__c ugStudentProgram {
        get {
            return ugProgramPlans.isEmpty() ? new Student_Program_Plan__c() : ugProgramPlans[0];
        }
        set;
    }

    public Student_Program_Plan__c gradStudentProgram {
        get {
            return activeGraduatePrograms.isEmpty()
                ? new Student_Program_Plan__c()
                : activeGraduatePrograms[0].gradProgramPlan;
        }
        set;
    }

    public String completedAcadmicIntegrity {
        get {
            if (completedAcadmicIntegrity == null) {
                List<Checklist_Item__c> academicIntegrity = [
                    SELECT Checklist_Item_Status__c
                    FROM Checklist_Item__c
                    WHERE Checklist_Item_Code__c = 'SRACIN' AND Contact__c = :theContact.Id
                    LIMIT 1
                ];
                if (academicIntegrity.isEmpty()) {
                    completedAcadmicIntegrity = '--';
                } else if (academicIntegrity[0].Checklist_Item_Status__c.equals('Completed')) {
                    completedAcadmicIntegrity = 'Yes';
                } else {
                    completedAcadmicIntegrity = 'No';
                }
            }
            return completedAcadmicIntegrity;
        }
        set;
    }

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
    }

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
            setTestScores();
            setFinancials();
            setMe3Results();
            setAdvisorStatus();
            setCIIndex();
            setFinancialAidIndicator();
            setContactEmailRecords();
        } else {
            initializeValuesForNullContactId();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.EMPLIDMissing));
        }
    }

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
            throw new StudentProfileException('Contact missing EMPLId');
        }
    }

    private void setDeceased() {
        deceased = theContact.Deceased__c ? 'Deceased' : '';
    }

    private void setMilestones() {
        setStudentMilestoneUGrad();
        setStudentMilestoneGrad();
    }

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

    private void setCurrentAndNextTerms() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        String nextTermPeoplesoftCode = currentTermData.NextTerm__c;
        String futureTermPeoplesoftCode = currentTermData.FutureTerm__c;
        currentTerm = currentTermData.CurrTerm__c;
        nextTerm = currentTermData.NextTerm__c;
        futureTerm = currentTermData.FutureTerm__c;

        List<TERM__c> termList = [
            SELECT Name, PeopleSoft_Code__c, Aid_Year__c
            FROM TERM__c
            WHERE
                PeopleSoft_Code__c = :currentTerm
                OR PeopleSoft_Code__c = :nextTermPeoplesoftCode
                OR PeopleSoft_Code__c = :futureTermPeoplesoftCode
        ];

        for (TERM__c term : termList) {
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

        List<Student_Profile_Message__mdt> messages = [
            SELECT Message_to_Display__c, Student_Profile_Tab__c
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
            }
        }
    }

    private void setOpenCases() {
        openCases = CaseService.getAllOpenCases(theContact.Id);
    }

    private void setStudentGroups() {
        sGroupList = StudentGroupService.getContactActiveStudentGroups(theContact.Id);
    }

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

    private void setStudentProgramsAndAdvisors() {
        setStudentProgramPlans();
        setUndergraduateStudentProgramPlanAdvisors();
        setGraduateStudentProgramPlanAdvisors();
        setGraduateStudentProgramPlanCommitteesAndAdvisors();
        setGraduateStudentProgramPlanMilestone();
    }

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

    private void setSubplanString() {
        if (studentProgram == null || studentProgram.Id == null) {
            return;
        }
        List<Student_Program_Subplan__c> subplans = [
            SELECT Subplan_description__c, Student_Program_Plan__c
            FROM Student_Program_Subplan__c
            WHERE Student_Program_Plan__c = :studentProgram.Id
        ];
        if (subplans == null || subplans.isEmpty()) {
            return;
        }
        for (Student_Program_Subplan__c subplan : subplans) {
            if (subPlan.Student_Program_Plan__c == studentProgram.Id) {
                subPlanString = subplan.Subplan_description__c;
            }
        }
    }

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

    public List<SelectOption> getCaseFunctionaGroupPicklist() {
        List<SelectOption> caseFunctionaGroupPicklist = new List<SelectOption>();
        List<Case_Classification__c> caseFunctionaGroupPicklistValues = [
            SELECT Name, Id
            FROM Case_Classification__c
            WHERE
                RecordTypeId = :RecordIdHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group')
                AND Active__c = TRUE
            ORDER BY Name ASC
        ];

        caseFunctionaGroupPicklist.add(new SelectOption('', '<SELECT>'));
        for (Case_Classification__c functionalGroup : caseFunctionaGroupPicklistValues) {
            caseFunctionaGroupPicklist.add(new SelectOption(functionalGroup.Id, functionalGroup.Name));
        }

        return caseFunctionaGroupPicklist;
    }

    private void setTestScores() {
        setUndergradStudentTestScores();
        setGraduateStudentTestScores();
    }

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
        testUnderGradScoreList = [
            SELECT Test_Component_Score__c, Test_Component__c, Test_Date__c, Test_Type__c
            FROM Test_Score__c
            WHERE
                Contact__c = :theContact.Id
                AND Test_Type__c IN :testCodes
                AND Integration_Source__c = 'Student Records'
            ORDER BY Test_Type__c, Test_Component__c, Test_Date__c DESC
        ];
    }

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
            WHERE
                Contact__c = :theContact.Id
                AND Test_Type__c IN :testCodes
                AND Integration_Source__c = 'Student Records'
            ORDER BY Test_Type__c, Test_Component__c, Test_Date__c DESC
        ];
    }

    private void setFinancials() {
        setFinancialAidWrapper();
        setStudentAccount();
        setFinancialAidPackage();
    }

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

    private void setMe3Results() {
        setMe3DegreeSearchResult();
        setMe3HighScoolResult();
    }

    private void setMe3DegreeSearchResult() {
        List<me3__c> me3List = [
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

    private void setMe3HighScoolResult() {
        List<me3__c> me3List = [
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
        me3HighSchoolResults = (!me3List.isEmpty() ? me3List[0] : new me3__c());
    }

    private void setCIIndex() {
        List<Opportunity> studentOpp = [
            SELECT CI_Score__c
            FROM Opportunity
            WHERE
                Contact__r.EMPLID__c = :theContact.EMPLID__c
                AND Career__c = 'Undergraduate'
                AND Application_Number__c != ''
                AND RecordType.Name = 'Undergraduate Application'
            ORDER BY CreatedDate
            LIMIT 1
        ];

        if (studentOpp.size() > 0 && studentOpp[0].CI_Score__c != null) {
            ciIndex = '' + studentOpp[0].CI_Score__c;
        } else {
            ciIndex = '--';
        }
    }

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

    private void setAdvisorStatus() {
        for (Student_Program_Plan__c spp : ugProgramPlans) {
            if (spp.eAdvisor__c == 'Off Track for Graduation') {
                eAdvisorStatus = 'Off Track for Graduation';
                return;
            }
        }

        eAdvisorStatus = 'No Status';
    }

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

    @RemoteAction
    global static String getSunCardPhotoRA(String asurite, String emplId) {
        String suncardPhotoUrl;

        try {
            suncardPhotoUrl = SuncardPhotoService.getSunCardPhotoUrl(asurite, emplId);
        } catch (Exception ex) {
            vars.add(ErrorLogger.convertStringToJSON('asurite', asurite));
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, false);
            return null;
        }

        return suncardPhotoUrl;
    }

    @RemoteAction
    global static List<AdvisingNoteWrapper> getPSAdvisorNotes(String emplId, String jsonAdvisorNotes) {
        List<AdvisingNoteWrapper> advNoteWrapperList = new List<AdvisingNoteWrapper>();
        List<PS_ASU_SP_ADNOTE_V__x> advisingNoteList = (List<PS_ASU_SP_ADNOTE_V__x>) JSON.deserialize(
            jsonAdvisorNotes,
            List<PS_ASU_SP_ADNOTE_V__x>.class
        );

        List<String> advAsuRiteIds = new List<String>();
        for (PS_ASU_SP_ADNOTE_V__x note : advisingNoteList) {
            if (note.CREATEOPRID__c != null && note.CREATEOPRID__c != '') {
                advAsuRiteIds.add(note.CREATEOPRID__c + '@admin.asu.edu');
            }
        }

        List<User> advUserList = [
            SELECT Id, FederationIdentifier
            FROM User
            WHERE FederationIdentifier IN :advAsuRiteIds
        ];

        Map<String, String> advUserMap = new Map<String, String>();
        for (User user : advUserList) {
            advUserMap.put(user.FederationIdentifier, user.Id);
        }

        for (PS_ASU_SP_ADNOTE_V__x note : advisingNoteList) {
            AdvisingNoteWrapper noteWrapper = new AdvisingNoteWrapper();
            noteWrapper.note = note;
            noteWrapper.advUserId = advUserMap.get(note.CREATEOPRID__c + '@admin.asu.edu');
            advNoteWrapperList.add(noteWrapper);
        }

        return advNoteWrapperList;
    }

    @RemoteAction
    global static List<CommentWrapper> getComments(String emplId, String jsonComments) {
        List<PS_ASU_SP_COMMNT_V__x> commentsList = (List<PS_ASU_SP_COMMNT_V__x>) JSON.deserialize(
            jsonComments,
            List<PS_ASU_SP_COMMNT_V__x>.class
        );

        Set<String> commenterUserIds = new Set<String>();
        for (PS_ASU_SP_COMMNT_V__x comment : commentsList) {
            if (comment.COMNT_ID__c != null && comment.COMNT_ID__c != '') {
                commenterUserIds.add(comment.COMNT_ID__c);
            }
        }

        List<User> commenterUserList = [SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber IN :commenterUserIds];

        Map<String, String> commenterUserMap = new Map<String, String>();
        for (User user : commenterUserList) {
            commenterUserMap.put(user.EmployeeNumber, user.Id);
        }

        List<CommentWrapper> commentWrapperList = new List<CommentWrapper>();
        for (PS_ASU_SP_COMMNT_V__x comment : commentsList) {
            CommentWrapper commentWrapper = new CommentWrapper();
            commentWrapper.comment = comment;
            commentWrapper.commenterUserId = commenterUserMap.get(comment.COMNT_ID__c);
            commentWrapperList.add(commentWrapper);
        }
        return commentWrapperList;
    }

    @RemoteAction
    global static List<SortableClass> sortClasses(
        String paramToSortBy,
        String listOfClassesJSON,
        Boolean sortDirection
    ) {
        List<SortableClass> classList = new List<SortableClass>();
        List<PS_ASU_SP_CLASS_V__x> listOfClasses = (List<PS_ASU_SP_CLASS_V__x>) JSON.deserialize(
            listOfClassesJSON,
            List<PS_ASU_SP_CLASS_V__x>.class
        );
        for (PS_ASU_SP_CLASS_V__x asuClass : listOfClasses) {
            classList.add(new SortableClass(asuClass, paramToSortBy));
        }

        classList.sort();
        if (!sortDirection) {
            List<SortableClass> reversedList = new List<SortableClass>();
            for (SortableClass sc : classList) {
                if (reversedList.size() == 0) {
                    reversedList.add(sc);
                } else {
                    reversedList.add(0, sc);
                }
            }
            return reversedList;
        }
        return classList;
    }

    @RemoteAction
    global static List<SortableCreditByExam> sortExams(
        String paramToSortBy,
        List<PS_ASU_SP_TRNSFR_V__x> listOfExams,
        Boolean sortDirection
    ) {
        List<SortableCreditByExam> examList = new List<SortableCreditByExam>();
        for (PS_ASU_SP_TRNSFR_V__x exam : listOfExams) {
            examList.add(new SortableCreditByExam(exam, paramToSortBy));
        }

        examList.sort();
        if (sortDirection) {
            return examList;
        }

        List<SortableCreditByExam> reversedList = new List<SortableCreditByExam>();
        for (SortableCreditByExam sc : examList) {
            if (reversedList.size() == 0) {
                reversedList.add(sc);
            } else {
                reversedList.add(0, sc);
            }
        }
        return reversedList;
    }

    @RemoteAction
    global static ClassesWrapper getClassesData(String classListJson, String asrListJson) {
        List<PS_ASU_SP_CLASS_V__x> classList = (List<PS_ASU_SP_CLASS_V__x>) JSON.deserialize(
            classListJson,
            List<PS_ASU_SP_CLASS_V__x>.class
        );
        List<PS_ASU_SP_ASR_CLSV__x> asrList = (List<PS_ASU_SP_ASR_CLSV__x>) JSON.deserialize(
            asrListJson,
            List<PS_ASU_SP_ASR_CLSV__x>.class
        );

        ClassesWrapper classesData = new ClassesWrapper();
        for (PS_ASU_SP_ASR_CLSV__x asr : asrList) {
            classesData.asrClasses.add(asr.STRM__c + '|' + asr.SESSION_CODE__c + '|' + asr.CLASS_NBR__c);
        }

        for (PS_ASU_SP_CLASS_V__x course : classList) {
            if (course.STDNT_ENRL_STATUS__c == 'E' && course.ENRL_STATUS_REASON__c == 'ENRL') {
                classesData.enrolledClasses.add(course);
            } else {
                classesData.droppedClasses.add(course);
            }
            classesData.classTerms.add(course.STRM__c + '|' + course.TERM_DESCR30__c);
            classesData.classSessions.add(course.SESSION_CODE__c);
        }
        if (!classList.isEmpty()) {
            classesData.classTerms.add('All|All');
            classesData.classSessions.add('All');
        }
        return classesData;
    }

    public String getAidYear() {
        return aidYear;
    }

    @RemoteAction
    global static String createCase(String descriptionIn, String subjectIn, String funcGroup, String emplidIn) {
        try {
            Id student = [SELECT Id FROM Contact WHERE EmplId__c = :emplidIn LIMIT 1].Id;
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'ASU Service' LIMIT 1];
            Case feedbackCase = new Case(
                Status = 'New',
                RecordType = recordType,
                ContactId = student,
                Subject = subjectIn,
                Description = descriptionIn,
                CC_Functional_Group__c = funcGroup,
                Origin__c = 'Student Profile',
                IsVisibleInSelfService = false
            );
            insert feedbackCase;
            return feedbackCase.Id;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplidIn));
            vars.add(ErrorLogger.convertStringToJSON('subjectIn', subjectIn));
            vars.add(ErrorLogger.convertStringToJSON('descriptionIn', descriptionIn));
            ErrorLogger.log(e, vars, false);
        }
        return null;
    }

    @RemoteAction
    global static List<ServiceIndicatorWrapper.ServiceIndicator> getServiceIndicatorsForStudent(String contactEmplid) {
        return StudentProfileCallout.getServiceIndicators(contactEmplid);
    }

    @RemoteAction
    global static List<FinancialAidChecklistWrapper.FinancialAidChecklist> getFinancialAidChecklist(
        String contactEmplid
    ) {
        return StudentProfileCallout.getFinancialAidChecklists(contactEmplid);
    }

    @RemoteAction
    global static List<FinancialAidChecklistWrapper.FinancialAidChecklist> getUnresolvedFinancialAidChecklist(
        List<FinancialAidChecklistWrapper.FinancialAidChecklist> finAidChecklists
    ) {
        return filterFinancialAidUnresolvedItems(finAidChecklists);
    }

    @RemoteAction
    global static Map<String, List<StudentProfileController.EditMessageWrapper>> getEditMessages(String contactEmplid) {
        FinancialEditMessageWrapper editMessageWrapperDetails = StudentProfileCallout.getEditMessages(contactEmplid);

        Map<String, List<StudentProfileController.EditMessageWrapper>> aidYearToEditMessage = new Map<String, List<StudentProfileController.EditMessageWrapper>>();

        if (editMessageWrapperDetails == null) {
            return null;
        }

        editMessageWrapperDetails.edit_messages.sort();

        for (FinancialEditMessageWrapper.cls_edit_messages messages : editMessageWrapperDetails.edit_messages) {
            List<StudentProfileController.EditMessageWrapper> messagesForTerm = new List<StudentProfileController.EditMessageWrapper>();
            messages.message_details.sort();
            for (FinancialEditMessageWrapper.cls_message_details messageDetails : messages.message_details) {
                StudentProfileController.EditMessageWrapper emw = new StudentProfileController.EditMessageWrapper();
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

    @RemoteAction
    global static FinancialAidBalanceWrapper getFinancialAidAccountBalance(String contactEmplid) {
        return StudentProfileCallout.getAccountBalance(contactEmplid);
    }

    @RemoteAction
    global static FinancialAidRefundWrapper getFinancialAidRefunds(String contactEmplid) {
        FinancialAidRefundWrapper refundWrapper = StudentProfileCallout.getRefunds(contactEmplid);

        if (refundWrapper != null && refundWrapper.refunds != null) {
            refundWrapper.refunds.sort();
        }

        return refundWrapper;
    }

    @RemoteAction
    global static DepositStatusWrapper getDepositStatus(String contactEmplid) {
        return StudentProfileCallout.getDepositStatus(contactEmplid);
    }

    @RemoteAction
    global static RenewableAidWrapper getRenewableAid(String contactEmplid) {
        RenewableAidWrapper aidWrapper = StudentProfileCallout.getRenewableAid(contactEmplid);
        aidWrapper.aid_years.sort();
        return aidWrapper;
    }

    @RemoteAction
    global static BookPaymentWrapper getBookPayments(String contactEmplid) {
        BookPaymentWrapper bookPaymentWrap = StudentProfileCallout.getBookPayments(contactEmplid);
        bookPaymentWrap.aid_years.sort();
        return bookPaymentWrap;
    }

    @RemoteAction
    global static TuitionResidencyWrapper getTuitionResidencyStatus(String contactEmplid) {
        try {
            TuitionResidencyWrapper residencyStatus = StudentProfileCallout.getTuitionResidencyStatus(contactEmplid);
            return residencyStatus;
        } catch (Exception e) {
            return null;
        }
    }

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

    global class FinancialAidWrapper {
        public Set<String> aidYears { get; set; }
        public List<Financial_Aid_Detail__c> summaryRecords { get; set; }

        public FinancialAidWrapper() {
            aidYears = new Set<String>();
            summaryRecords = new List<Financial_Aid_Detail__c>();
        }
    }

    global class AdvisingNoteWrapper {
        public PS_ASU_SP_ADNOTE_V__x note { get; set; }
        public String advUserId { get; set; }
    }

    global class ClassesWrapper {
        public Set<String> classTerms = new Set<String>();
        public Set<String> classSessions = new Set<String>();
        public Set<String> asrClasses = new Set<String>();
        public List<PS_ASU_SP_CLASS_V__x> enrolledClasses = new List<PS_ASU_SP_CLASS_V__x>();
        public List<PS_ASU_SP_CLASS_V__x> droppedClasses = new List<PS_ASU_SP_CLASS_V__x>();
    }

    global class CommentWrapper {
        public PS_ASU_SP_COMMNT_V__x comment { get; set; }
        public String commenterUserId { get; set; }
    }

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

    public class EditMessageWrapper {
        public String term { get; set; }
        public String action_description { get; set; }
        public String description { get; set; }
        public String item_type { get; set; }
        public String academic_year { get; set; }
        public String aid_year { get; set; }
    }

    private class StudentProfileException extends Exception {
    }
}