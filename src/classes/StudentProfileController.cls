global with sharing class StudentProfileController {
    private static List<String> vars = new List<String>();

    private Boolean isContactId;
    private String contactId;

    public boolean URLParamsExistAndAreValid {get; set;}
    public Contact theContact { get; set; }
    public List<Case> openCases { get; set; }
    public List<Student_Group__c> sGroupList { get; set; }
    public List<Student_Program_Plan__c> ugProgramPlans { get; set; }
    public List<Student_Program_Plan__c> gradProgramPlans { get; set; }
    public List<Service_Indicator__c> serviceIndicators { get; set; }
    public Student_Program_Plan__c studentProgram { get; set; }
    public List<Student_Program_Plan_Advisor__c> ugStudentProgramAdvisors { get; set; }
    public List<Student_Program_Plan_Advisor__c> gradStudentProgramAdvisors { get; set; }
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
    public String nextTermName { get; set; }
    public String subPlanString { get; set; }

    public Student_Program_Plan__c ugStudentProgram { get {
            return ugProgramPlans.isEmpty() ? new Student_Program_Plan__c() : ugProgramPlans[0];
        }
        set;
    }

    public Student_Program_Plan__c gradStudentProgram { get {
            return gradProgramPlans.isEmpty() ? new Student_Program_Plan__c() : gradProgramPlans[0];
        }
        set;
    }

    public StudentProfileController() {
        UrlParamsExistAndAreValid = true;
        if (ApexPages.currentPage().getParameters().get('contactId') != null) {
            contactId = ApexPages.currentPage().getParameters().get('contactId');
        } else {
            UrlParamsExistAndAreValid = false;
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
        }
        subPlanString = '';
        ugProgramPlans = new List<Student_Program_Plan__c>();
        gradProgramPlans = new List<Student_Program_Plan__c>();
    }

    public void init() {
        if (UrlParamsExistAndAreValid) {
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
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.EMPLIDMissing));
        }

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
            SELECT Id, Acad_Career__c, Acad_Program__c, Acad_Program__r.Name, Acad_Plan__r.Name, Milestone__c, Milestone_Complete__c,
                Descr__c, Descrformal__c, Milestone_Level__c, Milestone_Title__c, Term_Required__r.Name,
                Date_Completed__c, Anticipated_Term__c, Milestone_Nbr__c, Effdt__c
            FROM Student_Milestone__c WHERE Contact__c = :theContact.Id
            AND Acad_Career__c = 'UGRD'
            ORDER BY Effdt__c DESC
        ];
    }
    
    private void setStudentMilestoneGrad() {
        studentMilestonesGrad = [
            SELECT Id, Acad_Career__c, Acad_Program__c, Acad_Program__r.Name, Acad_Plan__r.Name, Milestone__c, Milestone_Complete__c, 
                Descr__c, Descrformal__c, Milestone_Level__c, Milestone_Title__c, Term_Required__r.Name,
                Date_Completed__c, Anticipated_Term__c, Milestone_Nbr__c, Effdt__c
            FROM Student_Milestone__c WHERE Contact__c = :theContact.Id
            AND (Acad_Career__c = 'GRAD' OR Acad_Career__c = 'LAW')
            ORDER BY Effdt__c DESC
        ];
    }
    
    private void setCurrentAndNextTerms() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        String nextTermPeoplesoftCode = currentTermData.NextTerm__c;
        currentTerm = currentTermData.CurrTerm__c;

        List<TERM__c> termList = [
            SELECT Name, PeopleSoft_Code__c
            FROM   TERM__c
            WHERE  PeopleSoft_Code__c = :currentTerm 
            OR  PeopleSoft_Code__c = :nextTermPeoplesoftCode
        ];

        for (TERM__c term : termList) {
            if (term.PeopleSoft_Code__c == currentTerm) {
                currentTermName = term.Name;
            } else if (term.PeopleSoft_Code__c == nextTermPeoplesoftCode) {
                nextTermName = term.Name;
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
            WHERE SI_Contact__c = :theContact.Id
            AND SI_Positive_Service_Indicator__c = FALSE
            AND (SI_Start_Date__c < :Date.today()
                OR SI_Start_Date__c = null)
            ORDER BY SI_Start_Date__c ASC, SI_Code__c ASC
        ];
        serviceIndicators = (!serviceIndicatorList.isEmpty() ? serviceIndicatorList : new List<Service_Indicator__c>());
    }
    
    private void setStudentProgramsAndAdvisors() {
        setStudentProgramPlans();
        setUndergraduateStudentProgramPlanAdvisors();
        setGraduateStudentProgramPlanAdvisors();
    }
    
    private void setStudentProgramPlans() {
        List<Student_Program_Plan__c> allProgramPlans = [
            SELECT Career__c, Adm_Appl_Dt__c, Adm_Appl_Prog__c, 
                Admit_Term__c, Admit_Term__r.Name, Admit_Type__c, Appt_Dt__c, 
                Appt_Dt_Pending__c, Enrl_Deposit__c, Enrl_Hrs__c, Enrl_Hrs_Pending__c, 
                Exp_Grad_Term__c, Exp_Grad_Term__r.Name, Cohort__c,
                Residency__c, Cum_GPA__c, 
                Tot_Cumulative__c, Academic_Standing__c, eAdvisor__c,
                Status__c, Program_Description__c, Plan_Description__c, Degree__c, Campus__r.Name,
                Primary_Flag__c, Completion_Term__c, Plan_Type_Text__c,
                ASU_AA_OVRL_GPA__c, ASU_AA_POS_GPA__c
            FROM Student_Program_Plan__c
            WHERE Contact__c = :theContact.Id
            ORDER BY Status__c, Primary_Flag__c DESC, Completion_Term__c DESC, Plan_Type_Text__c DESC, Plan_Description__c
        ];
        
        if (allProgramPlans.isEmpty()) {
            return;
        }
        
        for (Student_Program_Plan__c programPlan : allProgramPlans) {
            if (programPlan.Career__c == null || programPlan.Career__c == 'Undergraduate') {
                ugProgramPlans.add(programPlan);
            } else {
                gradProgramPlans.add(programPlan);
            }
            
            if (programPlan.Primary_Flag__c) {
                studentProgram = programPlan;
            }
        }        
        setSubplanString();
    }
    
    private void setSubplanString() {
        if (studentProgram == null || studentProgram.Id == null) {
            return;
        }
        List<Student_Program_Subplan__c> subplans = [
            SELECT Subplan_description__c
            FROM Student_Program_Subplan__c
            WHERE Student_Program_Plan__c =: studentProgram.Id
        ];
        if (subplans == null || subplans.isEmpty()) {
            return;
        }
        for (Student_Program_Subplan__c subplan : subplans) {
            subPlanString += subplan.Subplan_description__c + ', ';
        }
        subPlanString = subPlanString.removeEnd(', ');
    }
    
    public void setUndergraduateStudentProgramPlanAdvisors() {
       ugStudentProgramAdvisors = [
           SELECT Student_Program_Plan__r.Career__c, Advisor_Email__c, Advisor_Id__c, 
                  Name, Advisor_Phone__c, Advisor_Name__c
           FROM Student_Program_Plan_Advisor__c
           WHERE Student_Program_Plan__c = :ugStudentProgram.Id
           AND Student_Program_Plan__r.Career__c = 'Undergraduate'
           ORDER BY Name
       ];
    }
    
    public void setGraduateStudentProgramPlanAdvisors() {
        gradStudentProgramAdvisors = [
            SELECT Student_Program_Plan__r.Career__c, Advisor_Email__c, Advisor_Id__c, 
                Name, Advisor_Phone__c, Advisor_Name__c
            FROM Student_Program_Plan_Advisor__c
            WHERE Student_Program_Plan__c = :gradStudentProgram.Id
            AND (Student_Program_Plan__r.Career__c = 'Graduate'
                OR Student_Program_Plan__r.Career__c = 'Law')
            ORDER BY Name
        ];
    }
    
    private void setTestScores() {
        setUndergradStudentTestScores();
        setGraduateStudentTestScores();
    }
    
    private void setUndergradStudentTestScores() {
        Set<String> testCodes = new Set<String>{'ACT', 'AECP', 'AMPT', 'AP', 'CLEP', 'DSST', 'DSST2', 'GED', 'ALEKSMATH', 'ACCUPLACER2', 'HISET', 'IELTS', 'MPT', 'PTE', 'SAT I', 'SAT II', 'TOEFL', 'TOEIC', 'SATII'};
        testUnderGradScoreList = [
            SELECT Test_Component_Score__c, Test_Component__c , Test_Date__c , Test_Type__c 
            FROM Test_Score__c
            WHERE Contact__c = :theContact.Id
            AND Test_Type__c IN :testCodes
            AND Integration_Source__c = 'Student Records'
            ORDER BY Test_Type__c, Test_Component__c, Test_Date__c DESC
        ];
    }
    
    private void setGraduateStudentTestScores() {
        Set<String> testCodes = new Set<String>{'GMAT', 'GRE', 'IELTS', 'LSAT', 'MAT', 'MCAT', 'PTE', 'TOEFL', 'TOEIC'};
        testGradScoreList = [
            SELECT Test_Component_Score__c, Test_Component__c , Test_Date__c , Test_Type__c 
            FROM Test_Score__c
            WHERE Contact__c = :theContact.Id
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
        for (Financial_Aid_Detail__c faRecord: [
            SELECT Acad_Career__c, Accept_Amount__c, Aid_Year__c, Descr__c, Contact__c,
                Descr_Category__c, Disbursed_Amount__c, Id, 
                Offer_Amount__c, Name
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
            SELECT Aid_Year__c, Contact__c, CreatedById, CreatedDate, EFC_Range__c, 
                   FA_Status_Time_Stamp__c, FAFSA_Date_Received__c, Fin_Aid_Package_Date__c, 
                   Financial_Aid_Status__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, 
                   Name, Pell_Eligibility__c, Promise_Cohort__c, SystemModstamp 
            FROM Financial_Aid_Package__c
            WHERE Contact__c = :theContact.Id
            AND Aid_Year__c = :String.valueOf(Date.today().addMonths(6).year())
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
            SELECT Id, A_Score__c, C_Score__c, Contact__c, E_Score__c, I_Score__c, Name, R_Score__c, S_Score__c,                 
                Source__c, Test_Completed_Date__c, User_Id__c, 
                (SELECT Active__c, Alternate_Title__c, Career_Interest__c, Career_Major__c, Degree_Interest__c, Id, 
                        Name, O_NET_SOC_Code__c, OwnerId, Plan_Code__c, Position__c, Updated_Date__c 
                 FROM   Me3_Careers__r
                 WHERE Active__c = TRUE
                 ORDER BY Updated_Date__c DESC, Position__c ASC
                 LIMIT 10) 
             FROM   Me3__c
             WHERE  Contact__c = :theContact.Id 
             AND Source__c = 'DegreeSearch'
             ORDER BY Test_Completed_Date__c DESC
             LIMIT 1 
        ];
        me3Results = (!me3List.isEmpty() ? me3List[0] : new Me3__c());
    }
    
    private void setMe3HighScoolResult() {
        List<me3__c> me3List = [
            SELECT Id, A_Score__c, C_Score__c, Contact__c, E_Score__c, I_Score__c, Name, R_Score__c, S_Score__c,                 
                Source__c, Test_Completed_Date__c, User_Id__c, 
                (SELECT Active__c, Alternate_Title__c, Career_Interest__c, Career_Major__c, Degree_Interest__c, Id, 
                        Name, O_NET_SOC_Code__c, OwnerId, Plan_Code__c, Position__c, Updated_Date__c 
                 FROM   Me3_Careers__r
                 WHERE Active__c = TRUE
                 ORDER BY Updated_Date__c DESC, Position__c ASC, Plan_Code__c
                 LIMIT 10) 
             FROM Me3__c
             WHERE  Contact__c = :theContact.Id AND Source__c = 'me3hs' 
             ORDER BY Test_Completed_Date__c DESC
             LIMIT 1 
        ];
        me3HighSchoolResults = (!me3List.isEmpty() ? me3List[0] : new me3__c());
    }
    
    @RemoteAction
    global static String getSunCardPhotoRA(String asurite, String emplId) {
        String suncardPhotoUrl;
        
        try {
            suncardPhotoUrl = SuncardPhotoService.getSunCardPhotoUrl(asurite, emplId);
        } catch (Exception ex) {
            vars.add(ErrorLogger.convertStringToJSON('asurite', asurite));
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            ErrorLogger.log(ex, vars, FALSE);
            return null;
        }

        return suncardPhotoUrl;
    }

    @RemoteAction
    global static List<AdvisingNoteWrapper> getPSAdvisorNotes(String emplId, String jsonAdvisorNotes) {
        List<AdvisingNoteWrapper> advNoteWrapperList = new List<AdvisingNoteWrapper>();
        List<PS_ASU_SP_ADNOTE_V__x> advisingNoteList = (List<PS_ASU_SP_ADNOTE_V__x>)JSON.deserialize(jsonAdvisorNotes, List<PS_ASU_SP_ADNOTE_V__x>.class);

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
        for (User user: advUserList) {
            advUserMap.put(user.FederationIdentifier, user.Id);
        }

        for (PS_ASU_SP_ADNOTE_V__x note: advisingNoteList) {
            AdvisingNoteWrapper noteWrapper = new AdvisingNoteWrapper();
            noteWrapper.note = note;
            noteWrapper.advUserId = advUserMap.get(note.CREATEOPRID__c + '@admin.asu.edu');
            advNoteWrapperList.add(noteWrapper);
        }

        return advNoteWrapperList;
    }

    @RemoteAction
    global static List<CommentWrapper> getComments(String emplId, String jsonComments) {
        List<PS_ASU_SP_COMMNT_V__x> commentsList = (List<PS_ASU_SP_COMMNT_V__x>)JSON.deserialize(jsonComments, List<PS_ASU_SP_COMMNT_V__x>.class);

        Set<String> commenterUserIds = new Set<String>();
        for (PS_ASU_SP_COMMNT_V__x comment: commentsList) {
            if (comment.COMNT_ID__c != null && comment.COMNT_ID__c != '') {
                commenterUserIds.add(comment.COMNT_ID__c);
            }
        }

        List<User> commenterUserList = [
            SELECT Id, EmployeeNumber
            FROM User
            WHERE EmployeeNumber IN :commenterUserIds
        ];

        Map<String, String> commenterUserMap = new Map<String, String>();
        for (User user: commenterUserList) {
            commenterUserMap.put(user.EmployeeNumber, user.Id);
        }

        List<CommentWrapper> commentWrapperList = new List<CommentWrapper>();
        for (PS_ASU_SP_COMMNT_V__x comment: commentsList) {
            CommentWrapper commentWrapper = new CommentWrapper();
            commentWrapper.comment = comment;
            commentWrapper.commenterUserId = commenterUserMap.get(comment.COMNT_ID__c);
            commentWrapperList.add(commentWrapper);
        }
        return commentWrapperList;
    }

   @RemoteAction
   global static List<SortableClass> sortClasses(String paramToSortBy, String listOfClassesJSON, Boolean sortDirection) {
       List<SortableClass> classList = new List<SortableClass>();
       List<PS_ASU_SP_CLASS_V__x> listOfClasses = (List<PS_ASU_SP_CLASS_V__x>)JSON.deserialize(listOfClassesJSON, List<PS_ASU_SP_CLASS_V__x>.class);
       for (PS_ASU_SP_CLASS_V__x asuClass : listOfClasses) {
           classList.add(new SortableClass(asuClass, paramToSortBy));
       }
       
       classList.sort();
       if(!sortDirection) {
           List<SortableClass> reversedList = new List<SortableClass>();
           for(SortableClass sc : classList) {
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
   global static List<SortableCreditByExam> sortExams(String paramToSortBy, List<PS_ASU_SP_TRNSFR_V__x> listOfExams, Boolean sortDirection) {
       List<SortableCreditByExam> examList = new List<SortableCreditByExam>();
       for (PS_ASU_SP_TRNSFR_V__x exam : listOfExams) {
           examList.add(new SortableCreditByExam(exam, paramToSortBy));
       }
       
       examList.sort();
       if (sortDirection) {
           return examList;
       }
       
       List<SortableCreditByExam> reversedList = new List<SortableCreditByExam>();
       for(SortableCreditByExam sc : examList) {
           if (reversedList.size() == 0) {
               reversedList.add(sc);
           } else {
               reversedList.add(0, sc);
           }
       }
       return reversedList;
   }
   
   @RemoteAction
   global static List<SortableTransferWork> sortTransfers(String paramToSortBy, List<JBT_RET_CLASS_XFER__x> listOfTransfer, Boolean sortDirection) {
       List<SortableTransferWork> transferList = new List<SortableTransferWork>();
       for (JBT_RET_CLASS_XFER__x transferClass : listOfTransfer) {
           transferList.add(new SortableTransferWork(transferClass, paramToSortBy));
       }
       
       transferList.sort();
       if (sortDirection) {
           return transferList;
       }
       
       List<SortableTransferWork> reversedList = new List<SortableTransferWork>();
       for(SortableTransferWork sc : transferList) {
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
        List<PS_ASU_SP_CLASS_V__x> classList = (List<PS_ASU_SP_CLASS_V__x>)JSON.deserialize(classListJson, List<PS_ASU_SP_CLASS_V__x>.class);
        List<PS_ASU_SP_ASR_CLSV__x> asrList = (List<PS_ASU_SP_ASR_CLSV__x>)JSON.deserialize(asrListJson, List<PS_ASU_SP_ASR_CLSV__x>.class);
        
        ClassesWrapper classesData = new ClassesWrapper();
        for (PS_ASU_SP_ASR_CLSV__x asr: asrList) {
            classesData.asrClasses.add(asr.STRM__c + '|' + asr.SESSION_CODE__c + '|' + asr.CLASS_NBR__c);
        }

        for (PS_ASU_SP_CLASS_V__x course: classList) {
            if (course.STDNT_ENRL_STATUS__c == 'E' && course.ENRL_STATUS_REASON__c == 'ENRL') {
                classesData.enrolledClasses.add(course);
            } else {
                classesData.droppedClasses.add(course);
            }
            classesData.classTerms.add(course.STRM__c+ '|' + course.TERM_DESCR30__c);
            classesData.classSessions.add(course.SESSION_CODE__c);
        }     
        if (!classList.isEmpty()) {
            classesData.classTerms.add('All|All');
            classesData.classSessions.add('All');
        }
        return classesData;
    }

    @RemoteAction
    global static String createCase(String descriptionIn, String subjectIn, String emplidIn) {
        try {
            Id student = [SELECT Id FROM Contact WHERE EmplId__c =: emplidIn LIMIT 1].Id;
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'ASU Service' LIMIT 1];
            Case feedbackCase = new Case(
                Status = 'New',
                RecordType = recordType,
                ContactId = student,
                Subject = subjectIn,
                Description = descriptionIn,
                Origin__c = 'Student Profile',
                IsVisibleInSelfService = false
            );
            insert feedbackCase;
            return feedbackCase.Id;
        } catch (Exception e) {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplidIn));
            vars.add(ErrorLogger.convertStringToJSON('subjectIn', subjectIn));
            vars.add(ErrorLogger.convertStringToJSON('descriptionIn', descriptionIn));
            ErrorLogger.log(e, vars, FALSE);
        }
        return null;
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
        public PS_ASU_SP_ADNOTE_V__x note {get; set;}
        public String advUserId {get; set;}
    }
    
    global class ClassesWrapper {
        public Set<String> classTerms = new Set<String>();
        public Set<String> classSessions = new Set<String>();
        public Set<String> asrClasses = new Set<String>();
        public List<PS_ASU_SP_CLASS_V__x> enrolledClasses = new List<PS_ASU_SP_CLASS_V__x>();
        public List<PS_ASU_SP_CLASS_V__x> droppedClasses = new List<PS_ASU_SP_CLASS_V__x>();
    }
    
    global class CommentWrapper {
        public PS_ASU_SP_COMMNT_V__x comment {get; set;}
        public String commenterUserId {get; set;}
    }
    
    private class StudentProfileException extends Exception {}
}