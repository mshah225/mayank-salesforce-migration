public class LiveAgentPreSurveyController {
    public String buttonPressed {set; get;} 
    public String caseRecordType {set; get;}
    public String caseOwnerId {set; get;}
    public String caseFunctionalGroup {set; get;}
    public String caseCategory {set; get;}
    public String caseSubCategory {set; get;}
    public String caseSubject {set; get;}
    public String presurveyQuestion {set; get;}
    public String agentOfflineMessage {set; get;}
    public String uniqueKey {
        set; 
        get {
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);
            return hexDigest;
        }
    }
    public Live_Agent_Button__c buttonConfig {set; get;}
    
    public LiveAgentPreSurveyController() {
        getButtonIdFromURL();
        setButtonInformation();
        setCaseDetails();
        setPresurveyQuestion();
        setAgentOfflineMessage();
    }
    
    private void getButtonIdFromURL() {
        String buttonParam = ApexPages.currentPage().getURL();
        Integer indexOf = buttonParam.indexOf('button_id');
        buttonParam = buttonParam.substring(indexOf+12, indexOf+27);
        buttonPressed = [SELECT DeveloperName FROM LiveChatButton WHERE Id =: buttonParam LIMIT 1].DeveloperName;
    }
    
    private void setButtonInformation() {
        buttonConfig = Live_Agent_Button__c.getInstance(buttonPressed);
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
        String emailForCarFilter = buttonPressed.toLowerCase() + '@asu.edu';
        Case_Assignment_Rule__c carFromButton = [
            SELECT Case_Record_Type_Id__c, CC_Functional_Group__c, CC_Category__c, Queue_ID__c, CC_Sub_Category__c, OwnerId 
            FROM Case_Assignment_Rule__c
            WHERE Email_Address__c =: emailForCarFilter LIMIT 1
        ];
        return carFromButton;
    }
    
    private void setPresurveyQuestion() {
        presurveyQuestion = Label.PreSurveyQuestion;
    }
    
    private void setCaseOwnerAndSubject(Case_Assignment_Rule__c car) {
        if (car.Queue_ID__c.subString(0,3) == Group.SObjectType.getDescribe().getKeyPrefix()) {
        	List<Group> potentialQueue = [SELECT Id, Name FROM Group WHERE Id =: car.Queue_ID__c];
            caseOwnerId = potentialQueue[0].Id;
            caseSubject = potentialQueue[0].Name + ' ' + buttonPressed.replace('_', ' ');
        } else if (car.Queue_ID__c.subString(0,3) == User.SObjectType.getDescribe().getKeyPrefix()) {
            List<User> potentialUser = [SELECT Id, Name FROM User WHERE Id =: car.Queue_ID__c];
            caseOwnerId = potentialUser[0].Id;
            caseSubject = potentialUser[0].Name + ' ' + buttonPressed.replace('_', ' ');
        }
    }
    
    private void setAgentOfflineMessage() {
        List<LiveAgent_Custom_Message__c> offlineMessages = [
            SELECT Custom_Message__c 
            FROM LiveAgent_Custom_Message__c 
            WHERE LiveAgent_Button__c = 'Agent Offline'
            ORDER BY CreatedDate DESC
        ];
        agentOfflineMessage = offlineMessages.isEmpty() ? 'No agents are available.' : offlineMessages[0].Custom_Message__c;
    }
}