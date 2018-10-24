public without sharing class NonAuthenticatedLiveAgentController {
    public String buttonPressed {set; get;} 
    public String caseDescription {set; get;}
    public String caseRecordType {set; get;}
    public String caseOwnerId {set; get;}
    public String caseFunctionalGroup {set; get;}
    public String caseCategory {set; get;}
    public String caseSubCategory {set; get;}
    public String caseSubject {set; get;}
    public String presurveyQuestion {set; get;}
    public String contactId {set; get;}
    private static final NON_AFFILIATE_CAR_EMAIL = 'non_affiliate_live_chat@asu.edu';

    public NonAuthenticatedLiveAgentController() {
        buttonPressed = LiveAgentUtils.getButtonIdFromURL();
        setCaseDetails();
        setPresurveyQuestion();
    }
    
    private void setCaseDetails() {
        Case_Assignment_Rule__c carForButton = getCarFromButton();
        caseRecordType = carForButton.Case_Record_Type_Id__c;
        caseFunctionalGroup = carForButton.CC_Functional_Group__c;
        caseCategory = carForButton.CC_Category__c;
        caseSubCategory = carForButton.CC_Sub_Category__c;
        setCaseOwnerAndSubject(carForButton);
    }
    
    private Case_Assignment_Rule__c getCarFromButton() {
        String emailForCarFilter = 	NON_AFFILIATE_CAR_EMAIL;
        
        Case_Assignment_Rule__c carFromButton = [SELECT Case_Record_Type_Id__c, CC_Functional_Group__c, CC_Category__c, Queue_ID__c, CC_Sub_Category__c, OwnerId 
                                                 FROM Case_Assignment_Rule__c
                                                 WHERE Email_Address__c =: emailForCarFilter LIMIT 1];
        return carFromButton;
    }
    
    private void setPresurveyQuestion() {
        presurveyQuestion = Label.PreSurveyQuestion;
    }
    
    private void setCaseOwnerAndSubject(Case_Assignment_Rule__c car) {
        if (car.Queue_ID__c.subString(0,3) == IDHelper.findPrefixFromObjectName('Group')) {
        	List<Group> potentialQueue = [SELECT Id, Name FROM Group WHERE Id =: car.Queue_ID__c];
            caseOwnerId = potentialQueue[0].Id;
            caseSubject = potentialQueue[0].Name + ' ' + buttonPressed.replace('_', ' ');
        } else if (car.Queue_ID__c.subString(0,3) == IDHelper.findPrefixFromObjectName('User')) {
            List<User> potentialUser = [SELECT Id, Name FROM User WHERE Id =: car.Queue_ID__c];
            caseOwnerId = potentialUser[0].Id;
            caseSubject = potentialUser[0].Name + ' ' + buttonPressed.replace('_', ' ');
        }
    }
    
    private void setNonAffiliatedContact() {
        Contact nonAffiliatedContact = [SELECT Id FROM Contact WHERE Name = 'Non-Affiliate Chat Caller'];
        contactId = nonAffiliatedContact.Id;
    }
    
}