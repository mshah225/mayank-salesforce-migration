public with sharing class SuccessPortal_MainPageController {
    
    //external data
    public String ri {get;set;}
    public String riskScore {get;set;}
    public String lastActivityType {get;set;}
    public String lastActivityDate {get;set;}
    public String currentCourses {get;set;}
    public String lastLogin { get;set; }
    public String courseActivity { get;set; }
    public String nextRegSession { get;set; }
    public String viewLabel { get;set; }
    
    //flags
    public boolean isSuccess {get;set;}
    public boolean isEmailSuccess {get;set;}
    public boolean isSMSSuccess {get;set;}
    public boolean isTransferSuccess {get;set;}
    public boolean isError {get;set;}
    public boolean isPreview {get;set;}
    public boolean isNewCaseSuccess {get;set;}
    public boolean isUpdateCaseSuccess {get;set;}
    public boolean isUpdateSuccess {get;set;}
    public integer progressStatus {get;set;}
    public boolean showReasonsNotReturningOther {get;set;}
    public boolean showRecommendedActionsOther {get;set;}
    public boolean showWillReturnRiskOther {get;set;}
    public string selectedRecGroup {get;set;}
   
    //core
    public string userId {get;set;}
    public string resourceId {get;set;}
    public string userRoleId {get;set;}
    public string userRoleName {get;set;}
    public string userASURiteId {get;set;}
    public string userEmplId {get;set;}
    public string profileName {get;set;}
    public boolean isAdvisorUser {get;set;}
    public boolean isAdvisorLead {get;set;}
    public boolean isAdvisorManager {get;set;}
    public boolean isAdvisorAdmin {get;set;}
    public boolean isCoachUser {get;set;}
    public boolean isCoachLead {get;set;}
    public boolean isCoachManager {get;set;}
    public boolean isCoachAdmin {get;set;}
    public Date todaysDate {get;set;}
    public string pageTitle {get;set;}
    public string coachPODRecordTypeId {get;set;}
    public string advisorPODRecordTypeId {get;set;}
    public string coachCaseRecordTypeId {get;set;}
    public string advisorCaseRecordTypeId {get;set;}
    public string coachResourceRecordTypeId {get;set;}
    public string advisorResourceRecordTypeId {get;set;}
    public string taskRecordTypeId {get;set;}
    public string engagementCoachRecordTypeId {get;set;}
    public string engagementAdvisorRecordTypeId {get;set;}
    public string caseTasksIndicator {get;set; }
    public string Photolink {get;set;}
    public List<Success_POD__c> myPODs {get;set;}
    public List<Id> myPODIds {get;set;}
    public Id advisorQueueId;
    public Id coachUserId;
    public List<string> advisorProgramColleges {get;set;}
    public List<String> advisorCommittees {get;set;}
    public List<String> advisorPlanCodes {get;set;}
    public List<SelectOption> listOfRecs {get;set;}
    public string chatBaseUri {get;set;}

    //selections
    public string selectedTermReturning {get;set;}
    public string selectedWillReturnRisk {get;set;}
    public string selectedWillReturnRiskOther {get;set;}
    public string selectedCaseComments {get;set;}
    public string selectedGridType {get;set;}
    public string selectedCaseSubject {get;set;}
    public string selectedCasePriority {get;set;}
    public string selectedCaseCreatedDate {get;set;}
    public string selectedContactId {get;set;}
    public string selectedContactHidden {get;set;}
    public string selectedCaseId {get;set;}
    public Date selectedFollowupDate {get;set;}
    public string selectedCaseRecordTypeId {get;set;}
    public string selectedOutreachStatus {get;set;}
    public Date selectedDueDate {get;set;}
    public string newType {get;set;}
    public string newDescr {get;set;}
    public string newSubject {get;set;}
    public string newEmailMessage {get;set;}
    public string updatePrimaryPhone {get;set;}
    public string updatePrimaryEmail {get;set;}
    public List<Case> selectedCases {get;set;}
    public List<Contact> selectedStudents {get;set;}
    public List<Case> selectedStudentCases {get;set;}
    public Set<Id> selectedStudentIds {get;set;}
    public Set<Id> selectedStudentCaseIds {get;set;}
    public string selectedViewAsQueue {get;set;}
    public string selectedCoachUserId {get;set;}
    public string selectedAdvisorQueueId {get;set;}
    Public List<string> leftReasonsNotReturningSelected{get;set;}
    Public List<string> selectedReasonsNotReturning{get;set;}
    Public string selectedReasonsNotReturningOther{get;set;}
    Set<string> leftReasonsNotReturningValues = new Set<string>();
    Set<string> rightReasonsNotReturningValues = new Set<string>();
    Public List<string> leftSelected{get;set;}
    Public List<string> selectedRecommendedActions{get;set;}
    Public string selectedRecommendedActionsOther{get;set;}
    Set<string> leftValues = new Set<string>();
    Set<string> rightValues = new Set<string>();
    
    //flags
    public boolean contactSelected {get;set;}
    public boolean caseSelected {get;set;}
    public boolean taskSelected {get;set;}
    public boolean selectedProfile {get;set;}
    
    //transient selections
    public string selectedCaseDescription {get;set;}
    public case selectedCase {get;set;}
    public string selectedContactASURiteId {get;set;}
    public string selectedContactCaseId {get;set;}
    public string selectedContactName {get;set;}
    public string selectedContactEmplId {get;set;}
    public String selectedContactMobilePhone {get;set;}
    public String selectedContactHomePhone {get;set;}
    public String selectedContactOtherPhone {get;set;}
    public string selectedContactEmail {get;set;}
    public string selectedTaskId {get;set;}
    public string selectedDueDateString {get;set;}
    public string selectedFollowupDateMonth {get;set;}
    public string selectedFollowupDateDay {get;set;}
    public string selectedFollowupDateYear {get;set;}
    public string selectedStudentIntention {get;set;}
    public string selectedTab {get;set;}
    public string selectedPlannedMessage {get;set;}
    public string selectedSMSText {get;set;}
    public transient string selectedTransferToGroup {get;set;}
    public transient string selectedASRComments {get;set;}
    public transient string selectedASRReasons {get;set;}
    public transient string selectedASRActions {get;set;}
    public transient Date selectedASRDate {get;set;}
    public transient string selectedASRDateString {get;set;}
    public transient string selectedASRDateMonth {get;set;}
    public transient string selectedASRDateDay {get;set;}
    public transient string selectedASRDateYear {get;set;}
    public transient string selectedClassNumber {get;set;}
    public transient string selectedCourseCode {get;set;}
    public transient string selectedSession {get;set;}
    //public transient string selectedSessionCode {get;set;}
    public transient string selectedSessionDecode {get;set;}
    public transient string selectedTerm {get;set;}
    
    //transient counts
    public Integer myStudentsCount {get;set;}
    public Integer myChatsCount {get;set;}
    public Integer myOpenCasesCount {get;set;}
    public Integer myWatchlistCount {get;set;}

    //transient lists
    public transient List<Task> caseTasks {get;set;}
    public transient List<EmailMessage> caseEmails {get;set;}
    public List<trStudents> rowsStudents {get;set;}
    public List<trStudentCases> rowsStudentCases {get;set;}
    public List<trStudentCases> rowsOtherStudentCases {get;set;}
    public List<trSummaryCases> rowsSummaryCases {get;set;}
    public transient List<trCaseComments> rowsCaseComments {get;set;}
    
    //lists
    public List<Success_Resource__c> myPODTeamMembers {get;set;}
    public List<Success_Student__c> myStudents {get;set;}
    public List<Case> otherProactiveCases {get;set;}
    public List<Case> otherReactiveCases {get;set;}
    public List<Case> myChats {get;set;}
    public List<Case> myWatchList {get;set;}
    public List<Case> myOpenCases {get;set;}
    public List<String> myPrograms {get;set;}
    public String searchResultsId {get;set;}
    
    //dashboard counts
    public transient Integer dashCasesCount {get;set;}
    public transient Integer dashEmailsCount {get;set;}
    public transient Integer dashSMSCount {get;set;}
    public transient Integer dashChatsCount {get;set;}
    
    //My Students Grid
    public class trStudents {
        public transient Contact theContact {get;set;}
        public Boolean isStudentSelected {get;set;}
        public String contactId {get;set;}
        public trStudents(Contact co,Boolean b,String c) {
              theContact = co;
              isStudentSelected = b;
              contactId = c;
            }
    }
    
    //Cases Grid
    public class trStudentCases {
        public transient Contact theContact {get;set;}
        public transient Case theCase {get;set;}
        public Boolean isStudentCaseSelected {get;set;}
        public String caseId {get;set;}
        public trStudentCases(Case ca,Contact co,Boolean b,String c) {
              theContact = co;
              theCase = ca;
              isStudentCaseSelected = b;
              caseId = c;
            }
    }

    //custom summary table
    public class trSummaryCases {
        public transient string sumCount {get;set;}
        public transient string sumSubject {get;set;}
        public transient string sumIcon {get;set;}
        public transient string sumPriority {get;set;}
        public transient string sumDescription {get;set;}
        public transient string sumDueDate {get;set;}
        public transient Boolean isSummaryCaseSelected {get;set;}
        public trSummaryCases(string cnt, string sub, string icon, string priority, string descr, string duedate, Boolean b){
            sumCount = cnt;
            sumSubject = sub;
            sumIcon = icon;
            sumPriority = priority;
            sumDescription = descr;
            sumDueDate = duedate;
            isSummaryCaseSelected = b;
            }
    }
    
    //custom case comments table
    public class trCaseComments {
        public transient String theDate {get;set;}
        public transient String theName {get;set;}
        public transient String theComment {get;set;}
        public trCaseComments(String dt,String nm, String comm) {
              theDate = dt;
              theName = nm;
              theComment = comm;
            }
    }
    
    //modal stuff
    public Success_Resource__c successCoachDetails{get;set;}
    public Case caseDetails{get;set;}
    public String previewMessage{get;set;}
    
    public SuccessPortal_MainPageController(){
       searchResultsId = ApexPages.currentPage().getParameters().get('id');
       init();
    }
    
    public void init(){
        //try{
            todaysDate = Date.Today();
            pageTitle = '';
            progressStatus = 0;
            caseTasksIndicator = 'success';
            clearAllSelections();
            resetAllFlags();
            selectedRecGroup = '1-1000';

            List<User> u = [SELECT u.Id, u.Alias, u.EmployeeNumber, u.SmallPhotoUrl, u.FullPhotoUrl, u.UserRoleId 
                             FROM User u 
                             WHERE u.id=:UserInfo.getUserId()];
            if(u.size()>0)
            {
                Photolink = u[0].FullPhotoUrl;
                userId = u[0].Id;
                userRoleId = u[0].UserRoleId;
                userASURiteId = u[0].Alias;
                userEmplId = u[0].EmployeeNumber;
                
                //get chat app endpoint
                Rest_Service_Setting__mdt custMeta = [SELECT Id,Label,Login_Endpoint__c,Application_Base_URI__c,Authorization_Key__c,
                                                Username__c,Password__c
                                                FROM Rest_Service_Setting__mdt
                                                WHERE DeveloperName = 'RocketChat_API_Settings'];
                chatBaseUri = custMeta.Application_Base_URI__c;
                
                //get user role name
                //userRoleName = [SELECT DeveloperName FROM UserRole WHERE Id =: userRoleId].DeveloperName; 

                //BEGIN EXTERNAL DATA TODO
                ri = '5';
                riskScore = '30%';
                lastActivityType = 'Email';
                lastActivityDate = '05/01/2016';
                viewLabel = 'View';
                //END EXTERNAL DATA TODO
                
                //BEGIN NOT IMPLEMENTING
                currentCourses = 'ENG 110';
                lastLogin = '05/29/2016';
                courseActivity = '10m';
                nextRegSession = 'SumA';
                //END NOT IMPLEMENTING
            
                selectedCases = new List<Case>();
                rowsStudents = new List<trStudents>();
                rowsStudentCases = new List<trStudentCases>();
                rowsOtherStudentCases = new List<trStudentCases>();
                rowsSummaryCases = new List<trSummaryCases>();
                rowsCaseComments = new List<trCaseComments>();
                caseTasks = new List<Task>();
                caseEmails = new List<EmailMessage>();
                selectedStudentIds = new Set<Id>();
                selectedStudents = new List<Contact>();
                selectedStudentCaseIds = new Set<Id>();
                selectedStudentCases = new List<Case>();
                advisorCommittees = new List<String>();
                
                leftReasonsNotReturningSelected = new List<String>();
                selectedReasonsNotReturning = new List<String>();
                showReasonsNotReturningOther = false;
                Schema.DescribeFieldResult resRNR = Case.Reasons_Not_Returning__c.getDescribe();
                List<Schema.PicklistEntry> pleRNR = resRNR.getPicklistValues();
                for( Schema.PicklistEntry f : pleRNR)
                {
                    leftReasonsNotReturningValues.add(f.getLabel());
                }
                
                leftSelected = new List<String>();
                selectedRecommendedActions = new List<String>();
                showRecommendedActionsOther = false;
                Schema.DescribeFieldResult resRA = Case.Recommended_Actions__c.getDescribe();
                List<Schema.PicklistEntry> pleRA = resRA.getPicklistValues();
                for( Schema.PicklistEntry f : pleRA)
                {
                    leftValues.add(f.getLabel());
                }
                showWillReturnRiskOther = false;
                clearAllSelections();
                resetDashCounts();
            
                populateTaskRecordTypeId();
                populateAdvisorResourceRecordTypeId();
                populateCoachResourceRecordTypeId();
                populateAdvisorPODRecordTypeId();
                populateCoachPODRecordTypeId();
                populateAdvisorCaseRecordTypeId();
                populateCoachCaseRecordTypeId();
                populateCoachEngagementRecordTypeId();
                populateAdvisorEngagementRecordTypeId();
                
                checkUserRole();  

                reloadMainPage();
            }
        /*
        }
        catch(Exception ex){
            System.Debug('ERROR='+ex.getMessage());
            Apexpages.addMessages(ex);
            isError = true;
        }
        */
    }
    
    /****************************************************************************************************
    BEGIN UTILITY FUNCTIONS
    *****************************************************************************************************/
    private void reloadMainPage()
    {  
        myStudents = new List<Success_Student__c>();
        myOpenCases = new List<Case>();
        myWatchlist = new List<Case>();
        myChats = new List<Case>();
        myPods = new List<Success_POD__c>();
        myPODIds = new List<Id>();
        populateMyStudentsCount();
        populateMyOpenCasesCount();
        populateMyWatchlistCount();
        populateMyChatsCount();
        populateMyCaseSummaries();
        selectedContactId = '';
        clearAllSelections();
        resetAllFlags();
        
        if(isCoachUser||isCoachLead||isCoachManager||isCoachAdmin)
        {
            if(searchResultsId==null)
            {
                populateMyPODList();
                selectedCaseSubject = 'My Students';
                populateCasesGrid();
            }
            else if(searchResultsId!=null)
            {
                selectedCaseSubject = 'Search Results';
                populateCasesGrid();
            }
            else 
            {
                populateCasesGrid();
            }
            populateCasesCount();
            populateEmailsCount();
            populateSMSCount();
            populateChatsCount();
        }
        else if(isAdvisorUser||isAdvisorLead||isAdvisorManager||isAdvisorAdmin)
        {
            if(searchResultsId!=null)
            {
                selectedCaseSubject = 'Search Results';
                populateCasesGrid();
            }
        }
               
        pageTitle = isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin?'Advisor Portal':'Coach Portal';
        isSuccess = true;
        resetAllFlags();
        
        
    }
    
    public void reloadAfterSave()
    {  
        resetAllFlags();
        populateMyCaseSummaries();
        populateCasesCount();
        populateEmailsCount();
        populateChatsCount();
        selectedCaseSubject = selectedCaseSubject==''?'My Students':selectedCaseSubject;
        populateCasesGrid();
        getCaseTasks();
        resetAllFlags();
    }
    
    //clear all form selections
    private void clearFormSelections()
    {
        selectedOutreachStatus = '';
        selectedDueDateString = '';
        selectedDueDate = null;
        selectedFollowupDateMonth = '';
        selectedFollowupDateDay = '';
        selectedFollowupDateYear = '';
        selectedFollowupDate = null;
        selectedStudentIntention = '';
        selectedTermReturning = '';
        selectedPlannedMessage = '';
        selectedTransferToGroup = '';
        selectedTerm = '';
        //selectedSessionCode = '';
        selectedSessionDecode = '';
        selectedSession = '';
        selectedCourseCode = '';
       
        
        selectedReasonsNotReturning = null;
        selectedReasonsNotReturningOther = '';
        showReasonsNotReturningOther = false;
        
        selectedRecommendedActions = null;
        selectedRecommendedActionsOther = '';
        showRecommendedActionsOther = false;
        
        selectedWillReturnRisk = '';
        selectedWillReturnRiskOther = '';
        showWillReturnRiskOther = false;

        selectedCaseComments = '';
        //selectedCaseSubject = '';
        selectedCasePriority = '';
        selectedCaseDescription = '';
        selectedCaseCreatedDate = '';
        selectedASRComments = '';
        selectedASRDateString = '';
        selectedASRDateMonth = '';
        selectedASRDateDay = '';
        selectedASRDateYear = '';
        selectedASRDate = null;
        selectedASRReasons = '';
        selectedASRActions = '';
        selectedContactCaseId = '';
        selectedContactMobilePhone = '';
        selectedContactHomePhone = '';
        selectedContactOtherPhone = '';
        selectedContactEmail = '';
        selectedTab = '';
        selectedSMSText = '';
        newType = '';
        newDescr = '';
        newSubject = '';
        newEmailMessage = '';
        updatePrimaryPhone = '';
        updatePrimaryEmail = '';
        selectedProfile = false;
        //selectedContactId = null;
        //selectedContactASURiteId = null;
        //selectedContactName = null;
        //selectedContactEmplId = null;
        //selectedCaseId = null;
        //selectedCaseRecordTypeId = '';
        //selectedTaskId = null;
        //contactSelected = false;
        //caseSelected = false;
        //taskSelected = false;
    }
    
    //clear all selections
    private void clearAllSelections()
    {
        selectedOutreachStatus = '';
        selectedDueDateString = '';
        selectedDueDate = null;
        selectedFollowupDateMonth = '';
        selectedFollowupDateDay = '';
        selectedFollowupDateYear = '';
        selectedFollowupDate = null;
        selectedStudentIntention = '';
        selectedTermReturning = '';
        selectedPlannedMessage = '';
        selectedTransferToGroup = '';
        selectedTerm = '';
        //selectedSessionCode = '';
        selectedSessionDecode = '';
        selectedSession = '';
        selectedCourseCode = '';
        
        selectedReasonsNotReturning = null;
        selectedReasonsNotReturningOther = '';
        showReasonsNotReturningOther = false;
        
        selectedRecommendedActions = null;
        selectedRecommendedActionsOther = '';
        showRecommendedActionsOther = false;
        
        selectedWillReturnRisk = '';
        selectedWillReturnRiskOther = '';
        showWillReturnRiskOther = false;

        selectedCaseComments = '';
        selectedCaseSubject = '';
        selectedCasePriority = '';
        selectedCaseDescription = '';
        selectedCaseCreatedDate = '';
        selectedASRComments = '';
        selectedASRDateString = '';
        selectedASRDateMonth = '';
        selectedASRDateDay = '';
        selectedASRDateYear = '';
        selectedASRDate = null;
        selectedASRReasons = '';
        selectedASRActions = '';
        selectedContactCaseId = '';
        selectedContactMobilePhone = '';
        selectedContactHomePhone = '';
        selectedContactOtherPhone = '';
        selectedContactEmail = '';
        selectedTab = '';
        selectedSMSText = '';
        newType = '';
        newDescr = '';
        newSubject = '';
        newEmailMessage = '';
        updatePrimaryPhone = '';
        updatePrimaryEmail = '';
        selectedProfile = false;
        selectedContactId = null;
        selectedContactASURiteId = null;
        selectedContactName = null;
        selectedContactEmplId = null;
        selectedCaseId = null;
        selectedCaseRecordTypeId = '';
        selectedTaskId = null;
        contactSelected = false;
        caseSelected = false;
        taskSelected = false;
    }
    
    //clear all dashboard counts
    private void resetDashCounts()
    {
        dashCasesCount = 0;
        dashEmailsCount = 0;
        dashSMSCount = 0;
        dashChatsCount = 0;
    }
    
    //clear all flags
    public void resetAllFlags()
    {
        isSuccess = false;
        isError = false;
        isEmailSuccess = false;
        isSMSSuccess = false;
        isTransferSuccess = false;
        isUpdateSuccess = false;
        isPreview = false;
        isNewCaseSuccess = false;
        isUpdateCaseSuccess = false;
    }
    
    //determine if the user has access
    public void checkUserRole()
    {
        //Id profileId = userinfo.getProfileId();
        //profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
        isAdvisorUser = false;
        isAdvisorLead = false;
        isAdvisorManager = false;
        isAdvisorAdmin = false;
        isCoachUser = false;
        isCoachLead = false;
        isCoachManager = false;
        isCoachAdmin = false;
        advisorProgramColleges = new List<String>();
        
        List<Success_Resource__c> resource = [SELECT Id, Role__c, Success_POD__c, Success_POD__r.OwnerId, Committee_Code__c,Program_Code__c,Plan_Code__c, RecordTypeId FROM Success_Resource__c 
                                            WHERE Resource__c =: userId
                                            AND IsActive__c = true 
                                            ORDER BY CreatedDate ASC];
        if(resource.size()>0)
        {
            resourceId = resource[0].Id;
            if(resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'User')
            {
                isCoachUser = true;
                selectedCoachUserId = resource[0].Id;
            }
            else if (resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'Lead' )
            {
                isCoachLead = true;
                selectedCoachUserId = resource[0].Id;
            }
            else if (resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'Manager')
            {
                isCoachManager = true;
                selectedCoachUserId = resource[0].Id;
            }
            else if (resource[0].RecordTypeId == coachResourceRecordTypeId && resource[0].Role__c == 'Admin')
            {
                isCoachAdmin = true;
                selectedCoachUserId = resource[0].Id;
            }
            else if (resource[0].RecordTypeId == advisorResourceRecordTypeId && resource[0].Role__c == 'User')
            {
                isAdvisorUser = true;
                advisorQueueId = resource[0].Success_POD__r.Ownerid;
                selectedAdvisorQueueId = advisorQueueId;
                //populateAdvisorProgramColleges(resource[0].Id);
                
                for(Success_Resource__c rec : resource)
                {
                    advisorCommittees.add(rec.Committee_Code__c);
                }

            }
            else if (resource[0].RecordTypeId == advisorResourceRecordTypeId && resource[0].Role__c == 'Lead')
            {
                isAdvisorLead = true;
                advisorQueueId = resource[0].Success_POD__r.Ownerid;
                selectedAdvisorQueueId = advisorQueueId;
                //populateAdvisorProgramColleges(resource[0].Id);
                
                if(resource[0].Program_Code__c!=null)
                {
                    advisorProgramColleges = resource[0].Program_Code__c.split(';');
                }
            }
            else if (resource[0].RecordTypeId == advisorResourceRecordTypeId && resource[0].Role__c == 'Manager')
            {
                isAdvisorManager = true;
                advisorQueueId = resource[0].Success_POD__r.Ownerid;
                selectedAdvisorQueueId = advisorQueueId;
                //populateAdvisorProgramColleges(resource[0].Id);
                
                if(resource[0].Program_Code__c!=null)
                {
                    advisorProgramColleges = resource[0].Program_Code__c.split(';');
                }
                if(resource[0].Plan_Code__c!=null)
                {
                    advisorPlanCodes = resource[0].Plan_Code__c.split(';');
                }
            }
            else if (resource[0].RecordTypeId == advisorResourceRecordTypeId && resource[0].Role__c == 'Admin')
            {
                isAdvisorAdmin = true;
                advisorQueueId = resource[0].Success_POD__r.Ownerid;
                selectedAdvisorQueueId = advisorQueueId;
                //populateAdvisorProgramColleges(resource[0].Id);
                
                if(resource[0].Program_Code__c!=null)
                {
                    advisorProgramColleges = resource[0].Program_Code__c.split(';');
                }
            }
        }
        system.debug(isCoachAdmin);
    }
    
    /*
    public void populateAdvisorProgramColleges(string resourceId)
    {
        List<Success_Resource_Program__c> programs = new List<Success_Resource_Program__c>();
        programs = [SELECT Program__c FROM Success_Resource_Program__c WHERE Success_Resource__c =: resourceId];
        if(programs.size()>0)
        {
            for(Success_Resource_Program__c program : programs){
                advisorProgramColleges.add(string.valueOf(program.Program__c));
            }
        }
    }
    */
    
    public PageReference openPreferences()
    {
        resetAllFlags();
        return null;
    }
    
    public static String getResourceURL(String resourceName){

        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

        if(resourceList.size() == 1){
           String namespace = resourceList[0].NamespacePrefix;
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        else return '';
    }
    
    /****************************************************************************************************
    END UTILITY FUNCTIONS
    *****************************************************************************************************/
    
    /****************************************************************************************************
    BEGIN SELECT FUNCTIONS
    *****************************************************************************************************/
    
    //select case subject event
    public PageReference selectCaseSubject()
    {
        selectedFollowupDateYear = '';
        selectedFollowupDateMonth = '';
        selectedFollowupDateDay = '';
        selectedFollowupDate = null;
        try{
            selectedCaseSubject = System.currentPageReference().getParameters().get('selectedCaseSubject')!=null?System.currentPageReference().getParameters().get('selectedCaseSubject'):selectedCaseSubject;
            selectedDueDateString = System.currentPageReference().getParameters().get('selectedDueDate')!=null?System.currentPageReference().getParameters().get('selectedDueDate'):selectedDueDateString;
            selectedCasePriority = System.currentPageReference().getParameters().get('selectedCasePriority')!=null?System.currentPageReference().getParameters().get('selectedCasePriority'):selectedCasePriority;
            if(selectedDueDateString!=null && selectedDueDateString!='')
            {
                selectedDueDate = null;
                Date dt = System.Date.parse(selectedDueDateString);
                selectedDueDate = dt;
            }
            caseSelected = true;
            contactSelected = false;
            selectedContactId = '';
            selectedContactASURiteId = '';
            selectedContactName = '';
            selectedContactEmplId = '';
            selectedContactHomePhone = '';
            selectedContactMobilePhone = '';
            selectedContactOtherPhone = '';
            selectedContactEmail = '';
            //rowsStudents = new List<trStudents>();
            //rowsStudentCases = new List<trStudentCases>();
            selectedRecGroup = '1-1000';
            populateCasesGrid();
        }
        catch(Exception ex){
        
        }
        return null;
    }
    
    //select student event
    public PageReference selectStudent()
    {
        resetAllFlags();
        selectedCaseId = null;
        selectedContactId = System.currentPageReference().getParameters().get('selectedContactId');
        Contact con = new Contact();
        con = [SELECT Id, ASURite_Id__c,FirstName,LastName,Emplid__c,HomePhone,OtherPhone,MobilePhone,Email 
                FROM Contact 
                WHERE Id =: selectedContactId];
        selectedContactId = con.Id;
        selectedContactASURiteId = con.ASURite_Id__c;
        selectedContactName = con.FirstName + ' ' + con.LastName;
        selectedContactEmplId = con.EmplId__c;
        selectedContactHomePhone = con.HomePhone;
        selectedContactOtherPhone = con.OtherPhone;
        selectedContactMobilePhone = con.MobilePhone;
        selectedContactEmail = con.Email;

        getOtherProactiveCases();
        getOtherReactiveCases();
        contactSelected = true;
        resetAllFlags();
        return null;
    }
    
    //select student row event
    public PageReference selectStudentRow()
    {
        selectedContactId = System.currentPageReference().getParameters().get('selectedContactId')!=null?System.currentPageReference().getParameters().get('selectedContactId'):selectedContactId;
        selectedContactHidden = System.currentPageReference().getParameters().get('selectedContactHidden')!=null?System.currentPageReference().getParameters().get('selectedContactHidden'):selectedContactHidden;
        return null;
    }
    
    //select student event
    public PageReference selectStudentCase()
    {
        clearFormSelections();
        System.Debug('SELECTED CASE ID = '+selectedCaseId);
        selectedCaseId = System.currentPageReference().getParameters().get('selectedCaseId')!=null?System.currentPageReference().getParameters().get('selectedCaseId'):selectedCaseId;
        Case ca = new Case();
        ca = [SELECT Id,RecordTypeId,Subject,Status,Student_Intention__c,Followup_Date__c,
                Description,Recommended_Actions__c,Recommended_Actions_Other__c,
                Reasons_Not_Returning__c,Reasons_Not_Returning_Other__c,
                Student_Presented_Risk_for__c,Student_Presented_Risk_for_Other__c,
                CreatedDate,ASR_Comments__c,ASR_Reasons__c,ASR_Actions__c,ASR_Date__c,
                What_term_is_the_student_planning_to_ret__c,Contact.Id,Contact.FirstName,
                Contact.LastName,Contact.ASURite_Id__c,Contact.EmplId__c,Contact.HomePhone,
                Contact.OtherPhone,Contact.MobilePhone,Contact.Email,
                Class_Nbr__c,Course_Code__c,Session__c,Session_Decode__c,STRM__c,Priority
                FROM Case 
                WHERE Id =: selectedCaseId];
        selectedCaseId = ca.Id;
        selectedCaseRecordTypeId = ca.RecordTypeId;
        selectedContactId = ca.Contact.Id;
        selectedContactASURiteId = ca.Contact.ASURite_Id__c;
        selectedContactName = ca.Contact.FirstName + ' ' + ca.Contact.LastName;
        selectedContactEmplId = ca.Contact.EmplId__c;
        selectedContactHomePhone = ca.Contact.HomePhone;
        selectedContactOtherPhone = ca.Contact.OtherPhone;
        selectedContactMobilePhone = ca.Contact.MobilePhone;
        selectedContactEmail = ca.Contact.Email;
        selectedCaseSubject = ca.Subject;
        selectedOutreachStatus = ca.Status;
        selectedStudentIntention = ca.Student_Intention__c;
        selectedFollowupDate = ca.Followup_Date__c;
        selectedCaseDescription = ca.Description;
        selectedCase = ca;
        selectedCaseCreatedDate = string.valueOf(ca.CreatedDate);
        selectedCasePriority = ca.Priority;
        
        //clear all previous selected values
        showRecommendedActionsOther = false;
        Schema.DescribeFieldResult resRA = Case.Recommended_Actions__c.getDescribe();
        List<Schema.PicklistEntry> pleRA = resRA.getPicklistValues();
        for( Schema.PicklistEntry f : pleRA)
        {
            leftValues.add(f.getLabel());
        }
        rightValues.clear();
        if(ca.Recommended_Actions__c!=null)
        {
            string actions = ca.Recommended_Actions__c;
            selectedRecommendedActions = actions.split(';');
            showRecommendedActionsOther = false;
            for(String s : selectedRecommendedActions){
                leftValues.remove(s);
                if(s=='Other'){
                    showRecommendedActionsOther = true;
                }
                rightValues.add(s);
                
            }
        }
        selectedRecommendedActionsOther = ca.Recommended_Actions_Other__c;
        
        //clear all previous selected values
        showReasonsNotReturningOther = false;
        Schema.DescribeFieldResult resRNR = Case.Reasons_Not_Returning__c.getDescribe();
        List<Schema.PicklistEntry> pleRNR = resRNR.getPicklistValues();
        for( Schema.PicklistEntry f : pleRNR)
        {
            leftReasonsNotReturningValues.add(f.getLabel());
        }
        rightReasonsNotReturningValues.clear();
        if(ca.Reasons_Not_Returning__c!=null)
        {
            string reasons = ca.Reasons_Not_Returning__c;
            selectedReasonsNotReturning = reasons.split(';');
            showReasonsNotReturningOther = false;
            for(String s : selectedReasonsNotReturning){
                //leftReasonsNotReturningValues.remove(s);
                rightReasonsNotReturningValues.add(s);
                if(s=='Other'){
                    showReasonsNotReturningOther = true;
                }
            }
        }        
        selectedReasonsNotReturningOther = ca.Reasons_Not_Returning_Other__c;
        
        selectedTermReturning = ca.What_term_is_the_student_planning_to_ret__c;
        
        selectedWillReturnRisk = ca.Student_Presented_Risk_for__c;
        selectedWillReturnRiskOther = ca.Student_Presented_Risk_for_Other__c;
        showWillReturnRiskOther = selectedWillReturnRisk=='Other'?true:false;
        
        selectedASRComments = ca.ASR_Comments__c;
        selectedASRReasons = ca.ASR_Reasons__c;
        selectedASRActions = ca.ASR_Actions__c;
        selectedASRDateString = string.valueOf(ca.ASR_Date__c);
        
        selectedClassNumber = ca.Class_Nbr__c;
        selectedCourseCode = ca.Course_Code__c;
        selectedSession = ca.Session__c;
        //selectedSessionCode = string.valueOf(ca.Session_Code__c);
        selectedSessionDecode = string.valueOf(ca.Session_Decode__c);
        selectedTerm = string.valueOf(ca.STRM__c);

        getOtherProactiveCases();
        getOtherReactiveCases();
        getCaseTasks();
        getCaseEmails();
        getCaseComments();
        contactSelected = true;
        resetAllFlags();
        return null;
    }
    
    //select student event
    public PageReference selectUpdatedStudentCase()
    {
        return null;
    }
 
    //select outreach status event
    public PageReference selectOutreachStatus()
    {
        return null;
    }
    
    public PageReference selectFollowupDate()
    {
        try{
            string strDt = System.currentPageReference().getParameters().get('selectedFollowupDate');
            List<String> dateParts = strDt.split('-');
            Date dt = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            selectedFollowupDate = dt;
        }
        catch(Exception ex){
            selectedFollowupDate = todaysDate;
        }
        return null;
    }
    
    public PageReference selectStudentIntention()
    {
        resetAllFlags();
        return null;
    }
    
    public PageReference selectRecGroup()
    {
        selectedRecGroup = selectedRecGroup;
        populateCasesGrid();
        return null;
    }
    
    public PageReference selectRecommendedActions()
    {
        return null;
    }
    
    public PageReference selectRecommendedActionsOther()
    {
        selectedRecommendedActionsOther = System.currentPageReference().getParameters().get('selectedCaseComments');
        return null;
    }
    
    public PageReference selectReasonsNotReturning()
    {
        resetAllFlags();
        return null;
    }
    
    public PageReference selectReasonsNotReturningOther()
    {
        resetAllFlags();
        return null;
    }
    
    public PageReference selectTermReturning()
    {
        resetAllFlags();
        return null;
    }
    
    public PageReference selectWillReturnRisk()
    {
        resetAllFlags();
        showWillReturnRiskOther = selectedWillReturnRisk=='Other'?true:false;
        return null;
    }
    
    public PageReference selectWillReturnRiskOther()
    {
        resetAllFlags();
        return null;
    }
    
    public PageReference selectCaseComments()
    {
        selectedCaseComments = System.currentPageReference().getParameters().get('selectedCaseComments');
        return null;
    }
    
    public PageReference selectNewSubject()
    {
        newSubject = System.currentPageReference().getParameters().get('newSubject');
        return null;
    }
    
    public PageReference selectNewEmailMessage()
    {
        newEmailMessage = System.currentPageReference().getParameters().get('newEmailMessage');
        return null;
    }
    
    public PageReference selectNewDescription()
    {
        newDescr = System.currentPageReference().getParameters().get('newDescr');
        return null;
    }

    //select a task event 
    public PageReference selectTask()
    {
        selectedTaskId = System.currentPageReference().getParameters().get('selectedTaskId');
        taskSelected = true;
        return null;
    }
    
    public PageReference selectPlannedMessage()
    {
        selectedPlannedMessage = System.currentPageReference().getParameters().get('selectedPlannedMessage');
        return null;
    }
    
    public PageReference selectSMSText()
    {
        selectedSMSText = System.currentPageReference().getParameters().get('selectedSMSText');
        return null;
    }
    
    public PageReference selectCoachUserId()
    {
        coachUserId = selectedCoachUserId;
        List<Success_Resource__c> shadowCoach = [SELECT Id, Resource__r.Id, Resource__r.Alias FROM Success_Resource__c WHERE Id =: coachUserId];
        if(shadowCoach.size()>0)
        {
            userId = shadowCoach[0].Resource__r.Id;
            userASURiteId = shadowCoach[0].Resource__r.Alias;
            reloadMainPage();
        }
        return null;
    }
    
    public PageReference selectAdvisorQueueId()
    {
        advisorQueueId = selectedAdvisorQueueId;
        reloadMainPage();
        return null;
    }

    
    /****************************************************************************************************
    END SELECT FUNCTIONS
    *****************************************************************************************************/

    /****************************************************************************************************
    BEGIN POPULATE FUNCTIONS
    *****************************************************************************************************/

    //populate the list of other coaches in my pod
    public void populateMyPODList()
    {
        //myPODIds = new List<Id>();
        List<Success_Resource__c> resources = new List<Success_Resource__c>();
        if(isCoachUser)
        {
            resources = [SELECT Success_POD__c 
                        FROM Success_Resource__c 
                        WHERE Resource__c = :userId AND RecordTypeId =: coachResourceRecordTypeId];
        }
        else if(isCoachLead || isCoachManager || isCoachAdmin)
        {
            resources = [SELECT Success_POD__c 
                        FROM Success_Resource__c 
                        WHERE RecordTypeId =: coachResourceRecordTypeId];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            resources = [SELECT Success_POD__c 
                        FROM Success_Resource__c 
                        WHERE Resource__c = :userId AND RecordTypeId =: advisorResourceRecordTypeId];
        }
        
        for(Success_Resource__c resource : resources)
        {
            myPODIds.add(resource.Success_POD__c);
        }
        
        myPODs = new List<Success_POD__c>();
        myPODs = [SELECT Id,Name,OwnerId FROM Success_POD__c WHERE Id in: myPODIds];
        
        
        myPODTeamMembers = new List<Success_Resource__c>();
        myPODTeamMembers = [SELECT Resource__c FROM Success_Resource__c 
                                        WHERE Success_POD__c in: myPODIds
                                        AND IsActive__c = true
                                        AND Resource__c !=: userId];
        
    }
    
    //get a list of cases grouped by type and order by priority
    public void populateMyCaseSummaries(){
         rowsSummaryCases = new List<trSummaryCases>();
         if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
         {
            string tooltip = '';
            string icon = '';
            List<AggregateResult> agr1 = [SELECT Subject, Priority, Followup_Date__c, COUNT(Id) total
                                    FROM Case 
                                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                                    AND OwnerId=:userId                                        
                                    AND isClosed = False
                                    GROUP BY Subject,Priority,Followup_Date__c
                                    ORDER BY Priority ASC];
            for (AggregateResult theList : agr1) { 
                if(icon=='')
                {
                   icon = getResourceURL('Case_Priority_Indicator');                   
                }
                string priority = '';
                //if(priority=='')
                //{
                    priority = String.valueOf(theList.get('Priority'));
                //}
                if(tooltip=='')
                {
                   tooltip = String.valueOf(theList.get('subject'));                   
                }
                string duedate='';
                if(String.valueOf(theList.get('Followup_Date__c'))!=null)
                {
                    duedate = System.Date.valueOf(String.valueOf(theList.get('Followup_Date__c'))).format();
                }
                rowsSummaryCases.add(new trSummaryCases(String.valueOf(theList.get('total')),String.valueOf(theList.get('Subject')),icon,priority,tooltip,duedate,false));
            }
         }
         else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
         {
             string tooltip = '';
             string icon = '';
             List<AggregateResult> agr1 = [SELECT Subject, Priority, Followup_Date__c, COUNT(Id) total
                                        FROM Case 
                                        WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                        AND (Subject != 'My Chats' AND Subject != 'My Watchlist')
                                        AND (OwnerId =: advisorQueueId OR OwnerId=:userId) 
                                        AND isClosed = False
                                        GROUP BY Subject,Priority,Followup_Date__c 
                                        ORDER BY Priority];
            for (AggregateResult theList : agr1) { 
                if(icon=='')
                {
                   icon = getResourceURL('Case_Priority_Indicator');                     
                }
                string priority = '';
                //if(priority=='')
                //{
                    priority = String.valueOf(theList.get('Priority'));
                //}
                if(tooltip=='')
                {
                   tooltip = String.valueOf(theList.get('subject'));                   
                }
                if(tooltip=='')
                {
                   tooltip = String.valueOf(theList.get('subject'));
                }
                string duedate='';
                if(String.valueOf(theList.get('Followup_Date__c'))!=null)
                {
                    duedate = System.Date.valueOf(String.valueOf(theList.get('Followup_Date__c'))).format();
                }
                rowsSummaryCases.add(new trSummaryCases(String.valueOf(theList.get('total')),String.valueOf(theList.get('Subject')),icon,priority,tooltip,duedate,false));
            }

         }
    }
    
    public void populateCasesCount()
    {
        dashCasesCount = 0;
        List<Case> agr = new List<Case>();
        agr = [SELECT Id
                            FROM Case 
                            WHERE RecordTypeId =: coachCaseRecordTypeId 
                            AND OwnerId=:userid  
                            AND CreatedDate =: todaysDate];
        dashCasesCount = agr.size();
    }
    
    public void populateEmailsCount()
    {
        dashEmailsCount = 0;
        List<Task> agr = new List<Task>();
        agr = [SELECT OwnerId, Status,Subject,TaskSubtype,Task_Source__c,Type,WhatId,WhoId,CreatedDate 
                            FROM Task
                            WHERE OwnerId=:userId 
                            AND TaskSubtype = 'Task'
                            AND Type = 'Email'
                            AND ActivityDate =: System.today()];
         dashEmailsCount = agr.size();
        
    }
    
    public void populateSMSCount()
    {
        dashSMSCount = 0;
        List<Task> agr = new List<Task>();
        agr = [SELECT OwnerId, Status,Subject,TaskSubtype,Task_Source__c,Type,WhatId,WhoId,CreatedDate 
                            FROM Task
                            WHERE OwnerId=:userId 
                            AND TaskSubtype = 'Task'
                            AND Type = 'SMS'
                            AND ActivityDate =: System.today()];
        dashSMSCount = agr.size();
        
    }
    
    public void populateChatsCount()
    {
        dashChatsCount = 0;
        List<Task> agr = new List<Task>();
        agr =  [SELECT OwnerId, Status,Subject,TaskSubtype,Task_Source__c,Type,WhatId,WhoId,CreatedDate 
                            FROM Task
                            WHERE OwnerId=:userid 
                            AND TaskSubtype = 'Task'
                            AND Type = 'Chat Session'
                            AND ActivityDate =: todaysDate];
        dashChatsCount = agr.size();
        
    }
    
    //get coach details
    public void populateCoachDetails()
    {
        successCoachDetails = new Success_Resource__c();
        successCoachDetails = [SELECT Id,Primary_Phone__c ,Primary_Email__c
                            FROM Success_Resource__c 
                            WHERE Resource__c =: userId
                            AND RecordTypeId =: coachResourceRecordTypeId LIMIT 1];
                            
        updatePrimaryPhone = successCoachDetails.Primary_Phone__c;
        updatePrimaryEmail = successCoachDetails.Primary_Email__c;
    }
    
    //get a count of students assigned to a coach
    public void populateMyStudentsCount()
    {
        myStudentsCount = 0;
        
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            myStudentsCount = [SELECT count()
                            FROM Success_Student__c 
                            WHERE Success_Resource__r.Resource__c =: userId
                            AND Is_Active__c = true];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myStudentsCount = [SELECT count()
                            FROM Success_Student__c 
                            WHERE Success_POD__r.OwnerId =: advisorQueueId
                            AND Is_Active__c = true];
        }        
    }
    
    //get a list of students assigned to a coach or advisor the Case Status dropdown list
    public void populateMyStudents()
    {
        myStudents = new List<Success_Student__c>();
        
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            myStudents = [SELECT Student__r.Id 
                            FROM Success_Student__c 
                            WHERE Success_Resource__r.Resource__c =: userId 
                            AND Is_Active__c = true LIMIT 2000 ];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myStudents = [SELECT Student__r.Id 
                            FROM Success_Student__c 
                            WHERE Success_POD__r.OwnerId =: advisorQueueId 
                            AND Is_Active__c = true LIMIT 2000 ];
        }        
    }
    
    //get a count of students assigned to a coach
    public void populateMyOpenCasesCount()
    {
        myOpenCasesCount = 0;
        
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            myOpenCasesCount = [SELECT count()
                                FROM Case 
                                WHERE RecordTypeId =: coachCaseRecordTypeId 
                                AND isClosed = False
                                AND OwnerId=:userid];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myOpenCasesCount = [SELECT count()
                                FROM Case 
                                WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                AND isClosed = False
                                AND (OwnerId =: advisorQueueId OR OwnerId =: userId)];
        }        
    }
    
    //get a list of students with open cases for this coach or advisor
    public void populateMyOpenCases()
    {
        myOpenCases = new List<Case>();
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
             myOpenCases = [SELECT Id, 
                    CaseNumber, 
                    Status,
                    Followup_Date__c,
                    Student_Intention__c,
                    Recommended_Actions__c,
                    Recommended_Actions_Other__c,
                    What_term_is_the_student_planning_to_ret__c,
                    Reasons_Not_Returning__c,
                    Reasons_Not_Returning_Other__c,
                    Origin, 
                    Type,
                    Subject,
                    Age_Days_Excluding_Weekends__c,
                    CreatedDate, 
                    LastModifiedDate,
                    ASR_Comments__c,
                    ASR_Date__c,
                    ASR_Reasons__c,
                    ASR_Actions__c,
                    Student_Presented_Risk_for__c,
                    Student_Presented_Risk_for_Other__c,
                    Hidden_Selected__c,
                    RecordTypeId,
                    contact.Id, 
                    contact.ASURite_ID__c,
                    contact.Name,
                    contact.FirstName, 
                    contact.LastName,
                    contact.EmplId__c,
                    contact.Contact_Preference__c,
                    contact.Email,
                    contact.Personal_Email__c,
                    contact.ASU_Email__c,
                    contact.HomePhone,
                    contact.MobilePhone,
                    contact.OtherPhone,
                    contact.SF_Mobile__c,
                    contact.SMS_Phone__c,
                    contact.Work_Phone__c,
                    contact.Phone
                    FROM Case 
                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                    AND isClosed = False
                    AND OwnerId=:userid 
                    ORDER BY contact.LastName ASC];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myOpenCases = [SELECT Id, 
                            CaseNumber, 
                            Status,
                            Followup_Date__c,
                            Student_Intention__c,
                            Recommended_Actions__c,
                            Recommended_Actions_Other__c,
                            What_term_is_the_student_planning_to_ret__c,
                            Reasons_Not_Returning__c,
                            Reasons_Not_Returning_Other__c,
                            Origin, 
                            Type,
                            Subject,
                            Age_Days_Excluding_Weekends__c,
                            CreatedDate, 
                            LastModifiedDate,
                            ASR_Comments__c,
                            ASR_Date__c,
                            ASR_Reasons__c,
                            ASR_Actions__c,
                            Student_Presented_Risk_for__c,
                            Student_Presented_Risk_for_Other__c,
                            Hidden_Selected__c,
                            RecordTypeId,
                            contact.Id, 
                            contact.ASURite_ID__c,
                            contact.Name,
                            contact.FirstName, 
                            contact.LastName,
                            contact.EmplId__c,
                            contact.Contact_Preference__c,
                            contact.Email,
                            contact.Personal_Email__c,
                            contact.ASU_Email__c,
                            contact.HomePhone,
                            contact.MobilePhone,
                            contact.OtherPhone,
                            contact.SF_Mobile__c,
                            contact.SMS_Phone__c,
                            contact.Work_Phone__c,
                            contact.Phone
                            FROM Case 
                            WHERE RecordTypeId =: advisorCaseRecordTypeId 
                            AND isClosed = False
                            AND (OwnerId =: advisorQueueId OR OwnerId=:userId) 
                            ORDER BY contact.LastName ASC];
         }
    }
    
    //get a count of students assigned to a watchlist case type for this coach or advisor
    public void populateMyWatchListCount()
    {
        myWatchListCount = 0;
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
             myWatchListCount = [SELECT count()
                                FROM Case 
                                WHERE RecordTypeId =: coachCaseRecordTypeId 
                                AND Subject = 'My Watchlist'
                                AND isClosed = False
                                AND OwnerId=:userId];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myWatchListCount = [SELECT count()
                                FROM Case 
                                WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                AND Subject = 'My Watchlist'
                                AND isClosed = False
                                AND OwnerId=:userId];
         }
    }
    
    //get a list of students assigned to a watchlist case type for this coach or advisor
    public void populateMyWatchList()
    {
        myWatchList = new List<Case>();
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
             myWatchList = [SELECT Id, 
                    CaseNumber, 
                    Status,
                    Followup_Date__c,
                    Student_Intention__c,
                    Recommended_Actions__c,
                    Recommended_Actions_Other__c,
                    What_term_is_the_student_planning_to_ret__c,
                    Reasons_Not_Returning__c,
                    Reasons_Not_Returning_Other__c,
                    Origin, 
                    Type,
                    Subject,
                    Age_Days_Excluding_Weekends__c,
                    CreatedDate, 
                    LastModifiedDate,
                    ASR_Comments__c,
                    ASR_Date__c,
                    ASR_Reasons__c,
                    ASR_Actions__c,
                    Student_Presented_Risk_for__c,
                    Student_Presented_Risk_for_Other__c,
                    Hidden_Selected__c,
                    RecordTypeId,
                    contact.Id, 
                    contact.ASURite_ID__c,
                    contact.Name,
                    contact.FirstName, 
                    contact.LastName,
                    contact.EmplId__c,
                    contact.Contact_Preference__c,
                    contact.Email,
                    contact.Personal_Email__c,
                    contact.ASU_Email__c,
                    contact.HomePhone,
                    contact.MobilePhone,
                    contact.OtherPhone,
                    contact.SF_Mobile__c,
                    contact.SMS_Phone__c,
                    contact.Work_Phone__c,
                    contact.Phone
                    FROM Case 
                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                    AND Subject = 'My Watchlist'
                    AND isClosed = False
                    AND OwnerId=:userId 
                    ORDER BY contact.LastName ASC];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myWatchList = [SELECT Id, 
                            CaseNumber, 
                            Status,
                            Followup_Date__c,
                            Student_Intention__c,
                            Recommended_Actions__c,
                            Recommended_Actions_Other__c,
                            What_term_is_the_student_planning_to_ret__c,
                            Reasons_Not_Returning__c,
                            Reasons_Not_Returning_Other__c,
                            Origin, 
                            Type,
                            Subject,
                            Age_Days_Excluding_Weekends__c,
                            CreatedDate, 
                            LastModifiedDate,
                            ASR_Comments__c,
                            ASR_Date__c,
                            ASR_Reasons__c,
                            ASR_Actions__c,
                            Student_Presented_Risk_for__c,
                            Student_Presented_Risk_for_Other__c,
                            Hidden_Selected__c,
                            RecordTypeId,
                            contact.Id, 
                            contact.ASURite_ID__c,
                            contact.Name,
                            contact.FirstName, 
                            contact.LastName,
                            contact.EmplId__c,
                            contact.Contact_Preference__c,
                            contact.Email,
                            contact.Personal_Email__c,
                            contact.ASU_Email__c,
                            contact.HomePhone,
                            contact.MobilePhone,
                            contact.OtherPhone,
                            contact.SF_Mobile__c,
                            contact.SMS_Phone__c,
                            contact.Work_Phone__c,
                            contact.Phone
                            FROM Case 
                            WHERE RecordTypeId =: advisorCaseRecordTypeId 
                            AND Subject = 'My Watchlist'
                            AND isClosed = False
                            AND OwnerId=:userId 
                            ORDER BY contact.LastName ASC];
         }
    }
    
    
    //get a count of students assigned to a chat case type for this coach or advisor
    public void populateMyChatsCount()
    {
        myChatsCount = 0;
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
             myChatsCount = [SELECT count()
                                FROM Case 
                                WHERE RecordTypeId =: coachCaseRecordTypeId 
                                AND Subject = 'My Chats'
                                AND isClosed = False
                                AND OwnerId=:userId];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myChatsCount = [SELECT count()
                                FROM Case 
                                WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                AND Subject = 'My Chats'
                                AND isClosed = False
                                AND OwnerId=:userId];
         }
    }
    
    //get a list of students assigned to a chat case type for this coach or advisor
    public void populateMyChats()
    {
        myChats = new List<Case>();
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
             myChats = [SELECT Id, 
                            CaseNumber, 
                            Status,
                            Followup_Date__c,
                            Student_Intention__c,
                            Recommended_Actions__c,
                            Recommended_Actions_Other__c,
                            What_term_is_the_student_planning_to_ret__c,
                            Reasons_Not_Returning__c,
                            Reasons_Not_Returning_Other__c,
                            Origin, 
                            Type,
                            Subject,
                            Age_Days_Excluding_Weekends__c,
                            CreatedDate,
                            LastModifiedDate, 
                            ASR_Comments__c,
                            ASR_Date__c,
                            ASR_Reasons__c,
                            ASR_Actions__c,
                            Student_Presented_Risk_for__c,
                            Student_Presented_Risk_for_Other__c,
                            Hidden_Selected__c,
                            RecordTypeId,
                            contact.Id,
                            contact.ASURite_ID__c, 
                            contact.Name,
                            contact.FirstName, 
                            contact.LastName,
                            contact.EmplId__c,
                            contact.Contact_Preference__c,
                            contact.Email,
                            contact.Personal_Email__c,
                            contact.ASU_Email__c,
                            contact.HomePhone,
                            contact.MobilePhone,
                            contact.OtherPhone,
                            contact.SF_Mobile__c,
                            contact.SMS_Phone__c,
                            contact.Work_Phone__c,
                            contact.Phone
                            FROM Case 
                            WHERE RecordTypeId =: coachCaseRecordTypeId 
                            AND Subject = 'My Chats'
                            AND isClosed = False
                            AND OwnerId=:userId 
                            ORDER BY contact.LastName ASC];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            myChats = [SELECT Id, 
                            CaseNumber, 
                            Status,
                            Followup_Date__c,
                            Student_Intention__c,
                            Recommended_Actions__c,
                            Recommended_Actions_Other__c,
                            What_term_is_the_student_planning_to_ret__c,
                            Reasons_Not_Returning__c,
                            Reasons_Not_Returning_Other__c,
                            Origin, 
                            Type,
                            Subject,
                            Age_Days_Excluding_Weekends__c,
                            CreatedDate, 
                            LastModifiedDate,
                            ASR_Comments__c,
                            ASR_Date__c,
                            ASR_Reasons__c,
                            ASR_Actions__c,
                            Student_Presented_Risk_for__c,
                            Student_Presented_Risk_for_Other__c,
                            Hidden_Selected__c,
                            RecordTypeId,
                            contact.Id, 
                            contact.ASURite_ID__c,
                            contact.Name,
                            contact.FirstName, 
                            contact.LastName,
                            contact.EmplId__c,
                            contact.Contact_Preference__c,
                            contact.Email,
                            contact.Personal_Email__c,
                            contact.ASU_Email__c,
                            contact.HomePhone,
                            contact.MobilePhone,
                            contact.OtherPhone,
                            contact.SF_Mobile__c,
                            contact.SMS_Phone__c,
                            contact.Work_Phone__c,
                            contact.Phone
                            FROM Case 
                            WHERE RecordTypeId =: advisorCaseRecordTypeId 
                            AND Subject = 'My Chats'
                            AND isClosed = False
                            AND (OwnerId =: advisorQueueId OR OwnerId=:userId) 
                            ORDER BY contact.LastName ASC];
         }
    }

    //get a list of cases based on the type selected in the summary grid
    public void populateCasesGrid(){
        integer i = 0;
        rowsStudents = new List<trStudents>();
        List<trStudents> rowsStudents2 = new List<trStudents>();
        List<trStudents> rowsStudents3 = new List<trStudents>();
        List<trStudents> rowsStudents4 = new List<trStudents>();
        List<trStudents> rowsStudents5 = new List<trStudents>();
        rowsStudentCases = new List<trStudentCases>();
        List<trStudentCases> rowsStudentCases2 = new List<trStudentCases>();
        List<trStudentCases> rowsStudentCases3 = new List<trStudentCases>();
        List<trStudentCases> rowsStudentCases4 = new List<trStudentCases>();
        List<trStudentCases> rowsStudentCases5 = new List<trStudentCases>();
        rowsOtherStudentCases = new List<trStudentCases>();
        List<Id> studentIds = new List<Id>();
        List<Case> proactiveCases = new List<Case>();
        List<Case> reactiveCases = new List<Case>();
        listOfRecs = new List<SelectOption>();
        listOfRecs.add (new SelectOption('', '--select--'));
        //COACHES
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            if(selectedCaseSubject=='Search Results')
            {
                for(Contact co:[SELECT
                                    Id,
                                    ASURite_ID__c, 
                                    Name,
                                    FirstName, 
                                    LastName,
                                    EmplId__c,
                                    Contact_Preference__c,
                                    Email,
                                    Personal_Email__c,
                                    ASU_Email__c,
                                    HomePhone,
                                    MobilePhone,
                                    OtherPhone,
                                    SF_Mobile__c,
                                    SMS_Phone__c,
                                    Work_Phone__c,
                                    Phone,
                                    Hidden_Selected__c
                                    FROM Contact 
                                    WHERE Id = :searchResultsId
                                    ORDER BY LastName ASC]) 
                {            
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudents.add(new trStudents(co,false,co.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudents2.add(new trStudents(co,false,co.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudents3.add(new trStudents(co,false,co.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudents4.add(new trStudents(co,false,co.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudents5.add(new trStudents(co,false,co.Id));
                    }
                }
            }
            else if(selectedCaseSubject=='My Students')
            {
               List<Id> contactIds = new List<Id>();
               populateMyStudents();
                for(Success_Student__c con : myStudents)
                {
                    contactIds.add(con.Student__r.Id);
                }
                for(Contact co:[SELECT
                                    Id,
                                    ASURite_ID__c, 
                                    Name,
                                    FirstName, 
                                    LastName,
                                    EmplId__c,
                                    Contact_Preference__c,
                                    Email,
                                    Personal_Email__c,
                                    ASU_Email__c,
                                    HomePhone,
                                    MobilePhone,
                                    OtherPhone,
                                    SF_Mobile__c,
                                    SMS_Phone__c,
                                    Work_Phone__c,
                                    Phone,
                                    Hidden_Selected__c
                                    FROM Contact 
                                    WHERE Id in :contactIds
                                    ORDER BY LastName ASC ]) 
                { 
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudents.add(new trStudents(co,false,co.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudents2.add(new trStudents(co,false,co.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudents3.add(new trStudents(co,false,co.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudents4.add(new trStudents(co,false,co.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudents5.add(new trStudents(co,false,co.Id));
                    }
                }
            }
            else if (selectedCaseSubject=='My Open Proactive Cases')
            {
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                                    AND isClosed = False
                                    AND OwnerId=:userId 
                                    ORDER BY contact.LastName ASC ]) 
                {           
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                }
     
            }
            else if(selectedCaseSubject=='My Watchlist')
            {
                List<Id> contactIds = new List<Id>();
                populateMyWatchlist();
                for(Case con : myWatchList)
                {
                    contactIds.add(con.contact.Id);
                }
    
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                                    AND Subject = 'My Watchlist'
                                    AND isClosed = False
                                    AND contact.Id in :contactIds
                                    ORDER BY contact.LastName ASC ]) 
                 {               
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                 }
            }
            else if(selectedCaseSubject=='My Chats')
            {
                List<Id> contactIds = new List<Id>();
                populateMyChats();
                for(Case con : myChats)
                {
                    contactIds.add(con.contact.Id);
                }
    
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                                    AND Subject = 'My Chats'
                                    AND isClosed = False
                                    AND contact.Id in :contactIds
                                    ORDER BY contact.LastName ASC ]) 
                 {             
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                 }
            }
            else
            {
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                                    AND Subject =: selectedCaseSubject
                                    AND isClosed = False
                                    AND OwnerId=:userId 
                                    AND Followup_Date__c=:selectedDueDate
                                    AND Priority =: selectedCasePriority
                                    ORDER BY contact.LastName ASC ]) 
                { 
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                }
            }
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            if (selectedCaseSubject=='My Open Proactive Cases')
            {
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                    AND isClosed = False
                                    AND (OwnerId =: advisorQueueId OR OwnerId =: userId)
                                    ORDER BY contact.LastName ASC ]) 
                {           
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                }     
            }
            else if(selectedCaseSubject=='My Students')
            {
                List<Id> contactIds = new List<Id>();
                populateMyStudents();
                for(Success_Student__c con : myStudents)
                {
                    contactIds.add(con.Student__r.Id);
                }
                System.Debug('NUMBER_OF_STUDENTS='+contactIds.size());
                for(Contact co:[SELECT
                                    Id,
                                    ASURite_ID__c, 
                                    Name,
                                    FirstName, 
                                    LastName,
                                    EmplId__c,
                                    Contact_Preference__c,
                                    Email,
                                    Personal_Email__c,
                                    ASU_Email__c,
                                    HomePhone,
                                    MobilePhone,
                                    OtherPhone,
                                    SF_Mobile__c,
                                    SMS_Phone__c,
                                    Work_Phone__c,
                                    Phone,
                                    Hidden_Selected__c
                                    FROM Contact 
                                    WHERE Id in :contactIds
                                    ORDER BY LastName ASC ]) 
                { 
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudents.add(new trStudents(co,false,co.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudents2.add(new trStudents(co,false,co.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudents3.add(new trStudents(co,false,co.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudents4.add(new trStudents(co,false,co.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudents5.add(new trStudents(co,false,co.Id));
                    }
                }
            }
            else if(selectedCaseSubject=='My Watchlist')
            {
                List<Id> contactIds = new List<Id>();
                populateMyWatchlist();
                for(Case con : myWatchList)
                {
                    contactIds.add(con.contact.Id);
                }
    
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                    AND Subject = 'My Watchlist'
                                    AND isClosed = False
                                    AND OwnerId =: userId
                                    AND contact.Id in :contactIds
                                    ORDER BY contact.LastName ASC ]) 
                 {            
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                 }
            }
            else
            {
                for(Case ca:[SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE RecordTypeId =: advisorCaseRecordTypeId 
                                    AND Subject =: selectedCaseSubject
                                    AND isClosed = False
                                    AND (OwnerId =: advisorQueueId OR OwnerId =: userId)
                                    AND Followup_Date__c =: selectedDueDate
                                    AND Priority =: selectedCasePriority
                                    ORDER BY contact.LastName ASC ]) 
                { 
                    i++;
                    if(i<=1000)
                    {           
                        rowsStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>1000 && i<2001)
                    {
                        rowsStudentCases2.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>2000 && i<3001)
                    {
                        rowsStudentCases3.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>3000 && i<4001)
                    {
                        rowsStudentCases4.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                    if(i>4000 && i<5001)
                    {
                        rowsStudentCases5.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                    }
                }
 
            }

        }
        
        if(rowsStudents.size()>0){
            listOfRecs.add(new SelectOption('1-1000', rowsStudents[0].theContact.LastName + ' - ' + rowsStudents[rowsStudents.size()-1].theContact.LastName));
        }
        if(rowsStudents2.size()>0){
            listOfRecs.add(new SelectOption('1001-2000', rowsStudents2[0].theContact.LastName + ' - ' + rowsStudents2[rowsStudents2.size()-1].theContact.LastName));
        }
        if(rowsStudents3.size()>0){
            listOfRecs.add(new SelectOption('2001-3000', rowsStudents3[0].theContact.LastName + ' - ' + rowsStudents3[rowsStudents3.size()-1].theContact.LastName));
        }
        if(rowsStudents4.size()>0){
            listOfRecs.add(new SelectOption('3001-4000', rowsStudents4[0].theContact.LastName + ' - ' + rowsStudents4[rowsStudents4.size()-1].theContact.LastName));
        }
        if(rowsStudents5.size()>0){
            listOfRecs.add(new SelectOption('4001-5000', rowsStudents5[0].theContact.LastName + ' - ' + rowsStudents5[rowsStudents5.size()-1].theContact.LastName));
        }
        if(selectedRecGroup=='1-1000' && rowsStudents.size()>0)
        {
            System.Debug('SELECTED REC GROUP WITH STUDENTS='+selectedRecGroup);
        }
        if(selectedRecGroup=='1001-2000' && rowsStudents2.size()>0)
        {
            rowsStudents.clear();
            rowsStudents = rowsStudents2;
        }
        if(selectedRecGroup=='2001-3000' && rowsStudents3.size()>0)
        {
            rowsStudents.clear();
            rowsStudents = rowsStudents3;
        }
        if(selectedRecGroup=='3001-4000' && rowsStudents4.size()>0)
        {
            rowsStudents.clear();
            rowsStudents = rowsStudents4;
        }
        if(selectedRecGroup=='4001-5000' && rowsStudents5.size()>0)
        {
            rowsStudents.clear();
            rowsStudents = rowsStudents5;
        }
        rowsStudents2 = null;
        rowsStudents3 = null;
        rowsStudents4 = null;
        rowsStudents5 = null;
        
        
        if(rowsStudentCases.size()>0){
            listOfRecs.add(new SelectOption('1-1000', rowsStudentCases[0].theContact.LastName + ' - ' + rowsStudentCases[rowsStudentCases.size()-1].theContact.LastName));
        }
        if(rowsStudentCases2.size()>0){
            listOfRecs.add(new SelectOption('1001-2000', rowsStudentCases2[0].theContact.LastName + ' - ' + rowsStudentCases2[rowsStudentCases2.size()-1].theContact.LastName));
        }
        if(rowsStudentCases3.size()>0){
            listOfRecs.add(new SelectOption('2001-3000', rowsStudentCases3[0].theContact.LastName + ' - ' + rowsStudentCases3[rowsStudentCases3.size()-1].theContact.LastName));
        }
        if(rowsStudentCases4.size()>0){
            listOfRecs.add(new SelectOption('3001-4000', rowsStudentCases4[0].theContact.LastName + ' - ' + rowsStudentCases4[rowsStudentCases4.size()-1].theContact.LastName));
        }
        if(rowsStudentCases5.size()>0){
            listOfRecs.add(new SelectOption('4001-5000', rowsStudentCases5[0].theContact.LastName + ' - ' + rowsStudentCases5[rowsStudentCases5.size()-1].theContact.LastName));
        }
        if(selectedRecGroup=='1-1000' && rowsStudentCases.size()>0)
        {
            System.Debug('SELECTED REC GROUP WITH CASES='+selectedRecGroup);
        }
        if(selectedRecGroup=='1001-2000' && rowsStudentCases2.size()>0)
        {
            rowsStudentCases.clear();
            rowsStudentCases = rowsStudentCases2;
        }
        if(selectedRecGroup=='2001-3000' && rowsStudentCases3.size()>0)
        {
            rowsStudentCases.clear();
            rowsStudentCases = rowsStudentCases3;
        }
        if(selectedRecGroup=='3001-4000' && rowsStudentCases4.size()>0)
        {
            rowsStudentCases.clear();
            rowsStudentCases = rowsStudentCases4;
        }
        if(selectedRecGroup=='4001-5000' && rowsStudentCases.size()>0)
        {
            rowsStudentCases.clear();
            rowsStudentCases = rowsStudentCases5;
        }
        rowsStudentCases2 = null;
        rowsStudentCases3 = null;
        rowsStudentCases4 = null;
        rowsStudentCases5 = null;
        myStudents = null;
        
    }
    
    //get the coach resource recordtype id
    public void populateCoachResourceRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_Resource__c'];
        if(rectype.size()>0)coachResourceRecordTypeId=rectype[0].Id;
    }
    
    //get the advisor resource recordtype id
    public void populateAdvisorResourceRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Advisor' AND SobjectType = 'Success_Resource__c'];
        if(rectype.size()>0)advisorResourceRecordTypeId=rectype[0].Id;
    }
    
    //get the coach POD recordtype id
    public void populateCoachPODRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_POD__c'];
        if(rectype.size()>0)coachPODRecordTypeId=rectype[0].Id;
    }
    
    //get the advisor POD recordtype id
    public void populateAdvisorPODRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Advisor' AND SobjectType = 'Success_POD__c'];
        if(rectype.size()>0)advisorPODRecordTypeId=rectype[0].Id;
    }
    
    //get the coach case recordtype id
    public void populateCoachCaseRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASU_Coach_Outreach' AND SobjectType = 'Case'];
        if(rectype.size()>0)coachCaseRecordTypeId=rectype[0].Id;
    }
    
    //get the advisor case recordtype id
    public void populateAdvisorCaseRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASU_Advisor_Outreach' AND SobjectType = 'Case'];
        if(rectype.size()>0)advisorCaseRecordTypeId=rectype[0].Id;
    }
    
    //get the task recordtype id
    public void populateTaskRecordTypeId(){
        List<RecordType> rectype = [SELECT Id FROM RecordType WHERE DeveloperName = 'User_Task_Layout'];
        if(rectype.size()>0)taskRecordTypeId=rectype[0].Id;
    }
    
    //get the coach engagement recordtype id
    public void populateCoachEngagementRecordTypeId(){
        List<RecordType> rectype = [SELECT Id 
                                    FROM RecordType 
                                    WHERE DeveloperName = 'ASU_Coach_Outreach' 
                                    AND SobjectType = 'Engagement__c'];
        if(rectype.size()>0)engagementCoachRecordTypeId=rectype[0].Id;
    }
    
    //get the advisor engagement recordtype id
    public void populateAdvisorEngagementRecordTypeId(){
        List<RecordType> rectype = [SELECT Id 
                                    FROM RecordType 
                                    WHERE DeveloperName = 'ASU_Advisor_Outreach' 
                                    AND SobjectType = 'Engagement__c'];
        if(rectype.size()>0)engagementAdvisorRecordTypeId=rectype[0].Id;
    }
    
    /****************************************************************************************************
    END POPULATE FUNCTIONS
    *****************************************************************************************************/
    
    /****************************************************************************************************
    BEGIN GETS FUNCTIONS
    *****************************************************************************************************/
    
    //hydrate the Case Status dropdown list
    public list<SelectOption> getOutreachStatuses() {
        List<SelectOption> options = new list<SelectOption>();
        List<String> vals;
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            vals = PicklistDescriber.describe('Case', 'ASU_Coach_Outreach', 'Status');
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            vals = PicklistDescriber.describe('Case', 'ASU_Advisor_Outreach', 'Status');
        }
        for(String f : vals)
        {
          options.add(new SelectOption(f, f));
        }  

        return options;
    }
    
    //hydrate the Case Student Intention dropdown list
    public list<SelectOption> getStudentIntentions() {
        list<SelectOption> options = new list<SelectOption>();
        List<String> vals;
        options.add (new SelectOption('', '--select--'));
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            vals = PicklistDescriber.describe('Case', 'ASU_Coach_Outreach', 'Student_Intention__c');
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            vals = PicklistDescriber.describe('Case', 'ASU_Advisor_Outreach', 'Student_Intention__c');
        }
        for(String f : vals)
        {
            options.add(new SelectOption(f, f));
        }
        return options;
    }
    
    public PageReference selectReasonsNotReturningClick(){
        selectedReasonsNotReturning.clear();
        for(String s : leftReasonsNotReturningSelected){
            leftReasonsNotReturningValues.remove(s);
            rightReasonsNotReturningValues.add(s);
            if(s=='Other'){
                showReasonsNotReturningOther = true;
            }
        }
        return null;
    }
    
    public PageReference unSelectReasonsNotReturningClick(){
        leftReasonsNotReturningSelected.clear();
        for(String s : selectedReasonsNotReturning){
            rightReasonsNotReturningValues.remove(s);
            leftReasonsNotReturningValues.add(s);
            if(s=='Other'){
                showReasonsNotReturningOther = false;
            }
        }
        return null;
    }
    
    public PageReference selectClick(){
        selectedRecommendedActions.clear();
        for(String s : leftSelected){
            leftValues.remove(s);
            rightValues.add(s);
            if(s=='Other'){
                showRecommendedActionsOther = true;
            }
        }
        return null;
    }
    
    public PageReference unSelectClick(){
        leftSelected.clear();
        for(String s : selectedRecommendedActions){
            rightValues.remove(s);
            if(s=='Other'){
                showRecommendedActionsOther = false;
            }
            leftValues.add(s);
        }
        return null;
    }
    
    public List<SelectOption> getunSelectedReasonsNotReturningValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftReasonsNotReturningValues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedReasonsNotReturningValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightReasonsNotReturningValues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftValues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightValues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    //hydrate the Case Reason Not Returning dropdown list
    public list<SelectOption> getReasonsNotReturning() {
        list<SelectOption> options = new list<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case.Reasons_Not_Returning__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add (new SelectOption('', '--select--'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }
    
    //hydrate Case Term Returning dropdown list
    public list<SelectOption> getTermReturning() {
        list<SelectOption> options = new list<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case.What_term_is_the_student_planning_to_ret__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add (new SelectOption('', '--select--'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }
    
    //hydrate Will Return Risk dropdown list
    public list<SelectOption> getwillReturnRisks() {
        list<SelectOption> options = new list<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case.Student_Presented_Risk_for__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add (new SelectOption('', '--select--'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }
    
    //hydrate Planned Message recs for the MC
    public list<SelectOption> getPlannedMessages() {
        list<SelectOption> options = new list<SelectOption>();
        List<Engagement_Planned_Message__c> epms = new List<Engagement_Planned_Message__c>();
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            epms = [SELECT Id, Name__c 
                    FROM Engagement_Planned_Message__c 
                    WHERE Message_Type__c = 'Ad Hoc Email'
                    AND Engagement__r.RecordTypeId =: engagementCoachRecordTypeId];
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            epms = [SELECT Id, Name__c 
                    FROM Engagement_Planned_Message__c 
                    WHERE Message_Type__c = 'Ad Hoc Email'
                    AND Engagement__r.RecordTypeId =: engagementAdvisorRecordTypeId];
        }
        options.add (new SelectOption('', '--select--'));
        for(Engagement_Planned_Message__c epm : epms)
        {
            options.add(new SelectOption(epm.Id, epm.Name__c));
        }
        return options;
    }
    
    //hydrate all cases assigned to either coach or advisor
    public List<Case> getCasesAssigned(){ 
        List<Case> retVal;
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        { 
            retVal = [SELECT Id,CaseNumber,Status,Subject,Priority,Type
                    FROM Case 
                    WHERE RecordTypeId =: coachCaseRecordTypeId 
                    AND OwnerId=:userId  
                    AND isClosed = False];  
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            retVal = [SELECT Id,CaseNumber,Status,Subject,Priority,Type
                    FROM Case 
                    WHERE RecordTypeId =: advisorCaseRecordTypeId 
                    AND (OwnerId =: advisorQueueId OR OwnerId=:userId) 
                    AND isClosed = False]; 
        }
        return retVal;
    } 

    //hydrate all of the tasks associated to a selected case
    public void getCaseTasks(){

        if(selectedCaseId!=null)
        {
            caseTasks = new List<Task>();

            caseTasks = [SELECT 
                        AccountId,ActivityDate,CreatedById,CreatedDate,Description,
                        Id,IsArchived,IsClosed,IsDeleted,IsHighPriority,IsRecurrence,
                        IsReminderSet,LastModifiedById,LastModifiedDate,OwnerId,
                        Priority,ReminderDateTime,Status,Subject,SystemModstamp,
                        TaskSubtype,WhatId,WhoId 
                        FROM Task 
                        WHERE WhatId =: selectedCaseId
                        ORDER BY CreatedDate DESC];
      
            if(caseTasks.size()>0 && caseTasks.size()<3)
            {
                caseTasksIndicator = 'success';
            }
            else if(caseTasks.size()>2 && caseTasks.size()<10)
            {
                caseTasksIndicator = 'warning';
            }
            else
            {
                caseTasksIndicator = 'danger';
            }
        }
    }
        
    //hydrate a list of case comments
    public void getCaseComments(){
        rowsCaseComments = new List<trCaseComments>();
        List<Case> theCase = [Select (Select Id, ParentId, IsPublished, CommentBody, CreatedById, Createdby.Name, CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComments ORDER BY CreatedDate DESC) From Case WHERE Id =: selectedCaseId ];
        for(Case c : theCase)
        {
            for(CaseComment comm : c.CaseComments)
            {
                rowsCaseComments.add(new trCaseComments(String.valueOf(comm.CreatedDate.format()),String.valueOf(comm.Createdby.Name),String.valueOf(comm.CommentBody)));
            }
        }
    }
    
    //hydrate all of the emial replies associated to a selected case
    public void getCaseEmails(){

        if(selectedCaseId!=null)
        {
            caseEmails = new List<EmailMessage>();

            caseEmails = [SELECT BccAddress,CcAddress,CreatedById,CreatedDate,FromAddress,FromName,
                        HasAttachment,Headers,Id,Incoming,IsDeleted,IsExternallyVisible,LastModifiedById,
                        LastModifiedDate,MessageDate,ParentId,ReplyToEmailMessageId,Status,Subject,
                        TextBody,ToAddress FROM EmailMessage 
                        WHERE ParentId =: selectedCaseId
                        AND Incoming = true
                        ORDER BY CreatedDate DESC];
        }
    }
    
    //hydrate all other proactive cases regardless of owner
    public void getOtherProactiveCases(){
        rowsOtherStudentCases = new List<trStudentCases>();
        if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
        {
            for(Case ca:[SELECT Id, 
                            CaseNumber, 
                            Status,
                            Followup_Date__c,
                            Student_Intention__c,
                            Recommended_Actions__c,
                            Recommended_Actions_Other__c,
                            What_term_is_the_student_planning_to_ret__c,
                            Reasons_Not_Returning__c,
                            Reasons_Not_Returning_Other__c,
                            Origin, 
                            Type,
                            Subject,
                            Description,
                            Age_Days_Excluding_Weekends__c,
                            CreatedDate, 
                            LastModifiedDate,
                            ASR_Comments__c,
                            ASR_Date__c,
                            ASR_Reasons__c,
                            ASR_Actions__c,
                            Student_Presented_Risk_for__c,
                            Student_Presented_Risk_for_Other__c,
                            Hidden_Selected__c,
                            RecordTypeId,
                            Priority,
                            contact.Id, 
                            contact.ASURite_ID__c,
                            contact.Name,
                            contact.FirstName, 
                            contact.LastName,
                            contact.EmplId__c,
                            contact.Contact_Preference__c,
                            contact.Email,
                            contact.Personal_Email__c,
                            contact.ASU_Email__c,
                            contact.HomePhone,
                            contact.MobilePhone,
                            contact.OtherPhone,
                            contact.SF_Mobile__c,
                            contact.SMS_Phone__c,
                            contact.Work_Phone__c,
                            contact.Phone,
                            contact.Hidden_Selected__c
                            FROM Case 
                            WHERE RecordTypeId =: coachCaseRecordTypeId 
                            //AND OwnerId=:userId  
                            AND isClosed = False 
                            AND contact.Id =: selectedContactId])
                {           
                    rowsOtherStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                }
        }
        else if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
        {
            for(Case ca:[SELECT Id, 
                            CaseNumber, 
                            Status,
                            Followup_Date__c,
                            Student_Intention__c,
                            Recommended_Actions__c,
                            Recommended_Actions_Other__c,
                            What_term_is_the_student_planning_to_ret__c,
                            Reasons_Not_Returning__c,
                            Reasons_Not_Returning_Other__c,
                            Origin, 
                            Type,
                            Subject,
                            Description,
                            Age_Days_Excluding_Weekends__c,
                            CreatedDate, 
                            LastModifiedDate,
                            ASR_Comments__c,
                            ASR_Date__c,
                            ASR_Reasons__c,
                            ASR_Actions__c,
                            Student_Presented_Risk_for__c,
                            Student_Presented_Risk_for_Other__c,
                            Hidden_Selected__c,
                            RecordTypeId,
                            Priority,
                            contact.Id, 
                            contact.ASURite_ID__c,
                            contact.Name,
                            contact.FirstName, 
                            contact.LastName,
                            contact.EmplId__c,
                            contact.Contact_Preference__c,
                            contact.Email,
                            contact.Personal_Email__c,
                            contact.ASU_Email__c,
                            contact.HomePhone,
                            contact.MobilePhone,
                            contact.OtherPhone,
                            contact.SF_Mobile__c,
                            contact.SMS_Phone__c,
                            contact.Work_Phone__c,
                            contact.Phone,
                            contact.Hidden_Selected__c
                            FROM Case 
                            WHERE RecordTypeId =: advisorCaseRecordTypeId 
                            AND isClosed = False 
                            AND contact.Id =: selectedContactId])
                {           
                    rowsOtherStudentCases.add(new trStudentCases(ca,ca.Contact,false,ca.Id));
                }
        }
    }
    
    //hydrate all other reactive cases
    public void getOtherReactiveCases(){
        otherReactiveCases = [SELECT Id,CaseNumber,Status,Subject,Description,Priority,Type,Followup_Date__c
                    FROM Case 
                    WHERE (RecordTypeId !=: coachCaseRecordTypeId AND RecordTypeId !=: advisorCaseRecordTypeId)
                    AND isClosed = False 
                    AND contact.Id =: selectedContactId LIMIT 10];
    }
    
    //hydrate the View As Coach User Id dropdown list
    public list<SelectOption> getViewAsUsers() {
        list<SelectOption> options = new list<SelectOption>();
        if(isCoachLead || isCoachManager || isCoachAdmin)
        {
            List<Success_Resource__c> coaches = [SELECT Id, Name, Resource__r.Name 
                                                FROM Success_Resource__c 
                                                WHERE RecordTypeId =: coachResourceRecordTypeId 
                                                AND Success_POD__c in: myPODIds
                                                AND isActive__c = true 
                                                ORDER BY Name ASC];
            options.add (new SelectOption('', '--select--'));
            for(Success_Resource__c coach : coaches)
            {
                options.add(new SelectOption(coach.Id, coach.Resource__r.Name));
            }
        }
        return options;
    }
    
    //hydrate the View As Queue Id dropdown list
    public list<SelectOption> getViewAsQueues() {
        list<SelectOption> options = new list<SelectOption>();
        options.add (new SelectOption('', '--select--'));
        /*
        List<Success_POD_Program__c> programs = new List<Success_POD_Program__c>();
        programs = [SELECT Success_POD__c, Program__c FROM Success_POD_Program__c WHERE Program__c IN: advisorProgramColleges];
        if(programs.size()>0)
        {
            for(Success_POD_Program__c program : programs)
            {
                options.add(new SelectOption(program.Success_POD__r.OwnerId, program.Success_POD__r.Name));
            }
        }
        */
        if(advisorProgramColleges.size()>0)
        {
            
            List<Success_POD__c> pods = [SELECT Id, Name, Ownerid, Committee__c 
                                            FROM Success_POD__c 
                                            WHERE RecordtypeId =: advisorPODRecordTypeId
                                            AND Program__c IN: advisorProgramColleges
                                            ORDER BY Name ASC]; 
                                        
            if(pods.size()>0)
            {
                for(Success_POD__c pod : pods)
                {
                    options.add(new SelectOption(pod.OwnerId, pod.Name + '-' + pod.Committee__c));
                }
            }
        }
      
        return options;
    }
    
    //hydrate the View As Queue Id dropdown list
    public list<SelectOption> getViewAsCommittees() {
        list<SelectOption> options = new list<SelectOption>();
        options.add (new SelectOption('', '--select--'));
        
        List<Success_POD__c> pods = [SELECT Id, Name, Ownerid 
                                        FROM Success_POD__c 
                                        WHERE Committee__c IN: advisorCommittees
                                        ORDER BY Name ASC];
                                        
        if(pods.size()>0)
        {
            for(Success_POD__c pod : pods)
            {
                options.add(new SelectOption(pod.OwnerId, pod.Name));
            }
        }
      
        return options;
    }
    
    /****************************************************************************************************
    END GETS FUNCTIONS
    *****************************************************************************************************/
    
    /****************************************************************************************************
    BEGIN UPDATE FUNCTIONS
    *****************************************************************************************************/
 
    //update an existing case
    public void updateCase(){
        resetAllFlags();

        try{
            if(selectedFollowupDate<Date.today())
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'That Followup Date has already passed!');
                ApexPages.addMessage(myMsg);
            }
            else if((selectedStudentIntention=='Not returning temporarily') && (selectedCaseSubject=='Not Enrolled' && advisorCaseRecordTypeId==selectedCaseRecordTypeId && selectedTermReturning==null) || (selectedStudentIntention=='Not returning temporarily' || selectedStudentIntention=='Will enroll') && coachCaseRecordTypeId==selectedCaseRecordTypeId && selectedTermReturning==null)
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Returning Term to continue.');
                ApexPages.addMessage(myMsg);
            }
            else if(selectedStudentIntention=='Will enroll' && selectedWillReturnRisk==null)
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Student Presented Risk to continue');
                ApexPages.addMessage(myMsg);
            }
            else if(selectedStudentIntention=='Will enroll' && selectedWillReturnRisk=='Other' && selectedWillReturnRiskOther=='')
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter an Other value for Student Presented Risk to continue.');
                ApexPages.addMessage(myMsg);
            }
            else if((selectedStudentIntention!='Will enroll' && selectedStudentIntention!=null && selectedStudentIntention!='Active') && selectedReasonsNotReturning==null)
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Reason Not Returning to continue');
                ApexPages.addMessage(myMsg);
            }
            else if(showReasonsNotReturningOther && selectedReasonsNotReturningOther=='')
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter an Other reason they are Not Returning value to continue');
                ApexPages.addMessage(myMsg);
            }
            else if(showRecommendedActionsOther && (selectedRecommendedActionsOther==null || selectedRecommendedActionsOther==''))
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter an Other value for Recommended Action.');
                ApexPages.addMessage(myMsg);
            }
            else if(showReasonsNotReturningOther && selectedReasonsNotReturningOther=='')
            {
                isError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter an Other value for Not Returning');
                ApexPages.addMessage(myMsg);
            }
            else
            {
                caseDetails = new Case();
                caseDetails = [SELECT Id,Status,ContactId,Subject,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    Reasons_Not_Returning__c,
                                    What_term_is_the_student_planning_to_ret__c
                                    FROM Case
                                    WHERE Id =: selectedCaseId];
                caseDetails.Status = selectedOutreachStatus;
                selectedCaseSubject = caseDetails.Subject;
                selectedDueDate = null;
                if(selectedFollowupDate!=null)
                {
                    caseDetails.Followup_Date__c = selectedFollowupDate;
                    selectedDueDate = selectedFollowupDate;
                }
                if(selectedStudentIntention!='')
                {
                    caseDetails.Student_Intention__c = selectedStudentIntention;
                    if(selectedStudentIntention=='Will enroll')
                    {
                        if(selectedTermReturning!='')
                        {
                            caseDetails.What_term_is_the_student_planning_to_ret__c = selectedTermReturning;
                        }
                        if(selectedWillReturnRisk!='')
                        {
                            caseDetails.Student_Presented_Risk_for__c = selectedWillReturnRisk;
                            if(selectedWillReturnRisk=='Other')
                            {
                                caseDetails.Student_Presented_Risk_for_Other__c = selectedWillReturnRiskOther;
                            }
                        }
                        selectedReasonsNotReturning = null;
                        selectedReasonsNotReturningOther = '';
                    }
                }
                if(rightReasonsNotReturningValues.size()>0)
                {
                    string reasons = '';
                    for(String s : rightReasonsNotReturningValues) {
                       reasons += (reasons==''?'':';')+s;
                    }
                    caseDetails.Reasons_Not_Returning__c = reasons;
                }
                if(rightValues.size()>0)
                {
                    string actions = '';
                    for(String s : rightValues) {
                       actions += (actions==''?'':';')+s;
                    }
                    caseDetails.Recommended_Actions__c = actions;
                }
                if(selectedRecommendedActionsOther!='')
                {
                    caseDetails.Recommended_Actions_Other__c = selectedRecommendedActionsOther;
                }
               
                update caseDetails;

                insertCaseComments();

                insertTask(caseDetails.ContactId,
                            caseDetails.Id,
                            '',
                            selectedOutreachStatus,
                            selectedCaseComments,
                            'Completed',
                            'Normal');
                selectedCaseComments = '';
                selectedFollowupDateYear = '';
                selectedFollowupDateMonth = '';
                selectedFollowupDateDay = '';
                selectedFollowupDate = null;
                selectedCaseId = caseDetails.Id;
                selectStudentCase();
                isUpdateCaseSuccess = true;
             }
            //reload counts
            populateCasesCount();
            populateEmailsCount();
            populateSMSCount();
            populateChatsCount();
            populateMyStudentsCount();
            populateMyOpenCasesCount();
            populateMyWatchlistCount();
            populateMyChatsCount();
            //reload grids
            populateMyCaseSummaries();
            populateCasesGrid();
            getOtherProactiveCases();
            getOtherReactiveCases();
            getCaseTasks();
            getCaseComments();
            contactSelected = true;

        }
        catch(Exception ex){
            Apexpages.addMessages(ex);
            System.Debug('ERROR='+ex);
            isError = true;
        }
    }

    /*
    //update an existing cases at one time
    public void updateCases(){
        resetAllFlags();
        for(Case updateCase : otherProactiveCases)
        {
            //insert the comments first
            CaseComment newComm = new CaseComment();
            if(selectedCaseComments!='')
            {
                 newComm.CommentBody = selectedCaseComments;
                 newComm.IsPublished = false;
                 newComm.ParentId = updateCase.Id;
                 insert newComm;
            }
            //save and close the case
            updateCase.Status = selectedOutreachStatus;
            update updateCase;
        }
        isSuccess = true;
    }
    */
    
    /****************************************************************************************************
    END UPDATE FUNCTIONS
    *****************************************************************************************************/
    
    /****************************************************************************************************
    BEGIN INSERT FUNCTIONS
    *****************************************************************************************************/

    public boolean insertEngagement(string type){
        boolean retVal = false;

        try{
            List<Engagement__c> e;
            List<Engagement_Message__c> ems;
            if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
            {
                e = [SELECT Id FROM Engagement__c 
                    WHERE Engagement_Type__c =: type
                    AND RecordTypeId =: engagementAdvisorRecordTypeId];
            }
            else if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
            {
                e = [SELECT Id FROM Engagement__c 
                    WHERE Engagement_Type__c =: type
                    AND RecordTypeId =: engagementCoachRecordTypeId];
            }

            List<Engagement_Planned_Message__c> epm = [SELECT Id FROM Engagement_Planned_Message__c WHERE Engagement__c =: e[0].Id];
            string ec = insertEngagementContact(resourceId, e[0].Id,selectedContactId,selectedCaseId,'Pending');
            string em = insertEngagementMessage(ec,epm[0].Id,selectedContactId,selectedCaseId,'Pending');
            retVal = true;
        }
        catch(Exception ex){
            Apexpages.addMessages(ex);
            isError = true;
        }
        return retVal;
    }
    
    public string insertEngagementContact(string resourceId,
                                          string eId,
                                          string contactId, 
                                          string caseId,
                                          string status)
    {
        string retVal = '';
        try{
            Engagement_Contact__c ec = new Engagement_Contact__c();
            ec.Success_Resource_Record__c = resourceId;
            ec.Contact__c = contactId;
            if(caseId!='')
            {
                ec.Case__c = caseid;
            }
            ec.Engagement__c = eId;
            ec.Expiration_Date__c = todaysDate;
            ec.Status__c = status;
            ec.Additional_Message_Text__c = newEmailMessage;
            insert ec;
            retVal = ec.Id;
        }catch(Exception ex){
               Apexpages.addMessages(ex);
               isError = true;
        }
        return retVal;
    }
    
    public string insertEngagementMessage(string ecId, 
                                        string epmId,
                                        string contactId,
                                        string caseId,
                                        string status)
    {
        Engagement_Message__c em = new Engagement_Message__c();
        em.Contact__c = contactId;
        if(caseId!='')
        {
            em.Case__c = caseId;
        }
        em.Engagement_Contact__c = ecId;
        em.Engagement_Planned_Message__c = epmId;
        em.Status__c = status;
        insert em;
        return em.Id;
    }

    //create a new AdHoc Case 
    public PageReference insertCase(){
        resetAllFlags();
        if(newSubject==null||newSubject=='')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a Subject to continue.');
            ApexPages.addMessage(myMsg);
        }
        else if(newDescr==null||newdescr=='')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a Description to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            Case c = new Case();
            if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
            {
                c.RecordTypeId = coachCaseRecordTypeId;
                c.Functional_Group__c = 'ASU Advisor Outreach';
                c.Category__c = 'Ad Hoc Case';
                c.Type = 'Advisor Initiated';
                c.Subject = newSubject;
                c.ContactId = selectedContactId;
                c.OwnerId = userId;
                c.Description = newDescr;
                c.Status = 'Outreach Required';
                c.Origin__c = 'Resource';
                c.Visible_by_Contact__c = FALSE;
            }
            else if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
            {
                c.RecordTypeId = coachCaseRecordTypeId;
                c.Functional_Group__c = 'ASU Coach Outreach';
                c.Category__c = 'Ad Hoc Case';
                c.Type = 'Coach Initiated';
                c.Subject = newSubject;
                c.ContactId = selectedContactId;
                c.OwnerId = userId;
                c.Description = newDescr;
                c.Status = 'New';
                c.Origin__c = 'Resource';
                c.Visible_by_Contact__c = FALSE;
            }
            insert c;
            isNewCaseSuccess = true;
        }
        newSubject ='';
        newDescr = '';
        return null;
    }
    
    //create a new My Watchlist Case 
    public PageReference insertWatchlistCase(){
        resetAllFlags();
        if(selectedFollowupDate==null)
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Followup Date to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            integer cases = 0;
            cases = [SELECT count() FROM Case WHERE OwnerId =: userId AND ContactId =: selectedContactId AND Subject = 'My Watchlist' AND isClosed = false];
            if(cases==0)
            {
                Case c = new Case();
                if(isAdvisorUser || isAdvisorLead || isAdvisorManager || isAdvisorAdmin)
                {
                    c.RecordTypeId = advisorCaseRecordTypeId;
                    c.Functional_Group__c = 'ASU Advisor Outreach';
                    c.Category__c = 'Watchlist';
                    c.Visible_by_Contact__c = false;
                    c.Followup_Date__c = selectedFollowupDate;
                    c.Subject = 'My Watchlist';
                    c.ContactId = selectedContactId;
                    c.OwnerId = userId;
                    c.Description = 'Added via Success Portal';
                    c.Status = 'Outreach Required';
                    c.Origin__c = 'Resource';
                }
                else if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
                {
                    c.RecordTypeId = coachCaseRecordTypeId;
                    c.Functional_Group__c = 'ASU Coach Outreach';
                    c.Category__c = 'Watchlist';
                    c.Visible_by_Contact__c = false;
                    c.Followup_Date__c = selectedFollowupDate;
                    c.Subject = 'My Watchlist';
                    c.ContactId = selectedContactId;
                    c.OwnerId = userId;
                    c.Description = 'Added via Success Portal';
                    c.Status = 'New';
                    c.Origin__c = 'Resource';
                }
                insert c;
            }
            selectedFollowupDate = null;
            isNewCaseSuccess = true;
        }
        return null;

    }
    
    public string insertCaseComments()
    {             
        CaseComment newComm = new CaseComment();
        if(selectedCaseComments!='')
        {
             newComm.CommentBody = selectedCaseComments;
             newComm.IsPublished = false;
             newComm.ParentId = selectedCaseId;
             insert newComm;
        }
        return newComm.Id;
    }

    //create a new task 
    public string insertTask(string whoid, 
                            string whatid, 
                            string thetype, 
                            string subject, 
                            string descr, 
                            string status, 
                            string priority){
        string retVal = '';
        Task t = new Task();
        t.RecordTypeId = taskRecordTypeId; 
        t.WhoId = whoId;
        if(whatId!=''){t.WhatId = whatId;}
        t.OwnerId = userId;
        t.Subject = subject;
        t.Description = descr + ':' + newEmailMessage;
        t.Status = status;
        t.ActivityDate = system.today();
        t.Type = thetype;
        t.Priority = priority;
        insert t;
        retVal = t.Id;
        getCaseTasks(); 

        return retVal;
    }
    
    /****************************************************************************************************
    END INSERT FUNCTIONS
    *****************************************************************************************************/

    /****************************************************************************************************
    BEGIN MASS FUNCTIONS
    *****************************************************************************************************/
    
    //mass email all students in the set
    public PageReference massEmailStudents()
    {
        resetAllFlags();
        selectedPlannedMessage = '--select--';
        selectedStudentIds.clear();
        selectedStudents.clear();
        selectedStudentCaseIds.clear();
        selectedStudentCases.clear();
        selectedGridType = System.currentPageReference().getParameters().get('gridType');
        if(selectedGridType=='studentsGrid')
        {
            for (trStudents sel : rowsStudents) {
                if (sel.isStudentSelected == true) {
                    selectedStudentIds.add(sel.contactId);
                    //System.Debug('SELECTEDID='+sel.contactId);
                    //selectedStudents.add(sel.theContact);
                }
            }
            selectedStudents = [SELECT
                                    Id,
                                    ASURite_ID__c, 
                                    Name,
                                    FirstName, 
                                    LastName,
                                    EmplId__c,
                                    Contact_Preference__c,
                                    Email,
                                    Personal_Email__c,
                                    ASU_Email__c,
                                    HomePhone,
                                    MobilePhone,
                                    OtherPhone,
                                    SF_Mobile__c,
                                    SMS_Phone__c,
                                    Work_Phone__c,
                                    Phone,
                                    Hidden_Selected__c
                                    FROM Contact WHERE Id IN: selectedStudentIds];
        }
        else
        {
            for (trStudentCases sel : rowsStudentCases) {
                    if (sel.isStudentCaseSelected == true) {
                        selectedStudentCaseIds.add(sel.caseId);
                        //selectedStudentCases.add(sel.theCase);
                }
            }
            selectedStudentCases = [SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE Id IN: selectedStudentCaseIds];
        }

        return null;
    }
    
    //preview the engagement message
    public PageReference previewMassEmail()
    {
        resetAllFlags();
        Engagement_Planned_Message__c epm;
        if(selectedPlannedMessage==null || selectedPlannedMessage=='--select--')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Planned Message Template to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
                epm = [SELECT Id, Name__c, Message_Text__c 
                        FROM Engagement_Planned_Message__c 
                        WHERE Message_Type__c = 'Ad Hoc Email' 
                        AND Id =: selectedPlannedMessage];
                previewMessage = epm.Message_Text__c + '<br></br><p><b>' + newEmailMessage + '</b></p>';
                isPreview = true;
        } 
        return null;
    } 
    
    //create the engagement message
    public PageReference sendMassEmail()
    {
        resetAllFlags();
        if(selectedPlannedMessage==null || selectedPlannedMessage=='--select--')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Planned Message Template to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            try{
                //List<Engagement_Message__c> ems;
                Engagement__c e;
                if(isCoachUser || isCoachLead || isCoachManager || isCoachAdmin)
                {
                    e = [SELECT Id FROM Engagement__c WHERE Engagement_Type__c = 'Ad Hoc Email' AND RecordTypeId =: engagementCoachRecordTypeId LIMIT 1];
                }
                else
                {
                    e = [SELECT Id FROM Engagement__c WHERE Engagement_Type__c = 'Ad Hoc Email' AND RecordTypeId =: engagementAdvisorRecordTypeId LIMIT 1];                
                }
                Engagement_Planned_Message__c epm = [SELECT Id FROM Engagement_Planned_Message__c WHERE Engagement__c =: e.Id LIMIT 1];
                if(selectedStudents.size()>0)
                {
                    for(Contact student: selectedStudents)
                    {
                        string ec = insertEngagementContact(resourceId,e.Id,student.Id,'','Pending');
                        string em = insertEngagementMessage(ec,epm.Id,student.Id,'','Pending');
                        insertTask(student.Id,'','Email','Mass Email Message','Sent through MC Platform','Pending','Normal'); 
                    }
                }
                else if(selectedStudentCases.size()>0)
                {
                    for(Case ca: selectedStudentCases)
                    {
                        string ec = insertEngagementContact(resourceId,e.Id,ca.Contact.Id,ca.Id,'Pending');
                        string em = insertEngagementMessage(ec,epm.Id,ca.Contact.Id,ca.Id,'Pending');                        
                        insertTask(ca.Contact.Id,ca.Id,'Email','Mass Email Message','Sent through MC Platform','Pending','Normal');
                    }
                }
                progressStatus = 100;
                populateEmailsCount();
                populateChatsCount();
                populateCasesCount();
                isEmailSuccess = true;
            }
            catch(Exception ex){
                Apexpages.addMessages(ex);
                isError = true;
            }
        } 
        return null;
    } 
    
    //mass sms all students in the set
    public PageReference massSMSStudents()
    {
        resetAllFlags();
        selectedSMSText = '';
        selectedStudentIds.clear();
        selectedStudents.clear();
        selectedStudentCaseIds.clear();
        selectedStudentCases.clear();
        string gridType = System.currentPageReference().getParameters().get('gridType');
        if(selectedGridType=='studentsGrid')
        {
            for (trStudents sel : rowsStudents) {
                if (sel.isStudentSelected == true) {
                    selectedStudentIds.add(sel.contactId);
                    //System.Debug('SELECTEDID='+sel.contactId);
                    //selectedStudents.add(sel.theContact);
                }
            }
            selectedStudents = [SELECT
                                    Id,
                                    ASURite_ID__c, 
                                    Name,
                                    FirstName, 
                                    LastName,
                                    EmplId__c,
                                    Contact_Preference__c,
                                    Email,
                                    Personal_Email__c,
                                    ASU_Email__c,
                                    HomePhone,
                                    MobilePhone,
                                    OtherPhone,
                                    SF_Mobile__c,
                                    SMS_Phone__c,
                                    Work_Phone__c,
                                    Phone,
                                    Hidden_Selected__c
                                    FROM Contact WHERE Id IN: selectedStudentIds];
        }
        else
        {
            for (trStudentCases sel : rowsStudentCases) {
                    if (sel.isStudentCaseSelected == true) {
                        selectedStudentCaseIds.add(sel.caseId);
                        //selectedStudentCases.add(sel.theCase);
                }
            }
            selectedStudentCases = [SELECT Id, 
                                    CaseNumber, 
                                    Status,
                                    Followup_Date__c,
                                    Student_Intention__c,
                                    Recommended_Actions__c,
                                    Recommended_Actions_Other__c,
                                    What_term_is_the_student_planning_to_ret__c,
                                    Reasons_Not_Returning__c,
                                    Reasons_Not_Returning_Other__c,
                                    Origin, 
                                    Type,
                                    Subject,
                                    Description,
                                    Age_Days_Excluding_Weekends__c,
                                    CreatedDate, 
                                    LastModifiedDate,
                                    ASR_Comments__c,
                                    ASR_Date__c,
                                    ASR_Reasons__c,
                                    ASR_Actions__c,
                                    Student_Presented_Risk_for__c,
                                    Student_Presented_Risk_for_Other__c,
                                    Hidden_Selected__c,
                                    RecordTypeId,
                                    contact.Id, 
                                    contact.ASURite_ID__c,
                                    contact.Name,
                                    contact.FirstName, 
                                    contact.LastName,
                                    contact.EmplId__c,
                                    contact.Contact_Preference__c,
                                    contact.Email,
                                    contact.Personal_Email__c,
                                    contact.ASU_Email__c,
                                    contact.HomePhone,
                                    contact.MobilePhone,
                                    contact.OtherPhone,
                                    contact.SF_Mobile__c,
                                    contact.SMS_Phone__c,
                                    contact.Work_Phone__c,
                                    contact.Phone,
                                    contact.Hidden_Selected__c
                                    FROM Case 
                                    WHERE Id IN: selectedStudentCaseIds];
        }
        return null;
    }
    
    //send the SMS Text Message
    public PageReference sendMassSMS()
    {
        resetAllFlags();
        if(selectedSMSText=='')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a message to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            try{
                List<Engagement_Message__c> ems;
                Engagement__c e = [SELECT Id FROM Engagement__c WHERE Engagement_Type__c = 'Ad Hoc SMS Message'];
                Engagement_Planned_Message__c epm = [SELECT Id FROM Engagement_Planned_Message__c WHERE Engagement__c =: e.Id];     
                if(selectedStudents.size()>0)
                {
                    for(Contact student: selectedStudents)
                    {
                        string ec = insertEngagementContact(resourceId,e.Id,student.Id,'','Pending');
                        insertTask(student.Id,'','SMS','Mass SMS Message','Sent through InContact Platform','Pending','Normal'); 
                    }
                }
                else if(selectedStudentCases.size()>0)
                {
                    for(Case ca: selectedStudentCases)
                    {
                        string ec = insertEngagementContact(resourceId,e.Id,ca.Contact.Id,ca.Id,'Pending');
                        insertTask(ca.Contact.Id,ca.Id,'SMS','Mass SMS Message','Sent through InContact Platform','Pending','Normal');
                    }
                }    
                progressStatus = 100; 
                populateSMSCount(); 
                isSMSSuccess = true;
            }
            catch(Exception ex){
                Apexpages.addMessages(ex);
                isError = true;
            }
        }
        return null;
    } 
    
    //mass transfer all cases in the set
    public PageReference massTransferCases()
    {
        resetAllFlags();
        selectedTransferToGroup = '--select--';
        selectedStudentCaseIds.clear();
        selectedStudentCases.clear();
        for (trStudentCases sel : rowsStudentCases) {
                if (sel.TheCase.Hidden_Selected__c == true) {
                    selectedStudentCaseIds.add(sel.TheCase.Id);
                    selectedStudentCases.add(sel.theCase);
            }
        }
        return null;
    }
    
    //create the engagement message
    public PageReference submitMassTransferCases()
    {
        resetAllFlags();
        List<string> ids = new List<string>();

        try{
            for(Case ca: selectedStudentCases)
            {
                ids.add(ca.Id);
            }
            progressStatus = 100;
            isTransferSuccess = true;
        }
        catch(Exception ex){
            Apexpages.addMessages(ex);
            isError = true;
        } 
        PageReference requestPage = Page.CaseTransferMass;
        requestPage.getParameters().put('ids',string.valueOf(ids));
        requestPage.setRedirect(true);
        return requestPage;
    } 

    /****************************************************************************************************
    END MASS FUNCTIONS
    *****************************************************************************************************/
    
    /****************************************************************************************************
    BEGIN SINGLE AD HOC FUNCTIONS
    *****************************************************************************************************/
    
    //preview the engagement message
    public PageReference previewEmail()
    {
        resetAllFlags();
        Engagement_Planned_Message__c epm;
        if(selectedPlannedMessage==null || selectedPlannedMessage=='--select--')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Planned Message Template to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            epm = [SELECT Id, Name__c, Message_Text__c 
                    FROM Engagement_Planned_Message__c 
                    WHERE Message_Type__c = 'Ad Hoc Email' 
                    AND Id =: selectedPlannedMessage];
            
            previewMessage = epm.Message_Text__c + '<br></br><p><b>' + newEmailMessage + '</b></p>';
            isPreview = true;
        } 
        return null;
    } 
    
    //create the engagement message
    public PageReference sendEmail()
    {
        resetAllFlags();
        if(selectedPlannedMessage==null || selectedPlannedMessage=='--select--')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Planned Message Template to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            insertEngagement('Ad Hoc Email');
            insertTask(selectedContactId,selectedCaseId,'Email','Ad Hoc Email','Sent through the Marketing Cloud','Completed','Normal');
            populateEmailsCount();
            populateChatsCount();
            populateCasesCount();
            isEmailSuccess = true;
        } 
        return null;
    } 
    
    //send the SMS Text Message
    public PageReference sendSMS()
    {
        resetAllFlags();
        if(selectedSMSText=='')
        {
            isError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a message to continue.');
            ApexPages.addMessage(myMsg);
        }
        else
        {
            insertEngagement('Ad Hoc SMS Message');
            insertTask(selectedContactId,selectedCaseId,'SMS','Ad Hoc SMS Message','Sent through InContact Platform','Pending','Normal');
            populateSMSCount();
            isSMSSuccess = true;
        }
        return null;
    } 
    
    //start the call session
    public PageReference startPhoneCall()
    {
        resetAllFlags();
        insertTask(selectedContactId,selectedCaseId,'Phone Call','Phone Call','Initiated through InContact Platform','Pending','Normal');
        if(!Test.isRunningTest()){
            //HTTPRestService_InContact.GETRestCallout('services/v7.0/agents/');
        }
        isSuccess = true;
        return null;
    } 
    
    //start the Rocket Chat session
    public PageReference startChat()
    {
        resetAllFlags();
        insertTask(selectedContactId,selectedCaseId,'Chat Session','Chat Session','Rocket Chat Session','Pending','Normal');
        populateChatsCount();
        isSuccess = true;
        return null;
    } 
    
    /****************************************************************************************************
    END SINGLE AD HOC FUNCTIONS
    *****************************************************************************************************/
    
}