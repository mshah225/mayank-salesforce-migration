global with sharing class StudentProfileController
{
    // Error Logger Variables 
    private static boolean debug = false; // Used to determine if error logger is in debug mode or not
    private static List<String> vars = new List<String>(); // Stores the values of variables for use by the Error Logger
    
    private boolean URLParamsExistAndAreValid; // Stores whether or not URL params exist and are valid
    private boolean isContactId; // Stores wheter the ID parameter is a contact Id or EMPL Id
    public boolean failState {get; set;} // Used to determine if the page has reached a state where it cannot be rendered
    public static ASU_STDNT_RETENTION__x studentRetention { get; set; }

    public Contact theContact { get; set; }
    public List<Case> openCases { get; set; }
    // public List<Financial_Aid_Package__c> fapList { get; set; }
    // public List<Service_Indicator__c> sIList { get; set; }
    public List<PS_ASU_SP_SVCIND_V__x> sIList { get; set; }
    // public List<Student_Account__c> saList { get; set; }
    public List<Student_Group__c> sGroupList { get; set; }
    public List<Student_Program_Plan__c> allProgramPlans { get; set; }
    public List<Student_Program_Plan__c> ugProgramPlans { get; set; }
    public List<Student_Program_Plan__c> gradProgramPlans { get; set; }
    public Student_Program_Plan__c primaryProgramPlan { get; set; }
    public Student_Program_Subplan__c subProgramPlan {get; set;}
    // public List<Test_Score__c> testScoreList { get; set; }
    public Student_Program_Plan__c programPlan { get; set; }
    public JBT_RET_GENERAL_RIGHT__x studentProgram { get; set; }
    public JBT_RET_GENERAL_RIGHT__x ugStudentProgram { get; set; }
    public JBT_RET_GENERAL_RIGHT__x gradStudentProgram { get; set; }
    public JBT_RET_GENERAL_LEFT__x studentDemographic { get; set; }
    public JBT_RET_PROFILE_HEADER_VW__x profileHeader { get; set; }
    public JBT_RET_TERMS_VW__x termInfo { get; set; }
    public String suncardPhotoURL { get; set; }
    public String deceased { get; set; }
    public string contactId {get; set;}
    global static String paramToSort {get; set;}
    global static String examParamSort {get; set;}
    global static String transferParamSort {get; set;}
    global static boolean sortDirect = true;
    private Set<String> ugTestCodes;
    private Set<String> gradTestCodes;

    public List<JBT_RET_GENERAL_RIGHT__x> studentProgramDataList { get; set; }
    public String currentTerm { get; set; }
    public String currentTermName { get; set; }
    public String nextTerm { get; set; }
    public String nextTermName { get; set; }
    
    public static classesWrapper classesData; 

    /**
     * Constructor to get and validate URL parameters
     * <p>
     * Due to limitations on the ErrorLogger (cannot create cases in constructors)
     * the constructor should only contain code to grab and validate URL parameters.
     * Any initilization code has a chance to throw exceptions and should be placed
     * in the init method below.
     * </p>
     */
    public StudentProfileController() {
        URLParamsExistAndAreValid = true;
        
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            contactId = ApexPages.currentPage().getParameters().get('id');
        } else if (ApexPages.currentPage().getParameters().get('contactId') != null) {
            contactId = ApexPages.currentPage().getParameters().get('contactId');
        }
        
        if (Validator.validateId(contactId, Contact.class)) {
            isContactId = true;
        } else if (Validator.validateEMPLId(contactId)) {
            isContactId = false;
        } else {
            URLParamsExistAndAreValid = false;
        }
    }
    
    /**
     * Method to initialize page, called before page is rendered
     * <p>
     * Due to limitations on the error logger (cannot create cases in constructors)
     * initilization code cannot exist inside the constructor.
     * </p>
     * <p>
     * This method should be invoked by the <apex:page> action attribute:
     * <apex:page action="{!init}">
     * </p>
     */
    public pageReference init() {
        vars = new List<String>(); // Used to pass variable values to the error logger
        
        try {
            if (URLParamsExistAndAreValid) {
                if (isContactId) {
                    theContact = ContactService.getContactInformation(contactId, '');
                } else {
                    theContact = ContactService.getContactInformation('', String.valueOf(contactId));
                }
                
                if (theContact.EMPLID__c == null) {
                    failState = true;
                    vars.add(ErrorLogger.convertSObjectToJSON('theContact', theContact));
                    throw new StudentProfileException('Contact missing EMPLId');
                }
                
                // Initialize the lists 
                openCases = new List<Case>();
                sGroupList = new List<Student_Group__c>();
                // saList = new List<Student_Account__c>();
                // fapList = new List<Financial_Aid_Package__c>();
                // testScoreList = new List<Test_Score__c>();
                sIList = new List<PS_ASU_SP_SVCIND_V__x>();
                allProgramPlans = new List<Student_Program_Plan__c>();
                deceased = '';
                
                // Start populating the lists
                openCases = CaseService.getAllOpenCases(theContact.Id);
                sGroupList = StudentGroupService.getContactActiveStudentGroups(theContact.Id);
                // fapList = FinancialAidPackageService.getContactFinancialAidPackages(theContact.Id);
                // testScoreList = TestScoreService.getTestScores(theContact.Id);
                // sIList = ServiceIndicatorService.getContactSerivceIndicatorss(theContact.Id);

                studentProgramDataList = getStudentProgramData(theContact.EMPLID__c);
                if(studentProgramDataList.size() > 0){
				    studentProgram = studentProgramDataList[0];
				}
                profileHeader = getProfileHeader(theContact.EMPLID__c);
                getTermInfo();
                sIList = getServiceIndicators(theContact.emplId__c);
                allProgramPlans = StudentProgramPlanService.getContactStudentProgramPlans(theContact.Id);
                studentDemographic = getStudentDemographicData(theContact.emplId__c);
                studentProgramDataList = getStudentProgramData(theContact.EMPLID__c);
                
                for(JBT_RET_GENERAL_RIGHT__x prg : studentProgramDataList){
                    if(prg.ACAD_CAREER__c.equals('UGRD')){
                        ugStudentProgram = prg;
                    }
                    else if (prg.ACAD_CAREER__c.equals('GRAD')){
                        gradStudentProgram = prg;
                    }
                }
                // TODO: Find out about this list. It may just be a single object.
                // saList = StudentAccountService.getContactStudentAccounts(theContact.Id);
        
                /*
                * Handling for nulls. Get the Objects as Lists from the different services first.
                * If the list size is greater than expected, use first Object in list.
                */
                List<Student_Program_Plan__c> studentProgramPlansBeforeToday =
                    StudentProgramPlanService.getContactStudentProgramPlansBeforeToday(theContact.Id);
        
                programPlan = new Student_Program_Plan__c();
                if (theContact.Affiliation_Student__c == 'Current' && studentProgramPlansBeforeToday.size() > 0)
                {
                    for (Student_Program_Plan__c spp: studentProgramPlansBeforeToday)
                    {
                        if (spp.Status__c == 'Active in Program')
                        {
                            programPlan = spp;
                            break;
                        }
                    }                   
                }
                
                ugProgramPlans = new List<Student_Program_Plan__c>();
                gradProgramPlans = new List<Student_Program_Plan__c>();
                primaryProgramPlan =  new Student_Program_Plan__c();
                if (allProgramPlans.size() > 0)    
                {
                    for (Student_Program_Plan__c spp: allProgramPlans)
                    {
                        if (spp.PRIMARY_FLAG__c == true)
                            primaryProgramPlan = spp;
                            
                        if (spp.Career__c == null || spp.Career__c == 'Undergraduate')
                            ugProgramPlans.add(spp);
                        else
                            gradProgramPlans.add(spp);
                    }
                }
                
                List<Student_Program_Subplan__c> tmpSubPlanList = [
                            Select Subplan_description__c
                                  FROM Student_Program_Subplan__c
                                  WHERE Student_Program_Plan__c =: primaryProgramPlan.Id
                ];
                
                if(tmpSubPlanList.size() > 0){
                    for(Integer i = 0; i < tmpSubPlanList.size()-1; i++){
                        subPlanString += tmpSubPlanList[0].Subplan_description__c + ', ';
                    }
                    subPlanString += tmpSubPlanList[tmpSubPlanList.size()-1].Subplan_description__c;
                }
                // Temporary solution for beta release; setting currentTerm to a hard-coded value
                // so we have value to work with while the term populates asynchronously; ultimate 
                // solution will be to store term info in the Salesforce org and update it from 
                // PeopleSoft only as-needed
                currentTerm = '2177';
                
                try {
                    if (! theContact.ASU_Online_Student__c) {
                        suncardPhotoURL = getSuncardPhotoURL(theContact.ASURite_ID__c, theContact.EMPLID__c);
                    }
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }                
                
            } else {
                failState = true;
                vars.add(ErrorLogger.convertStringToJSON('contactId', contactId));
                throw new StudentProfileException('URL Parameters are missing or invalid');
            }
        
            return null;
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
            return null;
        }
    }

    public String getSuncardPhotoURL(String asurite, String emplId) {
        String suncardPhotoURL;
        vars = new List<String>();
        
        if (! Test.isRunningTest()) {
            try {
                vars.add(ErrorLogger.convertStringToJSON('asurite', asurite));
                vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
                
                suncardPhotoURL = SuncardPhotoService.getSunCardPhotoURL(asurite, emplId);
            } catch (Exception e) {
                ErrorLogger.log(e, vars, debug);
                return null;
            }
        }

        return suncardPhotoURL;
    }

    private void getTermInfo()
    {
        vars = new List<String>();
        List<JBT_RET_TERMS_VW__x> termInfoList = new List<JBT_RET_TERMS_VW__x>();
       
        try {
            termInfoList = 
            ( 
                Test.isRunningTest() ? new List<JBT_RET_TERMS_VW__x>() :
                [
                    SELECT CURR_TERM__c,
                           CURR_TERM_INCLUDE_SUMMER__c, 
                           NEXT_TERM_INCLUDE_SUMMER__c,
                           DisplayUrl, ExternalId, Id, 
                           NEXT_TERM__c, 
                           PREV_TERM__c,
                           PREV_PREV_TERM__c 
                    FROM JBT_RET_TERMS_VW__x
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        if (termInfoList.size() > 0)
        {
            currentTerm = termInfoList[0].CURR_TERM__c;
            // This field is coming from the external source with a ".0" appended, so let's remove it
            nextTerm = String.valueOf(Integer.valueOf(termInfoList[0].NEXT_TERM__c));
            List<TERM__c> termList = 
            [
                SELECT Name, PeopleSoft_Code__c
                FROM   TERM__c
                WHERE  PeopleSoft_Code__c = :currentTerm 
                   OR  PeopleSoft_Code__c = :nextTerm
            ];

            for (TERM__c term: termList)
            {
                if (term.PeopleSoft_Code__c == currentTerm)
                    currentTermName = term.Name;
                else if (term.PeopleSoft_Code__c == nextTerm)
                    nextTermName = term.Name;    
            }            
        }
    }

    @RemoteAction
    // Get JBT_RET_PROFILE_HEADER_VW__x data
    global static JBT_RET_PROFILE_HEADER_VW__x getProfileHeader(String emplId)
    {
        vars = new List<String>();
        List<JBT_RET_PROFILE_HEADER_VW__x> headerlist = new List<JBT_RET_PROFILE_HEADER_VW__x>();
        
        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            headerList = 
            (
                Test.isRunningTest() ? new List<JBT_RET_PROFILE_HEADER_VW__x>() : 
                [
                    SELECT COHORT__c
                    FROM JBT_RET_PROFILE_HEADER_VW__x
                    WHERE ExternalId = :emplId
                    ORDER BY STRM__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        if (headerList.size() > 0)
        {
            return headerList[0];
        }
        else
        {
            return new JBT_RET_PROFILE_HEADER_VW__x();
        }  
    }

    @RemoteAction
    // Get ASU_STDNT_RETENTION__x data
    global static ASU_STDNT_RETENTION__x getStudentRetention(String emplId)
    {
        vars = new List<String>();
        List<ASU_STDNT_RETENTION__x> stdntList = new List<ASU_STDNT_RETENTION__x>();
        
        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            stdntList = 
            (
                Test.isRunningTest() ? new List<ASU_STDNT_RETENTION__x>() : 
                [
                    SELECT ASR_INDICATOR__c, CI_INDEX_INDICATOR__c,
                        CUM_GPA_INDICATOR__c, DisplayUrl, EADVISOR_INDICATOR__c, EMPLID__c,
                        ENRL_HOLD_COUNT__c, ExternalId, FA_INDICATOR__c, FINANCIAL_HOLD__c,
                        Id, NEXT_TERM_ENROLLED__c, PROBATION_INDICATOR__c,
                        STRM__c, TOT_IND__c, AVG_MYASU_COHORT__c,
                        PAST_DUE_TIP__c, TERM_MYASU_USAGE__c
                    FROM ASU_STDNT_RETENTION__x
                    WHERE EMPLID__c = :emplId
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);            
        }

        if (stdntList.size() > 0)
        {
            return stdntList[0];
        }
        else
        {
            return new ASU_STDNT_RETENTION__x();
        }  
        
    }

    // Get the allowable test types by Career type
    global static Set<String> getTestCodes(String career)
    {
        if (career == 'UGRD')
            return new Set<String>{'ACT', 'AECP', 'AMPT', 'AP', 'CLEP', 'DSST', 'DSST2', 'GED', 'ALEKSMATH', 'ACCUPLACER2',
                                      'HISET', 'IELTS', 'MPT', 'PTE', 'SAT I', 'SAT II', 'TOEFL', 'TOEIC', 'SATII'};
        else
            return new Set<String>{'GMAT', 'GRE', 'IELTS', 'LSAT', 'MAT', 'MCAT', 'PTE', 'TOEFL', 'TOEIC'};            
    }

    @RemoteAction
    // Get PS_STDNT_TEST_COMP__x scores as a list
    global static List<PS_STDNT_TEST_COMP__x> getStdntTestComps(String emplId, String career)
    {
        vars = new List<String>();
        Set<String> testCodes = getTestCodes(career);
        List<PS_STDNT_TEST_COMP__x> stdntTestComps = new List<PS_STDNT_TEST_COMP__x>();

        // Build out list to avoid de-reference null object errors.
/*                SELECT DisplayUrl, EMPLID__c, ExternalId, Id, SCORE__c,
                    TEST_COMPONENT__c, TEST_DT__c, TEST_ID__c 8
*/
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('career', career));
            
            stdntTestComps = 
            (
                Test.isRunningTest() ? new List<PS_STDNT_TEST_COMP__x>() :
                
                
                [
                    SELECT SCORE__c, TEST_COMPONENT__c, TEST_DT__c, TEST_ID__c
                    FROM PS_STDNT_TEST_COMP__x
                    WHERE EMPLID__c = :emplId
                      AND TEST_ID__c IN :testCodes
                    ORDER BY TEST_ID__c, TEST_COMPONENT__c, TEST_DT__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }


        if (stdntTestComps.size() > 0)
        {
            for (Integer i=stdntTestComps.size(); i>0; i--)
            {
                if (!testCodes.contains(stdntTestComps[i-1].TEST_ID__c))
                    stdntTestComps.remove(i-1);
            }
        }
        else
        {
            stdntTestComps = new List<PS_STDNT_TEST_COMP__x>();
        }
        
        return stdntTestComps;
    }

    @RemoteAction
    // Get Undergraduate PS_STDNT_CAR_MLSTN__x milestones as a list
    global static List<PS_STDNT_CAR_MLSTN__x> getStdntCarMlstnsUG(String emplId)
    {
        vars = new List<String>();
        List<PS_STDNT_CAR_MLSTN__x> stdntCarMlstnsUG = new List<PS_STDNT_CAR_MLSTN__x>();
        
 /*
                SELECT ACAD_PROG__c, ACAD_CAREER__c, ACAD_PLAN__c,  ANTICIPATED_TERM__c,
                    DATE_COMPLETED__c, DESCR__c, DESCRFORMAL__c, DisplayUrl, EFFDT__c,
                    EMPLID__c, ExternalId, Id, MILESTONE__c, MILESTONE_COMPLETE__c,
                    MILESTONE_LEVEL__c, MILESTONE_NBR__c, MILESTONE_TITLE__c, TERM_REQUIRED__c
 */
        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            stdntCarMlstnsUG = 
            (
                Test.isRunningTest() ? new List<PS_STDNT_CAR_MLSTN__x>() :
                [
                    SELECT ACAD_PROG__c, ACAD_CAREER__c, ACAD_PLAN__c, DESCR__c,
                           DESCRFORMAL__c, EFFDT__c, EMPLID__c, Id, MILESTONE__c, 
                           MILESTONE_LEVEL__c, MILESTONE_NBR__c, MILESTONE_TITLE__c,
                           MILESTONE_COMPLETE__c, TERM_REQUIRED__c, ANTICIPATED_TERM__c,
                           DATE_COMPLETED__c
                    FROM PS_STDNT_CAR_MLSTN__x
                    WHERE EMPLID__c = :emplId
                    AND ACAD_CAREER__c = 'UGRD'
                    ORDER BY EFFDT__c DESC, MILESTONE_NBR__c ASC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        if (stdntCarMlstnsUG.size() > 0)
        {
            // Only return the most recent record for each distinct milestone 
            List<PS_STDNT_CAR_MLSTN__x> filteredPsStdntCarMlstn = new List<PS_STDNT_CAR_MLSTN__x>();
            Set<String> milestoneSet = new Set<String>();
            for (PS_STDNT_CAR_MLSTN__x milestoneRec: stdntCarMlstnsUG)
            {
                if (!milestoneSet.contains(milestoneRec.ACAD_PROG__c + milestoneRec.MILESTONE__c + milestoneRec.MILESTONE_NBR__c))
                {
                    filteredPsStdntCarMlstn.add(milestoneRec);
                    milestoneSet.add(milestonerec.ACAD_PROG__c + milestoneRec.MILESTONE__c + milestoneRec.MILESTONE_NBR__c);
                }
            }
            return filteredPsStdntCarMlstn;
        }
        else
        {
            return new List<PS_STDNT_CAR_MLSTN__x>();
        }
    }

    @RemoteAction
    // Get Graduate/Law PS_STDNT_CAR_MLSTN__x milestones as a list
    global static List<PS_STDNT_CAR_MLSTN__x> getStdntCarMlstnsGrad(String emplId)
    {
        vars = new List<String>();
        List<PS_STDNT_CAR_MLSTN__x> stdntCarMlstnsUG = new List<PS_STDNT_CAR_MLSTN__x>();
/*
                SELECT ACAD_CAREER__c, ACAD_PLAN__c, ACAD_PROG__c, ANTICIPATED_TERM__c,
                    DATE_COMPLETED__c, DESCR__c, DESCRFORMAL__c, DisplayUrl, EFFDT__c,
                    EMPLID__c, ExternalId, Id, MILESTONE__c, MILESTONE_COMPLETE__c,
                    MILESTONE_LEVEL__c, MILESTONE_NBR__c, MILESTONE_TITLE__c, TERM_REQUIRED__c
*/
        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            stdntCarMlstnsUG = 
            (
                Test.isRunningTest() ? new List<PS_STDNT_CAR_MLSTN__x>() :
                [
                   SELECT ACAD_PROG__c, ACAD_CAREER__c, ACAD_PLAN__c, DESCR__c,
                           DESCRFORMAL__c, EFFDT__c, EMPLID__c, Id, MILESTONE__c, 
                           MILESTONE_LEVEL__c, MILESTONE_NBR__c, MILESTONE_TITLE__c,
                           MILESTONE_COMPLETE__c, TERM_REQUIRED__c, ANTICIPATED_TERM__c,
                           DATE_COMPLETED__c
                     FROM PS_STDNT_CAR_MLSTN__x
                    WHERE EMPLID__c = :emplId
                    AND (ACAD_CAREER__c = 'GRAD' OR ACAD_CAREER__c = 'LAW')
                    ORDER BY EFFDT__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        if (stdntCarMlstnsUG.size() > 0)
        {
            // Only return records with the same Eff Dt as the most recent record
            List<PS_STDNT_CAR_MLSTN__x> filteredPsStdntCarMlstn = new List<PS_STDNT_CAR_MLSTN__x>();
            Date maxEffDt = stdntCarMlstnsUG[0].EFFDT__c;
            for (PS_STDNT_CAR_MLSTN__x milestoneRec: stdntCarMlstnsUG)
            {
                if (milestoneRec.EFFDT__C == maxEffDt)
                    filteredPsStdntCarMlstn.add(milestoneRec);
                else
                    break;
            }
            return filteredPsStdntCarMlstn;
        }
        else
        {
            return new List<PS_STDNT_CAR_MLSTN__x>();
        }
    }
    
    @RemoteAction
    // Get student transcript information
    global static List<JBT_RET_TRANSCRIPT_SENT_VW__x> getTranscripts(String emplId) {
        vars = new List<String>();
        List<JBT_RET_TRANSCRIPT_SENT_VW__x> transcripts = new List<JBT_RET_TRANSCRIPT_SENT_VW__x>();
        
        // Build out the list to avoid 'null de-reference' errors
        // TODO : Limit only to transcripts less than 365 days old
        // NOTE: This external object was incorrectly mapped. Even though
        // we are filtering by Contact__c, we need to pass it an EMPLID,
        // not a Contact ID, in order for this query to work.
        try {
            transcripts = (
                Test.isRunningTest() ? new List<JBT_RET_TRANSCRIPT_SENT_VW__x>() : [
                    SELECT
                        EMPLID__c, ADDRESS1__c, ADDRESS2__c, ADDRESS3__c,
                        ADDRESS4__c, CITY__c, COUNTRY__c, SEND_TO_NAME__c,
                        POSTAL__c, STATE__c, STATUS__c, REQUEST_OR_SENT_DATE__c,
                        DisplayURL, ExternalId, Id
                    FROM JBT_RET_TRANSCRIPT_SENT_VW__x
                    WHERE EMPLID__c = :emplId
                    ORDER BY REQUEST_OR_SENT_DATE__c DESC, SEND_TO_NAME__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        if (transcripts.size() > 0) {
            return transcripts;
        } else {
            return new List<JBT_RET_TRANSCRIPT_SENT_VW__x>();
        }
    }

    @RemoteAction
    // Get ASU_STDNT_RETENTION_SNP__x retention info as a list
    global static List<ASU_STDNT_RETENTION_SNP__x> getRetentionSNP(String emplId)
    {
        vars = new List<String>();
        List<ASU_STDNT_RETENTION_SNP__x> retention_snps = new List<ASU_STDNT_RETENTION_SNP__x>();
            
        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            retention_snps = 
            (
                Test.isRunningTest() ? new List<ASU_STDNT_RETENTION_SNP__x>() :
                [
                    SELECT ASR_INDICATOR__c, AVG_MYASU_COHORT__c, CI_INDEX_INDICATOR__c,
                        CREATED_EW_DTTM__c, CUM_GPA_INDICATOR__c, DisplayUrl, EADVISOR_INDICATOR__c,
                        EMPLID__c, ENRL_HOLD_COUNT__c, ExternalId, FA_INDICATOR__c,
                        FINANCIAL_HOLD__c, Id, NEXT_TERM_ENROLLED__c, PAST_DUE_TIP__c,
                        PROBATION_INDICATOR__c, SNP_WEEK__c, STRM__c, TERM_MYASU_USAGE__c,
                        TRANSCRIPTS_SENT_COUNT__c
                    FROM ASU_STDNT_RETENTION_SNP__x
                    WHERE emplId__c = :emplId
                    ORDER BY CREATED_EW_DTTM__c DESC, STRM__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        if (retention_snps.size() > 0)
        {
            return retention_snps;
        }
        else
        {
            return new List<ASU_STDNT_RETENTION_SNP__x>();
        }
    }

    global class advNoteWrapper
    {
        public PS_ASU_SP_ADNOTE_V__x note {get; set;}
        public String advUserId {get; set;}
    }

    @RemoteAction
    // Get PS_ASU_SP_ADNOTE_V__x advising notes as a list
    global static List<advNoteWrapper> getPSAdvisorNotes(String emplId)
    {
        vars = new List<String>();
        List<PS_ASU_SP_ADNOTE_V__x> advisingNoteList = new List<PS_ASU_SP_ADNOTE_V__x>();
        
        List<advNoteWrapper> advNoteWrapperList = new List<advNoteWrapper>();
        List<String> advAsuRiteIds = new List<String>();
        Map<String, String> advUserMap = new Map<String, String>();

        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            advisingNoteList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_ADNOTE_V__x>() :
                [
                    SELECT ACAD_CAREER__c, COMMENTS__c, CREATDTTM__c, CREATEOPRID__c, DisplayUrl,
                        EMPLID__c, ExternalId, Id, NAME__c, STRM__c
                    FROM PS_ASU_SP_ADNOTE_V__x
                    WHERE EMPLID__c = :emplId
                    ORDER BY CREATDTTM__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
            return null;
        }

        for (PS_ASU_SP_ADNOTE_V__x note: advisingNoteList)
        {
            if (note.CREATEOPRID__c != null && note.CREATEOPRID__c != '')
            {
                advAsuRiteIds.add(note.CREATEOPRID__c + '@admin.asu.edu');
            }
        }

        List<User> advUserList =
        (
            Test.isRunningTest() ? new List<User>() :
            [
                SELECT Id, FederationIdentifier
                FROM User
                WHERE FederationIdentifier IN :advAsuRiteIds
            ]
        );

        for (User u: advUserList)
        {
            advUserMap.put(u.FederationIdentifier, u.Id);
        }

        for (PS_ASU_SP_ADNOTE_V__x note: advisingNoteList) 
        {
            advNoteWrapper nw = new advNoteWrapper();
            nw.note = note;
            nw.advUserId = advUserMap.get(note.CREATEOPRID__c + '@admin.asu.edu');
            advNoteWrapperList.add(nw);
        }

        return (advNoteWrapperList.size() > 0 ? advNoteWrapperList : new List<advNoteWrapper>());
    }

    global class commentWrapper
    {
        public PS_ASU_SP_COMMNT_V__x comment {get; set;}
        public String commenterUserId {get; set;}
    }

    @RemoteAction
    // Get PS_ASU_SP_COMMNT_V__x comments as a list
    global static List<commentWrapper> getComments(String emplId)
    {
        vars = new List<String>();
        List<PS_ASU_SP_COMMNT_V__x> commentsList = new List<PS_ASU_SP_COMMNT_V__x>();
        
        List<commentWrapper> commentWrapperList = new List<commentWrapper>();
        Set<String> commenterUserIds = new Set<String>();
        Map<String, String> commenterUserMap = new Map<String, String>();

        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            commentsList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_COMMNT_V__x>() :
                [
                    SELECT ADMIN_FUNCTION__c, ADMIN_ROLENAME__c, COMMENT_DTTM__c, COMNT_ID__c,
                        COMMENTS__c, DisplayUrl, EMPLID__c, ExternalId, Id, NAME__c
                    FROM PS_ASU_SP_COMMNT_V__x
                    WHERE EMPLID__c = :emplId
                    ORDER BY COMMENT_DTTM__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
            return null;
        }

        for (PS_ASU_SP_COMMNT_V__x comment: commentsList)
        {
            if (comment.COMNT_ID__c != null && comment.COMNT_ID__c != '')
            {
                commenterUserIds.add(comment.COMNT_ID__c);
            }
        }

        List<User> commenterUserList =
        (
            Test.isRunningTest() ? new List<User>() :
            [
                SELECT Id, EmployeeNumber
                FROM User
                WHERE EmployeeNumber IN :commenterUserIds
            ]
        );

        for (User u: commenterUserList)
        {
            commenterUserMap.put(u.EmployeeNumber, u.Id);
        }

        for (PS_ASU_SP_COMMNT_V__x comment: commentsList) 
        {
            commentWrapper cw = new commentWrapper();
            cw.comment = comment;
            cw.commenterUserId = commenterUserMap.get(comment.COMNT_ID__c);
            commentWrapperList.add(cw);
        }

        return (commentWrapperList.size() > 0 ? commentWrapperList : new List<commentWrapper>());
    }

    @RemoteAction
    // Get PS_ASU_SP_GUEST_V__x comments as a list
    global static List<PS_ASU_SP_GUEST_V__x> getGuestAccess(String emplId)
    {
        vars = new List<String>();
        List<PS_ASU_SP_GUEST_V__x> guestAccessList = new List<PS_ASU_SP_GUEST_V__x>();
        
        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            guestAccessList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_GUEST_V__x>() : 
                [
                    SELECT AUTHOR__c, COMMENT_DT__c, COMMENTS__c, DisplayUrl, EMPLID__c,    
                           ExternalId, Id 
                    FROM PS_ASU_SP_GUEST_V__x
                    WHERE EMPLID__c = :emplId
                    ORDER BY COMMENT_DT__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (guestAccessList.size() > 0? guestAccessList : new List<PS_ASU_SP_GUEST_V__x>());
    }

    @RemoteAction
    // Get JBT_RET_GENERAL_RIGHT__x data 
    global static List<JBT_RET_GENERAL_RIGHT__x> getStudentProgramData(String emplId)
    {
        vars = new List<String>();
        List<JBT_RET_GENERAL_RIGHT__x> studentProgramDataList = new List<JBT_RET_GENERAL_RIGHT__x>();
        
        // Temporary while database issues are investigated
        //return new List<JBT_RET_GENERAL_RIGHT__x>();
            
        // Build out list to avoid de-reference null object errors.
        try {
            studentProgramDataList =
            (
                Test.isRunningTest() ? new List<JBT_RET_GENERAL_RIGHT__x>() :
                [
                 SELECT ACAD_CAREER__c, ADM_APPL_DT__c, ADM_APPL_PROG__c, 
                           ADMIT_TERM__c, ADMIT_TYPE__c, APPT_DT__c, 
                           APPT_DT_PENDING__c, ASU_CITZN_COUNTRY__c, CAMPUS__c, 
                           CURR_ADMIT_TYPE__c, CURR_PLAN__c, CURR_PROG__c, DisplayUrl, 
                           EMPLID__c, ENRL_DEPOSIT__c, ENRL_HRS__c, ENRL_HRS_PENDING__c, 
                           ENRL_PENDING__c, ENROLL_OPEN_DT__c, ENROLLED__c, 
                           EXP_GRAD_TERM__c, EXP_GRAD_TERM__r.Name, 
                           ExternalId, FERPA_LVL__c, FINANCIAL_NEED_LVL__c, 
                           Id, PROG_STATUS__c, ORIENT_DT__c, RESIDENCY__c, STRM__c, 
                           STRM__r.Name, STRM__r.Term_Status__c, SUB_PLAN__c, WUE__c 
                    FROM JBT_RET_GENERAL_RIGHT__x
                    WHERE EMPLID__c = :emplId
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        return (studentProgramDataList.size()>0 ? studentProgramDataList : new List<JBT_RET_GENERAL_RIGHT__x>());
    }    

   
    @RemoteAction
    // Get JBT_RET_GENERAL_LEFT__x data 
    global static JBT_RET_GENERAL_LEFT__x getStudentDemographicData(String emplId)
    {
        vars = new List<String>();
        List<JBT_RET_GENERAL_LEFT__x> studentDemographicDataList = new List<JBT_RET_GENERAL_LEFT__x>();
        
        //Temporary
        //return new JBT_RET_GENERAL_LEFT__x();

        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            studentDemographicDataList =
            (
                Test.isRunningTest() ? new List<JBT_RET_GENERAL_LEFT__x>() :
                [
                    SELECT AGE_YEARS__c, DisplayUrl, EMPLID__c, ETHNICITY__c, ExternalId, 
                           FIRST_GEN_FLG__c, Id 
                    FROM JBT_RET_GENERAL_LEFT__x
                    WHERE EMPLID__c = :emplId
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (studentDemographicDataList.size()>0 ? studentDemographicDataList[0] : new JBT_RET_GENERAL_LEFT__x());
    }       


    // Inner wrapper class for Academic Progress Data
    global class academicProgressDataWrapper
    {
        public JBT_RET_ACAD_SUMMARY_VW__x jbtRetAcadSummaryVw;
        public PS_ASU_SP_AC_STNDV__x psAsuSpAcStndv;
        public List<PS_ASU_SP_ACAD_ADV__x> psAsuSpAcadAdvList;
        public PS_ASU_SR_COL_PLAN__x psGradPlan;
        public JBT_RET_OTH_IND1_VW__x jbtRetOthInd1Vw;
    }

     @RemoteAction
    // Get all Academic Progress Data
    global static academicProgressDataWrapper getAcademicProgressData(String emplId, String career)
    {
        vars = new List<String>();
        List<JBT_RET_ACAD_SUMMARY_VW__x> academicSummaryList = new List<JBT_RET_ACAD_SUMMARY_VW__x>();
        List<JBT_RET_OTH_IND1_VW__x> otherIndicatorList = new List<JBT_RET_OTH_IND1_VW__x>();
        List<PS_ASU_SP_AC_STNDV__x> academicStandingList = new List<PS_ASU_SP_AC_STNDV__x>();
        List<PS_ASU_SP_ACAD_ADV__x> academicAdviserList = new List<PS_ASU_SP_ACAD_ADV__x>();
        List<PS_ASU_SR_COL_PLAN__x> gradPlanList = new List<PS_ASU_SR_COL_PLAN__x>();
        
        academicProgressDataWrapper dataWrapper = new academicProgressDataWrapper();

        Set<String> careerSet;
        if (career == 'UGRD')
            careerSet = new Set<String>{'UGRD'};
        else
            careerSet = new Set<String>{'GRAD','LAW'};

        // Build out list to avoid de-reference null object errors.
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('career', career));
            
            academicSummaryList = 
            (
                Test.isRunningTest() ? new List<JBT_RET_ACAD_SUMMARY_VW__x>() :
                [
                    SELECT ACAD_CAREER__c, AID_YEAR__c, COLLEGE__c, CUM_GPA__c, EMPLID__c, 
                           FND_TERM_REMAINA__c, Id, MAJOR__c, SCHOLARSHIP_NAME__c, 
                           STATUS__c, STRM__c, TOT_CUMULATIVE__c 
                    FROM JBT_RET_ACAD_SUMMARY_VW__x
                    WHERE EMPLID__c = :emplId
                      AND ACAD_CAREER__c IN :careerSet
                    ORDER BY STRM__c DESC
                    LIMIT 1
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        dataWrapper.jbtRetAcadSummaryVw = (academicSummaryList.size()>0 ? academicSummaryList[0] : new JBT_RET_ACAD_SUMMARY_VW__x());

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            vars.add(ErrorLogger.convertStringToJSON('careerSet', ''));
            
            for (String s : careerSet) {
                vars.add(ErrorLogger.convertStringToJSON('--Value: ', s));
            }
            
            otherIndicatorList = 
            (
                Test.isRunningTest() ? new List<JBT_RET_OTH_IND1_VW__x>() :
                [
                    SELECT EADVISOR__c 
                    FROM JBT_RET_OTH_IND1_VW__x
                    WHERE EMPLID__c = :emplId
                      AND ACAD_CAREER__c IN :careerSet
                    LIMIT 1
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        dataWrapper.jbtRetOthInd1Vw = (otherIndicatorList.size()>0 ? otherIndicatorList[0] : new JBT_RET_OTH_IND1_VW__x());

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('careerSet', ''));
            
            for (String s : careerSet) {
                vars.add(ErrorLogger.convertStringToJSON('--Value: ', s));
            }
            
            academicStandingList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_AC_STNDV__x>() :
                [
                    SELECT ACAD_CAREER__c, ACAD_STNDNG_ACTN__c, DESCR__c, EMPLID__c, 
                           Id, STRM__c 
                    FROM PS_ASU_SP_AC_STNDV__x
                    WHERE EMPLID__c = :emplId
                      AND ACAD_CAREER__c IN :careerSet
                    LIMIT 1
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        dataWrapper.psAsuSpAcStndv = (academicStandingList.size()>0 ? academicStandingList[0] : new PS_ASU_SP_AC_STNDV__x());

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('careerSet', ''));
            
            for (String s : careerSet) {
                vars.add(ErrorLogger.convertStringToJSON('--Value: ', s));
            }
            
            academicAdviserList =        
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_ACAD_ADV__x>() : 
                [
                    select ACAD_CAREER__c, EMAIL_ADDR__c, EMPLID__c, Id, 
                           NAME_DISPLAY__c, PHONE__c
                    FROM PS_ASU_SP_ACAD_ADV__x
                    WHERE EMPLID__c = :emplId
                      AND ACAD_CAREER__c IN :careerSet
                    ORDER BY NAME_DISPLAY__c
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        

        dataWrapper.psAsuSpAcadAdvList = (academicAdviserList.size()>0 ? academicAdviserList : new List<PS_ASU_SP_ACAD_ADV__x>());

/*
               SELECT ACAD_CAREER__c, ACAD_ORG__c, ACAD_PLAN__c, ACAD_PLAN_TYPE__c, ACAD_PROG__c, 
                       ADMIT_TERM__c, ADMIT_TYPE__c, APPLIED_TERM__c, ASU_AA_DEFENSE_DT__c, ASU_AA_DEFENSE_TM__c, 
                       ASU_AA_DFNS_LCTN__c, ASU_AA_GRD_STRM__c, ASU_AA_OVRL_GPA__c, ASU_AA_POS_GPA__c, 
                       ASU_ADV_TO_CANDCY__c, ASU_CANDCY_LET_GEN__c, ASU_CAPSTONE_STAT__c, 
                       ASU_CHECKOUTSTATUS__c, ASU_CMTEE_CHG_STAT__c, ASU_COLLEGE_URL__c, 
                       ASU_CRSE_CHG_STAT__c, ASU_DEFENSE_REQD__c, ASU_FORMAT_STATUS__c, 
                       ASU_IPOS_CRSE_CHG__c, ASU_IPOS_GRAD_DT__c, ASU_IPOS_STAT_DESC__c, 
                       ASU_IPOS_STATUS__c, ASU_MANAGED_IGAP__c, ASU_ORD_PLAN_TYPE__c, ASU_PARENT_ORG__c, 
                       ASU_PROG_DEPT_NAME__c, ASU_SHOW_ADV_SCHED__c, ASU_SHOW_RQST_CHG__c, 
                       ASU_SP_DEGR_FORMAL__c, ASU_SP_DEGREE_NAME__c, ASU_SP_IPOS_LNK__c, ASU_SP_MAJOR1__c, 
                       ASU_SP_MAJOR2__c, ASU_SP_MAJOR3__c, ASU_SP_PRG_COLLEGE__c, ASU_TRACK_STATUS__c, 
                       BUILDING__c, CAMPUS__c, COMPLETION_TERM__c, CUM_GPA__c, DEGR_CHKOUT_STAT__c, 
                       DEGR_CONFER_DT__c, DEGREE__c, DIPLOMA_DESCR__c, DisplayUrl, EDUCATION_LVL__c, 
                       EMAIL_ADDR__c, EMPLID__c, EXP_GRAD_TERM__c, ExternalId, Id, INSTITUTION__c, 
                       MILESTONE_LEVEL__c, PERCENT_OWNED__c, PHONE__c, PROG_STATUS__c, REQ_TERM__c, 
                       ROOM__c, RPT_DATE__c, STDNT_CAR_NBR__c, TERM_BEGIN_DT__c, TERM_END_DT__c 
*/
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('careerSet', ''));
            
            for (String s : careerSet) {
                vars.add(ErrorLogger.convertStringToJSON('--Value: ', s));
            }
            
            gradPlanList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SR_COL_PLAN__x>() :
                [
                    SELECT ASU_AA_POS_GPA__c, ASU_AA_OVRL_GPA__c, CUM_GPA__c, ACAD_CAREER__c, EMPLID__c
                    FROM PS_ASU_SR_COL_PLAN__x
                    WHERE EMPLID__c = :emplId
                      AND ACAD_CAREER__c IN :careerSet
                    LIMIT 1
                ]
            ); 
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        dataWrapper.psGradPlan = (gradPlanList.size() > 0? gradPlanList[0] : new PS_ASU_SR_COL_PLAN__x());

        return dataWrapper;        

    }

    @RemoteAction
    global static List<sortableClass> sortClasses(String paramToSortBy, List<PS_ASU_SP_CLASS_V__x> listOfClasses, boolean sortDirection){
        List<sortableClass> classList = new List<sortableClass>();
        sortDirect = sortDirection;
        for (PS_ASU_SP_CLASS_V__x c : listOfClasses) {
            classList.add(new sortableClass(c));
        }
        
        paramToSort = paramToSortBy;
        classList.sort();
        if(!sortDirection) {
            List<sortableClass> reversedList = new List<sortableClass>();
            for(sortableClass sc : classList) {
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
    global static List<sortableCreditByExam> sortExams(String paramToSortBy, List<PS_ASU_SP_TRNSFR_V__x> listOfExams, boolean sortDirection){
        List<sortableCreditByExam> examList = new List<sortableCreditByExam>();
        sortDirect = sortDirection;
        for (PS_ASU_SP_TRNSFR_V__x c : listOfExams) {
            examList.add(new sortableCreditByExam(c));
        }
        
        examParamSort = paramToSortBy;
        examList.sort();
        if(!sortDirection) {
            List<sortableCreditByExam> reversedList = new List<sortableCreditByExam>();
            for(sortableCreditByExam sc : examList) {
                if (reversedList.size() == 0) {
                    reversedList.add(sc);
                } else {
                    reversedList.add(0, sc);
                }
            }
            return reversedList;
        }
        return examList;
    }
    
    @RemoteAction
    global static List<sortableTransferWork> sortTransfers(String paramToSortBy, List<JBT_RET_CLASS_XFER__x> listOfTransfer, boolean sortDirection){
        List<sortableTransferWork> transferList = new List<sortableTransferWork>();
        sortDirect = sortDirection;
        for (JBT_RET_CLASS_XFER__x c : listOfTransfer) {
            transferList.add(new sortableTransferWork(c));
        }
        
        transferParamSort = paramToSortBy;
        transferList.sort();
        if(!sortDirection) {
            List<sortableTransferWork> reversedList = new List<sortableTransferWork>();
            for(sortableTransferWork sc : transferList) {
                if (reversedList.size() == 0) {
                    reversedList.add(sc);
                } else {
                    reversedList.add(0, sc);
                }
            }
            return reversedList;
        }
        return transferList;
    }

    global class sortableClass implements Comparable{
        PS_ASU_SP_CLASS_V__x classInfo;
        
        
        public sortableClass(PS_ASU_SP_CLASS_V__x classIn){
            classInfo = classIn;
        }
        
        global Integer compareTo(Object compareTo) {
            sortableClass compareToClass = (sortableClass)compareTo;
            Integer sortDir = 0;
            if (paramToSort.equals('Session')) {
                sortDir = compareToClass.classInfo.SESSION_CODE__c.compareTo(this.classInfo.SESSION_CODE__c);
            } else if (paramToSort.equals('Class')) {
                sortDir = compareToClass.classInfo.CLASS_NBR__c.compareTo(this.classInfo.CLASS_NBR__c);
            } else if (paramToSort.equals('Course')) {
                sortDir = compareToClass.classInfo.CRSE_ID__c.compareTo(this.classInfo.CRSE_ID__c);
            } else if (paramToSort.equals('Title')) {
                sortDir = compareToClass.classInfo.CLASS_DESCR__c.compareTo(this.classInfo.CLASS_DESCR__c);
            } else if (paramToSort.equals('Topic')) {
                if(compareToClass.classInfo.SSR_CLSTOPIC_DESCR__c != null && this.classInfo.SSR_CLSTOPIC_DESCR__c != null) {
                    sortDir = compareToClass.classInfo.SSR_CLSTOPIC_DESCR__c.compareTo(this.classInfo.SSR_CLSTOPIC_DESCR__c);
                } else if (compareToClass.classInfo.SSR_CLSTOPIC_DESCR__c != null && this.classInfo.SSR_CLSTOPIC_DESCR__c == null) {
                    sortDir = -1;
                } else {
                    sortDir = 1;
                }
            } else if (paramToSort.equals('Units')) {
                if(compareToClass.classInfo.UNT_TAKEN__c == this.classInfo.UNT_TAKEN__c){
                    sortDir = 0;
                } else if (this.classInfo.UNT_TAKEN__c > compareToClass.classInfo.UNT_TAKEN__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else if (paramToSort.equals('Instructor')) {
                if(compareToClass.classInfo.FT_FULL_NAME__c != null && this.classInfo.FT_FULL_NAME__c != null) {
                    sortDir = compareToClass.classInfo.FT_FULL_NAME__c.compareTo(this.classInfo.FT_FULL_NAME__c);
                } else if (compareToClass.classInfo.FT_FULL_NAME__c != null && this.classInfo.FT_FULL_NAME__c == null) {
                    sortDir = -1;
                } else {
                    sortDir = 1;
                }
            } else if (paramToSort.equals('Days')) {
                if(compareToClass.classInfo.SCH_HTML_DAY1__c != null && this.classInfo.SCH_HTML_DAY1__c != null) {
                    sortDir = compareToClass.classInfo.SCH_HTML_DAY1__c.compareTo(this.classInfo.SCH_HTML_DAY1__c);
                } else if (compareToClass.classInfo.SCH_HTML_DAY1__c != null && this.classInfo.SCH_HTML_DAY1__c == null) {
                    sortDir = -1;
                } else {
                    sortDir = 1;
                }
            } else if (paramToSort.equals('Times')) {
                if(compareToClass.classInfo.SCH_DAILY_TIME__c != null && this.classInfo.SCH_DAILY_TIME__c != null) {
                    sortDir = compareToClass.classInfo.SCH_DAILY_TIME__c.compareTo(this.classInfo.SCH_DAILY_TIME__c);
                } else if (compareToClass.classInfo.SCH_DAILY_TIME__c != null && this.classInfo.SCH_DAILY_TIME__c == null) {
                    sortDir = -1;
                } else {
                    sortDir = 1;
                }
            } else if (paramToSort.equals('Dates')) {
                sortDir = compareToClass.classInfo.ASU_SCH_DATES__c.compareTo(this.classInfo.ASU_SCH_DATES__c);
            } else if (paramToSort.equals('Location')) {
                sortDir = compareToClass.classInfo.SSR_MTG_LOC_LONG__c.compareTo(this.classInfo.SSR_MTG_LOC_LONG__c);
            } else if (paramToSort.equals('Grade')) {
                if(compareToClass.classInfo.CRSE_GRADE_OFF__c != null && this.classInfo.CRSE_GRADE_OFF__c != null) {
                    sortDir = compareToClass.classInfo.CRSE_GRADE_OFF__c.compareTo(this.classInfo.CRSE_GRADE_OFF__c);
                } else if (compareToClass.classInfo.CRSE_GRADE_OFF__c != null && this.classInfo.CRSE_GRADE_OFF__c == null) {
                    sortDir = -1;
                } else {
                    sortDir = 1;
                }
            } else {
                sortDir = 0;
            }
            
            return sortDir * -1;
        }
    }
    
    global class sortableCreditByExam implements Comparable{
        PS_ASU_SP_TRNSFR_V__x examInfo;
        
        
        public sortableCreditByExam(PS_ASU_SP_TRNSFR_V__x examIn){
            examInfo = examIn;
        }
        
        global Integer compareTo(Object compareTo) {
            sortableCreditByExam compareToExam = (sortableCreditByExam)compareTo;
            Integer sortDir = 0;
            if (examParamSort.equals('Title')) {
                sortDir = compareToExam.examInfo.Title__c.compareTo(this.examInfo.TITLE__c );
            } else if (examParamSort.equals('Course Title')) {
                sortDir = compareToExam.examInfo.COURSE_TITLE__c.compareTo(this.examInfo.COURSE_TITLE__c );
            } else if (examParamSort.equals('Score')) {
                if(compareToExam.examInfo.SCORE__c == this.examInfo.SCORE__c){
                    sortDir = 0;
                } else if (this.examInfo.SCORE__c > compareToExam.examInfo.SCORE__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else if (examParamSort.equals('Transfer')) {
                if(compareToExam.examInfo.UNT_TRNSFR__c == this.examInfo.UNT_TRNSFR__c){
                    sortDir = 0;
                } else if (this.examInfo.UNT_TRNSFR__c > compareToExam.examInfo.UNT_TRNSFR__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else {
                sortDir = 0;
            }
            
            return sortDir * -1;
        }
    }
    
    global class sortableTransferWork implements Comparable{
        JBT_RET_CLASS_XFER__x  transferInfo;
        
        
        public sortableTransferWork(JBT_RET_CLASS_XFER__x  transferIn){
            transferInfo = transferIn;
        }
        
        global Integer compareTo(Object compareTo) {
            sortableTransferWork compareToTransfer = (sortableTransferWork)compareTo;
            Integer sortDir = 0;
            if (transferParamSort.equals('Term')) {
                sortDir = compareToTransfer.transferInfo.TERM__c.compareTo(this.transferInfo.TERM__c );
            } else if (transferParamSort.equals('Institution')) {
                sortDir = compareToTransfer.transferInfo.INSTITUTION__c.compareTo(this.transferInfo.INSTITUTION__c );
            } else if (transferParamSort.equals('Course')) {
                sortDir = compareToTransfer.transferInfo.COURSE__c.compareTo(this.transferInfo.COURSE__c );
            } else if (transferParamSort.equals('Title')) {
                sortDir = compareToTransfer.transferInfo.TITLE__c.compareTo(this.transferInfo.TITLE__c );
            } else if (transferParamSort.equals('Topic')) {
                if(compareToTransfer.transferInfo.TOPIC__c != null && this.transferInfo.TOPIC__c != null) {
                    sortDir = compareToTransfer.transferInfo.TOPIC__c.compareTo(this.transferInfo.TOPIC__c);
                } else if (compareToTransfer.transferInfo.TOPIC__c != null && this.transferInfo.TOPIC__c == null) {
                    sortDir = -1;
                } else {
                    sortDir = 1;
                }
            } else if (transferParamSort.equals('Grade')) {
                sortDir = compareToTransfer.transferInfo.GRADE__c.compareTo(this.transferInfo.GRADE__c );
            } else if (transferParamSort.equals('RCredit')) {
                if(compareToTransfer.transferInfo.RCREDIT__c == this.transferInfo.RCREDIT__c){
                    sortDir = 0;
                } else if (this.transferInfo.RCREDIT__c > compareToTransfer.transferInfo.RCREDIT__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else if (transferParamSort.equals('ECredit')) {
                if(compareToTransfer.transferInfo.ECREDIT__c == this.transferInfo.ECREDIT__c){
                    sortDir = 0;
                } else if (this.transferInfo.ECREDIT__c > compareToTransfer.transferInfo.ECREDIT__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else if (transferParamSort.equals('Hours')) {
                if(compareToTransfer.transferInfo.GPAHRS__c == this.transferInfo.GPAHRS__c){
                    sortDir = 0;
                } else if (this.transferInfo.GPAHRS__c > compareToTransfer.transferInfo.GPAHRS__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else if (transferParamSort.equals('Points')) {
                if(compareToTransfer.transferInfo.GPAPTS__c == this.transferInfo.GPAPTS__c){
                    sortDir = 0;
                } else if (this.transferInfo.GPAPTS__c > compareToTransfer.transferInfo.GPAPTS__c) {
                    sortDir = 1;
                } else {
                    sortDir = -1;
                }
            } else {
                sortDir = 0;
            }
            
            return sortDir * -1;
        }
    }
    
    global class classesWrapper
    {
        //public Map<String, String> classTerms = new Map<String, String>();
        public Set<String> classTerms = new Set<String>();
        public Set<String> classSessions = new Set<String>();
        public Set<String> asrClasses = new Set<String>();

        public List<PS_ASU_SP_CLASS_V__x> enrolledClasses = new List<PS_ASU_SP_CLASS_V__x>();
        public List<PS_ASU_SP_CLASS_V__x> droppedClasses = new List<PS_ASU_SP_CLASS_V__x>();
        
    }

    @RemoteAction
    global static classesWrapper getClassesData(String emplid, String strm)
    {
        if (classesData == null)
        {
            classesData = new classesWrapper();
            List<PS_ASU_SP_ASR_CLSV__x> asrList = new List<PS_ASU_SP_ASR_CLSV__x>();
            Set<String> asrClassSet = new Set<String>();

            List<PS_ASU_SP_CLASS_V__x> classList = new List<PS_ASU_SP_CLASS_V__x>();
            
            try {
                vars.add(ErrorLogger.convertStringToJSON('emplid', emplid));
                vars.add(ErrorLogger.convertStringToJSON('strm', strm));
                
                classList =
                (
                    Test.isRunningTest() ? new LIST<PS_ASU_SP_CLASS_V__x>() : 
                    [
                        SELECT ACAD_CAREER__c, ASU_SCH_DATES__c, CATALOG_NBR__c, CLASS_DESCR__c, 
                        CLASS_NBR__c, CRSE_GRADE_OFF__c, CRSE_ID__c, CUM_GPA__c, CUR_GPA__c, 
                        DisplayUrl, EARN_CREDIT__c, EMPLID__c, ENRL_STATUS_REASON__c, ExternalId, 
                        FT_FULL_NAME__c, Id, SCH_DAILY_TIME__c, SCH_HTML_DAY1__c, SESSION_CODE__c, 
                        SSR_CLSTOPIC_DESCR__c, SSR_MTG_LOC_LONG__c, STDNT_ENRL_STATUS__c, STRM__c, 
                        SUBJECT__c, TERM_DESCR30__c, UNT_TAKEN__c, VALID_ATTEMPT__c  
                        FROM PS_ASU_SP_CLASS_V__x 
                        WHERE EMPLID__c = :emplid 
                        ORDER BY STRM__c DESC, CLASS_NBR__c ASC
                    ]
                );
            } catch (Exception e) {
                ErrorLogger.log(e, vars, debug);
            }

            // Build a Set of courses that have the ASR flag for the current term
            if (classList.size() > 0)
            {
                try {
                    vars.add(ErrorLogger.convertStringToJSON('emplid', emplid));
                    vars.add(ErrorLogger.convertStringToJSON('strm', strm));
                    
                    asrList = 
                    [
                        SELECT CLASS_NBR__c, SESSION_CODE__c, STRM__c 
                        FROM   PS_ASU_SP_ASR_CLSV__x
                        WHERE  EMPLID__c = :emplId 
                          AND  STRM__c = :strm
                    ];
                } catch (Exception e) {
                    ErrorLogger.log(e, vars, debug);
                }
                
                if (asrList.size() > 0) {
                    for (PS_ASU_SP_ASR_CLSV__x asr: asrList)
                    {
                        classesData.asrClasses.add(asr.STRM__c + '|' + asr.SESSION_CODE__c + '|' + asr.CLASS_NBR__c);
                    }
                }
            }

            for (PS_ASU_SP_CLASS_V__x course: classList)
            {
                if (course.STDNT_ENRL_STATUS__c == 'E' && course.ENRL_STATUS_REASON__c == 'ENRL') {
                    classesData.enrolledClasses.add(course);
                } else {
                    classesData.droppedClasses.add(course);
                }
                classesData.classTerms.add(course.STRM__c+ '|' + course.TERM_DESCR30__c);
                classesData.classSessions.add(course.SESSION_CODE__c);
            }     
            if (classList.size() > 0) {
                classesData.classTerms.add('All|All');
                classesData.classSessions.add('All');
            }
        }
        
        return classesData;

    }

    // Get Credit by Exam Information
    @RemoteAction
    global static LIST<PS_ASU_SP_TRNSFR_V__x> getCreditByExamData(String emplId)
    {
        List<PS_ASU_SP_TRNSFR_V__x> creditByExamList = new List<PS_ASU_SP_TRNSFR_V__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            creditByExamList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_TRNSFR_V__x>() : 
                [
                    SELECT ACAD_CAREER__c, COURSE_TITLE__c, DisplayUrl, EMPLID__c, 
                           ExternalId, Id, SCORE__c, STRM__c, TITLE__c, UNT_TRNSFR__c 
                    FROM PS_ASU_SP_TRNSFR_V__x
                    WHERE EMPLID__c = :emplId
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (creditByExamList.size() > 0? creditByExamList : new List<PS_ASU_SP_TRNSFR_V__x>());

    }

    // Get Transfer Work Information
    @RemoteAction
    global static LIST<JBT_RET_CLASS_XFER__x> getTransferWorkData(String emplId)
    {
        List<JBT_RET_CLASS_XFER__x> transferWorkList = new List<JBT_RET_CLASS_XFER__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            transferWorkList = 
            (
                Test.isRunningTest() ? new List<JBT_RET_CLASS_XFER__x>() :
                [
                    SELECT COURSE__c, DisplayUrl, ECREDIT__c, EMPLID__c, ExternalId, GPAHRS__c, 
                           GPAPTS__c, GRADE__c, Id, INSTITUTION__c, RCREDIT__c, TERM__c, TITLE__c, 
                           TOPIC__c 
                    FROM JBT_RET_CLASS_XFER__x 
                    WHERE EMPLID__c = :emplId
                    ORDER BY COURSE__c, TERM__c
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (transferWorkList.size() > 0? transferWorkList : new List<JBT_RET_CLASS_XFER__x>());

    }

    global class balancesWrapper
    {
        PS_ASU_SP_FA_BAL_V__x faBalance = new PS_ASU_SP_FA_BAL_V__x();
        Decimal pastDueTIP;
    }

    @RemoteAction
    global static balancesWrapper getFinancesBalanceData(String emplId)
    {
        balancesWrapper wrapper = new balancesWrapper();

        List<PS_ASU_SP_FA_BAL_V__x> balanceList = new List<PS_ASU_SP_FA_BAL_V__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            balanceList =
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_FA_BAL_V__x>() :
                [
                    SELECT BALANCE_AMT__c, DisplayUrl, DUE_AMT__c, EMPLID__c, ExternalId, Id 
                    FROM PS_ASU_SP_FA_BAL_V__x
                    WHERE EMPLID__c = :emplid
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        if (!balanceList.isEmpty())
            wrapper.faBalance = balanceList[0];

        List<ASU_STDNT_RETENTION_SNP__x> snpRecords = getRetentionSNP(emplid);
        if (!snpRecords.isEmpty())
        {
            wrapper.pastDueTIP = snpRecords[0].PAST_DUE_TIP__c;
        }

        return wrapper;
    } 

    @RemoteAction
    global static List<Financial_Aid_Package__c> getFinancialPackageData(String emplId)
    {
        List<Financial_Aid_Package__c> financesPackageList = new List<Financial_Aid_Package__c>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            financesPackageList =
            (
                Test.isRunningTest() ? new List<Financial_Aid_Package__c>() :
                [
                    SELECT Aid_Year__c, Contact__c, CreatedById, CreatedDate, EFC_Range__c, 
                           FA_Status_Time_Stamp__c, FAFSA_Date_Received__c, Fin_Aid_Package_Date__c, 
                           Financial_Aid_Status__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, 
                           Name, Pell_Eligibility__c, Promise_Cohort__c, SystemModstamp 
                    FROM Financial_Aid_Package__c
                    WHERE Contact__r.EMPLID__c = :emplId
                    ORDER BY Aid_Year__c DESC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (financesPackageList.size() > 0? financesPackageList : new List<Financial_Aid_Package__c>());
    } 

    @RemoteAction
    // Get Service Indicators as a list
    global static List<PS_ASU_SP_SVCIND_V__x> getServiceIndicators(String emplId)
    {
        //Temporary
        //return new List<PS_ASU_SP_SVCIND_V__x>();

        List<PS_ASU_SP_SVCIND_V__x> serviceIndicatorList = new List<PS_ASU_SP_SVCIND_V__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            serviceIndicatorList =
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_SVCIND_V__x>() :
                [
                    SELECT ACAD_CAREER__c, ADMIT_TERM__c, DESCR__c, DisplayUrl, EMPLID__c, ExternalId, 
                           Id, POS_SRVC_INDICATOR__c, REASON_DESCR__c, SCC_SI_END_DT__c, SCC_SI_END_TERM__c, 
                           SRVC_IND_ACT_TERM__c, SRVC_IND_ACTIVE_DT__c, SRVC_IND_CD__c, SRVC_IND_DTTM__c 
                    FROM PS_ASU_SP_SVCIND_V__x
                    WHERE EMPLID__c = :emplId
                      AND POS_SRVC_INDICATOR__c = 'N'
                    ORDER BY SRVC_IND_ACTIVE_DT__c ASC, SRVC_IND_CD__c ASC
                ]
            );
            Date currentDate = date.today();
            
            for(Integer i = serviceIndicatorList.size()-1; i >= 0; i--){
                Date tempDate = serviceIndicatorList[i].SCC_SI_END_DT__c;
                if (tempDate < currentDate) {
                    serviceIndicatorList.remove(i);
                }
            }
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (serviceIndicatorList.size() > 0? serviceIndicatorList : new List<PS_ASU_SP_SVCIND_V__x>());
    }    

    // Wrapper for financial aid data
    global class financialAidWrapper
    {
        public Set<String> aidYears = new Set<String>();
        public List<PS_ASU_SP_FA_SUM_V__x> summaryRecords = new List<PS_ASU_SP_FA_SUM_V__x>();

    }

    @RemoteAction
    // Get Financial Aid Summary records and return wrapper class
    global static financialAidWrapper getFinancialSummaryData(String emplId)
    {
        financialAidWrapper faData = new financialAidWrapper();

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            faData.summaryRecords = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_FA_SUM_V__x>() :
                [
                    SELECT ACAD_CAREER__c, ACCEPT_AMOUNT__c, AID_YEAR__c, DESCR__c, EMPLID__c,
                           DESCR_CATEGORY__c, DISBURSED_AMOUNT__c, DisplayUrl, ExternalId, Id, 
                           OFFER_AMOUNT__c, SFA_CR_AWARD_TYPE__c
                    FROM PS_ASU_SP_FA_SUM_V__x
                    WHERE EMPLID__c = :emplId
                    ORDER BY AID_YEAR__c DESC, DESCR_CATEGORY__c ASC, SFA_CR_AWARD_TYPE__c ASC
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        for (PS_ASU_SP_FA_SUM_V__x faRecord: faData.summaryRecords)
        {
            faData.aidYears.add(faRecord.AID_YEAR__c);
        }
        if (faData.summaryRecords.size() > 0)
            faData.aidYears.add('All');

        return faData;
    }      

    global class generalIndicatorsWrapper
    {
        public ASU_STDNT_RETENTION__x asuStudentRetention = new ASU_STDNT_RETENTION__x();
        public JBT_RET_FINAID_INDICATORS__x finAidIndicators = new JBT_RET_FINAID_INDICATORS__x();
        public List<JBT_RET_FINAID_UNRESOLVED__x> finAidUnresolvedList = new List<JBT_RET_FINAID_UNRESOLVED__x>();
        public PS_ASU_SR_INDASR_V__x asrIndicator = new PS_ASU_SR_INDASR_V__x();
        public List<PS_ASU_SR_ASR_INDV__x> asrInformation = new List<PS_ASU_SR_ASR_INDV__x>();
        public List<PS_ASU_SP_ENRHLD_V__x> enrollmentHoldInformation = new List<PS_ASU_SP_ENRHLD_V__x>();
        public Integer enrollmentHoldCount = 0;
        public JBT_RET_MYASU_ACCESS_CNT_VW__x myAsuAccessCount = new JBT_RET_MYASU_ACCESS_CNT_VW__x();
    }

    @RemoteAction
    global static generalIndicatorsWrapper getUGIndicatorsNew(String emplid, String currentTerm)
    {
        generalIndicatorsWrapper giData = new generalIndicatorsWrapper();

        List<ASU_STDNT_RETENTION__x> asuStdntRetentionList = new List<ASU_STDNT_RETENTION__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            asuStdntRetentionList =
            (
                Test.isRunningTest() ? new List<ASU_STDNT_RETENTION__x>() : 
                [SELECT ASR_INDICATOR__c, AVG_MYASU_COHORT__c, CI_INDEX_INDICATOR__c, CUM_GPA_INDICATOR__c, 
                        EADVISOR_INDICATOR__c, EMPLID__c, ENRL_HOLD_COUNT__c, ExternalId, FA_INDICATOR__c, 
                        FINANCIAL_HOLD__c, Id, NEXT_TERM_ENROLLED__c, PAST_DUE_TIP__c, PROBATION_INDICATOR__c, 
                        STRM__c, TERM_MYASU_USAGE__c, TOT_IND__c
                 FROM   ASU_STDNT_RETENTION__x 
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        if (asuStdntRetentionList.size() > 0)
            giData.asuStudentRetention = asuStdntRetentionList[0];

        List<JBT_RET_FINAID_INDICATORS__x> jbtRetFinaidIndicatorsList = new List<JBT_RET_FINAID_INDICATORS__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            jbtRetFinaidIndicatorsList =
            (
                Test.isRunningTest() ? new List<JBT_RET_FINAID_INDICATORS__x>() : 
                [SELECT FA_IND__c
                 FROM   JBT_RET_FINAID_INDICATORS__x
                 WHERE  EMPLID__c = :emplid
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        if (jbtRetFinaidIndicatorsList.size() > 0) {
            giData.finAidIndicators = jbtRetFinaidIndicatorsList[0];   
        }

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            giData.finAidUnresolvedList = 
            (
                Test.isRunningTest() ? new List<JBT_RET_FINAID_UNRESOLVED__x>() : 
                [SELECT ACTION__c, AID_YEAR__c, CHECKLIST_CD__c, CHKLST_ITEM_CD__c, STATUS__c, STATUS_DT__c, STRM__c 
                 FROM   JBT_RET_FINAID_UNRESOLVED__x
                 WHERE  EMPLID__c = :emplid
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        List<PS_ASU_SR_INDASR_V__x> psAsuSrIndasrVList = new List<PS_ASU_SR_INDASR_V__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            psAsuSrIndasrVList =
            (
                Test.isRunningTest() ? new List<PS_ASU_SR_INDASR_V__x>() : 
                [SELECT ACAD_CAREER__c, CLASSCOUNT__c, EMPLID__c, STRM__c 
                 FROM   PS_ASU_SR_INDASR_V__x
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        if(psAsuSrIndasrVList.size() > 0) {
            giData.asrIndicator = psAsuSrIndasrVList[0];
        }

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            giData.asrInformation =
            (
                Test.isRunningTest() ? new List<PS_ASU_SR_ASR_INDV__x>() : 
                [SELECT ACAD_CAREER__c, ASU_GRADE_INST_LST__c, ASU_GRADE_RSN_LIST__c, CLASS_NBR__c, COMMENT1__c, 
                        COURSE_SQC__c, COURSE_TITLE__c, CRSE_GRADE_INPUT__c, EMPLID__c, ENROLLED__c, INSTITUTION__c, 
                        SEQNUM__c, SESSION_CODE__c
                 FROM   PS_ASU_SR_ASR_INDV__x
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            giData.enrollmentHoldInformation =
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_ENRHLD_V__x>() : 
                [SELECT INFO_INSTRUCT1__c, REASON__c, SRVC_IND_CD__c, STRM__c
                 FROM   PS_ASU_SP_ENRHLD_V__x
                 WHERE  EMPLID__c = :emplid
                 AND  STRM__c = :currentTerm 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        giData.enrollmentHoldCount = giData.enrollmentHoldInformation.size();

        List<JBT_RET_MYASU_ACCESS_CNT_VW__x> jbtRetMyasuAccessCntVwList = new List<JBT_RET_MYASU_ACCESS_CNT_VW__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            jbtRetMyasuAccessCntVwList =
            (
                Test.isRunningTest() ? new List<JBT_RET_MYASU_ACCESS_CNT_VW__x>() : 
                [SELECT ACAD_CAREER__c, SEM_ACCESS_COUNT__c, STRM__c
                 FROM   JBT_RET_MYASU_ACCESS_CNT_VW__x
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        
        if (jbtRetMyasuAccessCntVwList.size() > 0)
            giData.myAsuAccessCount = jbtRetMyasuAccessCntVwList[0];

        return giData;
    }

    @RemoteAction
    global static JBT_RET_FINAID_INDICATORS__x getFinAidIndicator(String emplid)
    {

        List<JBT_RET_FINAID_INDICATORS__x> jbtRetFinaidIndicatorsList = new List<JBT_RET_FINAID_INDICATORS__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            
            jbtRetFinaidIndicatorsList = 
            (
                Test.isRunningTest() ? new List<JBT_RET_FINAID_INDICATORS__x>() : 
                [SELECT EMPLID__c, FA_IND__c
                 FROM   JBT_RET_FINAID_INDICATORS__x
                 WHERE  EMPLID__c = :emplid
                 LIMIT 1
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (jbtRetFinaidIndicatorsList.size() > 0? jbtRetFinaidIndicatorsList[0] : new JBT_RET_FINAID_INDICATORS__x());
    }

    @RemoteAction
    global static List<JBT_RET_FINAID_UNRESOLVED__x> getFinAidUnresolved(String emplid, String currentTerm)
    {
        List<JBT_RET_FINAID_UNRESOLVED__x> jbtRetFinaidUnresolvedList= new List<JBT_RET_FINAID_UNRESOLVED__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            jbtRetFinaidUnresolvedList =
            (
                Test.isRunningTest() ? new List<JBT_RET_FINAID_UNRESOLVED__x>() : 
                [SELECT ACTION__c, AID_YEAR__c, CHECKLIST_CD__c, CHKLST_ITEM_CD__c, STATUS__c, STATUS_DT__c, STRM__c 
                 FROM   JBT_RET_FINAID_UNRESOLVED__x
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm
                 ORDER BY AID_YEAR__c DESC, CHECKLIST_CD__c ASC
                ]
            );    
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (jbtRetFinaidUnresolvedList.size() > 0? jbtRetFinaidUnresolvedList : new List<JBT_RET_FINAID_UNRESOLVED__x>());
    }

    @RemoteAction
    global static PS_ASU_SR_INDASR_V__x getAsrIndicator(String emplid, String currentTerm)
    {
        List<PS_ASU_SR_INDASR_V__x> psAsuSrIndasrVList = new List<PS_ASU_SR_INDASR_V__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            psAsuSrIndasrVList =
            (
                Test.isRunningTest() ? new List<PS_ASU_SR_INDASR_V__x>() : 
                [SELECT CLASSCOUNT__c 
                 FROM   PS_ASU_SR_INDASR_V__x
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm 
                 LIMIT 1
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (psAsuSrIndasrVList.size() > 0? psAsuSrIndasrVList[0] : new PS_ASU_SR_INDASR_V__x());
    }

    @RemoteAction
    global static List<PS_ASU_SR_ASR_INDV__x> getAsrInformation(String emplid, String currentTerm)
    {
        List<PS_ASU_SR_ASR_INDV__x> asrInformationList = new List<PS_ASU_SR_ASR_INDV__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            asrInformationList = 
            (
                Test.isRunningTest() ? new List<PS_ASU_SR_ASR_INDV__x>() : 
                [SELECT ACAD_CAREER__c, ASU_GRADE_INST_LST__c, ASU_GRADE_RSN_LIST__c, CLASS_NBR__c, COMMENT1__c, 
                        COURSE_SQC__c, COURSE_TITLE__c, CRSE_GRADE_INPUT__c, EMPLID__c, ENROLLED__c, INSTITUTION__c, 
                        SEQNUM__c, SESSION_CODE__c
                 FROM   PS_ASU_SR_ASR_INDV__x
                 WHERE  EMPLID__c = :emplid
                   AND  STRM__c = :currentTerm
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (asrInformationList.size() > 0? asrInformationList : new List<PS_ASU_SR_ASR_INDV__x>());
    }

    @RemoteAction
    global static List<PS_ASU_SP_ENRHLD_V__x> getEnrollmentHolds(String emplid, String currentTerm)
    {
        List<PS_ASU_SP_ENRHLD_V__x> enrollmentHoldList = new List<PS_ASU_SP_ENRHLD_V__x>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplId));
            vars.add(ErrorLogger.convertStringToJSON('currentTerm', currentTerm));
            
            enrollmentHoldList =
            (
                Test.isRunningTest() ? new List<PS_ASU_SP_ENRHLD_V__x>() : 
                [SELECT INFO_INSTRUCT1__c, REASON__c, SRVC_IND_CD__c, STRM__c
                 FROM   PS_ASU_SP_ENRHLD_V__x
                 WHERE  EMPLID__c = :emplid
                   AND  (STRM__c >= :currentTerm OR STRM__c = '0000')
                 ORDER BY STRM__c ASC, SRVC_IND_CD__c ASC 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (enrollmentHoldList.size() > 0 ? enrollmentHoldList : new List<PS_ASU_SP_ENRHLD_V__x>());
    }

    @RemoteAction
    global static me3__c getMe3Results(String contactId)
    {
        List<me3__c> me3List = new List<me3__c>();
        
        try {
            vars.add(ErrorLogger.convertStringToJSON('contactId', contactId));
            
            me3List =
            (
                Test.isRunningTest() ? new List<me3__c>() : 
                [SELECT Id, A_Score__c, C_Score__c, Contact__c, E_Score__c, I_Score__c, Name, R_Score__c, S_Score__c,                 
                        Source__c, Test_Completed_Date__c, User_Id__c, 
                        (SELECT Active__c, Alternate_Title__c, Career_Interest__c, Career_Major__c, Degree_Interest__c, Id, 
                                Name, O_NET_SOC_Code__c, OwnerId, Plan_Code__c, Position__c, Updated_Date__c 
                         FROM   me3_Careers__r
                         ORDER BY Active__c DESC, Updated_Date__c DESC, Plan_Code__c
                         LIMIT 10) 
                 FROM   me3__c
                 WHERE  Contact__c = :contactId
                 ORDER BY Test_Completed_Date__c DESC
                 LIMIT 1 
                ]
            );
        } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }

        return (me3List.size() > 0? me3List[0] : new me3__c());
    }    

    @RemoteAction
    global static String createCase(String descriptionIn, String subjectIn, String emplidIn) {
        try{
            vars.add(ErrorLogger.convertStringToJSON('emplId', emplidIn));
            Id student = [SELECT Id FROM Contact WHERE emplId__c =: emplidIn LIMIT 1].Id;
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'ASU Service' LIMIT 1];
            Case feedbackCase = new Case(
                        status = 'New',
                        RecordType = rt,
    	                contactId = student,
    	                subject = subjectIn,
    	                description = descriptionIn,
    	                Origin__c = 'Student Profile',
                        IsVisibleInSelfService = false
    	    );
    	            
    	    insert feedbackCase;
    	    
    	    return feedbackCase.Id;
	    } catch (Exception e) {
            ErrorLogger.log(e, vars, debug);
        }
        return null;
    }
    
    public String subPlanString {
        get{
            if(subPlanString == null){
                return '';
            }
            else{
                return subPlanString;
            }
        }
        set;
    }
    private class StudentProfileException extends Exception {}
}