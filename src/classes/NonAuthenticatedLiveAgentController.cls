public without sharing class NonAuthenticatedLiveAgentController {
    public String buttonPressed { get; set; }
    public String caseDescription { get; set; }
    public String caseRecordType { get; set; }
    public String caseOwnerId { get; set; }
    public String caseFunctionalGroup { get; set; }
    public String caseCategory { get; set; }
    public String caseSubCategory { get; set; }
    public String caseSubject { get; set; }
    public String presurveyQuestion { get; set; }
    public String contactId { get; set; }

    public NonAuthenticatedLiveAgentController() {
        getButtonIdFromURL();
        setCaseDetails();
        setPresurveyQuestion();
        setNonAuthenticatedContact();
    }

    private void getButtonIdFromURL() {
        String buttonParam = ApexPages.currentPage().getURL();
        Integer indexOf = buttonParam.indexOf('button_id');
        buttonParam = buttonParam.substring(indexOf + 12, indexOf + 27);
        buttonPressed = [SELECT DeveloperName FROM LiveChatButton WHERE Id = :buttonParam LIMIT 1].DeveloperName;
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
        String emailForCarFilter = buttonPressed.toLowerCase();

        Case_Assignment_Rule__c carFromButton = [
            SELECT
                Case_Record_Type_Id__c,
                CC_Functional_Group__c,
                CC_Category__c,
                Queue_ID__c,
                CC_Sub_Category__c,
                OwnerId
            FROM Case_Assignment_Rule__c
            WHERE Email_Address__c = :emailForCarFilter
            LIMIT 1
        ];
        return carFromButton;
    }

    private void setPresurveyQuestion() {
        presurveyQuestion = Label.PreSurveyQuestion;
    }

    private void setCaseOwnerAndSubject(Case_Assignment_Rule__c car) {
        if (car.Queue_ID__c.subString(0, 3) == Group.SObjectType.getDescribe().getKeyPrefix()) {
            List<Group> potentialQueue = [SELECT Id, Name FROM Group WHERE Id = :car.Queue_ID__c];
            caseOwnerId = potentialQueue[0].Id;
            caseSubject = potentialQueue[0].Name + ' Live Chat';
        } else if (car.Queue_ID__c.subString(0, 3) == User.SObjectType.getDescribe().getKeyPrefix()) {
            List<User> potentialUser = [SELECT Id, Name FROM User WHERE Id = :car.Queue_ID__c];
            caseOwnerId = potentialUser[0].Id;
            caseSubject = potentialUser[0].Name + ' Live Chat';
        }
    }

    private void setNonAuthenticatedContact() {
        List<Live_Agent_Setting__mdt> callerIdSetting = [
            SELECT Value__c
            FROM Live_Agent_Setting__mdt
            WHERE DeveloperName = 'Non_Authenticated_CallerId'
            LIMIT 1
        ];
        contactId = callerIdSetting[0].Value__c;
    }
}
