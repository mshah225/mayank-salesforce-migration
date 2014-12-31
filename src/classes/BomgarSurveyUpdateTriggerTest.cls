@istest
private class BomgarSurveyUpdateTriggerTest{

    static testMethod void surveyUpdateTriggerTestResolved() {
        test.starttest();
        try{
            bomgar__BomgarSession__c session = new bomgar__BomgarSession__c();
            session.Name = 'Test';
            insert session;
            
            bomgar__Survey__c surveyHolder = new bomgar__Survey__c();
            surveyHolder.bomgar__BomgarSession__c = session.Id;
            insert surveyHolder;
            
            bomgar__SurveyData__c survey = new bomgar__SurveyData__c();
            survey.bomgar__Survey__c = surveyHolder.Id;
            survey.Name = 'close_state';
            survey.bomgar__Value__c = 'Resolved';
            insert survey;
        }
        catch(Exception e){
        
        }
        test.stoptest();
    }
    
    static testMethod void surveyUpdateTriggerTestEscalate() {
        test.starttest();
        try{
            bomgar__BomgarSession__c session = new bomgar__BomgarSession__c();
            session.Name = 'Test';
            insert session;
            
            bomgar__Survey__c surveyHolder = new bomgar__Survey__c();
            surveyHolder.bomgar__BomgarSession__c = session.Id;
            insert surveyHolder;
            
            bomgar__SurveyData__c survey = new bomgar__SurveyData__c();
            survey.bomgar__Survey__c = surveyHolder.Id;
            survey.Name = 'close_state';
            survey.bomgar__Value__c = 'Escalate';
            insert survey;
        }
        catch(Exception e){
        
        }
        test.stoptest();
    }
    
}