public class LiveAgentPreSurveyController {
    public String buttonPressed {set; get;} 
    public String caseRecordType {set; get;}
    public String caseOwnerId {set; get;}
    public String caseFunctionalGroup {set; get;}
    public String caseCategory {set; get;}
    public String caseSubCategory {set; get;}
    public String presurveyQuestion {set; get;}

    public LiveAgentPreSurveyController() {
        getButtonIdFromURL();
        setCaseDetails();
        setPresurveyQuestion();
    }
    
    private void getButtonIdFromURL() {
        String buttonParam = ApexPages.currentPage().getURL();
        Integer indexOf = buttonParam.indexOf('button_id');
        buttonParam = buttonParam.substring(indexOf+12, indexOf+27);
        buttonPressed = [SELECT DeveloperName FROM LiveChatButton WHERE Id =: buttonParam LIMIT 1].DeveloperName;
    }
    
    private void setCaseDetails() {
        Case_Assignment_Rule__c carForButton = getCarFromButton();
        caseRecordType = carForButton.Case_Record_Type_Id__c;
        caseFunctionalGroup = carForButton.CC_Functional_Group__c;
        caseCategory = carForButton.CC_Category__c;
        caseSubCategory = carForButton.CC_Sub_Category__c;
        caseOwnerId = carForButton.OwnerId;
    }
    
    private Case_Assignment_Rule__c getCarFromButton() {
        String emailForCarFilter = buttonPressed.toLowerCase() + '@asu.edu';
        
        Case_Assignment_Rule__c carFromButton = [SELECT Case_Record_Type_Id__c, CC_Functional_Group__c, CC_Category__c, CC_Sub_Category__c, OwnerId 
                                                 FROM Case_Assignment_Rule__c
                                                 WHERE Email_Address__c =: emailForCarFilter LIMIT 1];
        return carFromButton;
    }
    
    private void setPresurveyQuestion() {
        presurveyQuestion = Label.PreSurveyQuestion;
    }
}